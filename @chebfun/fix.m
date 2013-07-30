function f = fix(f)
%FIX Round pointwise toward zero.
% G = FIX(F) returns the chebfun FOUT such that G(x) = FIX(F(x)) for each x in
% the domain of F.
%
% See also CHEBFUN/ROUND, CHEBFUN/CEIL, CHEBFUN/FLOOR, FIX.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Deal with the trivial empty case:
if ( isempty(f) )
    return
end

% Deal with unbounded functions:
if ( ~isfinite(f) )
    error('CHEBFUN:fix:inf', ...
        'Fix is not defined for functions which diverge to infinity.');
end

% Deal with complex-valued functions:
if ( ~isreal(f) )
    if ( isreal(1i*f) )
        f = 1i*fix(imag(f));
    else
        f = fix(real(f)) + 1i*fix(imag(f));
    end
    return
end

% Set scales and tolerances:
hs = get(f, 'hscale'); hs = max([hs{:}]); % [TODO]
vs = get(f, 'vscale'); vs = max([vs{:}]); % [TODO]
pref = chebfun.pref();
tol = 100*pref.chebfun.eps*vs;
dom = f.domain;

% Find all the integer crossings for f:
[minf, maxf] = minandmax(f);
range = floor([ minf, maxf ]);
r = [];
for k = (range(1)+1):range(2)
    r = [ r ; roots(f - k, 'nozerofun') ];
end

% Include the endpoints in the roots list: (since this forms the new domain)
if ( isempty(r) )
    r = dom([1 end]).';
else
    if ( abs(r(1)  - dom(1)) > 1e-14*hs )
        % Leftmost root is far from domain(1):
        r = [ dom(1) ; r  ];
    else
        r(1) = dom(1);
    end
    if ( abs(r(end) - dom(end)) > 1e-14*hs )
        % Rightmost root is far from domain(1):
        r = [ r ; dom(end) ];
    else
        r(end) = dom(end);
    end
end

% Check for double roots: (double roots may be quite far apart!)
ind = find(diff(r) < 1e-7*hs);
cont = 1;
while ( ~isempty(ind) && cont < 3 )
    remove = false(size(r));
    for k = 1:length(ind)
        % Check whether a double root or two single roots very close
        if ( abs(feval(f, mean(r(ind(k):ind(k)+1)))) < tol )
            if ( ismember(r(ind(k)+1), dom) )
                remove(ind) = true;
            else
                remove(ind+1) = true;
            end
        end
    end
    r(remove) = [];
    cont = cont + 1;
    ind = find(diff(r) < 1e-7*hs);
end
% Make sure that the domain of definition is not changed
r([1 end]) = dom([1 end]);

% Non-trivial impulses should not be removed:
lvals = dom;
for k = 1:length(dom)-1
    lvals(k) = get(f.funs{k}, 'lval');
end
lvals(end) = get(f.funs{end}, 'rval');
rvals = dom;
for k = 2:length(dom)
    rvals(k) = get(f.funs{k-1}, 'rval');
end;
rvals(1) = get(f.funs{1}, 'lval');
idxl = abs(f.impulses(1,:) - lvals) > 100*tol;
idxr = abs(f.impulses(1,:) - rvals) > 100*tol;
idx = idxl | idxr;
idx([1 end]) = 1;
r = sort(unique([r ; dom(idx).']));
[ignored, idx2] = intersect(r,dom(idx));

% Evaluate at an arbitrary point between each root:
c = 0.5912;
nr = length(r);
vals = fix(feval( f , c*r(1:nr-1) + (1-c)*r(2:nr) ));

% Build new chebfun
ff = cell(1, nr-1);
for k = 1:nr-1
    ff{k} = fun.constructor(vals(k), r(k:k+1));
end
f.funs = ff;
f.domain = r.';
imps = f.impulses;
f.impulses = fix(chebfun.jumpvals(ff));
f.impulses(1,idx2) = fix( imps(1,idx) );
