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
