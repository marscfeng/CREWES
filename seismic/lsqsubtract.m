function [result,a]=lsqsubtract(sig1,sig2,iwin)
% LSQSUBTRACT: least squares subtraction
%
% [result,a]=lsqsubtract(sig1,sig2,iwin)
% result=lsqsubtract(sig1,sig2)
%
% LSQSUBTRACT calculates result=sig1-a*sig2 where a is a scalar chosen such that
% "result" has a minimal L2 norm. The signals are assumed to be real
% valued.
% sig1 ... first input signal, if a matrix it will be formed into a column vector
% sig2 ... second input signal, if a matrix it will be formed into a column vector
% NOTE: sig1 and sig2 must be vectors of the same size.
% iwin ... vector of indices defining a segment of the input signals to be
%   used to determine the least squares scalar.
% ************* default 1:length(sig1) ******************
% result ... the value of sig1-a*sig2
% a ... the scalar a
%
% G.F. Margrave, CREWES, 2000
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE



if(prod(size(sig1)-1)>0)
    sig1=sig1(:);
end
if(prod(size(sig2)-1)>0)
    sig2=sig2(:);
end
if(nargin<3)
    iwin=1:length(sig1);
end
if(any(size(sig1)~=size(sig2)))
   error('sig1 and sig2 must be the same size arrays') 
end

a=sum(sig1(iwin).*sig2(iwin))/sum((sig2(iwin).^2));

result=sig1-a*sig2;