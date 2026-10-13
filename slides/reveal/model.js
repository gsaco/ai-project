/* Deterministic firm model used by the presentation's interactive examples. */
(function (root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  if (root) root.EFWModel = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function () {
  "use strict";

  const DEFAULTS = Object.freeze({
    A: 2, alpha: 0.5, w: 1.25, F: 0.30, c: 0.09,
    beta: 0.9, kappa: 0.4, s0: 0.5, d: 0.2,
    suspension: false, h: 0.02
  });
  const EPSILON = 1e-10;
  const greater = (a, b) => a - b > EPSILON * Math.max(1, Math.abs(a), Math.abs(b));
  const tied = (a, b) => !greater(a, b) && !greater(b, a);

  function requireCondition(condition, message) {
    if (!condition) throw new RangeError(message);
  }

  function finiteParameters(p, names) {
    names.forEach(name => requireCondition(Number.isFinite(p[name]), name + " must be a finite number."));
  }

  function solveOperating(parameters) {
    const p = Object.assign({}, DEFAULTS, {s: DEFAULTS.s0}, parameters || {});
    finiteParameters(p, ["A", "alpha", "w", "s", "c", "F"]);
    requireCondition(p.A > 0 && p.w > 0, "Productivity A and input price w must be positive.");
    requireCondition(p.alpha > 0 && p.alpha < 1, "The input elasticity alpha must be between zero and one.");
    requireCondition(p.s > 0 && p.s <= 1, "The usable property share s must be greater than zero and at most one.");
    requireCondition(p.c >= 0 && p.F > 0, "Institution-related overhead c must be nonnegative; ordinary overhead F must be positive.");
    const inputPrice = p.w;
    const ratio = p.alpha * p.A / inputPrice;
    const x = p.s * Math.pow(ratio, 1 / (1 - p.alpha));
    const q = p.s * p.A * Math.pow(ratio, p.alpha / (1 - p.alpha));
    const inputBill = inputPrice * x;
    const pi = (1 - p.alpha) * q - p.F - p.c;
    requireCondition([x, q, inputBill, pi].every(Number.isFinite), "The parameters produce an unbounded numerical result.");
    return {
      x, q, pi, inputPrice, inputBill,
      overhead: p.F + p.c,
      marginalProduct: p.alpha * p.A * Math.pow(p.s, 1 - p.alpha) * Math.pow(x, p.alpha - 1)
    };
  }

  function simulate(parameters) {
    const p = Object.assign({}, DEFAULTS, parameters || {});
    finiteParameters(p, ["beta", "kappa", "s0", "d", "h"]);
    requireCondition(p.beta > 0 && p.beta < 1, "The discount factor beta must be between zero and one.");
    requireCondition(p.kappa >= 0 && p.h >= 0, "Restart cost kappa and suspension cost h must be nonnegative.");
    requireCondition(typeof p.suspension === "boolean", "suspension must be true or false.");
    requireCondition(p.d >= 0 && p.d < p.s0 && p.s0 + p.d <= 1, "Use a shock with 0 <= d < s0 and s0 + d <= 1.");
    const normal = solveOperating(Object.assign({}, p, {s: p.s0}));
    requireCondition(greater(normal.pi, 0), "The illustration requires positive normal operating profit pi0. Adjust the normal margin first.");
    const V = normal.pi / (1 - p.beta);
    const restartValue = V - p.kappa;
    const restartProfitable = greater(restartValue, 0);
    // A closed owner can reopen next period. Closure is worth zero only when kappa >= V.
    const W = restartProfitable ? restartValue : 0;
    const timing = [0, 1, 2, 3, 4];

    function scenario(key, direction) {
      const s = p.s0 + direction * p.d;
      const conditional = solveOperating(Object.assign({}, p, {s}));
      const continueValue = conditional.pi + p.beta * V;
      const closeValue = p.beta * W;
      const suspendValue = p.suspension ? -p.h + p.beta * V : null;
      // At ties keep operating. If closure and suspension tie below continuation,
      // preserve the organization by suspending rather than dismantling it.
      let decision = "operate";
      let chosenValue = continueValue;
      if (p.suspension && greater(suspendValue, chosenValue)) {
        decision = "suspend";
        chosenValue = suspendValue;
      }
      if (greater(closeValue, chosenValue)) {
        decision = "close";
        chosenValue = closeValue;
      }
      const restart = decision === "close" && restartProfitable;
      const restorationDecision = decision === "operate" ? "continue"
        : decision === "suspend" ? "resume"
        : restart ? "restart" : "remain closed";
      const subsequentOutput = decision !== "close" || restart ? normal.q : 0;
      const output = timing.map(t => t === 0 ? (decision === "operate" ? conditional.q : 0) : subsequentOutput);
      const alternatives = [continueValue, closeValue].concat(p.suspension ? [suspendValue] : []);
      const tie = alternatives.filter(value => tied(value, chosenValue)).length > 1;
      return {
        key, direction, s, conditional, continueValue, closeValue, suspendValue,
        chosenValue, decision, tie, restart, restartValue, restorationDecision, output
      };
    }

    const paths = {
      negative: scenario("negative", -1),
      baseline: scenario("baseline", 0),
      positive: scenario("positive", 1)
    };
    const loss = timing.map((_, t) => paths.baseline.output[t] - paths.negative.output[t]);
    const gain = timing.map((_, t) => paths.positive.output[t] - paths.baseline.output[t]);
    const constants = {
      q0: normal.q, pi0: normal.pi,
      piMinus: paths.negative.conditional.pi,
      piPlus: paths.positive.conditional.pi,
      V, W, restartValue
    };
    // The sufficient conditions use the same scenario profits as the slides.
    const adverseContinuationNegative = greater(0, paths.negative.continueValue);
    const restartUnprofitable = greater(p.kappa, V);
    const shockAdmissible = p.d > 0 && p.d < p.s0 && p.s0 + p.d <= 1;
    return {
      params: p, timing, normal, constants, paths,
      comparison: {
        loss, gain,
        levelDominance: timing.map((_, t) => !greater(gain[t], loss[t])),
        strictLevelDominance: timing.map((_, t) => greater(loss[t], gain[t])),
        persistentLoss: greater(loss[1], 0)
      },
      conjecture: {
        holds: shockAdmissible && adverseContinuationNegative && restartUnprofitable && !p.suspension,
        shockAdmissible, adverseContinuationNegative, restartUnprofitable,
        noSuspension: !p.suspension,
        note: "The displayed inequalities are sufficient conditions, not necessary conditions or a universal prediction."
      },
      tieConvention: "Keep an incumbent operating at a tie; otherwise prefer suspension to closure at a tie. A closed firm does not restart at a tie."
    };
  }

  return Object.freeze({DEFAULTS, solveOperating, simulate});
});
