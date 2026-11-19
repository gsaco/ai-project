"""Figures for the impact comparison and the suspension option."""
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from matplotlib.ticker import FuncFormatter
import numpy as np

from firm_model import simulate


ADVERSE = '#b36046'
FAVORABLE = '#277b73'
INK = '#22343e'
GREY = '#65717b'


def impact_and_recovery():
    fig, axes = plt.subplots(1, 2, figsize=(9.1, 3.30), sharey=True)
    fig.subplots_adjust(left=.18, right=.985, bottom=.23, top=.72, wspace=.13)
    periods = [r'During the shock  ($t=0$)', r'After restoration  ($t\geq1$)']
    for t, ax in enumerate(axes):
        ax.set(xlim=(-.90, .47), ylim=(-.55, 1.55), xticks=[-.8, -.4, 0, .4], yticks=[1, 0])
        ax.set_title(periods[t], loc='left', size=12.3, fontweight='bold', pad=10)
        ax.xaxis.set_major_formatter(FuncFormatter(lambda x, _: '0' if x == 0 else f'{x:.1f}'.replace('-', '−')))
        ax.tick_params(axis='both', length=0, pad=6)
        ax.spines['left'].set_visible(False)
        ax.spines['bottom'].set_color('#d6dfe0')
        ax.grid(axis='x', color='#e5e9e9', linewidth=.7)
        ax.set_axisbelow(True)
        ax.axvline(0, color='#74848a', lw=1.1, zorder=1)
        for y, cost in [(1, 0), (0, .40)]:
            paths = simulate(d=.20, kappa=cost)['paths']
            base = paths['baseline']['output'][t]
            loss = paths['negative']['output'][t] - base
            gain = paths['positive']['output'][t] - base
            for change, color in [(loss, ADVERSE), (gain, FAVORABLE)]:
                if change != 0:
                    ax.barh(y, change, .26, color=color, zorder=2)
                    label = f'{change:+.2f}'.replace('-', '−')
                    ax.text(change / 2, y, label, ha='center', va='center',
                            color='white', size=10.2, fontweight='bold')
            if gain == 0:
                ax.plot(0, y, 'o', markersize=5, markerfacecolor='white', markeredgecolor=FAVORABLE, zorder=3)
                ax.text(.036, y, '0.00 for both' if loss == 0 else '0.00', va='center', fontsize=9.3)
    axes[0].set_yticklabels(['Free reopening\n' + r'$\kappa=0$', 'Costly reopening\n' + r'$\kappa=0.40$'])
    handles = [Patch(color=ADVERSE, label='Deterioration'), Patch(color=FAVORABLE, label='Improvement')]
    fig.legend(handles=handles, loc='upper center', bbox_to_anchor=(.57, .99), frameon=False,
               ncol=2, handlelength=1.3, columnspacing=2.4)
    fig.text(.58, .045, 'Output difference relative to the no-shock path (model units)', ha='center', size=10.2)
    return fig


def suspension_threshold():
    result = simulate(d=.20, kappa=.40)
    adverse = result['paths']['negative']
    threshold = result['params']['beta'] * result['V']
    costs = np.linspace(0, .15, 301)
    fig, ax = plt.subplots(figsize=(8.15, 3.65))
    fig.subplots_adjust(left=.13, right=.98, top=.90, bottom=.20)
    ax.axvspan(0, threshold, facecolor='#e7f0ee')
    ax.axvspan(threshold, costs[-1], facecolor='#f6e9db')
    ax.plot(costs, threshold - costs, color=FAVORABLE, lw=2.7)
    ax.axhline(adverse['closeValue'], color=INK, lw=1.7)
    ax.axhline(adverse['continueValue'], color=GREY, lw=1.6, ls=(0, (4, 3)))
    ax.axvline(threshold, color='#879397', lw=1, ls=(0, (2, 3)))
    ax.plot(threshold, 0, 'o', color='white', markeredgecolor=INK, markersize=7, markeredgewidth=1.4, zorder=4)
    for x, y, label, color in [(.045, .100, 'Suspend and resume', INK), (.120, .100, 'Close permanently', INK),
                               (.029, .078, 'Suspend', FAVORABLE), (.136, .007, 'Close', INK), (.033, -.054, 'Operate', GREY)]:
        ax.text(x, y, label, color=color, ha='center', fontweight='bold')
    ax.set(xlim=(0, .15), ylim=(-.074, .110), xlabel=r'Cost of preserving the organization, $h$',
           ylabel='Value at the shock date', xticks=[0, .03, .06, .09, .12, .15], yticks=[-.06, -.03, 0, .03, .06, .09])
    ax.yaxis.set_major_formatter(FuncFormatter(lambda x, _: '0' if x == 0 else f'{x:.2f}'.replace('-', '−')))
    ax.spines[['bottom', 'left']].set_color('#98a7ab')
    ax.tick_params(length=3, color='#99a5aa')
    for tick, label in zip(ax.get_xticks(), ax.get_xticklabels()):
        if np.isclose(tick, threshold):
            label.set_fontweight('bold')
    return fig


def draw_additional_figures(directory):
    with plt.rc_context():
        plt.rcdefaults()
        plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10.5, 'pdf.fonttype': 42,
                             'axes.labelcolor': INK, 'text.color': INK, 'xtick.color': '#44535b',
                             'ytick.color': '#44535b', 'axes.spines.top': False, 'axes.spines.right': False})
        for name, draw in [('impact-and-recovery', impact_and_recovery), ('suspension-threshold', suspension_threshold)]:
            fig = draw()
            fig.savefig(directory / f'{name}.pdf', bbox_inches='tight', pad_inches=.09,
                        metadata={'CreationDate': None, 'ModDate': None})
            plt.close(fig)
