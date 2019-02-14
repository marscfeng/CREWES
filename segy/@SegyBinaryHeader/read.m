function binheadstruct = read ( obj )
%'Read a binary header struct from a SEG-Y file using the current binary header definition
%
% function bh = read ( obj )
%
% Read the binary file header from a SEG-Y file
% Returns:
%   bh as a struct. Uses the header definition obj.HdrDef
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

%position pointer at start of header
obj.fseek(obj.OFFSET,'bof');

%fread entire block of trace headers only
binhead = obj.fread(...
    obj.HDRSIZE, ...
    'uint8');

%convert uint8 to trace header structure
binheadstruct = BinaryHeader2struct(obj,binhead);
end

function binheadstruct = BinaryHeader2struct(obj,binhead)
% trchead is a vector of tpye uint8
% numtraces is the number of traces represented in trchead
if ~isvector(binhead) || ~isa(binhead,'uint8')
    mm_errordlg ('Input trchead must be a vector of type uint8','Error',obj.GUI)
end

[~,~,e] = computer; %get computer endianness and compare to file endianness
field_names = obj.HdrFieldNames;
start_bytes = obj.HdrStartBytes;
end_bytes = obj.HdrEndBytes;
data_types = obj.HdrDataTypes;

if strcmpi(obj.ByteOrder,e)
    flipbytes = false;
else
    flipbytes = true;
end

%convert binary header
for jj = 1:length(obj.HdrDef)
    fieldname = field_names{jj};
    idx = start_bytes.(fieldname):end_bytes.(fieldname);
    if flipbytes, idx=flip(idx); end    
    datatype = data_types.(fieldname);
    %typecast with byteswapping
    switch datatype
        case 'ieee64'
            binheadstruct.(fieldname) = typecast(binhead(idx),'double');
        case 'ieee32'
            binheadstruct.(fieldname) = typecast(binhead(idx),'single');
        case 'ibm32'
            binheadstruct.(fieldname) = ibm2single(typecast(binhead(idx),'uint32'));
        case 'int24'
            binheadstruct.(fieldname) = int24_2int32(binhead(idx),e);
        case 'uint24'
            binheadstruct.(fieldname) = uint24_2uint32(binhead(idx),e);
        otherwise
            binheadstruct.(fieldname) = typecast(binhead(idx),datatype);
    end
end

end
