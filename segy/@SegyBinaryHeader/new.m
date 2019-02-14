function [binhdr,bindef] = ...
    new(obj,nsamp,sampint,fmtcode,segrev,ndattrc,nauxtrc,ensfold,srtcode,meassys,nextxthdrs,nextrchdrs,ndatrailers)
%Creates a new binary header struct and a new binary header definition cell-array
%
% function [binhdr,bindef] = new ( nsamp, sampint, ...    %required inputs
%   fmtcode, segrev, ndattrc, nauxtrc, ...   %optional inputs
%   ensfold, srtcode, nextxthdrs, nextrchdrs, ndattrlrs )  %optional inputs
%
% nsamp    = number of samples per trace
% sampint  = sample interval (microsec)
% fmtcode  = SEG-Y format code; in range 1:5,8 (4 is obsolete!)
%            1=4-byte IBM float, 2=4-byte integer, 3=2-byte integer, 4 is
%            not supported by this code, 5=4-byte IEEE float (default), 8=1-byte
%            integer
% segrev   = SEG-Y revision (mandatory) 0='rev0', 1='rev1' (default),
%            2='rev2'
%            NOTE: rev1 will be represented by the number 256 in the struct
% ndattrc  = number of data traces per ensemble (mandatory for pre-stack)
% nauxtrc  = number of aux traces per ensemble (mandatory for pre-stack)
% ensfold  = ensemble fold (eg. CMP fold) (recommended) 1=default
% srtcode  = trace sort code; in range -1:9 (recommended)
%            -1=other, 0=unknown (default), 1=no sort, 2=common depth point,
%            3=single fold continuous, 4=horizontal stack, 5=common source 
%            point, 6=common receiver point, 7=common offset point,
%            8=common mid point, 9=common converstion point
% meassys  = measurement sytem (recommended) 1=meters (default), 2=feet
% nextxthdrs  = number of extended textual headers; in range -1:N (mandatory 
%               for SEG-Y Rev 1) 0=default
% nexttrchdrs = number of extended trace headers (Rev2) 0=default
% ndatrailers = number of data trailers (Rev 2) 0=default
%
% Creates a new SEG-Y binary file header struct
%
% Authors: Kevin Hall, 2017, 2019
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

narginchk(1, 11)

%% Check input values; set defaults if necessary
if nargin < 2 || isempty(nsamp)
    nsamp = obj.SamplesPerTrace;
end
if nargin < 3 || isempty(sampint)
    sampint = obj.SampleInterval;
end
if nargin < 4 || isempty(fmtcode)
    fmtcode = obj.FormatCode;
end
if nargin < 5 || isempty(segrev)
    segrev = obj.SegyRevision;
end
if nargin < 6 || isempty(ndattrc)
    ndattrc = 0; %mandatory for pre-stack data
end
if nargin < 7 || isempty(nauxtrc)
    nauxtrc = 0; %mandatory for pre-stack data
end
if nargin < 8 || isempty(ensfold)
    ensfold = 1; %recommended
end
if nargin < 9 || isempty(srtcode)
    srtcode = 0; %recommended; -1:9
end
if nargin < 10 || isempty(meassys)
    meassys = 1; %recommended; 1:2
end
if nargin < 11 || isempty(nextxthdrs)
    nextxthdrs = obj.NumExtTxtHdrs; %mandatory for SEG-Y rev1
end
if nargin < 12 || isempty(nextrchdrs)
    nextrchdrs = obj.NumExtTrcHdrs; %mandatory for SEG-Y rev2
end
if nargin < 13 || isempty(ndatrailers)
    ndatrailers = obj.NumDataTrailers; %mandatory for SEG-Y rev2
end

%% Sanity checks
%sample interval
if sampint <0
    mm_errordlg('@BinaryHeader/new: Sample interval must be positive','Error!',obj.GUI);
end
%number samples per trace
if nsamp <0
    mm_errordlg('@BinaryHeader/new: Number of samples per trace must be positive','Error!',obj.GUI);
end
%segy revision number
if isempty(segrev)
   segrev = obj.SegyRevision; %get revision number from object 
end
if isempty(obj.SegyRevision) %and if that fails...
    obj.SegyRevision = 1; %revision 1 by default
    segrev = 1;
end

if segrev<0 || segrev > 2
    mm_errordlg(['@BinaryHeader/new: Unknown SEG-Y revision number: ' num2str(segrev)],'Error!',obj.GUI);
end

%format code
if isempty(fmtcode)
    if segyrev == 0
        fmtcode = 1;
    else
        fmtcode = 5; %4-byte IEEE floating point by default
    end
end

if fmtcode==4
    mm_errordlg(['@BinaryHeader/new: 1.Format code ' num2str(fmtcode) ' is not supported by this code'],'Error!',obj.GUI);
elseif segrev==0 && (fmtcode <1 || fmtcode >4)
    mm_errordlg(['@BinaryHeader/new: 2.Format code ' num2str(fmtcode) ' is not defined in SEG-Y rev 0'],'Error!',obj.GUI);
elseif segrev==1 && (fmtcode <1 || fmtcode>5 && fmtcode<8 || fmtcode >8)
    mm_errordlg(['@BinaryHeader/new: 3.Format code ' num2str(fmtcode) ' is not defined in SEG-Y rev 1'],'Error!',obj.GUI);   
elseif segrev==2 && (fmtcode<1 || (fmtcode>12 && fmtcode<15) || fmtcode> 16)
    mm_errordlg(['@BinaryHeader/new: 4.Format code ' num2str(fmtcode) ' is not defined in SEG-Y rev 2'],'Error!',obj.GUI);
end

% num data traces
if ndattrc <0
    mm_errordlg('@BinaryHeader/new: Number of data traces must be positive','Error!',obj.GUI);
end
%num aux traces
if nauxtrc <0
    mm_errordlg('@BinaryHeader/new: Number of auxilliary traces must be positive','Error!',obj.GUI);
end
%ensemble fold
if ensfold <0
    mm_errordlg('@BinaryHeader/new: Ensemble fold must be positive','Error!',obj.GUI);
end
%trace sort code
if segrev==0 && (srtcode < 0 || srtcode > 4)
    mm_errordlg(['@BinaryHeader/new: Trace sort code ' num2str(strcode) ' is not supported in SEG-Y rev 0'],'Error!',obj.GUI);
elseif (srtcode < -1 || srtcode > 9)
    mm_errordlg(['@BinaryHeader/new: Trace sort code ' num2str(strcode) ' is not supported in SEG-Y rev 1'],'Error!',obj.GUI);
end
%measurement system
if meassys <1 || meassys >2
    mm_errordlg(['@BinaryHeader/new: Unkown measurement system ' num2str(meassys)],'Error!',obj.GUI);
end
%fixed trace length flag
if segrev==0
    fixlenflag=0;
else
    fixlenflag=1; %refusing to deal with variable trace lengths!
end
%number of extended textual file headers
if segrev<1
    nextxthdrs=0; %extended textual file headers are not a thing in rev. 0
elseif nextxthdrs < -1
    mm_errordlg('@BinaryHeader/new: Number of Extended Textual File Headers cannot be less than -1','Error!',obj.GUI);
end

%number of extended trace headers
if segrev<2
    nextrchdrs=0; %extended trace headers are not a thing in rev. 0 or 1
end

%number of data trailers
if segrev<2
    ndatrailers=0; %trace data trailers are not a thing in rev. 0 or 1
end

if isempty(obj.HdrDef)
    obj.HdrDef = obj.newDefinition(segrev);
end

%% Create binary file header struct from header definition
for ii = 1:length(obj.HdrDef)
    %initialize struct
    switch obj.HdrDef{ii,2}
        case 'uint8'
            binhdr.(obj.HdrDef{ii,1}) = uint8(0);
        case 'int8'
            binhdr.(obj.HdrDef{ii,1}) = int8(0);            
        case 'uint16'
            binhdr.(obj.HdrDef{ii,1}) = uint16(0);            
        case 'int16'
            binhdr.(obj.HdrDef{ii,1}) = int16(0);
         case 'uint24'
            binhdr.(obj.HdrDef{ii,1}) = uint24(0);            
        case 'int24'
            binhdr.(obj.HdrDef{ii,1}) = int24(0);           
        case 'uint32'
            binhdr.(obj.HdrDef{ii,1}) = uint32(0);             
        case 'int32'           
            binhdr.(obj.HdrDef{ii,1}) = int32(0); 
         case 'uint64'
            binhdr.(obj.HdrDef{ii,1}) = uint64(0);             
        case 'int64'
            binhdr.(obj.HdrDef{ii,1}) = int64(0);
         case 'single'
            binhdr.(obj.HdrDef{ii,1}) = single(0.0);           
        case 'ieee32'
            binhdr.(obj.HdrDef{ii,1}) = single(0.0);
        case 'ibm32'
            binhdr.(obj.HdrDef{ii,1}) = single(0.0);
         case 'double'
            binhdr.(obj.HdrDef{ii,1}) = double(0.0);            
        case 'ieee64'
            binhdr.(obj.HdrDef{ii,1}) = double(0.0);            
        otherwise
            mm_errordlg('@BinaryHeader/new: Unknown data type','Error!',obj.GUI);
    end
    %set struct values
    switch obj.HdrDef{ii,3} %start byte in header (= SEG-Y standard byte 
                            %location-3201)
        case 12 %data traces per ensemble (mandatory for pre-stack)
            binhdr.(obj.HdrDef{ii,1}) = ndattrc;
        case 14 %aux traces per ensemble (mandatory for pre-stack)
            binhdr.(obj.HdrDef{ii,1}) = nauxtrc;
        case 16 %sample rate in microseconds (mandatory)
            binhdr.(obj.HdrDef{ii,1}) = sampint;
        case 18 %original sample rate in microseconds
            binhdr.(obj.HdrDef{ii,1}) = sampint;            
        case 20 %number of samples per trace (mandatory)
            binhdr.(obj.HdrDef{ii,1}) = nsamp;
        case 22 %original number of samples per trace
            binhdr.(obj.HdrDef{ii,1}) = nsamp;            
        case 24 %format code (mandatory)
            binhdr.(obj.HdrDef{ii,1}) = fmtcode;
        case 26 %ensemble fold (recommended)
            binhdr.(obj.HdrDef{ii,1}) = ensfold;
        case 28 %trace sorting code (recommended)
            binhdr.(obj.HdrDef{ii,1}) = srtcode;
        case 54 %measurement system (recommended)
            binhdr.(obj.HdrDef{ii,1}) = meassys;            
        case 68 %extended samples per trace
            if segrev >1
                binhdr.(obj.HdrDef{ii,1}) = nsamp;
            end
        case 72 %extended sample rate in microseconds
            if segrev >1
                binhdr.(obj.HdrDef{ii,1}) = sampint;
            end
        case 80 %extended original sample rate in microseconds
            if segrev >1
                binhdr.(obj.HdrDef{ii,1}) = sampint;
            end
        case 88 %extended original number of samples per trace
            if segrev >1
                binhdr.(obj.HdrDef{ii,1}) = nsamp;
            end
        case 96 %extended original number of samples per trace
            if segrev >1
                binhdr.(obj.HdrDef{ii,1}) = 16909060; %defined for byte-order check
            end             
        case 300 %SEG-Y revision number (mandatory)
            binhdr.(obj.HdrDef{ii,1}) = segrev;
        case 302 %Fixed length trace flag (mandatory)
            binhdr.(obj.HdrDef{ii,1}) = fixlenflag;
        case 304 %Number of extended textual file headers (rev1)
            if segrev>0
                binhdr.(obj.HdrDef{ii,1}) = nextxthdrs;
            end
        case 306 %Number of extended trace headers (rev2)
            if segrev>1
                binhdr.(obj.HdrDef{ii,1}) = nextrchdrs;
            end
        case 328 %Number of data trailers (rev2)
            if segrev>1
                binhdr.(obj.HdrDef{ii,1}) = ndatrailers;
            end
    end
end

bindef = obj.HdrDef;

