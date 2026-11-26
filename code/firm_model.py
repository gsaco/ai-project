"""Operating choices and output in the deterministic incumbent model."""
from math import isfinite
from sys import float_info
DEFAULTS = dict(A=2., alpha=.5, w=1.25, F=.30, c=.09, beta=.9, kappa=.4, s0=.5, d=.2)

def operating(**overrides):
    p = DEFAULTS | {'s': DEFAULTS['s0']} | overrides
    assert all(isfinite(p[k]) for k in ['A','alpha','w','F','c','s'])
    assert p['A']>0 and p['w']>0 and p['F']>0 and p['c']>=0 and 0<p['alpha']<1 and 0<p['s']<=1
    x = p['s']*(p['alpha']*p['A']/p['w'])**(1/(1-p['alpha']))
    q = p['A']*p['s']**(1-p['alpha'])*x**p['alpha']
    return dict(x=x, q=q, pi=q-p['w']*x-p['F']-p['c'], inputBill=p['w']*x)

def value_order(left, right, scale):
    """Compare payoffs allowing for roundoff in their underlying cash flows."""
    band = 32 * float_info.epsilon * max(scale, abs(left), abs(right))
    if abs(left - right) <= band:
        return 0
    return 1 if left > right else -1


def simulate(*, h=None, **overrides):
    p = DEFAULTS | overrides
    beta, kappa = p['beta'], p['kappa']
    assert 0 < beta < 1 and isfinite(kappa) and kappa >= 0
    assert 0 <= p['d'] < p['s0'] and p['s0'] + p['d'] <= 1
    assert h is None or (isfinite(h) and h >= 0)
    normal = operating(**p, s=p['s0'])
    assert value_order(normal['pi'], 0, normal['q']) > 0, 'Normal profit must be positive at working precision.'
    V = normal['pi'] / (1 - beta)
    W = max(V - kappa, 0.)
    # The equivalent flow comparison avoids dividing a thin profit by 1-beta.
    restart_order = value_order(normal['pi'], (1 - beta) * kappa, normal['q'])
    paths = {}
    for name, sign in [('negative', -1), ('baseline', 0), ('positive', 1)]:
        o = operating(**p, s=p['s0'] + sign * p['d'])
        # Remove the common beta*V before comparing the alternatives.
        scores = {'operate': o['pi']}
        if h is not None:
            scores['suspend'] = -h
        scores['close'] = -beta * min(kappa, V)
        best = max(scores.values())
        scale = max(normal['q'], o['q'])
        choices = [action for action, score in scores.items() if value_order(score, best, scale) == 0]
        action = choices[0]  # Prefer operating, then suspending, at a numerical tie.
        active = action == 'operate'
        restart = action == 'close' and restart_order > 0
        restored_output = normal['q'] if action != 'close' or restart else 0.
        paths[name] = dict(
            output=[o['q'] if active else 0.] + [restored_output] * 4,
            pi=o['pi'], continueValue=o['pi'] + beta * V, closeValue=beta * W,
            active=active, restart=restart, decision=action, tie=len(choices) > 1,
        )
    adverse_negative = value_order(paths['negative']['pi'], -beta * V, normal['q']) < 0
    holds = h is None and p['d'] > 0 and adverse_negative and restart_order < 0
    return dict(params=p, normal=normal, V=V, paths=paths, conjecture=holds, restartTie=restart_order == 0)
