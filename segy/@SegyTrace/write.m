function write(obj,trchdr,trcdat)
%Writes a trace data array and a trace header structure to a SEG-Y file
%
% function write(obj,trchdr,trcdat)
%
% Writes trcdat and trchdr to disk where:
%  trchdr = trace header struct such as returned by Trace.new
%           or by Trace.read
%  trcdat = numeric matrix with samples in the rows and traces in the
%           columns
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
%

%check input arguments
narginchk(3,3)

if obj.FileID < 0
    mm_errordlg('@SegyTrace/write: Invalid file identifier',...
            'Error!',obj.GUI)    
end

if ~isnumeric(trcdat)
    mm_errordlg('@SegyTrace/write: Trace data must be numeric',...
            'Error!',obj.GUI)
end

if ~isstruct(trchdr)
    mm_errordlg('@SegyTrace/write: Trace header must be a struct',...
            'Error!',obj.GUI)
end

%% Make certain file headers have already been written to disk
fs = obj.fsize();
if isequal(fs,0)
    mm_errordlg('@SegyTrace/write: File does not appear to contain any SEG-Y file headers',...
            'Error!',obj.GUI)
elseif fs < obj.OFFSET
    mm_errordlg(['@SegyTrace/write: SEG-Y file header size ' num2str(obj.OFFSET) ' is less than the minimum: ' num2str(fs) ' bytes'],...
            'Error!',obj.GUI)
else
    obj.Permission = 'r';
    bhdr = SegyBinaryHeader(obj.FileID);
    nbhdrsamp = bhdr.readSamplesPerTrace();
    obj.Permission = 'a';
end

%% Make certain trchdr and trcdat have the same number of traces
%get some basic info about the trcdat array
[ndatsamp, ndattrc] = size(trcdat);

nthdrtrc = size(trchdr.(obj.byte2word(1)),2);

if ~isequal(ndattrc,nthdrtrc)
    mm_errordlg('@SegyTrace/write: Trace data and trace headers contain a different number of traces',...
            'Error!',obj.GUI)
end

%% Apply coordinate scalars
trchdr = obj.applyCoordinateScalars(trchdr); %apply scalars

%% Make certain number of data samples per trace in trace headers matches binary header

%check number of data samples and truncate or pad if necessary to match
%binary header
if ndatsamp>nbhdrsamp
    a = mm_yesnodlg(...
        '@SegyTrace/write: Trace data has more samples per trace than expected.',...
        'Truncate trace data? [y/n]', ...
        'Warning!','Yes',obj.GUI);

    if strncmpi(a,'y',1)
        trcdat = trcdat(1:nbhdrsamp,:);
    else
%         mm_warndlg('@SegyTrace/write: No traces have been written to disk', ...
%             'Warning!', obj.GUI);
%         return
    end
    
elseif ndatsamp<nbhdrsamp
    a = mm_yesnodlg(...
        '@SegyTrace/write: Trace data has fewer samples per trace than expected.',...
        'Pad trace data with zeros? [y/n]', ...
        'Warning!','Yes',obj.GUI);
        
    if strncmpi(a,'y',1)
        w = whos('trcdat');
        trcdat = [trcdat; zeros(nbhdrsamp-ndatsamp,ndattrc,w.class)];
    else
        mm_warndlg('@SegyTrace/write: No traces have been written to disk', ...
            'Warning!', obj.GUI);
        return
    end
end

%overwrite number of samples in this trace if trace headers matches binary header
trchdr.(obj.byte2word(115))(1:end) = nbhdrsamp; %stored in byte 115; SEG-Y standard
obj.SamplesPerTrace = nbhdrsamp;

%% Make certain sample interval matches this trace in trace headers 
thdrdt = trchdr.(obj.byte2word(117))(:); %stored in byte 117; SEG-Y standard
bhdrdt = obj.SampleInterval; %read from bin hdr already written to disk

if ~isequal(sum(thdrdt/bhdrdt),ndattrc)
    a = mm_yesnodlg(...
        ['@SegyTrace/write: Trace header sample interval ' num2str(thdrdt(1)) ...
        ' differs from binary file header sample interval ' num2str(bhdrdt)],...
        'Update trace headers? [y/n]', ...
        'Warning!','Yes',obj.GUI);
    
    if strncmpi(a,'y',1)
        %overwrite sample interval in this trace in trace headers
        fieldname = obj.byte2word(117);
        trchdr.(fieldname)(1:end) = bhdrdt;
    else
        mm_warndlg('@SegyTrace/write: No traces have been written to disk', ...
            'Warning!', obj.GUI);
        return
    end
end


%% renumber trace sequence number within SEG-Y file trace header
%This may be a bad idea. Pehaps leave this up to calling function
%fieldname = obj.byte2word(); %stored in byte 5; SEG-Y standard
%trchdr.(fieldname) = 1:ndattrc +obj.TracesInFile;

%% Final check of trace headers and trace data to write
obj.check(trchdr);
obj.check(trcdat);

% disp(['Trace.write datatype: ' datatype]);
% disp(['Trace.write Trace 1, sample1: ' num2str(trcdat(1,1))]);
    
%% Write traces to disk
%We are appending traces to end of file
obj.fseek(0,'eof');

%Write trace headers and trace data
obj.write2(trchdr,trcdat)

end

