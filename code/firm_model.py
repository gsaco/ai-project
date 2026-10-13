"""Deterministic topic model; no claim of a general proof or calibration."""
from math import isfinite
DEFAULTS = dict(A=2., alpha=.5, w=1.25, F=.30, c=.09, beta=.9, kappa=.4, s0=.5, d=.2)

def operating(**overrides):
    p = DEFAULTS | {'s': DEFAULTS['s0']} | overrides
    assert all(isfinite(p[k]) for k in ['A','alpha','w','F','c','s'])
    assert p['A']>0 and p['w']>0 and p['F']>0 and p['c']>=0 and 0<p['alpha']<1 and 0<p['s']<=1
    x = p['s']*(p['alpha']*p['A']/p['w'])**(1/(1-p['alpha']))
    q = p['A']*p['s']**(1-p['alpha'])*x**p['alpha']
    return dict(x=x, q=q, pi=q-p['w']*x-p['F']-p['c'], inputBill=p['w']*x)

def simulate(**overrides):
    p=DEFAULTS | overrides
    assert 0<p['beta']<1 and p['kappa']>=0 and 0<=p['d']<p['s0'] and p['s0']+p['d']<=1
    normal=operating(**p,s=p['s0']);assert normal['pi']>0
    V=normal['pi']/(1-p['beta']);W=max(V-p['kappa'],0.)
    paths={}
    for name,sign in [('negative',-1),('baseline',0),('positive',1)]:
        o=operating(**p,s=p['s0']+sign*p['d'])
        keep=o['pi']+p['beta']*V;close=p['beta']*W
        active=keep>=close-1e-10
        reopen=V-p['kappa']>1e-10
        paths[name]=dict(output=[o['q'] if active else 0.]+[normal['q'] if active or reopen else 0.]*4,
                         pi=o['pi'],continueValue=keep,closeValue=close,active=active,restart=(not active and reopen))
    holds=paths['negative']['continueValue']<0 and p['kappa']>V
    return dict(params=p,normal=normal,V=V,paths=paths,conjecture=holds)
