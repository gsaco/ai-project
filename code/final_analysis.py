"""Final-presentation calculations; extends the unchanged topic model."""
from itertools import product
from pathlib import Path
import json
import numpy as np
from firm_model import operating, simulate, DEFAULTS

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'slides/final-assets'

def decision(d=.2,kappa=.4,c=.09,h=None):
    r=simulate(d=d,kappa=kappa,c=c)
    p=r['params']; neg=r['paths']['negative']; V=r['V']
    values={'operate':neg['continueValue'],'close':neg['closeValue']}
    if h is not None:
        assert h>=0
        values['suspend']=-h+p['beta']*V
    best=max(values.values()); choices=[k for k,v in values.items() if abs(v-best)<1e-10]
    # Keep operating at ties, otherwise preserve the organization at a tie.
    selected=next(k for k in ['operate','suspend','close'] if k in choices)
    state='operate' if selected=='operate' else 'suspend' if selected=='suspend' else 'reopen' if V>kappa+1e-10 else 'closed'
    y0=neg['output'][0] if selected=='operate' else 0.
    y1=0. if state=='closed' else r['normal']['q']
    return dict(state=state,tie=len(choices)>1 or (selected=='close' and abs(kappa-V)<1e-10),values=values,y0=y0,y1=y1,V=V,piMinus=neg['pi'],normal=r['normal'])

def verify_final():
    reports=[]
    def check(name,ok):
        assert ok,name
        reports.append(name);print('PASS',name)
    q0=operating()['q'];V=operating()['pi']/.1
    rows=[];checked=0
    for c,d,k in product([.05,.07,.09,.095],[.01,.05,.1,.125,.2,.3,.45],[0,.04,.1,.2,.4,.8]):
        r=simulate(c=c,d=d,kappa=k);D=(1-.5)*r['normal']['q']*d/.5
        delta=r['paths']['negative']['continueValue']-r['paths']['negative']['closeValue']
        assert np.isclose(delta,r['normal']['pi']-D+.9*min(k,r['V']))
        for t,(ym,yp) in enumerate(zip(r['paths']['negative']['output'],r['paths']['positive']['output'])):
            assert r['normal']['q']-ym >= yp-r['normal']['q']-1e-10
        # Independent enumeration, not a restatement of the closure rule.
        vals=[]
        for acts in product([0,1],repeat=5):
            val=0.;prev=1
            for t,a in enumerate(acts):
                val+=.9**t*(a*(r['paths']['negative']['pi'] if t==0 else r['normal']['pi'])-k*a*(1-prev));prev=a
            val+=.9**5*(r['V'] if prev else max(r['V']-k,0))
            vals.append(val)
        assert np.isclose(max(vals),max(r['paths']['negative']['continueValue'],r['paths']['negative']['closeValue']))
        rows.append({'parameters':{'c':c,'d':d,'kappa':k},'continue_value':r['paths']['negative']['continueValue'],'close_value':r['paths']['negative']['closeValue'],'adverse_output':r['paths']['negative']['output'],'favorable_output':r['paths']['positive']['output']})
        checked+=1
    check('closure threshold, weak asymmetry and independent five-date enumeration: 168 parameter points',checked==168)
    for k in [0,.04,.1,.4]:
        candidates=[.9**n*(V-k) for n in range(200)]+[0.]
        assert np.isclose(max(candidates),max(V-k,0))
    check('delayed reopening: 200 dates plus never-restart, four restart costs',True)
    samples=[decision(d=.05),decision(kappa=0),decision(),decision(h=.02),decision(h=.12)]
    check('three topic cases reproduced', [r['state'] for r in samples[:3]]==['operate','reopen','closed'])
    check('cheap suspension restores production; expensive suspension is rejected',samples[3]['state']=='suspend' and samples[3]['y1']==q0 and samples[4]['state']=='closed')
    for h in np.linspace(0,.15,151):
        r=decision(h=float(h));assert np.isclose(max(r['values'].values()),max(-.06,0.,-h+.09))
    check('suspension value comparison: 151 preservation costs',True)
    check('boundaries explicitly indifferent',decision(d=.125)['tie'])
    # beta=.9,V=.1; at d=.1 closure with kappa=0 but continued operation at kappa=.4.
    check('a higher restart cost can discourage current closure',decision(d=.1,kappa=0)['state']=='reopen' and decision(d=.1,kappa=.4)['state']=='operate')
    check('normal profit is positive and all proposition inequalities coexist',q0>0 and V>0 and decision()['values']['operate']<0 and .4>V)
    data={'parameters':DEFAULTS,'checks':reports,'grid_points':checked,'suspension_costs':151,'cases':samples,'grid':rows,'limitations':['Finite numerical checks do not prove all parameters.','No estimated EFW shock, entry equilibrium, heterogeneous population or calibrated GDP effect.']}
    (ROOT/'code/output/final-verification.json').write_text(json.dumps(data,indent=2)+'\n')
    return data

def figures(data):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.colors import ListedColormap,BoundaryNorm
    OUT.mkdir(exist_ok=True)
    blue,teal,orange,grey='#223F91','#008A92','#D45D00','#566171'
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':12,'pdf.fonttype':42,'axes.spines.top':False,'axes.spines.right':False})
    def save(fig,name):
        fig.savefig(OUT/(name+'.pdf'),bbox_inches='tight',metadata={'CreationDate':None,'ModDate':None})
        fig.savefig(OUT/(name+'.png'),dpi=180,bbox_inches='tight');plt.close(fig)
    fig,axs=plt.subplots(1,3,figsize=(12,3.6),sharey=True)
    for ax,title,d,k in zip(axs,['Small shock','Free restart','Costly restart'],[.05,.2,.2],[.4,0,.4]):
        r=simulate(d=d,kappa=k)
        for key,col,style in [('positive',teal,'-'),('negative',orange,'-'),('baseline',grey,'--')]:
            y=r['paths'][key]['output'];ax.step([-1,0,1,3],[100,y[0]/.8*100,y[1]/.8*100,y[1]/.8*100],where='post',c=col,ls=style,lw=2.6,label=key)
        ax.axvline(1,c='#ccd4e2',ls=':');ax.set(title=f'{title}\nd={d:.2f}, κ={k:.2f}',xticks=[-1,0,1,3],xticklabels=['Before','0','1','3'],ylim=(-5,150));ax.grid(alpha=.15)
    axs[0].set_ylabel('Output index: normal = 100');fig.tight_layout();save(fig,'cases')
    ds=np.linspace(.001,.49,100);ks=np.linspace(0,.6,121)
    fig,axs=plt.subplots(1,3,figsize=(12,3.6),sharex=True,sharey=True)
    for ax,c in zip(axs,[.07,.09,.095]):
        Z=np.array([[{'operate':0,'reopen':1,'closed':2}[decision(d=float(d),kappa=float(k),c=c)['state']] for k in ks] for d in ds])
        V=operating(c=c)['pi']/.1
        ax.pcolormesh(ks,ds,Z,cmap=ListedColormap([blue,teal,orange]),norm=BoundaryNorm([-.5,.5,1.5,2.5],3),shading='nearest',rasterized=True)
        ax.plot(ks,.5/.4*(operating(c=c)['pi']+.9*np.minimum(ks,V)),c='white',lw=2)
        ax.axvline(V,c='white',ls='--',lw=1.5)
        ax.set(title=f'c = {c:.3f}; π₀ = {operating(c=c)["pi"]:.3f}',xlabel='Restart cost κ',ylim=(0,.49))
    axs[0].set_ylabel('Adverse shock size d');fig.tight_layout();save(fig,'regimes')
    hs=np.linspace(0,.15,100)
    fig,ax=plt.subplots(figsize=(10,3.4));ax.plot(hs,.09-hs,c=teal,lw=3,label='Suspend: −h + βV');ax.axhline(0,c=orange,lw=2,label='Close: 0');ax.axhline(-.06,c=blue,ls='--',lw=2,label='Operate: −0.06');ax.axvline(.09,c=grey,ls=':');ax.scatter([.02],[.07],c=teal,zorder=5);ax.annotate('h = 0.02: suspend',(.02,.07),(.035,.075));ax.set(xlabel='Preservation cost h',ylabel='Date-zero value',ylim=(-.075,.1));ax.legend(loc='upper right',ncol=1,fontsize=12,frameon=False);ax.grid(alpha=.15);fig.tight_layout();save(fig,'suspension')
    (OUT/'examples.json').write_text(json.dumps(data,indent=2)+'\n')

if __name__=='__main__':
    data=verify_final();figures(data)
