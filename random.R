
T <- 4
u <- 1.09
d <- .85
r <- 0.03
K <- 25
p <- .75

recurse <- function () {

    c()
}



blah <- function (n = 1000) {
    X <- c(0)
    for (i in 2:n) {
        X[i] <- X[i-1] + rnorm(1)
    }
    X
}

d <- blah(1000)

data.frame(x = d) %>%
    mutate(t = row_number(), y = t*x) %>%
    ggplot(aes(x = y)) +
    geom_histogram(bins = 100)


rbinom()






################################



brownian <- function (T = 5, n = 1000) {
    steps <- sqrt(T/n) * sapply(rbinom(n, 1, .5), function (x) (-1)^x)
    X <- c(0)
    for (i in 2:n) {
        X[i] <- X[i-1] + steps[i]
    }
    X
}

brownian.df <- function (T = 10, n = 1000, fn = brownian) {
    data.frame(val = fn(T, n), time = 1:n)
}


brownian.df(5, 10) %>% ggplot(aes(x = time, y = val)) + geom_line()

brownian.df(5, 50) %>% ggplot(aes(x = time, y = val)) + geom_line()

brownian.df(5, 100) %>% ggplot(aes(x = time, y = val)) + geom_line()

brownian.df(5, 1000) %>% ggplot(aes(x = time, y = val)) + geom_line()

brownian.df(5, 10000) %>% ggplot(aes(x = time, y = val)) + geom_line()



brownian.geometric <- function (T = 5, n = 1000, mu = 0, sigma = 1, fn = rnorm) {
    X <- c(fn(1, mu, sigma))
    for (i in 2:n) {
        X[i] <- X[i-1] + fn(1, mu, sigma)
    }
    X
}


brownian.df(1, 1000, brownian.geometric) %>% ggplot(aes(x = time, y = val)) + geom_line()


brownian.df(1, 1000, function (a,b) brownian.geometric(a,b,-0.5)) %>% ggplot(aes(x = time, y = val)) + geom_line()

brownian.df(1, 1000, function (a,b) brownian.geometric(a,b,0.5)) %>% ggplot(aes(x = time, y = val)) + geom_line()




brownian.df(1, 1000, function (a,b) brownian.geometric(a,b, 1, .1, rlnorm)) %>% ggplot(aes(x = time, y = val)) + geom_line()


brownian.df(1, 1000, function (a,b) brownian.geometric(a,b, .1, 1, rlnorm)) %>% ggplot(aes(x = time, y = val)) + geom_line()





## brownian.df(5, 1000, function (a,b) brownian.geometric(a,b,1, .1)) %>% ggplot(aes(x = time, y = val)) + geom_line()

## brownian.df(5, 1000, function (a,b) brownian.geometric(a,b,.1, 1)) %>% ggplot(aes(x = time, y = val)) + geom_line()





brownian.bridge <- function (T = 1, n = 1000) {
    B <- brownian.geometric(T, n)
    B.1 <- B[1]
    data.frame(B = B, t = 1:1000/1000) %>%
        mutate(X = B - t*B.1)
}

set.seed(14)
brownian.bridge() %>% ggplot(aes(x = t, y = X)) + geom_line()
brownian.bridge()[1, ]


brownian.squared <- function (T = 1, n = 1000) {
    B <- brownian.geometric(T, n)
    data.frame(B = B, t = 1:n/n) %>%
        mutate(X = B^2 - t)
}

unset.seed()
brownian.squared(1, 1000000) %>% ggplot(aes(x = t, y = X)) + geom_line()



brownian.df.d <- function (T = 10, n = 1000, d = 2) {
    data.frame(sapply(1:d, function (x) brownian(T,n)))
}

brownian.df.d(10,10000) %>% ggplot(aes(x = X1, y = X2)) + geom_line()

h <- sapply(1:1000, function (x) brownian(10, 1000)[10])
