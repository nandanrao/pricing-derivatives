def call_price(r, u, d, t, T, p, v):
    if t == T:
        return v - 20
    return (p * call_price(r,u,d,t+1,T, p, v*u) + max(0, (1-p)*call_price(r,u,d,t+1,T,p,v*d)))/r


def get_portfolio(S, n, u = 1.06, d = .98):
    vu = call_price(1.04, u, d, n+1, 4, .75, S*u)
    vd = call_price(1.04, u, d, n+1, 4, .75, S*d)
    b = (vu - vd)/((u - d) * S)
    a = (vu - b*S*u)/1.04
    value = b*S + a
    return (a,b,value)
