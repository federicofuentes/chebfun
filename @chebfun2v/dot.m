function f = dot( F, G )
%DOT  Vector dot product.
% 
% f = dot(F,G) returns the dot product of the chebfun2v objects F and G.
% dot(F,G) is the same as F'*G.
% 
% See also CROSS. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information. 

if ( isempty( F ) || isempty( G ) ) 
    f = chebfun2;
end

nF = F.nComponents; 
nG = G.nComponents; 
if ( nG ~= nF ) 
    error('CHEBFUN2:DOT:COMPONENTS','Chebfun2v object should have the same number of components.');
end

Fc = F.components; 
Gc = G.components; 

F = cellfun(@mtimes, Fc, Gc, 'UniformOutput', false);

f = chebfun2(0, G.components{1}.domain);
for j = 1 : nF
    f = f + F{j};
end
end