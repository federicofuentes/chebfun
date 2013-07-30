function h = mod(x, y)
%MOD   Modulus after division of two chebfun objects.
%   MOD(X, Y) is X - n.*Y where n = floor(X./Y).
%
% See also FLOOR.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun,org/ for Chebfun information.

n = floor(x./y);
h = x - n.*y;

end