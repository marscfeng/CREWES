function obj = guessSegyRevision(obj)
%Guess SEG-Y revision number from textual file header line 39
%
%function obj = guessSegyRevision(obj)
%
% Theory:
%  Column 14 of Line 39 of the text file header should contain a 1 or a 2
%  for SEGY Revisions 1 and 2.
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

if obj.FileID < 0 || obj.fsize <3200
    obj.SegyRevision=[];
    return
end

fpos = obj.ftell;
obj.fseek(3053,'bof');
sr = obj.fread(1,'uint8=>uint8');
obj.fseek(fpos,'bof');    

if isequal(sr,32) || isequal(sr,64) %ASCII || EBCDIC
    obj.SegyRevision = 0;    
elseif isequal(sr,49) || isequal(sr,241) %ASCII || EBCDIC
    obj.SegyRevision = 1;
elseif isequal(sr,50) || isequal(sr,242) %ASCII || EBCDIC
    obj.SegyRevision = 2;
else
    obj.SegyRevision = 0;
    mm_warndlg('Unable to determine SEG-Y Revision Number, using zero',...
        'Warning!',obj.GUI)
end

end % end guessSegyRevision