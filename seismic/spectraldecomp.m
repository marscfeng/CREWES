function [amp,phs,tout,fout]=spectraldecomp(seis,t,twin,tinc,tmin,tmax,fmin,fmax,df,phaseflag)
% SPECTRALDECOMP: spectral decomposition of a seismic section or gather
%
% [amp,phs,tout,fout]=spectraldecomp(seis,t,twin,tinc,tmin,tmax,fmin,fmax,df,phaseflag)
%
% This is a Gabor method. Each trace is Gabor transformed (see fgabor) to give a time-frequency
% decomposition with time increment tinc and frequency sampling df=1/(t(end)) . Then the complex
% Gabor spectrum is separated into amplitude and phase (see the phase flag parameter). Then, for
% each time, the amplitude and phase at the frequencies of interest (fmin:df:fmax) are interpolated
% from those computed. The returned amp and phs are 3D arrays with time as the first dimension,
% trace number as the second dimension, and frequency as the third dimension. They can be
% conveniently viewed in specd_viewer.
%
% seis ... seismic section (a matrix) one trace per column
% t    ... time coordinate for seis
% twin ... half-width of Gaussian window for the Gabor transform (in seconds) 
% tinc ... increment between neighboring windows (in seconds). This will be
%          the output time sample rate.
% tmin ... minimum output time (seconds)
% tmax ... maximum output time (seconds)
% fmin ... minimum output frequency (Hz)
% fmax ... maximum output frequency (Hz)
% df   ... output frequency sample rate (Hz)
% ********** defaults to whatever happens naturally from the FFT ************
% phaseflag ... 0 means phs is true phase
%               1 means phs is cos(phs) (hides phase wrap but shows spatial coherence)
%               2 means phs is sin(phs)
% ********* default =1 *********
%
% amp ... 3D amplitude spectral decomp. These are all positive numbers (amplitude spectra) and the
%       array is of size (nt,nx,nf) where nt=length(t(1):tinc:t(end)), nx=size(seis,2), and
%       nf=length(fmin:df:fmax).
% phs ... same size array as amp give the phase of the decomp
% tout ... time coordinate for amp and phs
% fout ... frequency coordinate for amp and phs
%
%
% G.F. Margrave, Devon, 2017
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

if(nargin<10)
    phaseflag=1;
end
if(nargin<9)
    df=[];
end

[nt,ntraces]=size(seis);
if(length(t)~=nt)
    error('time coordinate has the wrong length');
end

%see if we can benefit from resampling
dt=t(2)-t(1);
fnyq=.5/dt;
doresample=0;
if(fmax<.5*fnyq)
    dts=[.001,.002,.004,.008];
    fnys=.5./dts;
    ind=find(.5*fnys>fmax);
    dt2=dts(ind(end));
    %dt2 is the smallest sample rate that passes the half-nyquist criterion
    if(dt2>dt)
        doresample=1;
    end
end

it=near(t,tmin,tmax);
ievery=100;
tbegin=clock;
for k=1:ntraces
    tmp=seis(it,k);
    if(doresample)
        [s,t2]=resamp(tmp,t(it),dt2);
    else
        s=tmp;
        t2=t(it);
    end
    if(k==1)
        [tvs,tout,ftmp]=fgabor(s,t2,twin,tinc);
        indf=near(ftmp,fmin,fmax);
        indt=near(tout,tmin,tmax);
        if(isempty(df))
            fout=ftmp(indf);
        else
            fout=fmin:df:fmax;
        end
        amp=zeros(length(tout(indt)),ntraces,length(fout));
        phs=amp;
    else
        tvs=fgabor(s,t2,twin,tinc);
    end
    if(isempty(df))
        a=abs(tvs(indt,indf));
        switch phaseflag
            case 0
                b=angle(tvs(indt,indf));
            case 1
                b=real(tvs(indt,indf))./a;
            case 2
                b=imag(tvs(indt,indf))./a;
        end
                
    else
        a1=abs(tvs(indt,indf));
        switch phaseflag
            case 0
                b1=angle(tvs(indt,indf));
            case 1
                b1=real(tvs(indt,indf))./a1;
            case 2
                b1=imag(tvs(indt,indf))./a1;
        end
        a=interp1(ftmp(indf),a1',fout)';
        b=interp1(ftmp(indf),b1',fout)';
    end
    amp(:,k,:)=a;
    ind=find(isnan(b));
    if(~isempty(ind))
        b(ind)=0;
    end
    phs(:,k,:)=b;
    if(rem(k,ievery)==0)
        timeused=etime(clock,tbegin);
        time_per_trace=timeused/k;
        time_remaining=(ntraces-k)*time_per_trace;
        disp([' finished trace ' int2str(k) ' of ' int2str(ntraces)])
        disp(['time used = ' num2str(timeused/60) 'min, time remaining= ' num2str(time_remaining/60) 'min'])
    end
    tout=tout(indt);
end
        