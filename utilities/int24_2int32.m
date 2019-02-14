function u = int24_2int32(u,fe)
% function d = int24_2int32(u,fe)
% Where:
%     u = 3-byte signed int stored as 8-bit unsigned integer vector or
%     matrix
%    fe = file endian 'l' (little-endian) or 'b' (big-endian)
%
% Example:
%
% fid = fopen('test.uint24,'r')
% u = fread(fid,nbytes,'uint8=>uint8')
% d = int24_2num(u,'b');
% fclose(fid)
%
% Authors: Kevin Hall, 2017, 2018
%
% See also int24_2int32, num2int24, num2uint24
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%

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

narginchk(1,3)
[~,~,e]=computer;

if nargin<2 || isempty(fe)
    fe=e;
end

if ~isa(u,'uint8')
    u = uint8(u);
end

if ~isvector(u)
   u = reshape(u, 1, numel(u));
end

%make certain input vector has an integer multiple of 3 bytes
c = mod(numel(u),3);
if c
    error ('input array must have a length that is a multiple of three');
end

%reshape input
u = reshape(u,3,numel(u)/3);

if ~strcmpi(e,fe)
    s = bitget(u(1,:),8); %get sign bit
    u = flipud([s*255; u]); %add signed byte and byte swap
else
    s = bitget(u(3,:),8); %get sign bit
    u = [u; s*255]; %add signed byte
end

%typecast
u = typecast(reshape(u,1,numel(u)),'int32');

end %end function