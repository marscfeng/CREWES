function write (obj,txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef)
%Writes a new SEG-Y file
%
% function write (obj,txthdr,binhdr,exthdr,trchdr,trcdat,bindef,trcdef)
%
%Writes:  txthdr: text file header
%         binhdr: binary file struct
%         exthdr: extended text file header
%         trchdr: trace header struct
%         trcdat: trace data array
%         bindef: binary header definition cell arrary that matches binhdr
%         trcdef: trace header definition cell array that matches trchdr
%to output SEG-Y file: obj.FileName
%
% Examples:
%   sf = SegyFile('newfile.sgy','w');
%   sf.write (txthdr, binhdr, exthdr, trchdr, trcdat, bindef, trcdef)
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

narginchk(6,8);

if nargin>6 && ~isempty(bindef)
    obj.BinaryHeader.HdrDef = bindef;
    obj.FormatCode = binhdr.FormatCode;
    obj.SegyRevision = binhdr.SegyRevNumMaj;
    obj.SampleInterval = binhdr.SampleRate;
end
if nargin>7 && ~isempty(trcdef)
    obj.Trace.HdrDef = trcdef;
end

%Format code warnings
if obj.FormatCode < 1 || obj.FormatCode == 4 || obj.FormatCode == 13 ...
        || obj.FormatCode == 14 || obj.FormatCode > 16
    mm_errordlg(['writesegy: Trace data Format Code ' num2str(obj.FormatCode) ...
            ' is not supported by this code ' ...
            'Continuing...'],'Warning!',obj.GUI);
end
if obj.SegyRevision == 0
    %     if obj.FormatCode == 5
    %         mm_warndlg(['writesegy: Trace data Format Code ' num2str(obj.FormatCode) ...
    %             ' is not defined in SEG-Y Rev 0. Setting Format Code to 1 and ' ...
    %             'continuing...'],'Warning!',obj.GUI);
    %         %Original file had format code 1 and IEEE floats. Force format code 1 to mean IBM floats
    %         obj.FormatCode = 1;
    %     elseif obj.FormatCode > 5
    if obj.FormatCode > 4
        mm_warndlg(['writesegy: Trace data Format Code ' num2str(obj.FormatCode) ...
            ' is not defined in SEG-Y Rev 0. ' ...
            'Continuing...'],'Warning!',obj.GUI);
    end
elseif obj.SegyRevision==1 && ...
        ((obj.FormatCode>5 && obj.FormatCode<8) || obj.FormatCode>8)
    mm_warndlg(['writesegy: Trace data Format Code ' num2str(obj.FormatCode) ...
        ' is not defined in SEG-Y Rev 1. ' ...
        'Continuing...'],'Warning!',obj.GUI);
elseif obj.SegyRevision==2
    %error('This code does not yet support writing SEG-Y Rev 2 Files')
end

if isempty(txthdr)
    txthdr = obj.TextHeader.new(obj.SegyRevision); %rev1 by default
end

if isempty(exthdr)
    exthdr = obj.ExtendedTextHeader.new(obj.SegyRevision); %rev1 by default
end

[nsamp,ntrace] = size(trcdat);
if isempty(binhdr)
    %byte 3213 -> 3261 data trc per ens
    %byte 3215 -> 3265 aux trc per ens
    %byte 3221 -> 3269 samp per trc
    %byte 3217 -> 3273 sample interval
    %byte 3219 -> 3281 sample interval original
    %byte 3223 -> 3289 samp per trc original
    %byte 3227 -> 3293 ens fold     
    binhdr = obj.BinaryHeader.new(obj.SegyRevision); %rev1 == default
    [spt,~,spti] = obj.BinaryHeader.byte2word(20); %samples per trc
    ospt = obj.BinaryHeader.byte2word(22); %original samples per trc
    
    if obj.SegyRevision < 2
        binhdr.(spt) = nsamp;
        binhdr.(ospt) = nsamp;        
    else
        if ~check_int_range(nsamp,obj.BinaryHeader.HdrDef{spti,2})
            espt = obj.BinaryHeader.byte2word(68); %extended samp per trc
            eospt = obj.BinaryHeader.byte2word(88); %extended original samp per trc
            nextthdr = obj.BinaryHeader.byte2word(306); %number of extended trace headers
            
            binhdr.(spt) = 0;
            binhdr.(ospt) = 0;
            binhdr.(espt) = nsamp;
            binhdr.(eospt) = nsamp;
            binhdr.(nextthdr) = 1;
        end
    end        
end


sampint = obj.SampleInterval;

if isempty(trchdr)
    trchdr = obj.Trace.new(ntrace,nsamp,sampint); %rev1 by default
end



%override binary header values
% binhdr.(obj.BinaryHeader.byte2word(16)) = obj.SampleInterval; %microseconds
% binhdr.(obj.BinaryHeader.byte2word(18)) = obj.SampleInterval; %microseconds
% binhdr.(obj.BinaryHeader.byte2word(20)) = obj.SamplesPerTrace;
% binhdr.(obj.BinaryHeader.byte2word(22)) = obj.SamplesPerTrace;
% binhdr.(obj.BinaryHeader.byte2word(24)) = obj.FormatCode;


% if segyrev==0 && segfmt==5 %update segy revision major #. Warn user??
%     binhdr.(sf.BinaryHeader.byte2word(300)) = 1;  
% end


if ~isempty(exthdr)
    mm_errordlg('Extended Textual File Headers are not yet supported',...
        'Error!',gui)
end

% if ~isempty(trcdef)
%     sf.Trace.HdrDef=trcdef; %custom trace header def
% end
% 
% if isempty(trchdr)
%     trchdr = sf.Trace.new(numtrc,nsamps,sampint,'headers');
% else
%     trchdr.(sf.Trace.byte2word(114))(:) = nsamps;
%     trchdr.(sf.Trace.byte2word(116))(:) = sampint*1e6;
% end
% 
% %     if updatetrchdr  %update to segyrev 1
% %         ntrchdr = sf.Trc.new(numtrc,numsamp,sampint,'headers'); %rev1 by default
% %         f = fieldnames(ntrchdr);        
% %         for ii=1:length(f)
% %             if isfield(trchdr,f(ii)) && isfield(ntrchdr,f(ii))
% %                 ntrchdr.(f{ii}) = trchdr.(f{ii});
% %             end
% %         end
% %         trchdr=ntrchdr;
% %     end
% 
% 

%disp('TextHeader')
obj.TextHeader.write(txthdr);
%disp('BinHeader')
obj.BinaryHeader.write(binhdr);
%disp('ExtHdr')
obj.ExtendedTextHeader.write(exthdr);
%disp('Trace')
obj.Trace.write(trchdr,trcdat);

end %end function write()
