/* Final presentation UI. All economic decisions use the preserved topic model. */
(function () {
  'use strict';
  function boot() {
    document.querySelectorAll('.math').forEach(el => window.katex.render(el.textContent, el, {displayMode:el.classList.contains('display'),throwOnError:false}));
    const slides=[...document.querySelectorAll('.slides>section')];
    slides.forEach((s,i)=>{s.dataset.section=s.querySelector('.kicker')?.textContent.trim()||'Final presentation';s.dataset.page=String(i+1).padStart(2,'0')+' / '+slides.length;});
    const get=id=>document.getElementById(id), model=window.EFWModel;
    const C={blue:'#223F91',teal:'#008A92',orange:'#D45D00',grey:'#566171',line:'#ccd4e2'};
    const fmt=(x,n=2)=>(Math.abs(x)<1e-10?0:x).toFixed(n).replace('-','−');
    const text=(x,y,s,c=C.grey,size=20,anchor='start')=>`<text x="${x}" y="${y}" fill="${c}" font-size="${size}" text-anchor="${anchor}">${s}</text>`;
    const line=(x,y,xx,yy,c=C.line,dash='',width=1)=>`<line x1="${x}" y1="${y}" x2="${xx}" y2="${yy}" stroke="${c}" stroke-width="${width}" stroke-dasharray="${dash}"/>`;
    const presets={small:{d:.05,kappa:.4,c:.09},free:{d:.2,kappa:0,c:.09},costly:{d:.2,kappa:.4,c:.09},margin:{d:.2,kappa:.4,c:.07},avoid:{d:.1,kappa:.4,c:.09}};
    function update() {
      const p={d:+get('final-d').value,kappa:+get('final-k').value,c:+get('final-c').value};
      const r=model.simulate(p), neg=r.paths.negative, norm=r.normal.q;
      get('out-d').textContent=fmt(p.d);get('out-k').textContent=fmt(p.kappa);get('out-c').textContent=fmt(p.c,3);
      get('value-operate').textContent=fmt(neg.continueValue,3);get('value-close').textContent=fmt(neg.closeValue,3);get('value-restart').textContent=fmt(neg.restartValue,3);
      const restartTie=Math.abs(neg.restartValue)<1e-10;
      let message=neg.decision==='operate'?'Keep operating during the shock; normal output returns at date 1.':neg.restart?'Close during the shock; reopen at date 1.':'Close during the shock; remain closed after restoration.';
      if(neg.tie) message='Closure and operation tie. The displayed path keeps operating.';
      if(neg.decision==='close'&&restartTie) message='Close during the shock. Restarting at any restored date and never restarting tie; the displayed path stays closed.';
      get('final-decision').textContent=message;
      get('final-losses').textContent=`Impact: loss ${fmt(100*r.comparison.loss[0]/norm,0)} · gain ${fmt(100*r.comparison.gain[0]/norm,0)}. After restoration: loss ${fmt(100*r.comparison.loss[1]/norm,0)} · gain 0. Output-index points.`;
      document.querySelectorAll('[data-case]').forEach(b=>{const q=presets[b.dataset.case];b.setAttribute('aria-pressed',String(Object.keys(p).every(k=>Math.abs(p[k]-q[k])<1e-9)));});
      const x=[75,290,585,790], sy=v=>125-75*v, oy=v=>316-v*.76;
      let svg='<title>Institutions and output under equal temporary shocks</title><desc>'+message+' '+get('final-losses').textContent+'</desc>';
      svg+=text(75,20,'Usable property (%)',C.blue,22);
      svg+=text(75,153,'Output index · normal = 100',C.blue,22);
      [0,.5,1].forEach(v=>{svg+=line(75,sy(v),790,sy(v))+text(60,sy(v)+6,String(v*100),C.grey,18,'end');});
      [0,100,200].forEach(v=>{svg+=line(75,oy(v),790,oy(v))+text(60,oy(v)+6,String(v),C.grey,18,'end');});
      svg+=line(x[1],35,x[1],320,C.line,'4 4')+line(x[2],35,x[2],320,C.grey,'4 4');
      for(const [key,col,dash] of [['negative',C.orange,''],['positive',C.teal,''],['baseline',C.grey,'6 4']]){
        const a=r.paths[key];
        for(const [before,during,after,yp] of [[.5,a.s,.5,sy],[100,100*a.output[0]/norm,100*a.output[1]/norm,oy]]) {
          svg+=`<path d="M${x[0]},${yp(before)} H${x[1]} V${yp(during)} H${x[2]} V${yp(after)} H${x[3]}" fill="none" stroke="${col}" stroke-width="3.5" stroke-dasharray="${dash}"/>`;
        }
        if(key!=='baseline') {
          svg+=text(420,oy(100*a.output[0]/norm)+(key==='positive'||a.output[0]===0?-9:24),fmt(100*a.output[0]/norm,0),col,21,'middle');
        }
      }
      svg+=text(805,sy(.5)+6,'All: 50%',C.grey,21);
      svg+=text(805,oy(100)+6,neg.output[1]===0?'Normal / +: 100':'All: 100',C.grey,20);
      if(neg.output[1]===0)svg+=text(805,oy(0)+6,'Adverse: 0',C.orange,21);
      svg+=text(180,350,'Before',C.grey,21,'middle')+text(435,350,'Shock · t = 0',C.grey,21,'middle')+text(705,350,'Restored · t ≥ 1',C.blue,21,'middle');
      get('final-paths').innerHTML=svg;
      window.finalCurrentResult=r;
    }
    function suspension() {
      const h=+get('final-h').value,r=model.simulate({suspension:true,h}),a=r.paths.negative;
      get('out-h').textContent=fmt(h,3);
      get('suspend-choice').textContent=a.tie?'Suspension and closure tie. The displayed choice preserves the organization.':a.decision==='suspend'?`Suspend: value ${fmt(a.suspendValue,3)}. Output returns at date 1.`:`Close: value 0. Suspension value ${fmt(a.suspendValue,3)} is lower.`;
      const xp=v=>90+v/.15*840,yp=v=>230-(v+.07)/.17*200;
      let svg='<title>Suspension versus permanent closure</title><desc>'+get('suspend-choice').textContent+'</desc>';
      [-.06,0,.09].forEach(v=>svg+=line(90,yp(v),930,yp(v))+text(75,yp(v)+6,fmt(v),C.grey,20,'end'));
      svg+=line(xp(0),yp(.09),xp(.15),yp(-.06),C.teal,'',3)+line(90,yp(0),930,yp(0),C.orange,'',2)+line(90,yp(-.06),930,yp(-.06),C.blue,'5 4',2);
      svg+=line(xp(.09),20,xp(.09),234,C.grey,'3 5')+line(xp(h),25,xp(h),234,C.teal,'2 4');
      svg+=`<circle cx="${xp(h)}" cy="${yp(.09-h)}" r="7" fill="${C.teal}"/>`;
      [0,.05,.09,.15].forEach(v=>svg+=text(xp(v),258,fmt(v),C.grey,20,'middle'));
      svg+=text(90,20,'Value at date zero',C.blue,21)+text(980,258,'h',C.grey,20,'end');
      svg+=text(710,yp(.04),'Suspend',C.teal,21)+text(710,yp(0)-10,'Close',C.orange,21)+text(710,yp(-.06)-10,'Operate',C.blue,21);
      get('suspension-plot').innerHTML=svg;window.finalSuspensionResult=r;
    }
    ['final-d','final-k','final-c'].forEach(id=>get(id).addEventListener('input',update));
    get('final-h').addEventListener('input',suspension);
    document.querySelectorAll('[data-case]').forEach(b=>b.addEventListener('click',()=>{const p=presets[b.dataset.case];get('final-d').value=p.d;get('final-k').value=p.kappa;get('final-c').value=p.c;update();}));
    document.querySelectorAll('input[type=range]').forEach(el=>el.addEventListener('keydown',e=>e.stopPropagation()));
    update();suspension();
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',boot);else boot();
})();

// Inspect the author's unchanged photograph without leaving the offline deck.
(() => {
  function initHandwriting() {
    const buttons = document.querySelectorAll('.hand-image-button');
    if (!buttons.length) return;
    const viewer = document.createElement('dialog');
    viewer.className = 'hand-viewer';
    viewer.setAttribute('aria-label', 'Original handwritten revision');
    const close = document.createElement('button');
    close.className = 'hand-viewer-close'; close.textContent = 'Close';
    close.addEventListener('click', () => viewer.close());
    const image = document.createElement('img');
    image.alt = 'Original handwritten derivation by Gabriel Saco';
    viewer.append(close, image); document.body.append(viewer);
    viewer.addEventListener('keydown', event => event.stopPropagation());
    buttons.forEach(button => button.addEventListener('click', () => {
      image.src = button.querySelector('img').src;
      viewer.showModal(); viewer.scrollTop = 0; viewer.scrollLeft = 0;
    }));
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initHandwriting);
  else initHandwriting();
})();
