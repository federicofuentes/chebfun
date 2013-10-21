% Test file for chebfun constructor (basic).

function pass = test_constructor_basic(pref)

if ( nargin == 0 )
    pref = chebpref();
end

% Some basic test functions:
FF = {@sin, @(x) [sin(x), cos(x)], @(x) [sin(x), cos(x), exp(-x)]};

pass = zeros(3, numel(FF));

for j = 1:numel(FF);
    % Initialise k:
    k = 0;

    % Pick the test function:
    F = FF{j};

    % Test on [-1 1]:
    f = chebfun(F, [-1, 1], pref);
    xx = linspace(-1, 1);
    err = norm(feval(f, xx) - F(xx), inf);
    pass(j, k+1) = err < 10*epslevel(f)*vscale(f);
    % APA TODO:  Fix this once we've figured out what to do about eps.
    pass(j, k+2) = err < 50*eps;
    k = k + 2;

    % Test on [-1 1] (no domain passed):
    f = chebfun(F, pref);
    xx = linspace(-1, 1);
    err = norm(feval(f, xx) - F(xx), inf);
    pass(j, k+1) = err < 10*epslevel(f)*vscale(f);
    % APA TODO:  Fix this once we've figured out what to do about eps.
    pass(j, k+2) = err < 500*eps;
    k = k + 2;

    % Test on [0 10000]:
    f = chebfun(F, [0, 10000], pref);
    xx = linspace(0, 10000);
    err = norm(feval(f, xx) - F(xx), inf);
    pass(j, k+1) = err < 100*epslevel(f)*vscale(f);
    % APA TODO:  Fix this once we've figured out what to do about eps.
    pass(j, k+2) = err < 100*hscale(f)*eps;
    k = k + 2;

    % Test on piecewise domain:
    f = chebfun(F, [-1, 0, .5, sqrt(pi/4), 1], pref);
    xx = linspace(-1, 1);
    err = norm(feval(f, xx) - F(xx), inf);
    pass(j, k+1) = err < 10*epslevel(f)*vscale(f);
    % APA TODO:  Fix this once we've figured out what to do about eps.
    pass(j, k+2) = err < 100*eps;
    k = k + 2;
end

end
