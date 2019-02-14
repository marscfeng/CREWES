classdef SegyTrace < File
%classdef SegyTrace
%
% Class for SEGY Traces (Headers and Data)
%
% Usage: 
%   trc = SegyTrace(filename,permission,fmtcode,byteorder,segyrevision,gui)
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
    HDRSIZE    = 240.0; %Size of one trace header in bytes
    TOTHDRSIZE = 240.0; %Size of all trace headers (rev2)
    OFFSET     = 3600;  %Bytes from beginning of file to start of trace one
end

properties
    %Overrides
    SegyRevision       = 1; % SEG-Y revision number, 0, 1 (default), 2
    FormatCode         = 5; % Format Code, default = 5, IEEE 4-byte float
    SamplesPerTrace    = 1; % Samples Per Trace
    TracesPerRec       = 1; % Traces Per Record, includes data and aux traces
    SampleInterval     = 1000; % Sample Interval in microseconds, default = 1000
    FixedTrcLength     = 1; % Fixed Trace Length flag [rev 1+], default = 1
%     NumExtTxtHdrs      = 0; % Number of Extended Textual File headers [rev 1+], default = 0
%     ExtTracesPerRec    = 0; % Extended Traces Per Record [rev 2], default = 0
%     ExtSamplesPerTrace = 0; % Extended Samples Per Trace [rev2], default = 0
%     ExtSampleInterval  = 0; % Extended Sample interval [rev 2], default = 0
    NumExtTrcHdrs      = 0; % Number of Extended Trace Headers [rev 2], default = 0
    NumDataTrailers    = 0; % Number of Data trailers [rev 2], default = 0
    HdrDef             = [];% Trace Header Definition (cell array)
    ApplyCoordScalars  = true; % Apply Coordinate Scalars, default=true
end

events
    SegyRevisionChanged; %Notifies listeners that the SegyRevision has changed
    SamplesPerTraceChanged; %Notifies listeners that the number of samples per trace has changed
    NumExtTrcHdrsChanged; %Notifies listeners that the number of extended trace headers has changed
    NumDataTrailersChanged; %Notifies listeners that the number of trace data trailers has changed
end

properties (Dependent)
    HdrFieldNames; %Trace Header Field Names, HdrDef col 1
    HdrDefRows;    %Row index in HdrDef for a given Field Name
    HdrDataTypes;  %Header Data Types, HdrDef col 2
    HdrStartBytes; %Header Word Start Bytes, HdrDef col 3
    HdrEndBytes;   %Header Word End Bytes
    HdrScalars;    %Header Scalars, HdrDef col 4
    HdrLongName;   %Header Descriptive (Long) name, HdrDef col 5
    FormatCodeType; %Text equivalent to the numeric Format Code
    BytesPerSample; %Bytes Per Sample, eg. uint8 is 1, uint32 is 4,...
    TraceSize;      %Size of one trace in bytes
    TracesInFile;   %Total number of traces in file
end

methods
    function obj = SegyTrace(filename,permission,fmtcode,byteorder,segyrevision,gui)
        if nargin <1 || isempty(filename)
            filename = -1;
        end
        if nargin <2
            permission = [];                                              
        end
        if nargin <3
            fmtcode = [];                                              
        end            
        if nargin <4
            byteorder = [];
        end
        if nargin <5
            segyrevision = [];
        end
        if nargin <6
            gui = 1;
        end

        %Call superclass constructor
        obj = obj@File(filename,permission,byteorder,gui);

        %Create temporary SegyBinaryHeader object and read info from
        %binary header on disk and read file properties into object
        if obj.FileID > 0 && obj.fsize > 3600
            p = obj.Permission;
            obj.Permission = 'r';
            bh = SegyBinaryHeader(obj.FileID);
            obj.ByteOrder       = bh.ByteOrder;
            obj.SegyRevision    = bh.readSegyRevision();
            obj.FormatCode      = bh.readFormatCode();
            obj.SamplesPerTrace = bh.readSamplesPerTrace();
            obj.TracesPerRec    = bh.readTracesPerRec();
            obj.SampleInterval  = bh.readSampleInterval();

            if obj.SegyRevision >0
                obj.FixedTrcLength = bh.readFixedTrcLength();
                obj.NumExtTrcHdrs  = bh.readNumExtTrcHdrs();
            end

            if obj.SegyRevision >1
%                 obj.ExtTracesPerRec    = bh.readExtTracesPerRec();
%                 obj.ExtSamplesPerTrace = bh.readExtSamplesPerTrace();
%                 obj.ExtSampleInterval  = bh.readExtSampleInterval();
%                 obj.IntegerConstant    = bh.readIntegerConstant();
%                 obj.NumExtTrcHdrs   = bh.readNumExtTrcHdrs();
%                 obj.TraceOneOffset     = bh.readTraceOneOffset();
                 obj.NumDataTrailers    = bh.readNumDataTrailers();

%                 obj.OFFSET = obj.OFFSET ...
%                     +3200*double(bh.readNumExtTxtHeaders());
            end
            obj.Permission = p;
        end

        %Override SEG-Y Revision number
        if ~isempty(segyrevision)
            obj.SegyRevision=segyrevision;
        end

        %Override SEG-Y Format Code
        if ~isempty(fmtcode)
            obj.FormatCode = fmtcode;
        end

        %Sanity check; Format Code 1 has historically been used for both IEEE and IBM
        %floating point data
        if isequal(obj.FormatCode,1)
            obj.guessFormatCode();
        end

        %Set Header definition
        obj.HdrDef = obj.newDefinition();
        if obj.NumExtTrcHdrs > 0
            obj.TOTHDRSIZE = obj.HDRSIZE+obj.NumExtTrcHdrs*obj.HDRSIZE;
        end
        
        obj.listenNumExtTrcHdrs(); %manually trigger listener function

        if isequal(obj.SamplesPerTrace,0) && obj.FileID > 0 && obj.fsize > 3840
            %Binary Header number of samples per trace is 0
            %Reading number of samples from trace header one
            trcnsamp  = obj.read(1,obj.byte2word(114));
            if trcnsamp > 0
                %number of samples is non-zero in trace header one
                obj.SamplesPerTrace = trcnsamp;
                mm_warndlg(['Binary header number of samples per trace is zero. '...
                    'USING Trace header one number of samples per trace! '],...
                    'Warning!',...
                    obj.GUI);
            else
                mm_warndlg(['Binary header number of samples per trace is zero '...
                    'AND Trace header one number of samples per trace is zero. '...
                    'Manually set SegyTrace.SamplesPerTrace! '],...
                    'Warning!',...
                    obj.GUI);
            end
        end
        
        if isequal(obj.SampleInterval,0) && obj.FileID > 0 %Binary Header sample rate is 0
            trcdt  = obj.read(1,obj.byte2word(116));
            if trcdt > 0
                %number of samples is non-zero in trace header one
                obj.SampleInterval = trcdt;
                mm_warndlg(['Binary header sample rate is zero. '...
                    'USING Trace header one sample rate! '],...
                    'Warning!',...
                    obj.GUI);
            else
                mm_warndlg(['Binary header sample rate is zero '...
                    'AND Trace header 1 sample rate is zero. '...
                    'Manually set SegyTrace.SampleInterval! '],...
                    'Warning!',...
                    obj.GUI);
            end
        end
           
        if obj.TracesInFile-fix(obj.TracesInFile)>0
            obj.FixedTrcLength = 1;
            mm_warndlg(['File may not contain fixed length traces! '...
                'Assuming fixed trace length and attempting to continue...'],...
                'Warning!',...
                obj.GUI);
        end
        
        % Add Listeners
        addlistener(obj,'SegyRevisionChanged',@obj.listenSegyRevision);
        addlistener(obj,'SamplesPerTraceChanged',@obj.listenSamplesPerTrace);
        addlistener(obj,'NumExtTrcHdrsChanged',@obj.listenNumExtTrcHdrs);
        addlistener(obj,'PermissionChanged',@obj.listenPermission);
                
    end %end constructor       
    
    function set.SegyRevision(obj, v)
        if isempty(v) || (isscalar(v) && isnumeric(v) && v>-1 && v<3)
            obj.SegyRevision = v;
            notify(obj,'SegyRevisionChanged');
        else
            mm_errordlg('@SegyTrace: SegyRevision must be numeric, scalar and = 0, 1, or 2',...
            'Error!',obj.GUI);                
        end
    end

    function set.NumExtTrcHdrs(obj, v)
        if isempty(v) || (isscalar(v) && isnumeric(v) && v>-1 && v<2)
            obj.NumExtTrcHdrs = v;
            notify(obj,'NumExtTrcHdrsChanged');
        else
            mm_errordlg('@SegyTrace: NumExtTrcHdrs must be numeric, scalar and = 0 or 1',...
                'Error!',obj.GUI);
        end
    end

    function set.NumDataTrailers(obj, v)
        if isempty(v) || (isscalar(v) && isnumeric(v) && v>-1)
            obj.NumDataTrailers = v;
            notify(obj,'NumDataTrailersChanged');
        else
            mm_errordlg('@SegyTrace: NumDataTrailers must be numeric, scalar and positive',...
                'Error!',obj.GUI);
        end
    end
    
    function set.SamplesPerTrace(obj, v)
        if isscalar(v) && isnumeric(v) && v>0
            obj.SamplesPerTrace = v;
            notify(obj,'SamplesPerTraceChanged');
        else
            mm_errordlg('@SegyTrace: SamplesPerTrace must be numeric, scalar and greater than zero',...
                'Error!',obj.GUI);
        end
    end    
    
    function set.HdrDef(obj,v)
        if iscell(v) || isempty(v)
            obj.check(v);
            obj.HdrDef=v;
        else
            mm_errordlg('@SegyTrace: HdrDef must be a valid cell array',...
            'Error!',obj.GUI);
        end
    end

    function set.ApplyCoordScalars(obj,v)
        if islogical(v)
            obj.ApplyCoordScalars=v;
        else
            mm_errordlg('@SegyTrace: ApplyCoordScalars must be logical (true/false)',...
            'Error!',obj.GUI);
        end
    end

    %Get functions
    function nb = get.BytesPerSample(obj)
        if isempty(obj.FormatCode)
            nb = [];
            return
        end
        
        switch obj.FormatCode
            case 1 %ibm floating point
                nb = 4.0;
            case 2 %4-byte int
                nb = 4.0;
            case 3 %2-byte int
                nb = 2.0;
                %             case 4 %4-byte fixed-point with gain (obsolete)
                %                 nb = 4.0;
            case 5 %4-byte IEEE
                nb = 4.0;
            case 6 %8-byte IEEE
                nb = 8.0;
            case 7 %3-byte int
                nb = 3.0;
            case 8 %1-byte int
                nb = 1.0;
            case 9 %8-byte int
                nb = 8.0;
            case 10 %uint32
                nb = 4.0;
            case 11 %uint16
                nb = 2.0;
            case 12 %uint64
                nb = 8.0;
            case 15 %uint24
                nb = 3.0;
            case 16 %uint8
                nb = 1.0;
            otherwise
                mm_errordlg(['@SegyTrace: FormatCode ''' num2str(obj.FormatCode) ...
                    ''' not supported '],...
            'Error!',obj.GUI);
        end
    end %end get.bytesPerSample

    function fn = get.TraceSize(obj)
        if isempty(obj.SamplesPerTrace) || isempty(obj.BytesPerSample)
            fn =[];
        else
            fn = double(obj.SamplesPerTrace)*double(obj.BytesPerSample)...
                +obj.TOTHDRSIZE;
        end
    end

    function fn = get.TracesInFile(obj)
        if obj.FileID > 0 && ~isempty(obj.TraceSize)
            fn = (obj.fsize()-obj.OFFSET)/obj.TraceSize;
        else
            fn = [];
        end
    end

    function fn = get.HdrFieldNames(obj)
        %returns contents of col 1 of obj.HdrDef
        if isempty(obj.HdrDef)
            fn = [];
        else
            fn = obj.HdrDef(:,1);
        end
    end %end get.HdrFieldNames
    
    function st = get.HdrDataTypes(obj)
        %converts cols 1 and 2 of obj.HdrDef into a struct
        if isempty (obj.HdrDef)
            st = [];
        else
            st = cell2struct(obj.HdrDef(:,2),obj.HdrDef(:,1));
        end
    end %end get.HdrDataTypes
    
    function st = get.HdrDefRows(obj)
        if isempty (obj.HdrDef)
            st = [];
        else
            nrows = length(obj.HdrDef);
            st = cell2struct(num2cell(1:nrows)',obj.HdrDef(:,1));
        end
    end %end get.HdrDefRows
    
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
            st = cell2struct([obj.HdrDef(2:end,3); {obj.TOTHDRSIZE}],obj.HdrDef(:,1));
        end
    end %end get.HdrStartBytes
    
    function st = get.HdrScalars(obj)
        %converts cols 1 and 4 of obj.HdrDef into a struct
        if isempty(obj.HdrDef)
            st = [];
        else
            idx = ~cellfun('isempty',obj.HdrDef(:,4));
            st = cell2struct(obj.HdrDef(idx,4),obj.HdrDef(idx,1));
       end
    end %end get.HdrScalars

    function st = get.HdrLongName(obj)
        %converts cols 1 and 5 of obj.HdrDef into a struct
        if isempty(obj.HdrDef)
            st = [];
        else
            st = cell2struct(obj.HdrDef(:,5),obj.HdrDef(:,1));
        end
    end %end get.HdrLongName

    function dtype = get.FormatCodeType(obj)
        %for use with fread/fwrite
        if isempty(obj.FormatCode)
            dtype = [];
            return
        end
        
        switch obj.FormatCode
            case 1 %ibm floating point
                dtype = 'uint32';
            case 2 %4-byte int
                dtype = 'int32';
            case 3 %2-byte int
                dtype = 'int16';
%                 case 4 %4-byte fixed-point with gain (obsolete)
%                     dtype = 'fixed32';
            case 5 %4-byte IEEE
                dtype = 'single';
            case 6 %8-byte IEEE
                dtype = 'double';
            case 7 %3-byte int
                dtype = 'uint8';
            case 8 %1-byte int
                dtype = 'int8';
            case 9 %8-byte int
                dtype = 'int64';
            case 10 %uint32
                dtype = 'uint32';
            case 11 %uint16
                dtype = 'uint16';
            case 12 %uint64
                dtype = 'uint64';
            case 15 %uint24
                dtype = 'uint8';
            case 16 %uint8
                dtype = 'uint8';
            otherwise
                mm_errordlg(['@SegyTrace: FormatCode ''' num2str(obj.FormatCode) ...
                    ''' not supported '],...
            'Error!',obj.GUI);
        end
    end %end get.FormatCodeType

    function st = applyCoordinateScalars(obj, st)
        %Apply coordinate scalars to trace header values
        if obj.ApplyCoordScalars
            hdrscalars = obj.HdrScalars; %try to only call the object get function once
            hdrs_to_scale = fieldnames(hdrscalars);

            for ii = 1:length(hdrs_to_scale)
                if isfield(st,hdrs_to_scale{ii}) && isfield(st,hdrscalars.(hdrs_to_scale{ii}))
                    hw = double(st.(hdrs_to_scale{ii})); %get header word values
                    sc = double(st.(hdrscalars.(hdrs_to_scale{ii}))); %get coordinate scalar values

                    ps_idx = sc > 0;
                    ns_idx = sc < 0;

                    hw(ps_idx) = hw(ps_idx)./sc(ps_idx); %divide if scalar is positive
                    hw(ns_idx) = hw(ns_idx).*abs(sc(ns_idx)); %multiply if scalar is negative

                    st.(hdrs_to_scale{ii})=hw;
                end
            end
        end
    end

    function st=removeCoordinateScalars(obj, st)
        %Remove coordinate scalars from trace header values
        if obj.ApplyCoordScalars
            hdrscalars = obj.HdrScalars; %try to only call the object get function once
            hdrs_to_scale = fieldnames(hdrscalars);

            for ii = 1:length(hdrs_to_scale)
                if isfield(st,hdrs_to_scale{ii}) && isfield(st,hdrscalars.(hdrs_to_scale{ii}))
                    hw = double(st.(hdrs_to_scale{ii})); %get header word values
                    sc = double(st.(hdrscalars.(hdrs_to_scale{ii}))); %get coordinate scalar values

                    ps_idx = sc > 0;
                    ns_idx = sc < 0;

                    hw(ps_idx) = hw(ps_idx).*sc(ps_idx); %multiply if scalar is positive
                    hw(ns_idx) = hw(ns_idx)./abs(sc(ns_idx)); %divide if scalar is negative

                    st.(hdrs_to_scale{ii})=hw;
                end
            end
        end
    end

    %Listeners
    function obj = listenSegyRevision(obj, varargin)
        %SegyRevision has changed, reset the header definition
        if obj.SegyRevision < 2
            obj.NumExtTrcHdrs = 0;
        end
        obj.HdrDef = obj.newDefinition(obj.SegyRevision,obj.NumExtTrcHdrs);
    end
    
    function obj = listenSamplesPerTrace(obj, varargin)
        %SamplesPerTrace has changed, add an extended trace header if size is too big
        if obj.SamplesPerTrace > intmax('uint16') && obj.SegyRevision > 1
            obj.NumExtTrcHdrs = 1;
        else
            obj.NumExtTrcHdrs = 0;
        end
    end    
    
    function obj = listenNumExtTrcHdrs(obj, varargin)
        if obj.SegyRevision < 2 && obj.NumExtTrcHdrs >0
           mm_errordlg(['@SegyTrace: Segy Revision ',...
                num2str(obj.SegyRevision),...
                ' does not allow extended trace headers!'],...
                'Error!',obj.GUI);
        else
            switch obj.NumExtTrcHdrs
                case 0
                    if obj.TOTHDRSIZE > obj.HDRSIZE
%                         mm_warndlg('@SegyTrace: Truncating trace header definition',...
%                             'Warning!',obj.GUI);
                        obj.TOTHDRSIZE = obj.HDRSIZE;
                        obj.HdrDef([obj.HdrDef{:,3}] >= obj.HDRSIZE,:) = [];
                    end
                case 1
                    if obj.TOTHDRSIZE < 2*obj.HDRSIZE
                        obj.TOTHDRSIZE = 2*obj.HDRSIZE;
                        %extend existing header definition in case it's
                        %custom
                        th = obj.newDefinition(2,1);
                        obj.HdrDef = [obj.HdrDef; th([th{:,3}] >= obj.HDRSIZE,:)];
                    end
                otherwise
                    %should never get to this line
                    mm_errordlg(['@SegyTrace: This code does not handle ',...
                        'more than one extended trace header!'],...
                        'Error!',obj.GUI);
            end
        end
    end
    
    function obj = listenPermission(obj, varargin)
            obj.freopen();
    end    
    
end%end methods

methods (Hidden)

    function [trchead,trcdat]=readBoth(obj,trcrange)
        trchead = obj.readHeader(trcrange);
        trcdat  = obj.readData(trcrange);
    end

    function [startbyte,numtraces,skiptraces,fliptraces] = analyzeTraceRange(obj,trcrange)
        fliptraces=false;
        if isscalar(trcrange)
            startbyte  = obj.OFFSET+(trcrange-1)*obj.TraceSize;
            numtraces = 1;
            skiptraces = 1;
        else
            startbyte = obj.OFFSET+(min(trcrange)-1)*obj.TraceSize;
            numtraces = numel(trcrange);
            skiptraces = abs(trcrange(2)-trcrange(1));

            if isequal(sum(diff(trcrange)+skiptraces),0)
                %one block of trace sequential data in reverse order
                fliptraces = true;                               
            end
        end
    end
    
    function trcdat = readData(obj,trcrange)
        [startbyte,numtraces,skiptraces,fliptraces] = obj.analyzeTraceRange(trcrange);
        
        if obj.FormatCode==15 || obj.FormatCode==7
            spt = double(obj.SamplesPerTrace)*3;
            nbytes = spt*numtraces;
        else
            spt = double(obj.SamplesPerTrace);
            nbytes = [spt numtraces];
        end

        if(obj.Debug),fprintf(obj.LogFID,'@SegyTrace.readData: Starting data fread\n'); end
        obj.fseek(startbyte+obj.TOTHDRSIZE,'bof');
        trcdat = obj.fread(...
                nbytes, ...
                sprintf('%d*%s',spt,obj.FormatCodeType), ...
                obj.FormatCodeType, ...
                obj.TOTHDRSIZE +(skiptraces-1)*obj.TraceSize ...
            );
        if(obj.Debug),fprintf(obj.LogFID,'@SegyTrace.readData: Finished data fread\n'); end
        
        if fliptraces
            %flip data if trace block should be in reverse order
            trcdat = fliplr(trcdat);
        end
        
        if(obj.Debug),fprintf(obj.LogFID,'@SegyTrace.readData: Starting data conversion\n'); end
        switch(obj.FormatCode)
            case(1) %IBM float
                utrcdat = trcdat;
                trcdat  = zeros(obj.SamplesPerTrace, numtraces,'single');
                fudgefactor=20.;
                trcperblock = ceil(crmemfree/fudgefactor/obj.TraceSize);
                for ii = 1:trcperblock:numtraces
                    traceone = ii;
                    tracetwo = ii+trcperblock-1;
                    if tracetwo > numtraces
                        tracetwo = numtraces;
                    end
                    trcdat(:,traceone:tracetwo) = ibm2single(utrcdat(:,traceone:tracetwo));
                end
                
                if tracetwo < numtraces
                    trcdat(:,tracetwo+1:numtraces) = ibm2single(utrcdat(:,tracetwo+1:numtraces));
                end
            case(7) %int24                                
                nsamp = double(obj.SamplesPerTrace);
                bpsamp = double(obj.BytesPerSample);
                sampinfile = numtraces*nsamp*bpsamp;
                                
                fudgefactor=20.;
                trcinblock = ceil(crmemfree/fudgefactor/obj.TraceSize);
                sampinblock = trcinblock*nsamp*bpsamp;
                
                utrcdat = trcdat;
                trcdat  = zeros(nsamp,numtraces,'int32');
                
                ii = 1:trcinblock:numtraces;
                jj = 1:sampinblock:sampinfile;
                for kk = 1:length(ii)
                    traceone = ii(kk);
                    sampone = jj(kk);
                    tracetwo = ii(kk)+trcinblock-1;
                    samptwo = jj(kk)+sampinblock-1;
                    if tracetwo > numtraces
                        tracetwo = numtraces;
                        samptwo = sampinfile;
                    end
                    
                    trcdat(:,traceone:tracetwo) = reshape(...
                        int24_2int32(utrcdat(sampone:samptwo),obj.ByteOrder),...
                        obj.SamplesPerTrace, tracetwo-traceone+1 ...
                    );
                end
                
                if tracetwo < numtraces
                    traceone = tracetwo+1;
                    tracetwo = numtraces;
                    trcdat(:,traceone:tracetwo) = reshape(...
                        int24_2int32(utrcdat(samptwo+1:sampinfile),obj.ByteOrder),...
                        obj.SamplesPerTrace, tracetwo-traceone+1 ...
                        );
                end
                              
            case(15) %uint24
                nsamp = double(obj.SamplesPerTrace);
                bpsamp = double(obj.BytesPerSample);
                sampinfile = numtraces*nsamp*bpsamp;
                                
                fudgefactor=20.;
                trcinblock = ceil(crmemfree/fudgefactor/obj.TraceSize);
                sampinblock = trcinblock*nsamp*bpsamp;
                
                utrcdat = trcdat;
                trcdat  = zeros(nsamp,numtraces,'uint32');
                
                ii = 1:trcinblock:numtraces;
                jj = 1:sampinblock:sampinfile;
                for kk = 1:length(ii)
                    traceone = ii(kk);
                    sampone = jj(kk);
                    tracetwo = ii(kk)+trcinblock-1;
                    samptwo = jj(kk)+sampinblock-1;
                    if tracetwo > numtraces
                        tracetwo = numtraces;
                        samptwo = sampinfile;
                    end
                    
                    trcdat(:,traceone:tracetwo) = reshape(...
                        uint24_2uint32(utrcdat(sampone:samptwo),obj.ByteOrder),...
                        obj.SamplesPerTrace, tracetwo-traceone+1 ...
                    );
                end
                
                if tracetwo < numtraces
                    traceone = tracetwo+1;
                    tracetwo = numtraces;
                    trcdat(:,traceone:tracetwo) = reshape(...
                        uint24_2uint32(utrcdat(samptwo+1:sampinfile),obj.ByteOrder),...
                        obj.SamplesPerTrace, tracetwo-traceone+1 ...
                        );
                end             
        end
        if(obj.Debug),fprintf(obj.LogFID,'@SegyTrace.readData: Finished data conversion\n'); end
    end
    
    function trcheadstruct = TraceHeader2struct(obj,trchead,numtraces)
        % trchead is a vector of tpye uint8
        % numtraces is the number of traces represented in trchead
        if ~ismatrix(trchead) || ~isa(trchead,'uint8')
            mm_errordlg ('Input trchead must be a matrix of type uint8','Error',obj.GUI)        
        end
        
        [~,~,e] = computer; %get computer endianness and compare to file endianness
        field_names = obj.HdrFieldNames;
        start_bytes = obj.HdrStartBytes;
        end_bytes = obj.HdrEndBytes;
        %    nbytes = endbyte-startbyte+1;
        data_types = obj.HdrDataTypes;
        
        if strcmpi(obj.ByteOrder,e)
            flipbytes = false;
        else
            flipbytes = true;
        end
        
        %convert trace header
        for jj = 1:length(obj.HdrDef)
            fieldname = field_names{jj};
            idx = start_bytes.(fieldname):end_bytes.(fieldname);
            if flipbytes, idx=flip(idx); end
            nbytes = end_bytes.(fieldname)-start_bytes.(fieldname)+1;
            datatype = data_types.(fieldname);
            %typecast with byteswapping
            %                 trcheadstruct.(fieldname) = typecast(reshape(trchead(endbyte:-1:startbyte,:),1,numtraces*nbytes),datatype);
            switch datatype
                case 'ieee64'
                    trcheadstruct.(fieldname) = typecast(reshape(trchead(idx,:),1,numtraces*nbytes),'double');
                case 'ieee32'
                    trcheadstruct.(fieldname) = typecast(reshape(trchead(idx,:),1,numtraces*nbytes),'single');
                case 'ibm32'
                    trcheadstruct.(fieldname) = ibm2single(typecast(reshape(trchead(idx,:),1,numtraces*nbytes),'uint32'));
                case 'int24'
                    trcheadstruct.(fieldname) = int24_2uint32(trchead(idx,:),e);
                case 'uint24'
                    trcheadstruct.(fieldname) = uint24_2uint32(trchead(idx,:),e);
                otherwise
                    trcheadstruct.(fieldname) = typecast(reshape(trchead(idx,:),1,numtraces*nbytes),datatype);
            end
        end
        
    end
    
    function trcheadstruct = readHeader(obj,trcrange)
        %what help?
        
        [startbyte,numtraces,skiptraces,fliptraces] = obj.analyzeTraceRange(trcrange);
        
        %fseek to start of first trace in block
        obj.fseek(startbyte,'bof');
        
        %fread entire block of trace headers only
        if(obj.Debug),fprintf(obj.LogFID,'@SegyTrace.readHeader: Starting header fread\n'); end
        trchead = obj.fread(...
            [obj.TOTHDRSIZE, numtraces], ...
            sprintf('%d*uint8',obj.TOTHDRSIZE), ...
            'uint8', ...
            obj.TraceSize-obj.TOTHDRSIZE +(skiptraces-1)*obj.TraceSize...
            );
        if(obj.Debug),fprintf(obj.LogFID,'@SegyTrace.readHeader: Finished header fread\n'); end
                
        if fliptraces
            %flip data if trace block should be in reverse order
            trchead = fliplr(trchead);
        end        
        
        %convert uint8 to trace header structure
        trcheadstruct = TraceHeader2struct(obj,trchead,numtraces);
        
        %remove header scalars
        trcheadstruct = obj.removeCoordinateScalars(trcheadstruct);
    end    

    function hw = readHeaderWord(obj,trcrange,whattoread)
        hw = readHeaderWordIgnoreScalars(obj,trcrange,whattoread);

        if obj.ApplyCoordScalars %remove coordinate scalars
            %Get header word scalar name that should be applied
            try
                hwsname = obj.HdrScalars.(whattoread);
            catch
                %most likely we're here because the header word does not need to have a scalar applied
                %disp(ex.message)
                return
            end

            sc = readHeaderWordIgnoreScalars(obj,trcrange,hwsname);
            ps_idx = sc > 0;
            ns_idx = sc < 0;

            hw=double(hw);
            sc=double(sc);

            hw(ps_idx) = hw(ps_idx).*sc(ps_idx); %multiply if scalar is positive
            hw(ns_idx) = hw(ns_idx)./abs(sc(ns_idx)); %divide if scalar is negative
        end
    end

    function hw=readHeaderWordIgnoreScalars(obj,trcrange,whattoread)

        %check to see if whattoread is a valid field
        if ~isfield(obj.HdrDataTypes,whattoread)
            mm_errordlg(['@SegyTrace: Header word ''' whattoread ...
                ''' not found in obj.HdrDef'],...
            'Error!',obj.GUI)
        end

        [startbyte,numtraces,skiptraces,fliptraces] = obj.analyzeTraceRange(trcrange);
        
        hwoffset = obj.HdrStartBytes.(whattoread)-1;
        hwsize = obj.HdrEndBytes.(whattoread)-obj.HdrStartBytes.(whattoread)+1;
        
        switch(obj.HdrDataTypes.(whattoread))
            case('int24')
                numtraces = numtraces*3;
                indatatype = '3*uint8';
                outdatatype = 'uint8';
            case('uint24')
                numtraces = numtraces*3;
                indatatype = '3*uint8';
                outdatatype = 'uint8';
            case('ibm32')
                indatatype = 'uint32';
                outdatatype = 'uint32';
            case('ieee32')
                indatatype = 'single';
                outdatatype = 'single';
            case('ieee64')
                indatatype = 'double';
                outdatatype = 'double';
            otherwise
                indatatype = obj.HdrDataTypes.(whattoread);
                outdatatype = indatatype;
        end
        
        obj.fseek(startbyte+hwoffset,'bof')
        hw = obj.fread(...
            numtraces,...
            indatatype,...
            outdatatype,...
            skiptraces*obj.TraceSize-hwsize...
            );
        
        switch(obj.HdrDataTypes.(whattoread))
            case('ibm32') %IBM float
                hw = ibm2single(hw);
            case('int24')
                hw = int24_2int32(hw,obj.ByteOrder);  
            case('uint24')
                hw = uint24_2uint32(hw,obj.ByteOrder);                
        end
        
        if fliptraces
            %flip data if trace block should be in reverse order
            hw = flip(hw);
        end
    end

    function th = newHeader(obj,ntrace,nsamp,sampint)
        narginchk(1,4)
        
        if nargin<4
            sampint = [];
        end
        if nargin<3
            nsamp = [];
        end
        if nargin<2
            ntrace = [];
        end
        
        %number of traces in file
        if isempty(ntrace)
            if obj.TracesInFile < 1
                ntrace=1;
            else
                ntrace=obj.TracesInFile;
            end
        end
        if isempty(nsamp)
            if obj.SamplesPerTrace < 1
                nsamp=1;
            else
                nsamp=obj.SamplesPerTrace;
            end
        end           
        if isempty(sampint)
            sampint = obj.SampleInterval; %microseconds
        end
        if isempty(obj.SegyRevision)
            obj.SegyRevision = 1;
        end                   

        if isempty(obj.HdrDef)
            obj.HdrDef = obj.newDefinition(obj.SegyRevision);
            
        end      
    
        for ii = 1:length(obj.HdrDef)
            th.(obj.HdrDef{ii,1}) = obj.newHeaderWord(ntrace,obj.HdrDef{ii,2});
        end
        
        hw = obj.byte2word(115); %Samples this trace; stored in byte 115; SEG-Y standard
        th.(hw)(:) = nsamp; %number of samples
        hw = obj.byte2word(117); %Sample rate this trace; stored in byte 117; SEG-Y standard
        th.(hw)(:) = sampint; %microseconds
        
        if obj.SegyRevision >1
            hw = obj.byte2word(377); %Extended samples this trace; stored in byte 377; SEG-Y rev 2 standard
            th.(hw)(:) = nsamp; %number of samples
            hw = obj.byte2word(384); %Extended sample rate this trace; stored in byte 384; SEG-Y rev 2 standard
            th.(hw)(:) = sampint; %microseconds
            hw = obj.byte2word(472); %Txt Header name
            th.(hw)(:) = typecast(uint8('SEG00001'),'uint64');
        end
    end

    function td = newData(obj,ntrace,nsamp)
        if isempty(ntrace)
            ntrace=1;
        end
        if isempty(nsamp)
            if isequal(obj.SamplesPerTrace,0)
                nsamp = 1;
            else
                nsamp = obj.SamplesPerTrace;
            end
        end
        if isempty(obj.SegyRevision)
            obj.SegyRevision = 1;
        end
        
        if isempty(obj.FormatCode)
            obj.FormatCode = 5; %IEEE floating point
        end

        fct = obj.FormatCodeType; %Depends on obj.FormatCode
        if isequal(fct,'ibm32')
            fct = 'single';
        elseif isequal(fct,'ieee32')
            fct = 'single';
        elseif isequal(fct,'ieee64')
            fct = 'double';
        elseif isequal(fct,'int24')
            fct = 'int32';
        elseif isequal(fct,'uint24')
            fct = 'uint32';
        end

        td = zeros(nsamp,ntrace,fct);
    end

end %end methods (Hidden)

methods (Static)
    %td = newDefinition(segyrev,numexthdrs);
    hw = newHeaderWord(ntrace,datatype);
    [d,f,t] = struct2double(s);
    s = double2struct(d,f,t);        
end % end static methods


end %end classdef