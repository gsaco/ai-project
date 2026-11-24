"""Figures for the impact comparison and the suspension option."""
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

from firm_model import operating, simulate


CLOSURE = '#934126'
ACCESS = '#f3cf9c'
OPEN = '#14655e'
INK = '#243640'
MUTED = '#53636a'
GRID = '#dce3e3'


def impact_and_recovery():
    costly = simulate(d=.20, kappa=.40)
    free = simulate(d=.20, kappa=0)
    paths, params = costly['paths'], costly['params']
    normal = paths['baseline']['output'][0]
    restricted = operating(**params, s=params['s0'] - params['d'])['q']
    access_loss = normal - restricted
    closure_loss = restricted - paths['negative']['output'][0]
    gain = paths['positive']['output'][0] - normal

    fig, axes = plt.subplots(1, 2, figsize=(7.55, 2.36), sharex=True, sharey=True)
    fig.subplots_adjust(left=.028, right=.99, bottom=.27, top=.82, wspace=.17)
    for ax, title in zip(axes, ['A   During the shock', 'B   After access returns']):
        ax.set_title(title, loc='left', size=12, weight='bold', pad=8)
        ax.set(xlim=(-.012, .84), ylim=(-.34, 1.62), yticks=[], xticks=[0, .2, .4, .6, .8])
        ax.tick_params(axis='x', length=0, pad=4, labelsize=8.5)
        ax.xaxis.set_major_formatter(FuncFormatter(lambda x, _: f'{x:g}'))
        ax.spines[['left', 'bottom']].set_visible(False)
        ax.grid(axis='x', color=GRID, linewidth=.65)
        ax.set_axisbelow(True)

    impact, recovery = axes
    for y, label in [(1, 'Loss after deterioration'), (0, 'Gain after improvement')]:
        impact.text(0, y+.26, label, size=9)
    total_loss = access_loss + closure_loss
    impact.text(total_loss, 1.26, f'{total_loss:.2f} total', ha='right',
                color=CLOSURE, weight='bold', size=9)
    impact.barh(1, access_loss, height=.43, color=ACCESS)
    impact.barh(1, closure_loss, left=access_loss, height=.43, color=CLOSURE)
    impact.barh(0, gain, height=.43, color=OPEN)
    for x, y, label, color in [
        (access_loss/2, 1, f'{access_loss:.2f}  access', INK),
        (access_loss+closure_loss/2, 1, f'{closure_loss:.2f}  closure', 'white'),
        (gain/2, 0, f'{gain:.2f}', 'white'),
    ]:
        impact.text(x, y, label, ha='center', va='center', size=9.2, color=color, weight='bold')

    for y, scenario, label in [(1, free, 'Free reopening'), (0, costly, 'Costly reopening')]:
        after = scenario['paths']
        loss = after['baseline']['output'][1] - after['negative']['output'][1]
        recovery.text(0, y+.26, rf"{label}  ($\kappa={scenario['params']['kappa']:g}$)", size=9)
        if loss > 0:
            recovery.barh(y, loss, height=.43, color=CLOSURE)
            recovery.text(loss/2, y, f'{loss:.2f}  still lost', va='center', ha='center',
                          color='white', weight='bold', size=9.2)
        else:
            recovery.plot(0, y, 'o', color='white', mec=OPEN, mew=1.6, ms=6.5, clip_on=False)
            recovery.annotate('0.00  full recovery', (0, y), xytext=(7, 0), textcoords='offset points',
                              va='center', color=OPEN, weight='bold', size=9.2)

    fig.text(.5, .045, 'Magnitude of output loss or gain relative to normal output (model units)',
             ha='center', size=9.3)
    return fig


def suspension_threshold():
    example_cost = .02
    result = simulate(d=.20, kappa=.40, h=example_cost)
    adverse = result['paths']['negative']
    close, operate = adverse['closeValue'], adverse['continueValue']
    preserved = result['params']['beta'] * result['V']
    cutoff = preserved - close
    max_cost = .15
    example_value = preserved - example_cost

    fig, ax = plt.subplots(figsize=(7.5, 3.28))
    fig.subplots_adjust(left=.127, right=.975, top=.77, bottom=.18)
    ax.set(xlim=(0, max_cost), ylim=(-.075, .105), xticks=[0, .03, .06, cutoff, .12, max_cost],
           yticks=[-.06, -.03, 0, .03, .06, .09], xlabel=r'Cost of preserving the organization, $h$',
           ylabel='Payoff at the shock date')
    ax.yaxis.set_major_formatter(FuncFormatter(lambda x, _: '0' if x == 0 else f'{x:.2f}'.replace('-', '−')))
    ax.tick_params(length=3, color='#94a2a5', labelsize=9)
    ax.spines[['left', 'bottom']].set_color('#a9b3b7')
    ax.grid(axis='y', color=GRID, linewidth=.65)
    ax.set_axisbelow(True)

    # The two bands report tomorrow's output under today's optimal decision.
    band_transform = ax.get_xaxis_transform()
    reopened = adverse['output'][1]
    closed = simulate(d=.20, kappa=.40, h=max_cost)['paths']['negative']['output'][1]
    for left, right, label, output, shade, color in [
        (0, cutoff, 'Suspend and resume', reopened, '#e6f1ed', OPEN),
        (cutoff, max_cost, 'Close permanently', closed, '#f7ebe2', CLOSURE),
    ]:
        ax.fill_between([left, right], 1.045, 1.37, transform=band_transform,
                        clip_on=False, color=shade, linewidth=0)
        center = (left+right)/2
        ax.text(center, 1.262, label, transform=band_transform, ha='center', va='center',
                color=color, weight='bold', size=10.3)
        ax.text(center, 1.115, f'Next-period output  {output:.2f}', transform=band_transform,
                ha='center', va='center', color=INK, size=9)

    ax.axvline(cutoff, color=MUTED, lw=1, ls=(0, (2, 3)))
    ax.axhline(operate, color=MUTED, lw=1.3, ls=(0, (4, 3)))
    ax.plot([0, cutoff], [close, close], color=CLOSURE, lw=1.3, ls=(0, (4, 3)))
    ax.plot([cutoff, max_cost], [close, preserved-max_cost], color=OPEN, lw=1.3, ls=(0, (4, 3)))
    ax.plot([0, cutoff], [preserved, close], color=OPEN, lw=3.2, solid_capstyle='butt')
    ax.plot([cutoff, max_cost], [close, close], color=CLOSURE, lw=3.2, solid_capstyle='butt')

    ax.plot(example_cost, example_value, 'o', color=OPEN, mec='white', ms=7, zorder=4)
    ax.annotate(rf'At $h={example_cost:.2f}$, suspension pays {example_value:.2f}', (example_cost, example_value),
                xytext=(8, 8), textcoords='offset points', color=OPEN, size=9.2)
    ax.plot(cutoff, close, 'o', mfc='white', mec=INK, ms=7, mew=1.5, zorder=5)
    ax.annotate('Both pay zero', (cutoff, close), xytext=(7, 21), textcoords='offset points',
                color=INK, weight='bold', size=9.2,
                arrowprops=dict(arrowstyle='-', lw=.85, color=INK, shrinkA=1, shrinkB=4))
    ax.text(.014, operate+.006, f'Operate  {operate:.2f}'.replace('-', '−'), color=MUTED, size=9)
    ax.text(.005, close+.005, 'Close', color=CLOSURE, size=9)
    ax.text(.125, preserved-.125+.004, 'Suspend', color=OPEN, va='bottom', size=9)
    for tick, label in zip(ax.get_xticks(), ax.get_xticklabels()):
        if tick == cutoff:
            label.set_fontweight('bold')
    return fig


def draw_additional_figures(directory):
    with plt.rc_context():
        plt.rcdefaults()
        plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10, 'pdf.fonttype': 42,
                             'axes.labelcolor': INK, 'text.color': INK, 'xtick.color': MUTED,
                             'ytick.color': MUTED, 'axes.spines.top': False, 'axes.spines.right': False})
        for name, draw in [('impact-and-recovery', impact_and_recovery), ('suspension-threshold', suspension_threshold)]:
            fig = draw()
            fig.savefig(directory / f'{name}.pdf', bbox_inches='tight', pad_inches=.09,
                        metadata={'CreationDate': None, 'ModDate': None})
            plt.close(fig)
