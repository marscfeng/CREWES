function obj = guessFormatCode(obj)
%Guess if trace data are IBM32 or IEEE32 for FormatCode=1
%
% function fc = guessFormatCode(obj)
%
% Algorithm: If SEG-Y FormatCode = 1 read the first trace from the file as
% uint32, then use ibm2double and double2ibm to convert IEEE and back to 
% uint32. If the result does not match the input then trace data may 
% actually be IEEE floating point.
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

%Format code 1 is ambiguous, could be IBM or IEEE floats

if isequal(obj.FormatCode,1)
    
    %Check to see if there is at least one trace in the file
    if obj.fsize() < obj.TraceSize
        return
    end
    
    %max number of traces to check = 5% of all traces
    exitafter = 0.05*obj.TracesInFile;
    
    %number of traces to test
    ntraces = 10;
    
    %bit mask to match 23 bits of floating-point fraction= '7FFFFF'
    bitmask = uint32(8388607);
    
    ii = 0;
    while true
        
        testtrace = round((obj.TracesInFile-ntraces).*rand); %random trace number
        startbyte = obj.analyzeTraceRange(testtrace); %start byte for random trace
        
        obj.fseek(startbyte+obj.TOTHDRSIZE,'bof') %skip to random trace data
        trcin = obj.fread([obj.SamplesPerTrace ntraces],...
             sprintf('%d*uint32',double(obj.SamplesPerTrace)), ...
            'uint32', ...
            obj.TOTHDRSIZE); %read trace data
        
        %exit condition if we've found a non-zero trace
        if ~isequal (sum(bitand(trcin,bitmask)),0)
            break
        end
        
        %exit condition (if file contains all zeros)
        ii = ii+1;
        if ii>exitafter
            return
        end
    end
    
    %convert to single assuming data is IBM floating point
    trcdbl    = ibm2double(trcin);
    %convert back to uint32
    trcout    = double2ibm(trcdbl);

    %Test
%     plot(trcin-trcout)
%     sum(sum(trcin-trcout))
    if sum(sum(trcin-trcout)) %trcin and trcout are not identical
        obj.FormatCode=5;
        mm_warndlg(['@Trace/guessFormatCode: Data Sample Format Code is 1 (4-byte IBM), '...
            'but trace data appear to be Format Code 5 (4-byte IEEE)'],...
            'Warning!',obj.GUI);
    end
end

end %end function