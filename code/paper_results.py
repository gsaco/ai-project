"""Check the manuscript's numerical experiments against rational arithmetic."""
from fractions import Fraction
from math import isclose
from pathlib import Path

from firm_model import simulate


def check_case(d=Fraction(1, 5), kappa=Fraction(2, 5), beta=Fraction(9, 10), h=None):
    # With alpha=1/2, substituting the FOC gives q(s)=A²s/(2w).
    s0, A, w = Fraction(1, 2), 2, Fraction(5, 4)
    q0 = A**2 * s0 / (2 * w)
    q_minus = A**2 * (s0 - d) / (2 * w)
    overhead = Fraction(30, 100) + Fraction(9, 100)
    V = (q0 / 2 - overhead) / (1 - beta)
    keep = q_minus / 2 - overhead + beta * V
    close = beta * max(V - kappa, 0)
    values = {'operate': keep}
    if h is not None:
        values['suspend'] = -h + beta * V
    values['close'] = close
    choices = [action for action, value in values.items() if value == max(values.values())]
    action = choices[0]
    restart = action == 'close' and V > kappa
    y0 = q_minus if action == 'operate' else 0
    y1 = q0 if action != 'close' or restart else 0
    strict = h is None and keep < 0 and kappa > V

    params = dict(d=float(d), kappa=float(kappa), beta=float(beta))
    if h is not None:
        params['h'] = float(h)
    result = simulate(**params)
    path = result['paths']['negative']
    assert path['decision'] == action and path['restart'] == restart, params
    assert path['tie'] == (len(choices) > 1) and result['restartTie'] == (V == kappa), params
    assert result['conjecture'] == strict, params
    for actual, expected in [(path['continueValue'], keep), (path['closeValue'], close),
                             (result['V'], V), (path['output'][0], y0), (path['output'][1], y1)]:
        assert isclose(actual, float(expected), rel_tol=1e-13, abs_tol=2e-14), (params, actual, expected)
    return dict(parameters=params, action=action, tie=len(choices) > 1, restart=restart,
                restart_tie=V == kappa, strict=strict, V=float(V), keep=float(keep),
                close=float(close), y0=float(y0), y1=float(y1))


def path_label(case):
    if case['tie']:
        return 'Operate or close'
    if case['action'] == 'operate':
        return 'Keep operating'
    return 'Close, then reopen' if case['restart'] else 'Close permanently'


def draw_regions(shock_cases, output):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    result = simulate()
    p, normal, V = result['params'], result['normal'], result['V']
    k_max, d_max = 0.44, 0.25
    # Proposition 2 is piecewise linear with its only kink at kappa=V.
    costs = [0, V, k_max]
    cutoffs = [p['s0'] * (normal['pi'] + p['beta'] * min(k, V)) /
               ((1 - p['alpha']) * normal['q']) for k in costs]
    with plt.rc_context():
        plt.rcdefaults()
        plt.rcParams['pdf.fonttype'] = 42
        fig, ax = plt.subplots(figsize=(5.9, 2.55), layout='constrained')
        ax.fill_between(costs, 0, cutoffs, color='#dcece4')
        ax.fill_between(costs[:2], cutoffs[:2], d_max, color='#e1e8fa')
        ax.fill_between(costs[1:], cutoffs[1:], d_max, color='#f5dfc7')
        ax.plot(costs, cutoffs, color='#293849', linewidth=1.35)
        ax.vlines(V, cutoffs[1], d_max, color='#293849', linewidth=1.15, linestyles='dashed')
        for row in shock_cases:
            ax.plot(row['parameters']['kappa'], row['parameters']['d'], 'o', markersize=5,
                    markeredgecolor='#15232d', markerfacecolor='white', clip_on=False)
        for x, y, label in [(0.05, 0.20, 'Close, then\nreopen'), (0.25, 0.19, 'Close permanently'),
                            (0.25, 0.06, 'Keep operating')]:
            ax.text(x, y, label, ha='center', va='center', color='#182e3a', fontsize=10)
        ax.set(xlim=(0, k_max), ylim=(0, d_max), xlabel=r'Restart cost $\kappa$',
               ylabel=r'Shock size $d$', xticks=[0, .10, .20, .30, .40], yticks=[0, .05, .10, .15, .20, .25])
        ax.spines[['top', 'right']].set_visible(False)
        output.parent.mkdir(exist_ok=True)
        fig.savefig(output, metadata={'CreationDate': None, 'ModDate': None})
        plt.close(fig)


def verify_paper():
    shock_cases = [check_case(d=d, kappa=k) for d in (Fraction(1, 10), Fraction(1, 5)) for k in (0, Fraction(2, 5))]
    discount_cases = [check_case(beta=b) for b in (Fraction(9, 10), Fraction(15, 16), Fraction(19, 20))]
    boundaries = {'d': Fraction(1, 8), 'kappa': Fraction(1, 10), 'h': Fraction(9, 100), 'beta': Fraction(15, 16)}
    step = Fraction(1, 10**11)
    boundary_cases = [check_case(**{name: cutoff + offset})
                      for name, cutoff in boundaries.items() for offset in (-step, 0, step)]

    # Ship the checked cells with the manuscript so LaTeX can build on its own.
    tables = Path(__file__).resolve().parents[1] / 'paper' / 'tables'
    tables.mkdir(exist_ok=True)
    shock_rows = []
    for row in shock_cases:
        p = row['parameters']
        shock_rows.append(
            f"{p['d']:.2f} & {p['kappa']:.2f} & {row['keep']:.2f} & {row['close']:.2f} & "
            f"{row['y0']:.2f} & {row['y1']:.2f} & {path_label(row)}" + r" \\"
        )
    discount_rows = []
    for row in discount_cases:
        beta = row['parameters']['beta']
        discount_rows.append(
            f"{beta:.4f} & {row['V']:.2f} & {row['keep']:.2f} & {row['close']:.2f} & "
            f"{path_label(row)}" + r" \\"
        )
    layout = [
        ('shock-cases', 'rrrrrrl', r'$d$ & $\kappa$ & Continue & Close & $y^-_0$ & $y^-_1$ & Optimal path', shock_rows),
        ('discount-cases', 'rrrrl', r'$\beta$ & Restored value $V$ & Continue & Close & Optimal path', discount_rows),
    ]
    for name, columns, headings, rows in layout:
        lines = [r'\begin{tabular}{@{}' + columns + r'@{}}\toprule', headings + r' \\\midrule',
                 *rows, r'\bottomrule\end{tabular}']
        (tables / f'{name}.tex').write_text('\n'.join(lines) + '\n')
    draw_regions(shock_cases, tables.parent / 'figures' / 'switching-regions.pdf')
    return shock_cases + discount_cases + boundary_cases
