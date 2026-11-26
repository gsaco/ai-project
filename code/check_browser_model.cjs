/* Compare the final-presentation parameter grid across Python and JavaScript. */
const assert=require('node:assert/strict');
const model=require('../slides/reveal/model.js');
const data=require('./output/final-verification.json');
function near(a,b){assert.ok(Math.abs(a-b)<1e-9,`${a} differs from ${b}`);}
for(const row of data.grid){
  const r=model.simulate(row.parameters);
  near(r.paths.negative.continueValue,row.continue_value);
  near(r.paths.negative.closeValue,row.close_value);
  r.paths.negative.output.forEach((v,i)=>near(v,row.adverse_output[i]));
  r.paths.positive.output.forEach((v,i)=>near(v,row.favorable_output[i]));
}
for(let i=0;i<=150;i++){
  const h=i/1000,r=model.simulate({suspension:true,h}),p=r.paths.negative;
  near(p.chosenValue,Math.max(-.06,0,.09-h));
  if(h<.09-1e-10)assert.equal(p.decision,'suspend');
  if(h>.09+1e-10)assert.equal(p.decision,'close');
}
console.log(`PASS final browser/Python agreement: ${data.grid.length} parameter points and 151 suspension costs.`);
if (process.argv.includes('--paper')) {
  const cases = JSON.parse(require('node:fs').readFileSync(0, 'utf8'));
  for (const expected of cases) {
    const params = expected.parameters;
    const result = model.simulate({...params, suspension: params.h !== undefined});
    const adverse = result.paths.negative;
    const context = JSON.stringify(params);
    assert.equal(adverse.decision, expected.action, context);
    assert.equal(adverse.tie, expected.tie, context);
    assert.equal(adverse.restart, expected.restart, context);
    assert.equal(adverse.restartTie, expected.restart_tie, context);
    assert.equal(result.conjecture.holds, expected.strict, context);
    near(adverse.output[0], expected.y0);
    near(adverse.output[1], expected.y1);
  }
  console.log(`PASS ${cases.length} manuscript and threshold comparisons against rational arithmetic.`);
}
