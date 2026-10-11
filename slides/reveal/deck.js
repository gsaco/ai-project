/* Slide UI and SVG figures. Economic optimization is defined in model.js. */
(function () {
  'use strict';
  function boot() {
    document.querySelectorAll('.math').forEach(el => window.katex.render(el.textContent,el,{displayMode:el.classList.contains('display'),throwOnError:false}));
    const model=window.EFWModel, el=id=>document.getElementById(id);
    const put=(id,text)=>{el(id).textContent=text;};
    const f=x=>(Math.abs(x)<1e-9?0:x).toFixed(2).replace('-','−');
    const formatChange=x=>Math.abs(x)<1e-9?'Unchanged':(x>0?'+':'−')+Math.abs(x).toFixed(2)+' vs. starting value';
    const ink='#161b24',blue='#223f91',teal='#008A92',orange='#D45D00',grey='#566171',line='#ccd4e2';
    let current;
    // The reference deck uses section labels and page numbers above a fine rule.
    const slides=[...document.querySelectorAll('.slides>section')];
    slides.forEach((s,i)=>{s.dataset.section=s.querySelector('.kicker,.backup-label')?.textContent.trim()||'Topic presentation';s.dataset.page=String(i+1).padStart(2,'0')+' / '+slides.length;});
    const text=(x,y,t,opts='')=>`<text x="${x}" y="${y}" fill="${grey}" font-size="21" ${opts}>${t}</text>`;
    const ln=(x1,y1,x2,y2,color=line,dash='')=>`<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${color}" stroke-dasharray="${dash}"/>`;

    function profitPlot(p,opt) {
      const normal=model.solveOperating(), base=model.DEFAULTS;
      const points=Array.from({length:111},(_,i)=>i/100);
      const profit=(x,c)=>c.A*Math.pow(c.s,1-c.alpha)*Math.pow(x,c.alpha)-c.w*x-c.F-c.c;
      const bp={...base,s:.5}, cp={...base,...p};
      const series=[points.map(x=>profit(x,bp)),points.map(x=>profit(x,cp))];
      const low=Math.min(-.3,Math.floor(Math.min(...series.flat())*10)/10), high=Math.max(.15,Math.ceil(Math.max(...series.flat())*10)/10+.05);
      const xp=x=>90+x/1.1*900, yp=y=>232-(y-low)/(high-low)*190;
      let html='<title>Operating profit and the best input choice</title><desc>The grey dashed curve holds starting conditions fixed. The blue curve shows current conditions. The highest point determines input use.</desc>';
      [low,0,high].forEach(v=>{html+=ln(85,yp(v),1000,yp(v));html+=text(71,yp(v)+6,f(v),'text-anchor="end"');});
      html+=ln(85,yp(0),1000,yp(0),'#788396','4 5');
      html+=text(15,22,'Profit');
      ['baseline','current'].forEach((key,i)=>{
        html+=`<polyline points="${points.map((x,j)=>xp(x)+','+yp(series[i][j])).join(' ')}" fill="none" stroke="${i?blue:grey}" stroke-width="${i?3.8:2.5}" stroke-dasharray="${i?'':'7 5'}"/>`;
      });
      html+=ln(xp(opt.x),yp(opt.pi),xp(opt.x),239,blue,'4 5');
      html+=`<circle cx="${xp(normal.x)}" cy="${yp(normal.pi)}" r="6" fill="white" stroke="${grey}" stroke-width="2"/>`;
      html+=`<circle cx="${xp(opt.x)}" cy="${yp(opt.pi)}" r="7" fill="${blue}"/>`;
      // Keep the optimum label above both curves so changes in overhead cannot obscure it.
      html+=`<text x="${xp(opt.x)+(xp(opt.x)>620?-16:16)}" y="25" fill="${blue}" font-size="23" text-anchor="${xp(opt.x)>620?'end':'start'}" font-weight="600">Best input: x* = ${f(opt.x)}</text>`;
      [0,.25,.5,.75,1].forEach(x=>{html+=text(xp(x),259,x.toFixed(2),'text-anchor="middle"');});
      html+=text(1058,282,'Input x','text-anchor="end"');
      el('profit-chart').innerHTML=html;
    }
    function channelUpdate() {
      const p={s:+el('channel-s').value,c:+el('channel-c').value};
      const a=model.solveOperating(p), b=model.solveOperating();
      put('channel-s-value',f(p.s));put('channel-c-value',f(p.c));
      [['x',a.x,b.x],['q',a.q,b.q],['pi',a.pi,b.pi]].forEach(([name,v,old])=>{put('channel-'+name,f(v));put('channel-d'+name,formatChange(v-old));});
      el('channel-pi').className=a.pi<0?'orange':'teal';
      put('acct-revenue',f(a.q));put('acct-input',f(a.inputBill));put('acct-c',f(p.c));put('acct-profit',f(a.pi));
      const changes=[Math.abs(p.s-.5)>1e-9,Math.abs(p.c-.09)>1e-9];
      let message;
      if(changes.filter(Boolean).length===0)message='A thin-margin firm: revenue of 0.80 leaves only 0.01 in operating profit.';
      else if(changes[1]&&!changes[0])message='Institutional overhead shifts profit vertically. Optimal input and output are unchanged while operating.';
      else if(changes[0]&&!changes[1])message='Usable property changes the return to input. The firm adjusts its optimal input and output.';
      else message='Several channels changed. Reset, then change one channel to isolate its effect.';
      put('channel-description',message);profitPlot(p,a);
      [['channel-legal',p.s===.3&&p.c===.09],['channel-compliance',p.s===.5&&p.c===.19]].forEach(([id,on])=>el(id).setAttribute('aria-pressed',String(on)));
    }
    function pathPlot(r) {
      // Discrete periods: steps occur at date 0 and date 1, never a gradual recovery.
      const start=90, shock=305, restore=610, end=840;
      const top=v=>135-v*60, bot=v=>365-v*.85;
      const index=v=>100*v/r.normal.q, rounded=v=>String(Math.round(v));
      const persistent=r.comparison.persistentLoss, noShock=r.params.d===0;
      const baseline=100, low=index(r.paths.negative.output[0]), high=index(r.paths.positive.output[0]);
      const loss=index(r.comparison.loss[0]), gain=index(r.comparison.gain[0]), later=index(r.comparison.loss[1]);
      const styles={negative:{color:orange,shape:'square',name:'Deterioration'},positive:{color:teal,shape:'circle',name:'Improvement'},baseline:{color:grey,shape:'diamond',name:'No change'}};
      const label=(x,y,value,color=grey,size=21,extra='')=>`<text x="${x}" y="${y}" fill="${color}" font-size="${size}" ${extra}>${value}</text>`;
      const segment=(x1,y1,x2,y2,color=line,dash='',width=1)=>`<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${color}" stroke-width="${width}" stroke-dasharray="${dash}"/>`;
      const marker=(x,y,key,description)=>{
        const st=styles[key], tip=`<title>${st.name}: ${description}</title>`;
        if(st.shape==='square')return `<rect x="${x-4.5}" y="${y-4.5}" width="9" height="9" fill="${st.color}">${tip}</rect>`;
        if(st.shape==='diamond')return `<path d="M${x},${y-6} l6,6 l-6,6 l-6,-6 Z" fill="white" stroke="${st.color}" stroke-width="2">${tip}</path>`;
        return `<circle cx="${x}" cy="${y}" r="5.5" fill="${st.color}">${tip}</circle>`;
      };
      const path=(before,during,after,yp,key)=>`<path d="M${start},${yp(before)} H${shock} V${yp(during)} H${restore} V${yp(after)} H${end}" fill="none" stroke="${styles[key].color}" stroke-width="3" stroke-dasharray="${key==='baseline'?'7 5':''}"/>`;
      const bracket=(x,y1,y2,color)=>`<path d="M${x-6},${y1} H${x+6} M${x},${y1} V${y2} M${x-6},${y2} H${x+6}" fill="none" stroke="${color}" stroke-width="2"/>`;
      const badge=(x,y,value,color,width)=>`<rect x="${x-5}" y="${y-19}" width="${width}" height="26" fill="white"/>`+label(x,y,value,color,22,'font-weight="600"');
      let h='<title id="path-title">Institutional restoration and actual production</title>';
      h+='<desc id="path-description">Usable property is a percentage of existing property. Output is an index with initial output equal to 100. '+['negative','baseline','positive'].map(k=>styles[k].name+': output at date 0 is '+rounded(index(r.paths[k].output[0]))+'; from date 1 onward it is '+rounded(index(r.paths[k].output[1]))).join('. ')+'. Impact loss '+rounded(loss)+' index points; gain '+rounded(gain)+'; loss after restoration '+rounded(later)+'.</desc>';
      h+='<rect x="90" y="0" width="210" height="31" rx="3" fill="#F5F7FC"/>';
      h+='<rect x="305" y="0" width="300" height="31" rx="3" fill="#eef1f8"/>';
      h+='<rect x="610" y="0" width="445" height="31" rx="3" fill="#eef7f7"/>';
      h+=label(197,21,'Before the shock',ink,22,'text-anchor="middle"');
      h+=label(457,21,'Temporary shock · t = 0',ink,22,'text-anchor="middle"');
      h+=label(829,21,'Institutions restored · t ≥ 1',blue,22,'text-anchor="middle"');
      h+='<g transform="translate(0,16)">';
      h+=segment(shock,31,shock,371,'#b2bac9','4 5',1.2);
      h+=segment(restore,31,restore,371,'#8994a9','4 5',1.5);
      h+=label(90,57,'Usable property',ink,23,'font-weight="600"');
      h+=label(290,57,'Share of existing property (%)',grey,20);
      [0,.5,1].forEach(v=>{h+=segment(start,top(v),end,top(v));h+=label(75,top(v)+6,rounded(100*v)+'%',grey,19,'text-anchor="end"');});
      ['negative','positive','baseline'].forEach(key=>{
        const a=r.paths[key];
        h+=path(r.params.s0,a.s,r.params.s0,top,key);
        if(!noShock||key==='baseline')h+=marker(380,top(a.s),key,rounded(a.s*100)+'% usable property during the shock');
      });
      h+=marker(180,top(r.params.s0),'baseline','all scenarios, '+rounded(r.params.s0*100)+'% before the shock');
      h+=marker(730,top(r.params.s0),'baseline','all scenarios, '+rounded(r.params.s0*100)+'% after restoration');
      h+=label(864,top(r.params.s0)+6,'All scenarios: '+rounded(r.params.s0*100)+'%',grey,21);
      h+=label(90,178,'Actual production',ink,24,'font-weight="600"');
      h+=label(315,178,'Output index · before shock = 100',grey,20);
      if(persistent)h+=`<rect x="${restore}" y="${bot(100)}" width="${end-restore}" height="${bot(0)-bot(100)}" fill="${orange}" fill-opacity=".07"/>`;
      [0,100,200].forEach(v=>{h+=segment(start,bot(v),end,bot(v));h+=label(75,bot(v)+6,v,grey,20,'text-anchor="end"');});
      ['negative','positive','baseline'].forEach(key=>{
        const a=r.paths[key];h+=path(baseline,index(a.output[0]),index(a.output[1]),bot,key);
        if(!noShock||key==='baseline')h+=marker(380,bot(index(a.output[0])),key,rounded(index(a.output[0]))+' output index at date 0');
      });
      h+=marker(180,bot(100),'baseline','all scenarios, output index 100 before the shock');
      h+=marker(730,bot(100),'baseline','output index 100 after restoration');
      if(persistent)h+=marker(730,bot(0),'negative','output index 0 after restoration');
      if(noShock){
        h+=label(458,322,'No output change',grey,22,'text-anchor="middle"');
      }else{
        h+=bracket(422,bot(high),bot(100),teal)+bracket(422,bot(100),bot(low),orange);
        h+=badge(440,bot(100)-bot(high)>=32?(bot(high)+bot(100))/2+7:bot(high)-12,'Gain: '+rounded(gain),teal,105);
        h+=badge(440,Math.max(310,(bot(low)+bot(100))/2+7),'Loss: '+rounded(loss),orange,118);
      }
      if(persistent){
        h+=label(718,318,'Persistent loss',orange,22,'text-anchor="middle" font-weight="600"');
        h+=label(718,344,rounded(later)+' index points',orange,21,'text-anchor="middle"');
        h+=bracket(825,bot(100),bot(0),orange);
        h+=label(864,274,'No change +',grey,21)+label(864,298,'improvement: 100',grey,21);
        h+=label(864,371,'Deterioration: 0',orange,21);
      }else{
        h+=label(864,286,'All scenarios: 100',grey,21);
        h+=label(725,328,noShock?'No output gap':'Full output recovery',blue,22,'text-anchor="middle"');
        h+=label(725,352,'Remaining loss: 0',grey,20,'text-anchor="middle"');
      }
      h+='</g>';
      el('output-chart').innerHTML=h;
    }
    function shockUpdate() {
      const d=+el('shock-d').value,kappa=+el('shock-kappa').value;
      current=model.simulate({d,kappa});const n=current.paths.negative,c=current.constants;
      const closed=n.decision==='close';
      put('shock-d-value',Math.round(d*100)+' pp');put('shock-kappa-value',f(kappa));
      el('shock-d').setAttribute('aria-valuetext',Math.round(d*100)+' percentage points of usable property');
      el('shock-kappa').setAttribute('aria-valuetext',f(kappa)+' model units');
      function choice(id,selected,tip){
        const target=el(id);target.classList.toggle('chosen',selected);
        target.dataset.tip=tip;target.setAttribute('aria-label',target.textContent+(selected?' (chosen). ':'. ')+tip);
      }
      choice('choice-continue',!closed,'Value at date 0: '+f(n.continueValue)+'. Current profit plus discounted future profits.');
      choice('choice-close',closed,'Value at date 0: '+f(n.closeValue)+'. Includes the option to restart at date 1.');
      choice('choice-restart',closed&&n.restart,'Value at date 1: '+f(c.restartValue)+'. Future business value minus the restart cost.');
      choice('choice-stay-closed',closed&&!n.restart,'Value at date 1: 0.00. No production and no rebuilding expense.');
      el('restart-options').hidden=!closed;el('stays-open').hidden=closed;
      put('restart-context',closed?'After restoration · if closed':'After restoration · date 1');
      put('shock-decision',d===0?'No institutional shock: all three scenarios retain their initial output.':!closed?'The firm keeps operating. Equal shocks to usable property produce equal output losses and gains.':n.restart?'Closure creates the impact asymmetry. Free or profitable restarting restores production.':'Institutions recover; the firm remains closed because restarting does not pay.');
      el('shock-decision').className='insight'+(current.comparison.persistentLoss?' caution':'');
      [['preset-conjecture',d===.2&&kappa===.4],['preset-free',d===.2&&kappa===0],['preset-small',d===.05&&kappa===.4]].forEach(([id,on])=>el(id).setAttribute('aria-pressed',String(on)));
      pathPlot(current);
    }
    function channelPreset(s=.5,c=.09){el('channel-s').value=s;el('channel-c').value=c;channelUpdate();}
    ['s','c'].forEach(k=>el('channel-'+k).addEventListener('input',channelUpdate));
    el('channel-reset').addEventListener('click',()=>channelPreset());
    el('channel-legal').addEventListener('click',()=>channelPreset(.3));
    el('channel-compliance').addEventListener('click',()=>channelPreset(.5,.19));
    function preset(d,kappa){el('shock-d').value=d;el('shock-kappa').value=kappa;shockUpdate();}
    ['d','kappa'].forEach(k=>el('shock-'+k).addEventListener('input',shockUpdate));
    el('preset-conjecture').addEventListener('click',()=>preset(.2,.4));el('preset-free').addEventListener('click',()=>preset(.2,0));el('preset-small').addEventListener('click',()=>preset(.05,.4));
    document.querySelectorAll('input,button').forEach(e=>e.addEventListener('keydown',event=>{if(['ArrowLeft','ArrowRight','ArrowUp','ArrowDown',' ','Home','End','Enter'].includes(event.key))event.stopPropagation();}));
    window.EFWDeck={getSimulation:()=>current,reset:()=>preset(.2,.4)};
    channelUpdate();shockUpdate();
  }
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',boot);else boot();
})();
