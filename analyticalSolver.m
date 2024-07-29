function T = analyticalSolver(x, y, a, b, T0, N)
    T = zeros(size(x));
    for n = 1:N
        term = T0/(n*pi*sinh(n*pi*a/b))*sin(n*pi)*sinh(n*pi*x/b)*cos(n*pi*y/b) ;
        T = T + term;
    end
    T = x*T0/a + T;
end