classdef blockFunction
%BLOCKFUNCTION   Convert linear operator to callable function.
%   This class is not intended to be called directly by the end user.
%
%   See also LINOP, CHEBOP, CHEBOPPREF.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Developer notes
%
% This class converts a LINBLOCK object into a callable function suitable
% for application to a CHEBFUN.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties ( Access=public )
        % This property is assigned the callable function that does the
        % correct operation when called on CHEBFUN objects.
        func = [];
        % The domain of functions that are operated upon.
        domain;
    end
    
    methods
        
        function A = blockFunction(varargin)
        % BLOCKFUNCTION     Constructor of BLOCKFUNCTION objects.
        
            % When called with no arguments, the returned object causes the
            % block's stack to be evaluated with these methods to produce
            % coefficients.
            % TODO: This comment doesn't make much sense to me (AB 22/1/14)
            if ( isempty(varargin{1}) )
                pref = cheboppref;
                A.domain = pref.domain;  % TODO: not clear this is ever used...
                return
                
                
            % Calling the constructor with a linBlock argument initiates the
            % process of evaluating the stack with a dummy object of this class.
            elseif ( isa(varargin{1}, 'linBlock') )
                % Convert the given linBlock to its function form by
                % evaluating its stack.
                L = varargin{1};
                dummy = blockFunction([]);
                dummy.domain = L.domain;
                A = L.stack( dummy );
                
                
            % If the constructor is called with data, just make a regular object
            % out of it.
            else
                A.func = varargin{1};
            end
        end
        
        function C = cumsum(A, m)
        %CUMSUM   
        %
        % Returns a BLOCKFUNCTION corresponding to a call to chebfun/cumsum
            C = blockFunction( @(u) cumsum(u, m) );
        end
        
        function D = diff(A, m)
        %DIFF   
        %
        % Returns a BLOCKFUNCTION corresponding to a call to chebfun/diff
            D = blockFunction( @(z) diff(z, m) );
        end
        
        function I = eye(A)
        %EYE
        %
        % Returns a BLOCKFUNCTION corresponding to a function that simply
        % returns the input chebfun.
            I = blockFunction( @(z) z );
        end
        
        function E = feval(A, location, direction)
        %FEVAL
        %
        % Returns a BLOCKFUNCTION corresponding to a call to chebfun/feval.    
            if ( direction < 0 )
                E = blockFunction( @(u) feval(u, location, -1) );
            elseif ( direction > 0 )
                E = blockFunction( @(u) feval(u, location, 1) );
            else
                E = blockFunction( @(u) feval(u, location) );
            end
        end
 
        function F = inner(A, f)
        %INNER
        %
        % Returns a BLOCKFUNCTION corresponding to a call to chebfun/inner.  
            F = blockFunction( @(z) mtimes(f', z) );
        end
                               
        function C = mtimes(A, B)
        %*      Composition of BLOCKFUNCTION objects
            C = blockFunction( @(z) A.func(B.func(z)) );
        end

        function F = mult(A, f)
        %MULT 
        %
        % Returns a BLOCKFUNCTION corresponding to a call to chebfun/times.
            F = blockFunction( @(z) times(f, z) );
        end
                
        function C = plus(A, B)
        %-     Addition of BLOCKFUNCTION objects.
            C = blockFunction( @(z) A.func(z) + B.func(z) );
        end

        function S = sum(A)
        %SUM
        %
        % Returns a BLOCKFUNCTION corresponding to a call to chebfun/sum.
            S = blockFunction( @(z) sum(z) );
        end
        
        function C = uminus(A)
        %-     Unary minus of BLOCKFUNCTION.
            C = blockFunction( @(z) -A.func(z) );
        end
        
        function A = uplus(A)
        %-     Unary plus of BLOCKFUNCTION.
        end      

        function z = zero(A)
        %ZERO
        %
        % Returns a BLOCKFUNCTION corresponding to a function that returnins a
        % zero scalar.
            z = blockFunction( @(u) 0 );
        end
        
        function Z = zeros(A)
        %ZEROS
        %
        % Returns a BLOCKFUNCTION corresponding to a function that returns the
        % zero chebfun.
            Z = blockFunction( @(z) chebfun(0, A.domain) );
        end
        
    end
    
end
