function [txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef] = read (obj,trcrange)
%Reads a SEG-Y file
%
% function [txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef] = read (obj,trcrange)
%
%Reads:   File headers and 'trcrange' traces from obj.FileName. Reads all 
%         all traces if 'trcrange' is empty
%Returns: txthdr: text file header
%         binhdr: binary file struct
%         exthdr: extended text file header
%         trchdr: trace header struct
%         trcdat: trace data array
%         bindef: binary header definition cell-array used to read binhdr
%         trcdef: trace header definition cell-array used to read trchdr
%
% Examples:
%   [txthdr,binhdr,exthdr,trchdr,trcdat] = read (); %read all traces
%   [txthdr,binhdr,exthdr,trchdr,trcdat] = read ([]); %read all traces
%   [txthdr,binhdr,exthdr,trchdr,trcdat] = read (1); %read trace 1
%   [txthdr,binhdr,exthdr,trchdr,trcdat] = read (20:30); %read traces 20-30
%
% Authors: Kevin Hall, 2009, 2017
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

narginchk(1,2)

if nargin <2
    trcrange = []; %read all traces
end


txthdr = obj.TextHeader.read;
binhdr = obj.BinaryHeader.read;
exthdr = obj.ExtendedTextHeader.read;
[trchdr,trcdat] = obj.Trace.read(trcrange);
bindef = obj.BinaryHeader.HdrDef;
trcdef = obj.Trace.HdrDef;

end %end function read()
