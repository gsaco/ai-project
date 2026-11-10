# AI-assisted derivation to check independently

This explanation is AI-prepared. It is the contribution to be checked, not Gabriel's handwritten work or his assessment.

The claim is that an initially active firm which closes at date zero retains an option worth

\[
C_0=\beta\max\{V-\kappa,0\},\qquad V=\frac{\pi_0}{1-\beta}.
\]

Assume the original institutions return permanently at date one, this is known at date zero, normal operating profit is \(\pi_0>0\), \(0<\beta<1\), and \(\kappa\geq0\). Inactivity pays zero and there is no salvage or organization-preserving suspension. Financing is available. Restart costs and profits do not change with the length of inactivity.

## 1. Write the cash flows before comparing alternatives

Suppose the firm closes now and first reopens at date \(1+n\), where \(n\) is a nonnegative integer. At that date it pays \(\kappa\) and earns \(\pi_0\). If it then stays open, it earns \(\pi_0\) at every later date. Measured at date zero, the value is

\[
C_0(n)=-\beta^{1+n}\kappa+
\sum_{t=1+n}^{\infty}\beta^t\pi_0.
\]

The cost and the first operating profit occur at the same date; neither is moved to date zero without discounting.

## 2. Sum the future operating profits

Set \(t=1+n+j\). Then

\[
\begin{aligned}
\sum_{t=1+n}^{\infty}\beta^t\pi_0
&=\sum_{j=0}^{\infty}\beta^{1+n+j}\pi_0\\
&=\beta^{1+n}\pi_0\sum_{j=0}^{\infty}\beta^j\\
&=\beta^{1+n}\frac{\pi_0}{1-\beta}.
\end{aligned}
\]

The last equality uses \(0<\beta<1\), which makes the geometric series converge. Therefore

\[
C_0(n)=\beta^{1+n}(V-\kappa).
\]

At date one, rather than date zero, the same plan has value \(\beta^n(V-\kappa)\). This explains the extra factor of \(\beta\) in the closure value at date zero.

## 3. Explain why repeated switching cannot improve this plan

Take any plan with a first restart at date \(1+n\). Replace all its later closures with continued operation. The replacement earns strictly positive normal profit in every period that used to be closed and avoids any later nonnegative restart payments. It does not alter the first restart payment. Thus it is at least as valuable, and strictly more valuable if there is any later closed period. It is enough to compare the first restart date and never restarting; this reduction has been proved rather than assumed.

## 4. Include never reopening

Never reopening gives exactly zero. Compare it with every finite \(n\):

- If \(V-\kappa>0\), \(\beta^{1+n}(V-\kappa)\) is positive and decreases strictly with \(n\). The best restart date is one: \(n=0\).
- If \(V-\kappa<0\), every finite restart date has negative value. Delaying makes the loss smaller, but never restarting attains zero and strictly dominates every finite restart.
- If \(V-\kappa=0\), every first restart date and never restarting give zero. There is no unique choice.

Consequently,

\[
C_0=\max\{\beta(V-\kappa),0\}
=\beta\max\{V-\kappa,0\},
\]

where the last equality uses \(\beta>0\). There is no need to represent “never” as an actual finite date or to mistake a limit for an attained choice.

## 5. Compare with continuing

If the adverse firm keeps operating today, it earns \(\pi_-\), arrives active at date one, and is worth \(V\) then. Its date-zero value is

\[
O_0=\pi_-+\beta V.
\]

Choose closure if \(C_0>O_0\), operation if \(O_0>C_0\), and recognize indifference at equality. Both sides are now expressed at date zero.

## 6. Check numbers that reveal the timing error

Let \(\pi_0=0.01\), \(\beta=0.9\), and \(\pi_-=-0.15\). Then \(V=0.10\) and \(O_0=-0.06\).

With \(\kappa=0\), closing today and reopening tomorrow is worth \(0.9\times0.10=0.09\). Calling closure “worth zero” would discard a valuable option. Closure is chosen, followed by reopening.

With \(\kappa=0.40\), forced reopening tomorrow is worth \(0.9(0.10-0.40)=-0.27\). Delaying multiplies this negative number by another power of 0.9. Never reopening is worth zero, so optimized closure value is zero. Closure is again chosen, now followed by permanent inactivity.

## Your independent assessment

A concrete formalization error was detected during the AI-assisted run. A generic helper allowed \(\beta=0\) while claiming uniqueness of an infinite activity path. For example, with normal profit 1, restart cost 2, and an inactive initial state, staying inactive today and operating later has the same discounted value as never operating: both are zero when \(\beta=0\). The helper's uniqueness claim is false at that boundary. The paper already requires \(\beta>0\), so imposing its actual maintained condition on the helper corrects the formal statement without strengthening the paper. Reconstruct this counterexample by hand as an additional check on where strict discount-factor positivity is used.

On your own handwritten pages, reconstruct the cash flows and summation, name the rule at every equality, and check all three sign cases. Explain in your own words whether the derivation is correct and which step you initially doubted. Identify what would change with cheap suspension, uncertain restoration, time-varying restart costs, or negative normal profits. Supply the original scan and your own verdict; this explanation is not a substitute for either.
