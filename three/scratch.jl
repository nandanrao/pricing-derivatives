using Distributions
using Gadfly
using DataFrames

#######################################
# Basic Brownian Motion Functions
#######################################
function make_walk(steps::AbstractArray{Float64,1}, start = 0.0)
    reduce((a,b) -> append!(a, a[end] + b), [start], steps)
end

make_time(N, T) = range(0, T/N, N)
brownian(N, T, start = 0.0) = make_walk(rand(Normal(0, sqrt(T/N)), N-1), start)

geom(w, mu, sigma, t) = exp(sigma*w + (mu - sigma^2/2)*t)
geometric(brownian, time, mu, sigma) = [geom(b,mu,sigma,t) for (b,t) in zip(brownian, time)]


#######################################
# Asians
#######################################


function expected_value(y, s, i, N, T, K)
    # T/N is like 1/T in discrete
    # time_left is like 1/T * (T - t)
    time_left = T/N * (N - i)
    mu = (y * T/N) + time_left * s - K
    sigma = sqrt(time_left/3) # why 3 ??? Seems to work???
    prob_in_the_money = 1 - cdf(Normal(mu, sigma), 0)
    prob_in_the_money * mean(TruncatedNormal(mu, sigma, 0, Inf))
end

function asian_value(S, K, N, T)
    Y = cumsum(S)
    [expected_value(Y[i], S[i], i, N, T, K) for i in 1:N-1]
end

function make_path(r, mu, sigma, N, T)
    time = make_time(N, T)
    lambda = (mu - r)/sigma
    W = brownian(N, T) - lambda*time
    geometric(W, time, mu, sigma)
end


function path_and_price(r, mu, sigma, N, T)

end


##################
# messin

function plot_bs(N, T, mu = 2, sigma = 1.5, start = 1.0)
    time = make_time(N, T)
    frames = [
        DataFrame(
            value = geometric(brownian(N, T), time, mu, sigma),
            time = time,
            variable = Symbol(i))
        for i in 1:30]
    plot(reduce(vcat, frames), x = "time", y = "value", color = "variable", Geom.line)
end


function plot_adjusted_bs(r, N, T, mu = 2, sigma = 1.5, start = 1.0)
    time = make_time(N, T)
    lambda = (mu - r)/sigma
    w(B) = B - lambda*time
    frames = [
        DataFrame(
            value = geometric(w(brownian(N, T)), time, mu, sigma),
            time = time,
            variable = Symbol(i))
        for i in 1:30]
    plot(reduce(vcat, frames), x = "time", y = "value", color = "variable", Geom.line)
end
