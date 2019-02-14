%% Example 0.0: Set input and output filenames
disp('*** Example 0.0: Set input and output filenames ***')
%Segy Revision number is 1 by default
%File Permission is 'r' by default
insgyfile = '1042.sgy'; %SEG-Y filename to read from disk
outsgyfile = 'newsegyfile.sgy'; %SEG-Y filename to write to disk

%TextHeader
%% Example 1.2: Create new textual file header
disp('*** Example 1.2: Create new textual file header ***')
thdr = SegyTextHeader; %Create a new SegyTextHeader object
txthdr=thdr.new; %Create a new SegyRevision 1 (default) textual file header
thdr.SegyRevision = 0; %Update SegyRevision
txthdr=thdr.new; %Create a new SegyRevision 0 textual file header
thdr.SegyRevision = 2; %Update SegyRevision
txthdr=thdr.new; %Create a new SegyRevision 2 textual file header

%% Example 1.4: Read textual file header from disk
disp('*** Example 1.4: Read textual file header ***')
thdr = SegyTextHeader(insgyfile); %Create a new SegyTextHeader object, TextFormat is guessed from file
txthdr = thdr.read; %Read textual file header from disk
thdr.TextFormat = 'ascii'; %Update TextFormat
txthdr = thdr.read; %Read textual file header from disk
thdr.TextFormat = 'ebcdic'; %Update TextFormat
txthdr = thdr.read; %Read textual file header from disk

%% Example 1.5: Write textual file header
disp('*** Example 1.5: Write textual file header ***')
thdr = SegyTextHeader(outsgyfile,'w'); %Create a new SegyTextHeader object with write permission
thdr.write(thdr.new); %Create and write a new textual file header to disk
thdr.Permission = 'r'; %Update Permission
txthdr = thdr.read; %Read textual file header from disk
if isequal(thdr.new,txthdr)
    disp('PASSED')
else
    disp('FAILED')
end

%% Binary Header
%% Example 2.0: Get binary header definition information
disp('*** Example 2.0: Get binary header definition information ***')
bhdr = SegyBinaryHeader; %Create a new SegyBinaryHeader object
bhdr.SegyRevision = 2; %Update SeGYRevision
bhdr.HdrDef; %Display current header definition cell array
[hwname, byteloc, idx] = bhdr.byte2word(20); %Return information about header word closest to byte 20
bhdr.HdrDef(idx,:); %Display header word definition for row number idx

%% Example 2.1: Create a new binary header definition
disp('*** Example 2.1: Create new binary header definition ***')
bhdr = SegyBinaryHeader; %Create a new SegyBinaryHeader object
bindef = bhdr.newDefinition; %Create a new SegyRevision=1 (default) header definition
bindef = bhdr.newDefinition(0); %Create a new SegyRevision 0 header definition
bindef{50,1} = 'NewField'; %Update header word name for row 50 of the definition
bhdr.HdrDef = bindef; %Update object's header definition
bhdr.HdrDef(50,:); %Display row 50 of object's definition

%% Example 2.2: Create a new binary header
disp('*** Example 2.2: Create new binary header ***')
bhdr = SegyBinaryHeader; %Create a new SegyBinaryHeader object
binhdr = bhdr.new; %Create a new binary header struct, using object defaults
bhdr.SamplesPerTrace = 500; %Override number of samples per trace
bhdr.SampleInterval = 1000; %Override sample interval
[binhdr,bindef] = bhdr.new; %Create a new binary file header struct and header definition

%% Example 2.4: Read binary file header
disp('*** Example 2.4: Read binary file header ***')
bhdr = SegyBinaryHeader(insgyfile); %Create a new SegyBinaryHeader object, ByteOrder is guessed from file
binhdr = bhdr.read; %Read binary file header from disk
bhdr.ByteOrder = 'l'; %Update ByteOrder: 'l' is little-endian
binhdr = bhdr.read; %Read binary file header from disk 
bhdr.ByteOrder = 'b'; %Update ByteOrder: 'b' is big-endian (SEG_Y revision 0 and 1 standard)
binhdr = bhdr.read; %Read binary file header from disk 

%% Example 2.5: Write binary file header to disk
disp('*** Example 2.5: Write binary file header to disk ***')
thdr = SegyTextHeader(outsgyfile,'w'); %Create a new SegyTextHeader object with write permission
thdr.write(thdr.new); %Create a new text header and write it to disk
bhdr = SegyBinaryHeader(outsgyfile,'a'); %Create a new SegyBinaryHeader object with append permission
nsamp = 10; %Samples per trace
sampint = 1000; %Sample interval in microseconds
bhdr.write(bhdr.new(nsamp,sampint)); %Write a new binary file header to disk, override bhdr.SamplesPerTrace and bhdr.SampleInterval
bhdr.Permission = 'r'; %Update Permission
bhdr.read; %Read binary file header from disk

%% Extended textual file headers (SEG-Y revision 1+)
%% Example 3.2: Create
%% Example 3.4: Read
%% Example 3.5: Write

%% Trace
%% Example 4.0: Get trace header definition information
disp('*** Example 4.0: Get trace header definition information ***')
trc = SegyTrace; %Create a new SegyTrace object
trc.HdrDef; %Display the current trace header definition cell array
[hwname, byteloc, idx] = trc.byte2word(20); %Get info about header word closest to byte 20
trc.word2byte('EnsembleNum'); %Get byte number for a given header word name
trc.HdrDef(idx,:); %Display header word definition for row number idx

%% Example 4.1: Create new trace header definition cell array
disp('*** Example 4.1: Create new trace header definition ***')
trc = SegyTrace; %Create a new SegyTrace object
trc.HdrDef{80,1} = 'NewField'; %Update field name for row 80 of the definition
% trc.HdrDef(80,:) %Display row 80 of HdrDef
trcdef = trc.newDefinition(0); %Create a new SegyRevision 0 header definition
trcdef = trc.newDefinition(2); %Create a new SegyRrevision 2 header definition
%Modify trcdef manually or by using uiSegyDefinition (not shown)
trc.HdrDef = trcdef; %Override object's header definition

%% Example 4.2: Create new trace header struct, data array and definition
disp('*** Example 4.2: Create new trace header struct, data array and definition ***')
trc = SegyTrace; %Create a new SegyTrace object
trcdef = trc.newDefinition(); %Return a new trace header definition
ntrace=10;
[trchdr, trcdat, trcdef] = trc.new(ntrace, nsamp, sampint); %Return new trace header, trace data and trace definition
trc.SegyRevision = 0; %Update SegyRevision
trcdef = trc.newDefinition(); %Create a new SegyRevision 0 trace header definition 
[trchdr, trcdat, trcdef] = trc.new (ntrace, nsamp, sampint); %Return new trace header, trace data and trace definition
trc.SegyRevision = 2; %Update SegyRevision
trc.NumExtTrcHdrs = 1; %Allow for one extended trace header per trace
trcdef = trc.newDefinition(); %Create a new SegyRevision 2 trace header definition
nsamp = double(intmax('uint16'))+1;
sampint = double(intmax('uint16'))+1;
[trchdr, trcdat, trcdef] = trc.new (ntrace, nsamp, sampint); %Return new trace header, trace data and trace definition

%% Example 4.3: Convert between trace header struct and array of doubles
disp('*** Example 4.3: Convert between trace header struct and array of doubles ***')
[hdrvals,fieldnames,datatypes] = trc.struct2double(trchdr); %Convert trace header struct to array of doubles
trchdr = trc.double2struct(hdrvals,fieldnames,datatypes); %Convert array of doubles to a trace header struct

%% Example 4.4: Read trace headers and data
disp('*** Example 4.4: Read trace headers and data ***')
trc = SegyTrace(insgyfile); %Create a new SegyTrace object
[trchdr,trcdat,trcdef] = trc.read; %Read all trace headers and trace data and return trace definition used
[trchdr,trchdr,trcdef] = trc.read(10:20); %Read traces 10-20
[trchdr,trchdr,trcdef] = trc.read(20:-1:10); %Read traces 10-20 in reverse order
[trchdr,trchdr,trcdef] = trc.read([1,5,8]); %Read traces 1, 5 and 8
trchdr = trc.read([1,5,8],'headers'); %Read trace headers only
trcdat = trc.read([1,5,8],'data'); %Read trace data only
tnl = trc.read(1:100,'TrcNumLine'); %Read header word TrcNumLine from traces 1-100
trc.SegyRevision = 1; %Update SegyRevision
trc.ByteOrder = 'b'; %Update ByteOrder
trc.SamplesPerTrace = 1001; %Update SamplesPerTrace
[trchdr,trcdat] = trc.read; %Read all trace headers and trace data and return trace definition used
%NOTE, SegyRevision, ByteOrder and SamplesPerTrace are incorrect for 1042.sgy, trchdr and trcdat read by the previous line will be garbage!

%% Example 4.5: Write trace headers and data to disk
disp('*** Example 4.5: Write trace headers and data to disk ***')
nsamp = 10; %Samples per trace
sampint = 1000; %Sample interval in microseconds
thdr = SegyTextHeader(outsgyfile,'w'); %Create a new SegyTrace object with write permission
thdr.write(thdr.new); %Create a new text header and write to disk
bhdr = SegyBinaryHeader(outsgyfile,'a'); %Create a new SegyBinaryHeader object with append permission
bhdr.write(bhdr.new(nsamp,sampint)); %Create and write a new binary header to disk
trc = SegyTrace(outsgyfile,'a'); %Create a new SegyTrace object with append permission
trcdat = magic(10);
[nsamp,ntrace]=size(trcdat);
trchdr = trc.new(ntrace, nsamp, sampint); %Create new trace header
trc.write(trchdr, trcdat); %Write trace header and trace data to disk
trc.Permission = 'r'; %Update Permission
[trchdr,trcdat2] = trc.read; %Read all trace headers and trace data and return trace definition used
if ~sum(sum(trcdat-trcdat2))
    disp('PASSED')
else
    disp('FAILED')
end

%% Data trailers (SEG-Y revision 2+)
%% Example 5.2: Create
%% Example 5.4: Read
%% Example 5.5: Write

%% SegyFile
%% Example 6.2: Create new file headers and trace data array
disp('*** Example 6.2: Create new file headers, trace data array, and header definitions ***')
sf = SegyFile; %Create a new SegyFile object
[txthdr, binhdr, exthdr, trchdr, trcdat, bindef, trcdef] = sf.new; %Create new file and trace headers, trace data and header defintions
[txthdr, binhdr, exthdr, trchdr, trcdat] = sf.new(ntrace, nsamp, sampint); %Create new file and trace headers, trace data and header defintions over-riding nsamp and sampint
%NOTE that exthdr will be empty ([])

%% Example 6.4: Read an existing SEG-Y file
disp('*** Example 6.4: Read SEG-Y file ***')
%In the following examples, exthdr will always be empty (exthdr = []). This
%is a placeholder for when the ExtendedText Header class has been fully written and tested.u
if exist('uiSegyFile.m','file')
    sf = uiSegyFile(insgyfile); %Create a new SegyFile object and inspect SEG-Y file with GUI (sponsors toolbox release only)
else
    sf = SegyFile(insgyfile); %Create a new SegyFile object
end
[txthdr, binhdr, exthdr, trchdr, trcdat, bindef, trcdef] = sf.read; %Read entire file
[txthdr, binhdr, exthdr, trchdr, trcdat, bindef, trcdef] = sf.read(1:2); %Read traces 1 and 2
txthdr = sf.TextHeader.read; %Read just the textual file header
binhdr = sf.BinaryHeader.read; %Read just the binary header
exthdr = sf.ExtendedTextHeader.read; %Read just the extended text file header(s)
trchdr = sf.Trace.read(1,'headers'); %Read trace header 1
trchdr = sf.Trace.read([],'headers'); %Read all trace headers
trcdat = sf.Trace.read(1:2:10,'data'); %Read data from traces 1-10 by two's
trcdat = sf.Trace.read([],'data'); %Read all trace data
[trchdr,trcdat] = sf.Trace.read; %Read all trace headers and trace data

%% Example 6.5: Write a new SEG-Y file
disp('*** Example 6.5: Write new SEG-Y file ***')
sf = SegyFile(insgyfile); %Create a new SegyFile object
[txthdr, binhdr, exthdr, trchdr, trcdat, bindef, trcdef] = sf.read; %Read entire file
gui=1; %Command line prompts
% gui=[]; %GUI prompts
sf2 = SegyFile(outsgyfile,'w',sf.SegyRevision,sf.SampleInterval,...
    sf.SamplesPerTrace,sf.FormatCode,sf.TextFormat,sf.ByteOrder,...
    bindef,trcdef,gui); %Create a new SegyFile object with write permissions
sf2.write(txthdr, binhdr, exthdr, trchdr, trcdat, ...
    bindef, trcdef); %Write SEG-Y file to disk
sf2.Permission = 'r';
[txthdr2, binhdr2, exthdr2, trchdr2, trcdat2, bindef2, trcdef2] = sf2.read; %Read entire file

%% Wrappers
%% Example 7.0: Get trace header information
disp('*** Example 7.0: Get trace header information ***')
tracebyte2word(232); %Get header name closest to byte 20, revision 1 trace header definition (default)
tracebyte2word(232,0); %Get header name closest to byte 20, revision 0 trace header definition
tracebyte2word(232,2); %Get header name closest to byte 20, revision 2 trace header definition
traceword2byte('Unassigned01'); %Get byte location for header name, revision 1 trace header definition (default)
traceword2byte('Unassigned14',0); %Get byte location for header name, revision 0 trace header definition
traceword2byte('TrcHdrName',2); %Get byte location for header name, revision 2 trace header definition
traceheaderdump(trchdr); %List all header names in trchdr struct that contain non-zero values
[dump,words,inotempty]=traceheaderdump(trchdr); %Return all header values, names and indices in trchdr struct for non-zero values
traceheaderdump_g(trchdr); %Display GUI that can plot values for up to three separate header words

%% Example 7.4: Read a SEG-Y file
disp('*** Example 7.4: Read SEG-Y file ***')
%Read SEG-Y file with no overrides, display uiSegyFile() GUI if it exists
[trcdat,segyrev,sampint,fmtcode,txtfmt,bytord,txthdr,...
        binhdr,exthdr,trchdr,bindef,trcdef] = ...
        readsegy(insgyfile); 
%Read SEG-Y file using all available overrides
%Update input paramters:
trcrange = []; %Empty => all traces
gui = 1; %Command line prompts, no GUI
nsamps = []; %Empty => Determine number of samples per trace from file on disk
%Read SEG-Y file using all overrides, display uiSegyFile() GUI if it exists
[trcdat,segyrev,sampint,fmtcode,txtfmt,bytord,txthdr,binhdr,exthdr,trchdr,...
    bindef,trcdef] = readsegy(insgyfile,trcrange,segyrev,sampint,nsamps,...
    fmtcode,txtfmt,bytord,bindef,trcdef,gui);   

%% Example 7.5: Write a new SEG-Y file
disp('*** Example 7.5: Write SEG-Y file ***')
writesegy(outsgyfile,trcdat); %Write Seg-Y revision 1 file using just trcdat and defaults
trcdat2=readsegy(outsgyfile);
if ~sum(sum(trcdat-trcdat2))
    disp('PASSED')
else
    disp('FAILED')
end

segyrev=2;
writesegy(outsgyfile,trcdat,segyrev,sampint,fmtcode,txtfmt, ...
    bytord,txthdr,binhdr,exthdr,trchdr,bindef,trcdef); %Write SEG-Y file using all overrides
[trcdat1,segyrev2,sampint2,fmtcode2,txtfmt2,bytord2,txthdr2,binhdr2,exthdr2,trchdr2,...
    bindef2,trcdef2] = readsegy(outsgyfile); %Read it back
if ~sum(sum(trcdat-trcdat2))
    disp('PASSED')
else
    disp('FAILED')
end

%% Clean up
clear


