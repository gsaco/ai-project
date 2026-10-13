"use strict";
const assert = require("node:assert/strict");
const {solveOperating, simulate} = require("./model.js");
let checks = 0;
const check = (name, fn) => { fn(); checks += 1; console.log("PASS " + name); };
const near = (actual, expected, epsilon = 1e-9) => assert.ok(Math.abs(actual - expected) < epsilon, `${actual} != ${expected}`);

check("The conditional optimum satisfies the FOC and the profit identity", () => {
  const o = solveOperating({s: 0.5});
  near(o.inputPrice, 1.25);
  near(o.x, 0.32); near(o.q, 0.8); near(o.pi, 0.01);
  near(o.marginalProduct, o.inputPrice);
  near(o.q - o.inputBill - o.overhead, o.pi);
});

check("The numerical illustration reproduces the proposed conjecture", () => {
  const m = simulate();
  near(m.constants.q0, 0.8); near(m.constants.pi0, 0.01);
  near(m.constants.piMinus, -0.15); near(m.constants.piPlus, 0.17);
  near(m.constants.V, 0.1);
  near(m.paths.negative.conditional.q, 0.48);
  near(m.paths.baseline.conditional.q, 0.8);
  near(m.paths.positive.conditional.q, 1.12);
  near(m.paths.negative.continueValue, -0.06);
  near(m.paths.positive.continueValue, 0.26);
  near(m.constants.restartValue, -0.3);
  assert.equal(m.paths.negative.decision, "close");
  assert.equal(m.paths.negative.restorationDecision, "remain closed");
  assert.deepEqual(m.paths.negative.output, [0, 0, 0, 0, 0]);
  near(m.comparison.loss[0], 0.8); near(m.comparison.gain[0], 0.32);
  near(m.comparison.loss[1], 0.8); near(m.comparison.gain[1], 0);
  assert.equal(m.conjecture.holds, true);
  assert.ok(m.comparison.strictLevelDominance.every(Boolean));
});

check("Scenario profits and normal-output formulas match the simplified conjecture", () => {
  const m = simulate({kappa: 0.2}), p = m.params, c = m.constants;
  near(m.paths.negative.conditional.q, c.q0 * (1 - p.d / p.s0));
  near(m.paths.positive.conditional.q, c.q0 * (1 + p.d / p.s0));
  near(c.piPlus - c.pi0, c.pi0 - c.piMinus);
  near(m.paths.negative.continueValue, c.piMinus + p.beta * c.V);
  near(m.paths.positive.continueValue, c.piPlus + p.beta * c.V);
  assert.ok(c.pi0 > 0 && c.piMinus + p.beta * c.V < 0);
  assert.ok(p.kappa > c.V);
  assert.equal(m.conjecture.holds, true);
  assert.deepEqual(m.paths.negative.output, [0, 0, 0, 0, 0]);
  near(m.comparison.loss[0], c.q0);
  near(m.comparison.gain[0], p.d / p.s0 * c.q0);
});

check("Free restarting produces closure now and full recovery after restoration", () => {
  const m = simulate({kappa: 0});
  assert.equal(m.paths.negative.decision, "close");
  assert.equal(m.paths.negative.restorationDecision, "restart");
  near(m.paths.negative.closeValue, 0.09);
  assert.equal(m.paths.negative.output[0], 0);
  near(m.paths.negative.output[1], 0.8);
  assert.equal(m.comparison.persistentLoss, false);
  assert.equal(m.conjecture.holds, false);
});

check("Small shocks leave the firm active and produce symmetric level changes", () => {
  const m = simulate({d: 0.02});
  assert.equal(m.paths.negative.decision, "operate");
  near(m.comparison.loss[0], m.comparison.gain[0]);
  near(m.comparison.loss[1], 0);
});

check("Closure includes the option to reopen, even when continuing has positive value", () => {
  const m = simulate({kappa: 0, d: 0.02});
  assert.ok(m.paths.negative.continueValue > 0);
  assert.ok(m.paths.negative.closeValue > m.paths.negative.continueValue);
  assert.equal(m.paths.negative.decision, "close");
  assert.equal(m.paths.negative.restart, true);
});

check("Cheap suspension prevents persistent loss", () => {
  const m = simulate({suspension: true, h: 0.02});
  assert.equal(m.paths.negative.decision, "suspend");
  near(m.paths.negative.suspendValue, 0.07);
  assert.equal(m.paths.negative.restorationDecision, "resume");
  near(m.paths.negative.output[1], 0.8);
  assert.equal(m.conjecture.holds, false);
  assert.equal(m.comparison.persistentLoss, false);
});

check("Expensive suspension is rejected; availability alone does not imply use", () => {
  const m = simulate({suspension: true, h: 0.2});
  assert.equal(m.paths.negative.decision, "close");
  assert.equal(m.comparison.persistentLoss, true);
});

check("Compliance affects profit, while legal access changes input and output", () => {
  const base = solveOperating();
  const compliance = solveOperating({c: 0.19});
  near(base.q, compliance.q); near(base.pi - compliance.pi, 0.1);
  const property = solveOperating({s: 0.25});
  near(property.q, base.q / 2);
  near(property.x, base.x / 2);
  assert.ok(property.pi < base.pi);
});

check("At the closure threshold the incumbent continues; restarting at zero is declined", () => {
  const m = simulate();
  const threshold = simulate({d: m.params.s0 * m.constants.V / ((1 - m.params.alpha) * m.constants.q0)});
  assert.equal(threshold.paths.negative.tie, true);
  assert.equal(threshold.paths.negative.decision, "operate");
  const reopenTie = simulate({kappa: m.constants.V});
  assert.equal(reopenTie.paths.negative.decision, "close");
  assert.equal(reopenTie.paths.negative.restart, false);
  assert.equal(reopenTie.conjecture.holds, false);
});

check("Zero shock is admissible for the explorer but not a strict conjecture case", () => {
  const m = simulate({d: 0});
  assert.deepEqual(m.paths.negative.output, m.paths.positive.output);
  assert.equal(m.conjecture.holds, false);
});

check("Invalid parameter regions produce actionable validation errors", () => {
  assert.throws(() => simulate({d: 0.5}), /shock/);
  assert.throws(() => simulate({c: 0.2}), /positive normal/);
  assert.throws(() => simulate({kappa: -1}), /nonnegative/);
  assert.throws(() => solveOperating({s: 0}), /share/);
  assert.throws(() => solveOperating({alpha: 1}), /elasticity/);
});

check("Interactive and Python-exported PDF examples agree", () => {
  const exported = require("../figures/topic_examples.json");
  for (const item of exported.cases) {
    const actual = simulate(item.params);
    near(actual.normal.q, item.normal.q);
    near(actual.normal.pi, item.normal.pi);
    near(actual.constants.V, item.V);
    for (const name of ["negative", "baseline", "positive"]) {
      actual.paths[name].output.forEach((y, i) => near(y, item.paths[name].output[i]));
      near(actual.paths[name].continueValue, item.paths[name].continueValue);
      near(actual.paths[name].closeValue, item.paths[name].closeValue);
    }
  }
});

console.log(`\n${checks} economic-model checks passed.`);
