function sf=writesegy(filename,trcdat,segyrevision,sampint,fmtcode,txtfmt, ...
                   byteorder,txthdr,binhdr,exthdr,trchdr,bindef,trcdef,gui)
% Write Matlab structure, array and scalar data to a new big-endian SEG-Y file.
%
% function  writesegy(sgyfile,trcdat,segyrev,sampint,fmtcode,txtfmt, ...
%                  bytord,txthdr,binhdr,exthdr,trchdr,bindef,trcdef,gui)
%
% Required inputs:
%   filename  - filename (should end in .sgy or .segy)
%   trcdat    - 2-D matrix of samples indexed by (sample, trace)
%
% Optional inputs, [] is accepted:
%   segyrevision - segy revision number (0, 1 or 2)
%   sampint   - sample interval in seconds (default 1e-3)
%   fmtcode   - output segfmt (default=5)
%               1=IBM floating point, 2=4-byte integer, 3=2-byte integer,
%               5=IEEE floating point,8=1-byte integer
%   txtfmt    - text file format (default='ascii')
%               'ascii', 'ebcdic'
%   byteorder - output byte order (default='b')
%               'b' = big-endian (SEG-Y standard), 'l' = little-endian
%   txthdr    - 2-D char array containing an ASCII SEG-Y textual file header. This
%               will be written to disk as EBCDIC if txtfmt='ebcdic'
%   binhdr    - binary header struct
%   exthdr    - 2-D char array containing ASCII SEG-Y extended textual file
%               header(s)
%   trchdr    - trace header struct (optional)
%   bindef    - 4 column binary header definition cell array such as provided by
%               @BinaryHeader/new; See uiSegyDefinition().
%               NOTE! writesegy requires the same custom bindef used with 
%               readsegy unless you modify the binhdr struct to match!
%   trcdef    - 5 column trace header definition cell array such as provided by
%               @BinaryHeader/new; See uiSegyDefinition()
%               NOTE! writesegy requires the same custom trcdef used with 
%               readsegy unless you modify the binhdr struct to match!
%   gui       - 0 (no progress bar or prompts; guess and go...), 1 (text
%               progress bar and prompts, [] (default; gui progress bar and 
%               prompts), h=figure handle (same as [], but an attempt is
%               made to center gui popups on the figure represented by h)
%
% Examples:
%   writesegy('test_ieee.sgy',dataout,1,sampint)
%   writesegy(sgyfile, dataout, segyrev, sampint, fmtcode, txtfmt, ...
%                     byteorder, txthdr, binhdr, exthdr, trchdr)
%   writesegy('test_ieee.sgy',dataout,[],sampint,[],[],[],txthdr,binhdr,[],trchdr)
%
% NOTE: writesegy is a wrapper for @SegyFile/write
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
% of Geoscience of the University of Calgary, Calgary,
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

% Make certain we have between three and eleven input arguments
%narginchk(2,14)
%                        1       2        3       4       5       6
% function  writesegy(sgyfile, trcdat, sampint, segfmt, txtfmt, bytord,

narginchk(2,14)

% Check inputs
if nargin <3 || isempty(segyrevision)
    segyrevision=1; 
end
if nargin < 4 || isempty(sampint)
    sampint = [];
end
if nargin <5 || isempty(fmtcode)
    if exist('binhdr','var')
        fmtcode = binhdr.FormatCode; %4-byte IEEE float
    else
        if segyrevision <1
            fmtcode = 1;
        else
            fmtcode = 5;
        end
    end
end
if nargin < 6 || isempty(txtfmt)
    txtfmt = 'ascii';
end
if nargin < 7 || isempty(byteorder)
    byteorder = 'b';
end
if nargin < 8
    txthdr = [];
end
if nargin < 9
    binhdr = [];
end
if nargin < 10
    exthdr = [];
end
if nargin < 11
    trchdr = [];
end
if nargin < 12
    bindef = [];
end
if nargin < 13
    trcdef = [];
end
if nargin < 14
    gui=1; %print warnings and errors to console by default
end    

nsamp = length(trcdat);

sf = SegyFile(filename,'w',segyrevision,sampint,nsamp,...
    fmtcode,txtfmt,byteorder,bindef,trcdef,gui);

sf.write(txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef)

%end function writesegy