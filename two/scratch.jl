using Distributions
using DataFrames
using Gadfly
using Base.Test




#######################################
# Basic Brownian Motion Functions
#######################################
function make_walk(steps::AbstractArray{Float64,1}, start = 0.0)
    reduce((a,b) -> append!(a, a[end] + b), [start], steps)
end

make_time(N, T) = range(0, T/N, N)
brownian(N, T, start = 0.0) = make_walk(rand(Normal(0, sqrt(T/N)), N-1), start)

# Helper to cover the normal distributions from a brownian motion
function get_steps(B, N)
    step_size = Int(length(B)/N)
    steps = [B[i] - B[i-step_size] for i in (step_size + 1):step_size:length(B)]
end

@testset "get_steps" begin
    @test get_steps([0,2,4,6,8,10,12,14,16,18], 10) == fill(2, 9)
    @test get_steps([0,2,4,6], 4) == [2,2,2]
    @test get_steps([0,2,4,6,8,10,12,14,16,18], 5) == fill(4, 4)
end

geom(w, mu, sigma, t) = exp(sigma*w + (mu - sigma^2/2)*t)
geometric(brownian, time, mu, sigma) = [geom(b,mu,sigma,t) for (b,t) in zip(brownian, time)]

#######################################
# Eulers Method
#######################################

function eulers_method(B, N, T, a_fn, b_fn, start = 1.0)
    d = T/N
    W = get_steps(B, N)
    fn(x,w,t) = x + a_fn(t, x)*d + b_fn(t, x)*w
    reduce((a,i) -> append!(a, fn(a[end], W[i], i)), [start], 1:length(W))
    # extra = (length(B) - 1) % step_size
    # append!(base, fill(base[end], extra))
end

@testset "eulers method" begin
    fn(t,x) = x*t
    @test eulers_method([0,1,2], 3, 1, fn, fn) == [1,3,15]
    @test eulers_method([0,1,2,3], 4, 1, fn, fn, 2) == [2,6,30]
    @test eulers_method([0,1,2,3], 4, 1, fn, fn) == [1,2.5,10]
    @test eulers_method([0,1,2,3], 2, 2, fn, fn) == [1,1,4,4]
end


function geometric_euler(B, N, T, mu, sigma, start)
    a_fn(t, x) = mu*x
    b_fn(t, x) = sigma*x
    eulers_method(B, N, T, a_fn, b_fn, start)
end

#######################################
# Simulations
#######################################

function plot_bs(N, T, mu = 2, sigma = 1.5, start = 1.0, B_N = 1000)
    B = brownian(B_N, T)
    path_time = make_time(B_N, T)
    path = DataFrame(value = geometric(B, time, mu, sigma),
                     time = time,
                     variable = "Brownian Path")
    euler_time = make_time(N, T)
    euler = DataFrame(value = geometric_euler(B, N, T, mu, sigma, start),
                      time = euler_time,
                      variable = "Euler Approximation")
    plot([path; euler], x = "time", y = "value", color = "variable", Geom.line)
end

function plot_vasicek(N, T, mu, sigma, a, start = 1.0)
    B = brownian(N, T)
    a_fn(t, x) = a*(mu - x)
    b_fn(t, x) = sigma
    euler = eulers_method(B, N, T, a_fn, b_fn, start)
    plot(x = make_time(N, T), y = euler, Geom.line)
end

function plot_cir(N, T, sigma, alpha, beta, start = 0.0)
    B = brownian(N, T)
    a_fn(t, r) = alpha - beta*r
    b_fn(t, r) = sigma*sqrt(r)
    euler = eulers_method(B, N, T, a_fn, b_fn, start)
    plot(x = make_time(N, T), y = euler, Geom.line)
end

#######################################
# Exercise #1
#######################################



srand(1)
plot_bs(10,1)

plot_bs(100,1)

plot_bs(1000,1)

#######################################
# Exercise #2
#######################################


plot_vasicek(1000, 5, 0, 1, 10, 5.0)

plot_vasicek(1000, 5, 0, 2, 0.2, 5.0)

plot_vasicek(1000, 5, 0, 10, 100, 5.0)

#######################################
# Exercise #3
#######################################


plot_cir(1000, 10, .05, .04, 1)

plot_cir(1000, 10, .05, 4, 100)


##############################



fit(LogNormal, [geometric(brownian(500,1), make_time(500,1), 10, 3)[end] for _ in 1:1000])
