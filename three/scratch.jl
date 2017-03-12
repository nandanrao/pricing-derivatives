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

discount(r, N, i) = exp(-r * (N - i))

function expected_value(y, s, r, i, N, T)
    # T/N is like 1/T in discrete
    # N - i is like (T - t)
    d = discount(r, N, i)
    y * T/N * d + s/r * T/N * (1 - d)
end

function hedge(r, i, N, T)
    T/N * r * (1 - discount(r, N, i))
end

function asian_value(S, r, N, T)
    Y = cumsum(S)
    [expected_value(Y[i], S[i], r, i, N, T) for i in 1:N]
end


function path_and_price(r, mu, sigma, N, T)
    time = make_time(N, T)
    asset = geometric(brownian(N,T), time, mu, sigma)
    value = asian_value(asset, r, N, T)
    vcat(DataFrame(value = value, time = time, variable = fill("Asian Option", N)),
         DataFrame(value = asset, time = time, variable = fill("Asset Price", N)))
end

function plot_asian(r, mu, sigma, N, T)
    d = path_and_price(r, mu, sigma, N, T)
    plot(d, x = :time, y = :value, color = :variable, Geom.line)
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
