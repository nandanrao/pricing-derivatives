using Distributions

phi(x) = cdf(Normal(), x)

function v(t, S, r, K, sigma, T, S_initial)
    delta_t = T - t
    d_minus = (log(S/K) + (r - sigma^2/2)*delta_t)/(sigma * sqrt(delta_t))
    d_plus = (log(S/K) + (r + sigma^2/2)*delta_t)/(sigma * sqrt(delta_t))
    v = S*phi(d_plus) - K*exp(-r * delta_t) * phi(d_minus)
    b = phi(d_plus)
    a = (v - b*S)/exp(r*t)
    delta = phi(d_plus)
    v, b, a, delta
end

# simulate
