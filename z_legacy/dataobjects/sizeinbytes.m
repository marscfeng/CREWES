function bytes=sizeinbytes(thing)
% SIZEINBYTES ... returns the nymber of bytes occupied by a thing
%
% bytes=sizeinbytes(thing)
%
% example thing=rand(1000);
%         sizeinbytes(thing)
%         returns 8000000
%         because thing is 1000x1000 and is double precision (8 bytes per number)
%
% example2 thing=single(rand(1000))
%          sizeinbytes(thing) 
%          returns 4000000
%
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


klass=class(thing);

bytes=8*numel(thing);%default size

if(strcmp(klass,'char'))
   bytes=2*numel(thing);
elseif(strcmp(klass,'int8')||strcmp(klass,'uint8'))
   bytes=numel('thing');
elseif(strcmp(klass,'uint16')||strcmp(klass,'int16'))
   bytes=2*numel(thing);
elseif(strcmp(klass,'int32')||strcmp(klass,'uint32'))
   bytes=4*numel(thing);
elseif(strcmp(klass,'single'))
    bytes=4*numel(thing);
elseif(strcmp(klass,'struct'))
    names=fieldnames(thing);
    numnames=size(names,1);
    bytes=0;
    for k=1:numnames
        bytes=bytes+sizeinbytes(getfield(thing,char(names(k,:))));
    end
 end