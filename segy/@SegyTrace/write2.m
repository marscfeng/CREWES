function write2(obj,trchdr,trcdat)

%read last trace in file
if obj.TracesInFile == 0
    prevtrace = 0;
else
    prevtrace = double(obj.read(obj.TracesInFile,obj.byte2word(5)));
end

[~,ntrc] = size(trcdat);
trchdr.(obj.byte2word(5)) = prevtrace+(1:ntrc);

%prepare trace header
trchdr = struct2uint8(obj, trchdr);

switch(obj.FormatCode)
    case 1 %IBM float
        fudgefactor = 40;
        trcperblock = ceil(crmemfree/fudgefactor/obj.TraceSize);
%         [~,ntrc] = size(trcdat);
        for ii = 1:trcperblock:ntrc+trcperblock-1 %for each block of traces
            traceone = ii;
            tracetwo = ii+trcperblock-1;
            if tracetwo > ntrc
                tracetwo = ntrc;
            end
            %             tdat = prepdata(obj,single2ibm(trcdat(:,traceone:tracetwo)),obj.FormatCodeType);
            obj.fwrite([trchdr(:,traceone:tracetwo); prepdata(obj,single2ibm(trcdat(:,traceone:tracetwo)),obj.FormatCodeType)],'uint8');
        end
    case 7 %int24
        fudgefactor = 40;
        trcperblock = ceil(crmemfree/fudgefactor/obj.TraceSize);
%         [~,ntrc] = size(trcdat);
        for ii = 1:trcperblock:ntrc+trcperblock-1 %for each block of traces
            traceone = ii;
            tracetwo = ii+trcperblock-1;
            if tracetwo > ntrc
                tracetwo = ntrc;
            end
            [m,n] = size(trcdat(:,traceone:tracetwo));
            obj.fwrite([trchdr(:,traceone:tracetwo); reshape(num2int24(reshape(trcdat(:,traceone:tracetwo),1,m*n),obj.ByteOrder),m*3,n)],'uint8');
        end
    case 15 %uint24
        fudgefactor = 40;
        trcperblock = ceil(crmemfree/fudgefactor/obj.TraceSize);
%         [~,ntrc] = size(trcdat);
        for ii = 1:trcperblock:ntrc+trcperblock-1 %for each block of traces
            traceone = ii;
            tracetwo = ii+trcperblock-1;
            if tracetwo > ntrc
                tracetwo = ntrc;
            end
            [m,n] = size(trcdat(:,traceone:tracetwo));
            obj.fwrite([trchdr(:,traceone:tracetwo); reshape(num2uint24(reshape(trcdat(:,traceone:tracetwo),1,m*n),obj.ByteOrder),m*3,n)],'uint8');
        end
    otherwise %all other data formats
%         obj.ftell
        obj.fwrite([trchdr; prepdata(obj,trcdat,obj.FormatCodeType)],'uint8');
%         obj.ftell
end

end %end function write2

function d = prepdata(obj,d,dtype)

[nsamp,ntrc] = size(d);
d = reshape(d,1,nsamp*ntrc);

%convert incoming data to dtype
if ~isa(d,dtype)
    eval(sprintf('d = %s(d);',dtype)); %eg. d = uint32(d)
end

%byteswap if necessary
[~,~,e] = computer;
if ~strcmpi(e,obj.ByteOrder) && (~strcmp(dtype,'int8') || ~strcmp(dtype,'uint8'))
    d = swapbytes(d);
end

d = reshape(typecast(d,'uint8'),nsamp*obj.BytesPerSample,ntrc);

end

function trchead = struct2uint8(obj,trcheadstruct)
% trchead is a vector of tpye uint8
% numtraces is the number of traces represented in trchead
if ~isstruct(trcheadstruct)
    mm_errordlg ('Input trchead must be a struct','Error',obj.GUI)
end

%preallocate trchead
ntrace = length(trcheadstruct.(obj.HdrFieldNames{1,1}));
trchead = zeros(obj.TOTHDRSIZE,ntrace,'uint8');

[~,~,e] = computer; %get computer endianness and compare to file endianness
bswap = ~strcmpi(obj.ByteOrder,e);

field_names = obj.HdrFieldNames; %NOTE: fieldnames is a matlab built-in function
start_bytes = obj.HdrStartBytes;
end_bytes = obj.HdrEndBytes;
data_types = obj.HdrDataTypes;
    
%convert trace header
for jj = 1:length(obj.HdrDef)
    fieldname = field_names{jj};
    startbyte = start_bytes.(fieldname);
    endbyte = end_bytes.(fieldname);
    nbytes = endbyte-startbyte+1;
    datatype = data_types.(fieldname);

    switch datatype
        case 'ibm32'
            trcheadstruct.(fieldname) = double2ibm(trcheadstruct.(fieldname));
            datatype = 'uint32';
        case 'ieee32'
            datatype = 'single';
        case 'ieee64'
            datatype = 'double';            
    end
    
    if ~isa(trcheadstruct.(fieldname),datatype)
        eval(sprintf('trcheadstruct.(''%s'') = %s(trcheadstruct.(''%s''));',fieldname,datatype,fieldname));
    end

    if bswap
    trchead(startbyte:endbyte,:) = ...
        flipud(reshape(typecast(trcheadstruct.(fieldname),'uint8'),nbytes,ntrace));        
    else
    trchead(startbyte:endbyte,:) = ...
        reshape(typecast(trcheadstruct.(fieldname),'uint8'),nbytes,ntrace);
    end
end

end %end function

