"""Export the interactive deck's operating and activity examples as vector PDFs."""
from pathlib import Path
import json
import subprocess
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
import sys
sys.path.insert(0, str(ROOT / 'code'))
from firm_model import DEFAULTS, operating, simulate
data = dict(defaults=DEFAULTS,
            operating=[operating(),operating(s=.3),operating(c=.19)],
            cases=[simulate(d=.05),simulate(kappa=0),simulate()])
BLUE, TEAL, ORANGE, GREY, LINE = '#223f91', '#008a92', '#d45d00', '#566171', '#ccd4e2'
plt.rcParams.update({'font.family':'DejaVu Sans', 'font.size':11, 'axes.labelsize':11,
                     'axes.titlesize':12, 'axes.titleweight':'bold', 'axes.labelcolor':GREY,
                     'xtick.color':GREY, 'ytick.color':GREY, 'pdf.fonttype':42,
                     'axes.spines.top':False, 'axes.spines.right':False,
                     'axes.spines.left':False, 'axes.spines.bottom':False})
p=data['defaults']
x=np.linspace(0,.85,400)
def profit(s,c): return p['A']*s**(1-p['alpha'])*x**p['alpha']-p['w']*x-p['F']-c
fig,axs=plt.subplots(1,2,figsize=(12,3.5),sharey=True)
for ax,title,s,c,opt in zip(axs,['Less usable property','Higher institutional overhead'],[.3,.5],[.09,.19],data['operating'][1:]):
    ax.plot(x,profit(.5,.09),color=GREY,ls='--',lw=1.9,label='Starting conditions')
    ax.plot(x,profit(s,c),color=BLUE,lw=2.5,label='Current conditions')
    ax.axhline(0,color=LINE,lw=1)
    ax.plot(opt['x'],opt['pi'],'o',color=BLUE,ms=6)
    ax.vlines(opt['x'],-.54,opt['pi'],color=BLUE,linestyle=':',lw=1)
    ax.set(xlim=(0,.85),ylim=(-.54,.12),xticks=[0,.2,.4,.6,.8],yticks=[-.5,-.25,0],xlabel='Variable input x',title=title)
    ax.grid(axis='y',color=LINE,alpha=.35,lw=.7)
axs[0].set_ylabel('Operating profit')
handles,labels=axs[0].get_legend_handles_labels()
fig.legend(handles,labels,loc='upper center',ncol=2,frameon=False,bbox_to_anchor=(.52,1.035))
fig.tight_layout(rect=(0,0,1,.94),w_pad=3)
fig.savefig(OUT/'channel_profit.pdf',bbox_inches='tight')
plt.close(fig)

fig,axs=plt.subplots(1,3,figsize=(12,3.65),sharey=True)
for ax,title,result in zip(axs,['Small shock','Free restart','Costly restart'],data['cases']):
    ax.axvspan(0,1,color='#f5f7fc',zorder=-2)
    for key,color,label,style in [('positive',TEAL,'Improvement','-'),('negative',ORANGE,'Deterioration','-'),('baseline',GREY,'No change','--')]:
        q0=result['normal']['q']; path=result['paths'][key]['output']
        times=[-1,0,1,3]; ys=[100,100*path[0]/q0,100*path[1]/q0,100*path[1]/q0]
        ax.step(times,ys,where='post',color=color,ls=style,lw=2.3,label=label)
    ax.axvline(1,color=LINE,lw=1,ls=':')
    ax.set(xlim=(-1,3),ylim=(-7,155),xticks=[-1,0,1,3],xticklabels=['Before','0','1','3'],yticks=[0,50,100,150])
    ax.set_title(title+'\n'+rf"$d={result['params']['d']:.2f},\ \kappa={result['params']['kappa']:.2f}$",pad=9)
    ax.grid(axis='y',color=LINE,alpha=.35,lw=.7)
axs[0].set_ylabel('Output index (normal = 100)')
handles,labels=axs[0].get_legend_handles_labels()
fig.legend([handles[i] for i in [1,2,0]],[labels[i] for i in [1,2,0]],loc='lower center',ncol=3,frameon=False,bbox_to_anchor=(.51,-.02))
fig.tight_layout(rect=(0,.07,1,1),w_pad=2)
fig.savefig(OUT/'output_cases.pdf',bbox_inches='tight')
plt.close(fig)
# The values displayed in the slide table are exported from the same model.
(OUT/'topic_examples.json').write_text(json.dumps(data,indent=2)+'\n')
print('Created channel_profit.pdf and output_cases.pdf from code/firm_model.py.')
