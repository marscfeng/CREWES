function u = single2ibm(d)
% function u = single2ibm(d)
%Where:
%    u = IBM 4-byte floats stored as a 32-bit unsigned integers.
%        Bits can be examined using dec2hex(u)
%    d = Any number(s) stored in any Matlab datatype. vectors and matrices
%        are OK.
%
% NOTE: IBM 4-byte floats are encoded using the formula
%          ( -1)^sign * 0.fraction * 16^(ibm_exponent +ibm_bias),
%       where ibm_bias is defined to be +64.
%
% The sign is stored in bit 32 (the most significant bit of the most
%     significant byte)
% The exponent+bias is stored in bits 25-31 (the most significant byte)
% The fraction is stored in bits 1-24 (three least significant bytes)
%
% WARNING! 
%   IEEE_MAX = (2 -2^-23)*2^127; % =~ 3.4028e+38
%   IEEE_MIN  = 2^-126;          % =~ 1.1755e-38
%
%   **NOTE*: NaN and Inf are not defined for IBM floats
%   NaN is output as IEEE_MAX
%   Inf is output as IEEE_MAX
%   abs(d) < IEEE_MIN is output as 0.0
%   abs(d) > IEEE_MAX is output as IEEE_MAX
%
% Example:
%
% fid = fopen('test_ibm.sgy','w','ieee-be')
% u = single2ibm([realmin('single') realmax('single')])
% fwrite(fid,u,'uint32')
% fclose(fid)
%
% See also double2ibm, ibm2single, ibm2double, log16
%
% Authors: Kevin Hall, 2017, 2018
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

IEEE_MAX  = (2 -2^-23)*2^127; % =~ 3.4028e+38
IEEE_MIN  = 2^-126;           % =~ 1.1755e-38
IBM_BIAS = 64.0;              %defined

%get sign
sbit = int8(sign(d));  %sign is in range -1:1
sbit = bitget(sbit,8); %sign is in range 0:1

%make certain d is a single
d = abs(single(d));

% Deal with numbers between 0.0 and IBM_MIN
d(d<=IEEE_MIN) = 0.0; %set to 0.0

%deal with Inf
d(isinf(d)) = IEEE_MAX; %set to IEEE_MAX

% Deal with NaN
d(isnan(d)) = IEEE_MAX; %set to IEEE_MAX

% get IBM fraction and exponent
[f,e] = log16(d);

%encode IBM sign, fraction and exponent
% s should be an integer stored as a double
% e +IBM_BIAS should be an integer stored as a double
% f is rounded by uint32(), not truncated (this is desirable)
u = uint32(sbit)*2.0^31.0 + uint32((e +IBM_BIAS)*2.0^24.0) +uint32(f*2.0^24.0);

% Deal with potential zero wierdness
u(d==0.0)=0; %set to 0

end %end function single2ibm


