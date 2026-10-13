"""Single entry point for topic-stage symbolic/numerical checks and model figures.
Run: python3 code/verify.py. Raises on failure; this is not a formal proof.
"""
from pathlib import Path
from itertools import product
from math import isclose, log
import json, runpy
import numpy as np
import sympy as sp
from firm_model import DEFAULTS, operating, simulate
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'code/output';OUT.mkdir(exist_ok=True)
checks=[]
def check(name, condition):
    assert condition, name
    checks.append(name)
    print('PASS',name)

# Differentiate the primitive objective; check the closed form against it.
x,A,s,w,F,c=sp.symbols('x A s w F c',positive=True)
alpha=sp.symbols('alpha',positive=True)
obj=A*s**(1-alpha)*x**alpha-w*x-F-c
check('symbolic FOC',sp.simplify(sp.diff(obj,x)-(alpha*A*s**(1-alpha)*x**(alpha-1)-w))==0)
check('symbolic second derivative',sp.simplify(sp.diff(obj,x,2)-alpha*(alpha-1)*A*s**(1-alpha)*x**(alpha-2))==0)
for a,sv in product([.2,.5,.8],[.15,.5,.9]):
    o=operating(alpha=a,s=sv)
    marginal=a*2*sv**(1-a)*o['x']**(a-1)
    assert isclose(marginal,1.25,rel_tol=1e-10)
    grid=np.linspace(0,4*o['x'],20001)
    profits=2*sv**(1-a)*grid**a-1.25*grid-.30-.09
    assert float(profits.max())<=o['pi']+1e-10
check('closed form dominates a numerical input grid',True)
r=simulate()
check('illustrative output and profits',np.allclose([r['normal']['q'],r['normal']['pi'],r['paths']['negative']['pi'],r['paths']['positive']['pi'],r['V']],[.8,.01,-.15,.17,.1]))
check('costly restarting: loss persists',all(case['conjecture'] and case['paths']['negative']['output']==[0]*5 for case in [r,simulate(kappa=.2)]))
f=simulate(kappa=0)
check('free restarting: complete recovery',not f['paths']['negative']['active'] and f['paths']['negative']['restart'] and np.allclose(f['paths']['negative']['output'][1:],[.8]*4))
z=simulate(d=.05)
check('small shock: symmetric levels while active',z['paths']['negative']['active'] and np.isclose(.8-z['paths']['negative']['output'][0],z['paths']['positive']['output'][0]-.8))
check('overhead leaves input unchanged',isclose(operating(c=.19)['x'],operating()['x']))
# Independently enumerate all 4-period activity paths, with an exact stationary tail.
# This catches omissions such as treating closure as zero when restarting is profitable.
comparisons=0
for d,kappa,c0 in product([.01,.05,.15,.2,.3,.45],[0,.04,.1,.2,.4,.8],[0,.05,.09]):
    r=simulate(d=d,kappa=kappa,c=c0);p=r['params'];V=r['V'];W=max(V-kappa,0)
    for name in ['negative','baseline','positive']:
        p0=r['paths'][name]['pi'];pnormal=r['normal']['pi']
        values=[]
        for acts in product([0,1],repeat=4):
            prev=1;val=0
            for t,a in enumerate(acts):
                val+=p['beta']**t*(a*(p0 if t==0 else pnormal)-kappa*a*(1-prev));prev=a
            val+=p['beta']**4*(V if prev else W)
            values.append(val)
        target=max(r['paths'][name]['continueValue'],r['paths'][name]['closeValue'])
        assert isclose(max(values),target,abs_tol=1e-10), (d,kappa,c0,name)
        comparisons+=1
    if r['conjecture']:
        y0=r['normal']['q'];ym=r['paths']['negative']['output'];yp=r['paths']['positive']['output']
        assert all(y0-a>b-y0+1e-10 for a,b in zip(ym,yp))
        B,N=2.,3.
        assert all(log(B+N*y0)-log(B+N*a)>log(B+N*b)-log(B+N*y0) for a,b in zip(ym,yp))
check(f'optimal switching versus {comparisons} enumerated scenario problems and conditional log comparison',True)
r=simulate();suspend=-.02+.9*r['V']
check('cheap suspension defeats permanent closure in the illustration',suspend>max(r['paths']['negative']['continueValue'],r['paths']['negative']['closeValue']))
# Export figures and numerical examples from this project's model, not the template toy.
runpy.run_path(str(ROOT/'slides/figures/build_topic_figures.py'),run_name='__main__')
(OUT/'verification.json').write_text(json.dumps(dict(status='passed',scope='topic-stage checks; not a proof',checks=checks,enumerated_scenarios=comparisons),indent=2)+'\n')
print(f'{len(checks)} checks passed; own-model figures regenerated.')
