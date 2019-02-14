function write ( obj, th )
%`Write a textual file header to a SEG-Y file
%
%function write ( obj, th )
% Warning: Input textual header is assumed to be a 2D ASCII matrix
%   Conversions are performed, this function writes:
%     EBCDIC if obj.TxtFormat = 'ebcdic'
%     ASCII  if obj.TxtFormat = 'ascii'
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%
% Authors: Chad Hogan, 2009
%          Kevin Hall 2009, 2017
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

%expecting exactly two inputs, obj and th
narginchk(2,2)

if ~ischar(th)
    mm_errordlg('@TextHeader/write: Text file header must be char',...
                                'Error!',obj.GUI);
else
    [m,n]=size(th);
    if ~isequal(m,40)
        mm_errordlg('@TextHeader/write: Text file header must be 40 rows',...
                                    'Error!',obj.GUI);
    elseif ~isequal(n,80)
        mm_errordlg('@TextHeader/write: Text file header must be 80 cols',...
                                    'Error!',obj.GUI);
    end
end

%make sure file is zero bytes
fs = obj.fsize();
if fs >0
    mm_errordlg('@TextHeader/write: Refusing to overwrite existing text file header',...
                                'Error!',obj.GUI);
end

if isempty(obj.TextFormat)
    obj.TextFormat = 'ascii';
end

%convert ascii input to ebcdic if needed
if strcmp(obj.TextFormat,'ebcdic')
        th = ascii2ebcdic(th);
end   

%write text header to file
obj.fwrite(th', 'uchar');

end