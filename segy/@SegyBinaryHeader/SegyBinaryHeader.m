classdef SegyBinaryHeader <File
%
%classdef SegyBinaryHeader
%
% SEG-Y binary file header class
%
% Usage: 
%   bh = SegyBinaryHeader(filename,permission,byteorder,segyrevision,gui)
%
% Where:
%   filename     = string containing full file name or a file id from fopen
%   permission   = string containing file permissions to use with fopen
%                     (optional), default is 'r' (see help fopen)
%   byteorder    = string containing 'b' or 'l' for big- or little-endian
%                     (optional), default is 'n' (see help fopen)
%   segyrevision = 0, 1, or 2
%   gui          = 0: no prompts,
%                  1: text prompts
%                  figure handle or empty: gui prompts
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

properties (Hidden = false)
    HDRSIZE   = 400.0;  %Header size in bytes
    OFFSET = 3200.0; %Header offset from beginning of file in bytes
end

properties
    HdrDef = {}; %Cell array containing the binary file header definition
    SegyRevision = 1; %SEG-Y revision number: 0, 1 (default), or 2
    FormatCode = 5; %SEG-Y data sample format code. Set default to IEEE floating point (5)
    SamplesPerTrace = 0; %Number of data samples per trace
    SampleInterval = 1000; %Sample interval in microseconds. Set default to 1 ms
    NumExtTxtHdrs = 0; %Number of extended textual file headers (rev 1)
    NumExtTrcHdrs = 0; %Number of extended trace headers (rev 2)
    NumDataTrailers = 0; %Number of trace trailers (rev 2)    
end

properties (Dependent)
    HdrFieldNames; %HdrDef col 1 (Dependent)
    HdrDataTypes;  %HdrDef col 2 (Dependent)
    HdrStartBytes; %HdrDef col 3 (Dependent)
    HdrEndBytes;   % (Dependent)
    HdrLongNames;  %HdrDef col 4 (Dependent)
end

events
    SegyRevisionChanged; %Notifies listeners that SegyRevision has changed
    SamplesPerTraceChanged; %Notifies listeners that SamplesPerTrace has changed
    NumExtTrcHdrsChanged; %Notifies listeners that NumExtTrcHdrs has changed 
end

methods
    function obj = SegyBinaryHeader(filename,permission,byteorder,...
            segyrevision,gui,varargin)

        if nargin <1 || isempty (filename)
            filename = -1;
        end
        if nargin <2
            permission = [];
        end
        if nargin <3
            byteorder = [];
        end
        if nargin <4
            segyrevision = [];
        end            
        if nargin <5
            gui = 1;
        end

        %Call superclass constructor
        obj = obj@File(filename,permission,byteorder,gui,varargin{:});

        %Read information from binary file header on disk if it exists
        if obj.FileID > 0 && obj.fsize >= obj.HDRSIZE+obj.OFFSET
            obj = obj.guessByteOrder();
            if ~isempty(segyrevision)
                obj.SegyRevision = segyrevision;
            else
                obj.SegyRevision = obj.readSegyRevision();
            end
            obj.FormatCode = obj.readFormatCode();
            obj.SamplesPerTrace = obj.readSamplesPerTrace();
            obj.SampleInterval = obj.readSampleInterval();
            if obj.SegyRevision > 0
                obj.NumExtTxtHdrs  = obj.readNumExtTxtHdrs; %Number of extended textual file headers
            end
            if obj.SegyRevision > 1
                obj.NumExtTrcHdrs   = obj.readNumExtTrcHdrs;   %Number of extended trace headers
                obj.NumDataTrailers = obj.readNumDataTrailers; %Number of trace trailers
            end
        end
        
        %Apply overrides
        if ~isempty(byteorder)
            obj.ByteOrder = byteorder;
        end

        if ~isempty(segyrevision)
            obj.SegyRevision = segyrevision;
        end
        
        obj.HdrDef = obj.newDefinition();
                
        % Add Listeners
        addlistener(obj,'SegyRevisionChanged',@obj.listenSegyRevision);
        addlistener(obj,'SamplesPerTraceChanged',@obj.listenSamplesPerTrace);        
        addlistener(obj,'PermissionChanged',@obj.listenPermission);

    end %end constructor        

    function set.SegyRevision(obj,v)
        if isempty(v) || (isnumeric(v) && isscalar(v) && v>-1 && v<3)
                obj.SegyRevision=v;
        elseif ~isempty(v)
                mm_errordlg(['@SegyBinaryHeader: Unknown SegyRevision '...
                    num2str(v)],'Error!',obj.GUI);
        end
        notify(obj,'SegyRevisionChanged');
    end

    function set.SamplesPerTrace(obj,v)
        if isnumeric(v) && isscalar(v) && v>-1
                obj.SamplesPerTrace=v;
        elseif ~isempty(v)
                mm_errordlg('@SegyBinaryHeader: SamplesPerTrace must be positive ',...
                    'Error!',obj.GUI);
        end
        notify(obj,'SamplesPerTraceChanged');   
    end
    
    function set.HdrDef(obj,v)
        if iscell(v) || isempty(v)
            obj.check(v)
            obj.HdrDef=v;
        else
            mm_errordlg(['@SegyBinaryHeader: HdrDef must be a valid cell array; '...
                'see SegyBinaryHeader/checkDefinition'],'Error!',obj.GUI);
        end
    end

    function fn = get.HdrFieldNames(obj)
        %returns contents of col 1 of obj.HdrDef
        fn = obj.HdrDef(:,1);
    end %end get.HdrFieldNames

    function st = get.HdrDataTypes(obj)
        %converts cols 1 and 2 of obj.HdrDef into a struct
        st = cell2struct(obj.HdrDef(:,2),obj.HdrDef(:,1));
    end %end get.HdrDataTypes

    function st = get.HdrStartBytes(obj)
        %converts cols 1 and 3 of obj.HdrDef into a struct
        if isempty(obj.HdrDef)
            st = [];
        else
            st = cell2struct(num2cell(cell2mat(obj.HdrDef(:,3))+1),obj.HdrDef(:,1));
        end
    end %end get.HdrStartBytes
    
    function st = get.HdrEndBytes(obj)
        %converts cols 1 and 3 of obj.HdrDef into a struct
        if isempty(obj.HdrDef)
            st = [];
        else
            st = cell2struct([obj.HdrDef(2:end,3); {obj.HDRSIZE}],obj.HdrDef(:,1));
        end
    end %end get.HdrStartBytes    

    function st = get.HdrLongNames(obj)
        %converts cols 1 and 4 of obj.HdrDef into a struct
        idx = ~cellfun('isempty',obj.HdrDef(:,4));
        st = cell2struct(obj.HdrDef(idx,4),obj.HdrDef(idx,1));
    end %end get.HdrLongName

    %Functions to read specific header words independent of obj.HdrDef
    function hw = readFormatCode(obj)
        %Read data sample format code (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+24,'uint16');
    end

    function hw = readSamplesPerTrace(obj)
        %Read samples per trace (Does not use the Header Definition)            
        hw = readHeaderWord(obj,obj.OFFSET+20,'uint16');
        if obj.SegyRevision > 1
            hw2 = readHeaderWord(obj,obj.OFFSET+68,'uint32');
            if ~isequal(hw2,0)
                hw = hw2;
            end
        end
    end

    function hw = readTracesPerRec(obj)
        %Read traces per record (Does not use the Header Definition)                
        ndathw = readHeaderWord(obj,obj.OFFSET+12,'uint16');
        nauxhw = readHeaderWord(obj,obj.OFFSET+14,'uint16');
        if isequal(ndathw,nauxhw)
            hw=ndathw;
        else
            hw = ndathw+nauxhw;
        end
    end

    function hw = readSampleInterval(obj)
        %Read sample interval (Does not use the Header Definition)            
        hw = readHeaderWord(obj,obj.OFFSET+16,'uint16');
        if obj.SegyRevision > 1
            hw2 = readHeaderWord(obj,obj.OFFSET+72,'ieee64');
            if ~isequal(hw2,0.0)
                hw = hw2;
            end
        end        
    end
        
    function hw = readOriginalSampleInterval(obj)
        %Read sample interval (Does not use the Header Definition)            
        hw = readHeaderWord(obj,obj.OFFSET+18,'uint16');
    end

    function hw = readExtTracesPerRec(obj)
        %Read extended traces per record [rev 2] (Does not use the Header Definition) 
        ndathw = readHeaderWord(obj,obj.OFFSET+60,'uint32');
        nauxhw = readHeaderWord(obj,obj.OFFSET+64,'uint32');
        hw = ndathw+nauxhw;
    end

    function hw = readExtSamplesPerTrace(obj)
        %Read extended samples per trace [rev 2] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+68,'uint32');
    end

    function hw = readExtSampleInterval(obj)
        %Read extended sample interval [rev 2] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+72,'ieee64');
    end

    function hw = readIntegerConstant(obj)
        %Read integer constant [rev 2] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+96,'uint32');
    end          

    function hw = readSegyRevision(obj)
        %Read Segy Revision [rev 1+] (Does not use the Header Definition)
        segmaj = double(readHeaderWord(obj,obj.OFFSET+300,'uint8'));
        segmin = double(readHeaderWord(obj,obj.OFFSET+301,'uint8'));
        hw = segmaj+segmin/10;

        %hw _should be_ 0, 1, 2
        if hw < 0 || hw > 2
            mm_warndlg(['Unknown SEG-Y revision ' num2str(hw) ...
                ': Attempting to continue using SEG-Y revision 0'],...
                'Warning!',obj.GUI)
            hw=0;
        end
    end

    function hw = readFixedTrcLength(obj)
        %Read fixed trace length flag [rev 1+] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+302,'uint16');
    end

    function hw = readNumExtTxtHdrs(obj)
        %Read number of extended textual file headers [rev 1+] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+304,'int16');
    end

    function hw = readNumExtTrcHdrs(obj)
        %Read number of extended trace headers [rev 2] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+306,'uint32');
    end                

    function hw = readTraceOneOffset(obj)
        %Read trace one offset [rev 2] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+320,'uint64');
    end        

    function hw = readNumDataTrailers(obj)
        %Read number of data trailers [rev 2] (Does not use the Header Definition)
        hw = readHeaderWord(obj,obj.OFFSET+328,'int32');
    end        
    
    function hw = readHeaderWord(obj,startbyte,datatype)
        %Read a single header word from a given byte position and data type
        %
        % Example: readHeaderWord(3528,'int32')
        obj.fseek(startbyte,'bof');
        hw = obj.fread(1, datatype);
    end

    %Listeners    
    function obj = listenSegyRevision(obj, varargin)
        %SegyRevision has changed, reset the header definition
        obj.HdrDef = obj.newDefinition(obj.SegyRevision);
    end

    function obj = listenSamplesPerTrace(obj, varargin)
        %SamplesPerTrace has changed, add an extended trace header if size is too big
        if obj.SamplesPerTrace > intmax('uint16') && obj.SegyRevision > 1
            obj.NumExtTrcHdrs = 1;
        else
            obj.NumExtTrcHdrs = 0;
        end
    end    
    
    function obj = listenPermission(obj, varargin)
        obj.freopen();
        
        if obj.FileID > 0 && obj.fsize >= 3600
            obj.SegyRevision = obj.readSegyRevision;
            obj.FormatCode = obj.readFormatCode;
            obj.SamplesPerTrace = obj.readSamplesPerTrace;
            obj.SampleInterval = obj.readSampleInterval;
        end
    end
end %end methods


end %end classdef