function sf=filt_hyp(s,t,t0,fmin,fmax,fmaxlim,phase,max_atten,option,twin,ievery,iwait)
% FILT_HYP ... time variant bandpass filter whose passband follows hyperbolic trajectories
%
% sf=filt_hyp(s,t,t0,fmin,fmax,fmaxlim,phase,max_atten,option,twin,ievery,iwait)
%
% In the time-frequency plane, curves of t*f=constant are hyperbolae. If
% the min and max frequencies of a bandpass filter are specified at some
% time, t0, then the they can be automatically adjusted to follow a
% hyperbolic trajectory. This gets a wider passband for t<t0 and a narrower
% one for t>t0.
%
% s ... seismic trace or gather to be filtered
% t ... time coordinate vector for s
% t1 ... time at which filter specs apply
% fmin ... a two element vector specifying:
%         fmin(1) : 3db down point of filter on low end (Hz)
%         fmin(2) : gaussian width on low end
%    note: if only one element is given, then fmin(2) defaults
%          to 5 Hz. Set to [0 0] for a low pass filter 
% fmax ... a two element vector specifying:
%         fmax(1) : 3db down point of filter on high end (Hz)
%         fmax(2) : gaussian width on high end
%    note: if only one element is given, then fmax(2) defaults
%          to 20% of (fnyquist-fmax(1)). Set to [0 0] for a high pass filter
% fmaxlim ... Two element vector. After adjusting fmax for t~=t1, it will not be allowed to
%           exceed fmaxlim(1) or fall below fmaxlim(2).
%     ********** default fmaxlim = [.8*fnyq, .5*fmax] *********
% phase... 0 ... zero phase filter
%          1 ... minimum phase filter
%          any other number ... constant phase rotation of that
%		   many degrees
%  ****** default = 0 ********
% note: Minimum phase filters are approximate in the sense that
%  the output from FILTF is truncated to be the same length as the
%  input. This works fine as long as the trace being filtered is
%  long compared to the impulse response of your filter. Be wary
%  of narrow band minimum phase filters on short time series. The
%  result may not be minimum phase.
% 
% max_atten= maximum attenuation in decibels
%   ******* default= 80db *********
% option ... 1 means only the high-end parameters follow a hyperbolae
%            2 means both low and high end follow hyperbolae
%   ******* default = 1 **********
% twin ... half-width in seconds of Gaussian Gabor windows to be used
%   ******* default = .2 seconds *********
% ievery ... write out a progress message every this many traces
%   ******* default = 100 traces ********
% iwait ... 1 means put up a GUI waitbar showing progress. 0 means print progress messages to
%       command window
%   ************* default = 0 *************
%
% sf ... output filtered trace
% 
% G.F. Margrave, CREWES, 2009
%
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

global WaitBarContinue

fnyq=.5/(t(2)-t(1));
if(length(fmin)==1)
    fmin=[fmin 5];
end
if(length(fmax)==1)
    fmax=[fmax .1*fnyq];
end
if(nargin<6)
    fmaxlim=[.8*fnyq, .5*fmax(1)];
end
fmaxmax=fmaxlim(1);
fmaxmin=fmaxlim(2);
if(nargin<7)
    phase =0;
end
if(nargin<8)
    max_atten=80;
end
if(nargin<9)
    option=1;
end
if(nargin<10)
    twin=.2;
end
if(nargin<11)
    ievery=100;
end
if(nargin<12)
    iwait=0;
end

tmax=max(t);
tmin=min(t);

p=1;
tinc=twin/2;
%multitrace accomodation
[nt,ntraces]=size(s);
if((nt-1)*(ntraces-1)==0)
    %means a single trace
    s=s(:);  
end
sf=zeros(size(s));
tnot=clock;
if(ntraces>1)
    disp('Beginning hyperbolic bandpass filtering');
end

hbar=[];
if(iwait==1)
    hbar=WaitBar(0,ntraces,'Please wait for time-variant filtering to complete','Time-variant filtering');
    ievery=10;
end
for j=1:ntraces
    if(sum(abs(s(:,j)))>0)
        %forward Gabor
        [tvs,trow,fcol]=fgabor(s(:,j),t,twin,tinc,p,1);
        
        %loop over rows in the Gabor spectrum
        for k=1:length(trow)
            tmp=tvs(k,:);
            if(trow(k)~=0)
                fmx=fmax(1)*t0/trow(k);
            else
                fmx=fmaxmax;
            end
            if(fmx>fmaxmax);fmx=fmaxmax; end
            if(fmx<fmaxmin);fmx=fmaxmin; end
            if(option==2)
                if(trow(k)~=0)
                    fmn=fmin(1)*t0/trow(k);
                else
                    fmn=fmin(2);
                end
            else
                fmn=fmin(1);
            end
            
            ftmp=(filtspec(t(2)-t(1),tmax-tmin,[fmn fmin(2)],[fmx fmax(2)],phase,max_atten))';
            %     if(k>10)
            %         disp('Sucks')
            %     end
            %make sure Nyquist is real
            ftmp(end)=real(ftmp(end));
            tvs(k,:)=tmp.*ftmp;
        end
        
        tmp=igabor(tvs,trow,fcol,twin,tinc,p);
        sf(:,j)=tmp(1:length(t));
        cancelled=false;
        if(rem(j,ievery)==0)
                tnow=clock;
                timeused=etime(tnow,tnot);
                timepertrace=timeused/j;
                timeleft=timepertrace*(ntraces-j);
                if(iwait==1)
                    if(WaitBarContinue)
                        WaitBar(j,hbar,['Estimated time remaining ' num2str(timeleft,4) ' seconds']);
                    else
                        delete(hbar);
                        cancelled=true;
                        break
                    end
                else
                    if(timeleft==0)
                        disp(['Filtered all ' int2str(j) ' traces in ' num2str(timeused) ' seconds'])
                    else
                        disp(['Completed ' int2str(j) ' traces in ' num2str(timeused) ' seconds'])
                        disp(['Estimated time remaining ' num2str(timeleft) ' seconds'])
                    end
                end
        end
        
    end
    
end


if(cancelled)
    sf=0;
    disp('filt_hyp cancelled')
end
if(isgraphics(hbar))
    delete(hbar);
end