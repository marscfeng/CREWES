function [txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef] = new ( obj, ntrace, nsamp, sampint )
%Returns new text header (char), binary header (struct), trace header (struct) and trace data (double)
%
% function [txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef] = new ( obj, ntrace, nsamp, sampint )
%
%Returns: txthdr: new text file header
%         binhdr: new binary file struct
%         exthdr: new extende text file header
%         trchdr: new trace header struct
%         trcdat: new trace data array
%         bindef: new binary header definition cell 
%         trcdef: new trace header definition cell array
%
%    ntrace   = number of traces to be represented or [] (default)
%    nsamp    = number of samples per trace or [] (default)
%    sampint  = sample interval in microseconds or [] (default)
%
% Examples:
%   [txthdr,binhdr,trchdr,trcdat] = obj.new(ntrace,nsamp,sampint)
%
% Authors: Kevin Hall, 2017
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

narginchk(1,4)

if nargin<2
    ntrace = obj.Trace.TracesInFile;
end

if nargin<3
    nsamp = obj.SamplesPerTrace;
end

if nargin<4
    sampint = obj.SampleInterval;
end

if isempty(ntrace)
    ntrace = 1;
end
if isempty(nsamp)
    nsamp = 1;
end
if isempty(sampint)
    sampint = 1000;
end

txthdr = obj.TextHeader.new();
binhdr = obj.BinaryHeader.new(nsamp,sampint);
exthdr = obj.ExtendedTextHeader.new();
[trchdr,trcdat] = obj.Trace.new(ntrace,nsamp,sampint);
bindef = obj.BinaryHeader.HdrDef;
trcdef = obj.Trace.HdrDef;

end  %end function