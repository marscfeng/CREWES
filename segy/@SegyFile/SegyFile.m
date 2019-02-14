classdef SegyFile < File
%function sf = SegyFile(filename,permission,segyrevision,sampint,nsamp,...
%                       fmtcode,txtfmt,byteorder,bindef,trcdef,gui)
% Optional Inputs ([] is accepted):
% filename   - SEG-Y disk file name
% permission   - 'r' (default), 'w', or 'a' (see help fopen)
% segyrevision - segy revision (0,1,2); Overrides SEG-Y Binary File Header on
%                disk.
% sampint      - Sample interval in (s); Overrides SEG-Y Binary File Header on
%                disk.
% nsamp        - Samples per trace; Overrides SEG-Y Binary File Header on
%                disk.
% fmtcode      - SEG-Y trace data format code. eg. 1 = IBM float, 5 = IEEE
%                float
% txtfmt       - Text format, 'ascii' or 'ebcdic'
% byteorder    - byte order of disk file 'l'=little-endian, 'b'=big-endian
% bindef       - 4 column binary header definition cell array such as provided by
%                @BinaryHeader/new; See uiSegyDefinition().
%                NOTE! writesegy will require the same bindef unless you
%                modify binhdr!
% trcdef       - 5 column trace header definition cell array such as provided by
%                @BinaryHeader/new; See uiSegyDefinition()
%                NOTE! writesegy will require the same trcdef unless you
%                modify trchdr!
% gui          - 0 (no progress bar), 1 (text progress bar), 
%                [] (default; gui progress bar and warnings), figure handle 
%                (same as [], but an attempt is made to center GUI popups on 
%                the figure represented by the figure handle)
% Outputs:
% sf           - A SEG-Y file object
%
% Example:
%   s=SegyFile('file.sgy','r')
%   s.TextHeader.read
%   s.BinaryHeader.read
%   s.Trace.read(1:2:100)
%
% See also uiSegyFile
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

properties
    TextHeader;         %Contains SegyTextHeader object
    BinaryHeader;       %Contains BinaryHeader object
    ExtendedTextHeader; %Contains SegyExtendedTextHeader object
    Trace;              %Contains SegyTrace object    
    SegyRevision=1;       %Segy revision number: 0, 1 (default), 2    
    TextFormat='ascii';   %Text format: 'ascii' or 'ebcdic'
    FormatCode=5;         %Data sample format code: 1,2,3,5,6,7,8,9,10,11,12,15,16
    SamplesPerTrace=1;    %Number of data samples per trace
    SampleInterval=1000;  %Sample interval in microseconds
    NumExtTxtHdrs=0;      %Number of extended textual file headers (rev 1)
    NumExtTrcHdrs=0;      %Number of extended trace headers (rev 2)
    NumDataTrailers=0;    %Number of trace data trailers (rev 2)
end % end properties

events
    SegyRevisionChanged;%Notifies listeners that the SegyRevision has changed
    TextFormatChanged;%Notifies listeners that the TextFormat has changed
    FormatCodeChanged;%Notifies listeners that the FormatCode has changed
    SamplesPerTraceChanged;%Notifies listeners that the SamplesPerTrace has changed
    SampleIntervalChanged;%Notifies listeners that the SampleInterval has changed
    NumExtTxtHdrsChanged;%Number of extended textual file headers (rev 1) has changed
    NumExtTrcHdrsChanged;%Number of extended trace headers (rev 2) has changed
    NumDataTrailersChanged;%Number of trace data trailers (rev 2) has changed   
end
    
methods
    %Constructor
    function obj = SegyFile(varargin)
        %1.filename,2.permission,3.segyrevision,4.sampint,5.nsamp,...
        %6.fmtcode,7.txtfmt,8.byteorder,9.bindef,10.trcdef,11.gui
        narginchk(0,11);
        
        if nargin < 1
            filename = [];
        else
            filename = varargin{1};
        end

        if nargin < 2
            permission=[];
        else
            permission = varargin{2};
        end
        
        %Doctor file permission so we can read info as well as write
        if strcmp(permission,'w')
            permission = 'w+';
            if ~isempty(filename)
                %add .sgy filename extension if it does not already exist
                f = fliplr(filename);
                if ~(strncmpi (f,'yges.',5) || strncmpi (f,'ygs.',4))
                    filename = [filename '.sgy'];
                end
            end
        elseif strcmp(permission,'a')
            permission = 'a+';
        end
                    
        if nargin < 3 %segyrevision
            segyrevision = []; %pass the buck to SegyBinaryHeader
        else
            segyrevision = varargin{3};
        end
        if nargin < 4 % sampint
            sampint = [];
        else
            sampint = varargin{4}*1e6; %convert to microseconds
        end 
        if nargin < 5 % nsamps
            nsamp = [];
        else
            nsamp=varargin{5};
        end    
        
        if nargin < 6 %fmtcode
            fmtcode = [];
        else
            fmtcode=varargin{6};
        end
        if nargin < 7 %txtfmt
            txtfmt = [];
        else
            txtfmt=varargin{7};
        end

        if nargin < 8 %byteorder
            byteorder = [];
        else
            byteorder=varargin{8};
        end
        if nargin < 9 %bindef
            bindef = [];
        else
            bindef=varargin{9};
        end
        if nargin < 10 %trcdef
            trcdef = [];
        else
            trcdef=varargin{10};
        end
        if nargin < 11 %gui
            gui = 1;
        else
            gui = varargin{11};
        end       
        
        %1.filename,2.permission,3.segyrevision,4.sampint,5.nsamp,...
        %6.fmtcode,7.txtfmt,8.byteorder,9.bindef,10.trcdef,11.gui

        %Call superclass @File constructor
%         disp('SegyFile: calling superclass constructor');
        obj = obj@File(filename,permission,byteorder,gui);
        
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.SegyFile: Start of constructor\n');end

        %% Create binary file header object
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.SegyFile: Creating BinaryHeader\n');end
        obj.BinaryHeader = SegyBinaryHeader(obj.FileID,obj.Permission,...
            byteorder,segyrevision,gui);

        if ~strncmpi(obj.Permission,'w',1)
            %Need to manually trigger the byteorder listener, because
            %SegyBinaryHeader can't call freopen without a filename
            %This only needs to happen if we are reading an existing file            
            obj.ByteOrder = obj.BinaryHeader.ByteOrder;
        end

        %Override binary header definition
        if ~isempty(bindef)
            obj.BinaryHeader.HdrDef = bindef;
        end

        %Update data format code
        if isempty(fmtcode)
            obj.FormatCode = obj.BinaryHeader.FormatCode;
        else %override files data format code
            obj.FormatCode = fmtcode;
            obj.BinaryHeader.FormatCode = fmtcode;
        end
        
        if ~isempty(nsamp)
            obj.BinaryHeader.SamplesPerTrace = nsamp;
            obj.SamplesPerTrace = nsamp;
        end
        
        if ~isempty(sampint)
            obj.BinaryHeader.SampleInterval = sampint;
            obj.SampleInterval = sampint;
        end
        
        %Update
        %Sync info from BinaryHeader to SegyFile;
        obj.SegyRevision = obj.BinaryHeader.SegyRevision;
        obj.NumExtTxtHdrs = obj.BinaryHeader.NumExtTxtHdrs;
        obj.NumExtTrcHdrs = obj.BinaryHeader.NumExtTrcHdrs;
        obj.NumDataTrailers = obj.BinaryHeader.NumDataTrailers;
        
        %% Create text file header object
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.SegyFile: Creating TextHeader object\n');end
        obj.TextHeader = SegyTextHeader(obj.FileID,obj.Permission,...
            obj.ByteOrder,obj.SegyRevision,obj.GUI);
        
        %Override guessed Text file header format
        if ~isempty(txtfmt)
            obj.TextHeader.TextFormat=txtfmt;
            obj.TextFormat=txtfmt;
        end
        
        %% Create extended text file header object
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.SegyFile: Creating ExtendedTextHeader object\n');end
        obj.ExtendedTextHeader = SegyExtendedTextHeader(obj.FileID,obj.Permission,...
            obj.ByteOrder,obj.SegyRevision,obj.NumExtTxtHdrs,obj.GUI);
        
        %Override guessed Text file header format        
        if ~isempty(txtfmt)
            obj.ExtendedTextHeader.TextFormat=txtfmt;
        end        
  
        %% Create trace object
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.SegyFile: Creating Trace object\n');end        
        obj.Trace = SegyTrace(obj.FileID,obj.Permission,...
            fmtcode,obj.ByteOrder,obj.SegyRevision,obj.GUI);
        
        %Override trace header definition
        if~isempty(trcdef)
            obj.Trace.HdrDef=trcdef;
        end
        
        %Override nsamp
        if ~isempty(nsamp)
            obj.Trace.SamplesPerTrace=nsamp;
        end
                        
        %Override sampint
        if ~isempty(sampint)
            obj.SampleInterval=sampint;
            obj.BinaryHeader.SampleInterval=sampint;
            obj.Trace.SampleInterval=sampint;
        end 
        
        %Add Listeners
        addlistener(obj,'FileNameChanged',@obj.listenFileName);
        addlistener(obj,'ByteOrderChanged',@obj.listenByteOrder);
        addlistener(obj,'PermissionChanged',@obj.listenPermission);
        addlistener(obj,'SegyRevisionChanged',@obj.listenSegyRevision);
        addlistener(obj,'TextFormatChanged',@obj.listenTextFormat);
        addlistener(obj,'FormatCodeChanged',@obj.listenFormatCode);
        addlistener(obj,'SamplesPerTraceChanged',@obj.listenSamplesPerTrace);
        addlistener(obj,'SampleIntervalChanged',@obj.listenSampleInterval);
        addlistener(obj,'NumExtTxtHdrsChanged',@obj.listenNumExtTxtHdrs);
        addlistener(obj,'NumExtTrcHdrsChanged',@obj.listenNumExtTrcHdrs);
        addlistener(obj,'NumDataTrailersChanged',@obj.listenNumDataTrailers);
        addlistener(obj,'DebugChanged',@obj.listenDebug);
        addlistener(obj,'GUIchanged',@obj.listenGUI);
        addlistener(obj,'LogFIDchanged',@obj.listenLogFID);
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.SegyFile: End of constructor\n');end
    end
    
    %Set property functions
    function set.TextHeader(obj, v)
        if isa(v,'SegyTextHeader')
            obj.TextHeader = v;
        else
            error('@SegyFile: TextHeader must be a SegyTextHeader object')
        end
    end
    
    function set.BinaryHeader(obj, v)
        if isa(v,'SegyBinaryHeader')
            obj.BinaryHeader = v;
        else
            error('@SegyFile: BinaryHeader must be a SegyBinaryHeader object')
        end
    end
    
    function set.ExtendedTextHeader(obj, v)
        if isa(v,'SegyExtendedTextHeader')
            obj.ExtendedTextHeader = v;
        else
            error('@SegyFile: ExtendedTextHeader must be a SegyExtendedTextHeader object')
        end
    end
    
    function set.Trace(obj, v)
        if isa(v,'SegyTrace')
            obj.Trace = v;
        else
            error('@SegyFile: Trace must be a SegyTrace object')
        end
    end         

    %Set over-ride property functions
    %SegyRevision;       %Segy revision number: 0, 1 (default), 2
    function set.SegyRevision(obj, v)
        if isempty(v) || (isscalar(v) && isnumeric(v) && v>-1 && v<3)
            obj.SegyRevision = v;
            notify(obj,'SegyRevisionChanged');
        else
            error('@SegyFile: SegyRevision must be numeric, scalar and = 0, 1, or 2')
        end
    end
    
    %TextFormat;         %Text format: 'ascii' or 'ebcdic'
    function set.TextFormat(obj, v)
        if ischar(v)
            obj.TextFormat = v;
            notify(obj,'TextFormatChanged');
        else
            error('@SegyFile: TextFormat must be char')
        end
    end
    
    %FormatCode;         %Data sample format code: 1,2,3,5,6,7,8,9,10,11,12,15,16
    function set.FormatCode(obj, v)
        if isempty(v) || (isscalar(v) && isnumeric(v) && v>0 && v<17)
            obj.FormatCode = v;
            notify(obj,'FormatCodeChanged');
        else
            error('@SegyFile: FormatCode must be numeric, scalar and between 1 and 16')
        end
    end
    
    %SamplesPerTrace;    %Number of data samples per trace
    function set.SamplesPerTrace(obj, v)
        if isscalar(v) && isnumeric(v) && v>0
            obj.SamplesPerTrace = v;
            notify(obj,'SamplesPerTraceChanged');
        else
            error('@SegyFile: SamplesPerTrace must be numeric, scalar and positive')
        end
    end
    
    %SampleInterval;    %Sample interval in microseconds
    function set.SampleInterval(obj, v)
        if isscalar(v) && isnumeric(v) && v>=0
            obj.SampleInterval = v;
            notify(obj,'SampleIntervalChanged');
        else
            error('@SegyFile: SamplesInterval must be numeric, scalar and positive')
        end
    end
    
    function set.NumExtTxtHdrs(obj, v) %Number of extended textual file headers (rev 1)
        if isscalar(v) && isnumeric(v) && v>-2
            obj.NumExtTxtHdrs = v;
            notify(obj,'NumExtTxtHdrsChanged');
        else
            error('@SegyFile: NumExtTxtHdrs must be numeric, scalar and greater than -1')
        end        
    end
    
    function set.NumExtTrcHdrs(obj, v) %Number of extended trace headers (rev 2)
         if isscalar(v) && isnumeric(v) && v>-1
            obj.NumExtTrcHdrs = v;
            notify(obj,'NumExtTrcHdrsChanged');
        else
            error('@SegyFile: NumExtTrcHdrs must be numeric, scalar and positive')
        end       
    end
    
    function set.NumDataTrailers(obj, v) %Number of trace data trailers (rev 2)    
         if isscalar(v) && isnumeric(v) && v>-1
            obj.NumDataTrailers = v;
            notify(obj,'NumDataTrailersChanged');
        else
            error('@SegyFile: NumDataTrailers must be numeric, scalar and positive')
        end        
    end
    
    %Listeners
    function obj = listenFileName(obj, varargin)
        % FileName has changed, fopen file for file operations
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenFileName\n'); end
        if ~isempty(obj.FileName)
             obj.fclose();
        end
    end
    
    function obj = listenByteOrder(obj, varargin)
        % ByteOrder has changed, freopen file for file operations
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenByteOrder\n'); end
        if ~isempty(obj.FileName)
             obj.freopen();
             %ByteOrder changes in constructor, header and trace objects
             %may not exist yet
             if ~isempty(obj.TextHeader)
                obj.TextHeader.FileID = obj.FileID;
                obj.TextHeader.ByteOrder = obj.ByteOrder;
             end
             if ~isempty(obj.BinaryHeader)
                 obj.BinaryHeader.FileID = obj.FileID;
                 obj.BinaryHeader.ByteOrder = obj.ByteOrder;
                 
                 if obj.fsize >= obj.BinaryHeader.HDRSIZE +obj.BinaryHeader.OFFSET
                     if isempty(obj.BinaryHeader.SegyRevision)
                         obj.BinaryHeader.SegyRevision = obj.BinaryHeader.readSegyRevision();
                     end
                     
                     obj.BinaryHeader.FormatCode = obj.BinaryHeader.readFormatCode();
                     obj.BinaryHeader.SamplesPerTrace = obj.BinaryHeader.readSamplesPerTrace();
                     obj.BinaryHeader.SampleInterval = obj.BinaryHeader.readSampleInterval();
                 end
             end
             if ~isempty(obj.ExtendedTextHeader)
                 obj.ExtendedTextHeader.FileID = obj.FileID;
                 obj.ExtendedTextHeader.ByteOrder = obj.ByteOrder;
             end
             if ~isempty(obj.Trace)
                 obj.Trace.FileID = obj.FileID;
                 obj.Trace.ByteOrder = obj.ByteOrder;
             end
        end
    end
    
    function obj = listenPermission(obj, varargin)
        % Permission has changed, freopen file for file operations
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenPermission\n'); end
        if ~isempty(obj.FileName)
            obj.freopen();
            obj.TextHeader.FileID = obj.FileID;
            obj.BinaryHeader.FileID = obj.FileID;
            obj.ExtendedTextHeader.FileID = obj.FileID; 
            obj.Trace.FileID = obj.FileID;
        end
        obj.TextHeader.Permission = obj.Permission;
        obj.BinaryHeader.Permission = obj.Permission;
        obj.ExtendedTextHeader.Permission = obj.Permission;
        obj.Trace.Permission = obj.Permission;
    end

    function obj = listenSegyRevision(obj, varargin)
        % SegyRevision has changed, update header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenSegyRevision\n'); end
        obj.TextHeader.SegyRevision = obj.SegyRevision;
        obj.BinaryHeader.SegyRevision = obj.SegyRevision;
        obj.ExtendedTextHeader.SegyRevision = obj.SegyRevision;
        obj.Trace.SegyRevision = obj.SegyRevision;
    end

    function obj = listenTextFormat(obj, varargin)
        % TextFormat has changed, update text header objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenTextFormat\n'); end
        obj.TextHeader.TextFormat = obj.TextFormat;
        obj.ExtendedTextHeader.TextFormat = obj.TextFormat; 
    end
    
    function obj = listenFormatCode(obj, varargin)
        % FormatCode has changed, update binary header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenFormatCode\n'); end
        obj.BinaryHeader.FormatCode = obj.FormatCode;
        obj.Trace.FormatCode = obj.FormatCode;            
    end

    function obj = listenSamplesPerTrace(obj, varargin)
        % SamplesPerTrace has changed, update binary header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenSamplesPerTrace\n'); end		
        obj.BinaryHeader.SamplesPerTrace = obj.SamplesPerTrace;
        obj.Trace.SamplesPerTrace = obj.SamplesPerTrace;               
    end
    
    function obj = listenSampleInterval(obj, varargin)
        % Sample Interval has changed, update binary header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenSampleInterval\n'); end				
        obj.BinaryHeader.SampleInterval = obj.SampleInterval;
        obj.Trace.SampleInterval = obj.SampleInterval;
    end

    function obj = listenNumExtTxtHdrs(obj, varargin)
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenNumExtTextHdrs\n'); end				
        obj.BinaryHeader.NumExtTxtHdrs = obj.NumExtTxtHdrs;
        obj.ExtendedTextHeader.NumExtTxtHdrs = obj.NumExtTxtHdrs;      
    end
    
    function obj = listenNumExtTrcHdrs(obj, varargin)
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenNumExtTrcHdrs\n'); end				
        obj.BinaryHeader.NumExtTrcHdrs = obj.NumExtTrcHdrs;
        obj.Trace.NumExtTrcHdrs = obj.NumExtTrcHdrs;     
    end
    
    function obj = listenNumDataTrailers(obj, varargin)
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenNumDataTrailers\n'); end				
        obj.BinaryHeader.NumDataTrailers = obj.NumDataTrailers;
        obj.Trace.NumDataTrailers = obj.NumDataTrailers;     
    end
    
    function obj = listenDebug(obj, varargin)
        % Debug has changed, update header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenDebug\n'); end				
        obj.TextHeader.Debug = obj.Debug;
        obj.BinaryHeader.Debug = obj.Debug;
        obj.ExtendedTextHeader.Debug = obj.Debug;
        obj.Trace.Debug = obj.Debug;
    end    
    
    function obj = listenGUI(obj, varargin)
        % GUI has changed, update header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenGUI\n'); end				
        obj.TextHeader.GUI = obj.GUI;
        obj.BinaryHeader.GUI = obj.GUI;
        obj.ExtendedTextHeader.GUI = obj.GUI;
        obj.Trace.GUI = obj.GUI;
    end

    function obj = listenLogFID(obj, varargin)
        % GUI has changed, update header and trace objects
        if(obj.Debug),fprintf(obj.LogFID,'@SegyFile.listenLogFID\n'); end				
        obj.TextHeader.LogFID = obj.LogFID;
        obj.BinaryHeader.LogFID = obj.LogFID;
        obj.ExtendedTextHeader.LogFID = obj.LogFID;
        obj.Trace.LogFID = obj.LogFID;
    end    
end % end methods

end % end classdef