/* Run after rendering topic.qmd; requires Playwright and its Chromium browser. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {pathToFileURL} = require('node:url');
const {chromium} = require('playwright');

(async () => {
  const browser = await chromium.launch({headless:true});
  const context = await browser.newContext({viewport:{width:1440,height:900}});
  await context.setOffline(true);
  const page = await context.newPage();
  const errors = [], failed = [], external = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('requestfailed', r => failed.push(r.url()));
  page.on('request', r => {if (/^https?:/.test(r.url())) external.push(r.url());});
  // Copy the HTML alone: catches accidentally retained local asset dependencies.
  const isolated = fs.mkdtempSync(path.join(os.tmpdir(),'efw-standalone-'));
  const file = path.join(isolated,'topic.html');
  fs.copyFileSync(path.join(__dirname,'..','topic.html'),file);
  await page.goto(pathToFileURL(file).href);
  await page.waitForFunction(()=>window.Reveal?.isReady() && window.EFWDeck);
  await page.evaluate(()=>document.fonts.ready);
  assert.equal(await page.evaluate(()=>Reveal.getSlides().length),14);
  assert.equal(await page.locator('.katex-error').count(),0);
  assert.ok(await page.locator('.math').count()>0);
  assert.ok(await page.locator('.math').evaluateAll(es=>es.every(e=>e.querySelector('.katex'))));
  assert.equal(await page.locator('.slides').innerText().then(t=>t.includes(':::')),false);
  const go = id=>page.evaluate(id=>{const slide=document.getElementById(id);const ix=Reveal.getIndices(slide);Reveal.slide(ix.h,ix.v,-1);},id);
  const state = ()=>page.evaluate(()=>EFWDeck.getSimulation());
  const setRange = async (id,value)=>{await page.locator('#'+id).evaluate((el,v)=>{el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}));},value);};

  await go('opening'); await page.keyboard.press('ArrowRight');
  assert.equal(await page.evaluate(()=>Reveal.getCurrentSlide().id),'question');
  await page.keyboard.press('Escape'); assert.equal(await page.evaluate(()=>Reveal.isOverview()),true);
  await page.keyboard.press('Escape');
  assert.equal(await page.locator('.fragment').count(),0);
  assert.equal(await page.evaluate(()=>Reveal.getConfig().transition),'none');
  assert.ok(await page.locator('#question h2').evaluate(e=>getComputedStyle(e).fontFamily.includes('Libre Franklin')));
  assert.equal(await page.evaluate(()=>getComputedStyle(document.body).backgroundColor),'rgb(255, 255, 255)');
  await go('foc');
  await page.keyboard.press('ArrowRight');
  assert.equal(await page.evaluate(()=>Reveal.getCurrentSlide().id),'solution');

  await go('channels');
  await setRange('channel-c',.19);
  assert.equal(await page.locator('#channel-q').innerText(),'0.80');
  assert.equal(await page.locator('#channel-pi').innerText(),'−0.09');
  await page.locator('#channel-reset').click();
  await page.locator('#channel-s').focus();await page.keyboard.press('ArrowRight');
  assert.equal(await page.evaluate(()=>Reveal.getCurrentSlide().id),'channels');
  assert.equal(await page.locator('#channel-s').inputValue(),'0.51');
  await page.locator('#channel-reset').click();
  await page.locator('#channel-legal').click();assert.equal(await page.locator('#channel-q').innerText(),'0.48');
  await page.locator('#channel-compliance').click();assert.equal(await page.locator('#channel-q').innerText(),'0.80');
  assert.equal(await page.locator('#channel-x').innerText(),'0.32');
  assert.ok((await page.locator('#channel-description').innerText()).includes('vertically'));
  await page.locator('#channel-reset').click();

  await go('experiment');
  let s=await state();assert.equal(s.conjecture.holds,true);
  assert.deepEqual(s.paths.negative.output,[0,0,0,0,0]);
  assert.equal(await page.locator('#shock-d-value').innerText(),'20 pp');
  assert.ok((await page.locator('#path-description').textContent()).includes('Impact loss 100 index points; gain 40; loss after restoration 100'));
  assert.ok(await page.locator('#choice-close').evaluate(e=>e.classList.contains('chosen')));
  assert.ok(await page.locator('#choice-stay-closed').evaluate(e=>e.classList.contains('chosen')));
  assert.equal(await page.locator('#restart-options').isVisible(),true);
  await page.locator('#preset-free').click();s=await state();assert.equal(s.paths.negative.restart,true);assert.equal(s.comparison.loss[1],0);
  assert.equal(s.params.d,.2);
  assert.ok((await page.locator('#path-description').textContent()).includes('loss after restoration 0'));
  assert.ok(await page.locator('#choice-restart').evaluate(e=>e.classList.contains('chosen')));
  await page.locator('#preset-small').click();s=await state();assert.equal(s.paths.negative.decision,'operate');
  assert.ok((await page.locator('#path-description').textContent()).includes('Impact loss 10 index points; gain 10'));
  assert.equal(await page.locator('#restart-options').isVisible(),false);
  assert.equal(await page.locator('#stays-open').isVisible(),true);
  await setRange('shock-kappa',0);s=await state();assert.equal(s.paths.negative.decision,'close');assert.equal(s.comparison.loss[1],0);
  await page.locator('#preset-conjecture').click();
  await setRange('shock-d',0);assert.deepEqual((await state()).comparison.loss,[0,0,0,0,0]);
  await page.locator('#preset-conjecture').click();

  const sizes=[{width:1440,height:900},{width:1280,height:720}];
  for (const size of sizes) {
    await page.setViewportSize(size);await page.evaluate(()=>Reveal.layout());
    for(let i=0;i<14;i++){
      await page.evaluate(i=>Reveal.slide(i,0,100),i);
      const issue = await page.evaluate(()=>{
        const slide=Reveal.getCurrentSlide(),r=slide.getBoundingClientRect(),scale=Reveal.getScale();
        const nodes=[...slide.querySelectorAll('p,table,.takeaway,.interactive-layout,.metrics,.accounting,.insight,.state-path,svg text,.flow,h1,h2,.rule,.katex-html')];
        return nodes.filter(e=>{const b=e.getBoundingClientRect();return b.width>0&&(b.right>r.right-80*scale+2||b.left<r.left+85*scale-2||b.bottom>r.top+835*scale+2);}).map(e=>({slide:slide.id,text:e.textContent.slice(0,80)}));
      });
      assert.deepEqual(issue,[],JSON.stringify(size)+' slide '+(i+1)+' overflow');
    }
  }
  assert.deepEqual(errors,[]);assert.deepEqual(external,[]);assert.deepEqual(failed,[]);
  console.log('PASS: isolated HTML works offline; 14 slides; all equations rendered.');
  console.log('PASS: reference styling, no fragments, navigation, both diagrams, presets and reset.');
  console.log('PASS: all slide content fits at 1440×900 and 1280×720; no browser errors.');
  await browser.close();fs.rmSync(isolated,{recursive:true,force:true});
})().catch(e=>{console.error(e);process.exit(1);});
