function [amp,phs,tout,fout]=specdecomp(s,t,twin,tinc,fmin,fmax,df,tmin,tmax,phaseflag,interpflag,iwait,ievery)
% SPECDECOMP: This is a vectorized version of spectraldecomp. 
%
% [amp,phs,tout,fout]=specdecomp(s,t,twin,tinc,fmin,fmax,df,tmin,tmax,phaseflag,interpflag,iwait,ievery)
% 
% This is a Gabor method. For each output time, the input gather is windowed with a Gaussian
% centered at that time and then Fourier transformed as a panel. The Gaussian length is truncated
% (or expanded) to control the Frequency sample rate. Then the resulting complex spectrum is
% separated into amplitude and phase (see the phase flag parameter) and the requested frequencies
% are written into the output arrays. The returned amp and phs are 3D arrays with time as the first
% dimension, trace number as the second dimension, and frequency as the third dimension. They can be
% conveniently viewed in specd_viewer.
%
% NOTE: specdecomp produces identical results to spectraldecomp but the former is vectorized for
% speed on large datasets. The latter is easier to understand but is slower. Use spectraldecomp on
% single traces or small 2D data. If your data is organized as a 3D matrix use spectdecomp3D. If it
% is a very large 2D matrix, and you are a confident coder, use specdecomp in a loop where you send
% it 1000 trace panels of data one at a time.
%
% s ... seismic trace gather, one trace per column. Should be a 2D matrix. Use specdecomp3D for 3D
%       matrices.
% t ... time coordinate for s
% NOTE: Length of t must equal the number of rows of s
% twin ... width (seconds) of the Gaussian window (standard deviation)
% tinc ... temporal shift (seconds) between windows
%          the output time sample rate.
% fmin ... minimum output frequency (Hz)
% fmax ... maximum output frequency (Hz)
% df   ... output frequency sample rate (Hz)
% ********** default = 1 Hz ************
% tmin ... minimum output time (seconds)
% ********** default = t(1) ***********
% tmax ... maximum output time (seconds)
% ********** default = t(end) ***********
% phaseflag ... 0 means phs is true phase
%               1 means phs is cos(phs) (hides phase wrap but shows spatial coherence)
%               2 means phs is sin(phs)
%               3 means no phase info computed
% ********* default =3 *********
% interpflag ... 0 means the fd values will fall of the sparse time grid of
%      tnot=t(1):tinc:t(end) while 1 means they will be interpolated with 1D spline to provide a
%      value for every t.
% ************ default is 1 ***********
% iwait ... 1 means put up a GUI waitbar showing progress. 0 means print progress messages to
%       command window, -1 means no messages
%   ************* default = 0 *************
% ievery ... print a progress message (or update the waitbar) every this many window positions
%   ************* default = 100 *************
%
% amp ... 3D amplitude spectral decomp. These are all positive numbers (amplitude spectra) and the
%       array is of size (nt,nx,nf) where nt=length(t(1):tinc:t(end)), nx=size(seis,2), and
%       nf=length(fmin:df:fmax).
% phs ... same size array as amp give the phase of the decomp
% tout ... time coordinate for amp and phs
% fout ... frequency coordinate for amp and phs
% 
% G.F. Margrave, Devon, 2018
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
if(nargin<13)
    ievery=100;
end
if(nargin<12)
    iwait=0;
end
if(nargin<11)
    interpflag=1;
end
if(nargin<10)
    phaseflag=3;
end
if(nargin<9)
    tmax=t(end);
end
if(nargin<8)
    tmin=t(1);
end
if(nargin<7)
    df=1;
end

if(length(size(s))>2)
    error('specdecomp is 2D. Use specdecomp3D for 3D')
end

[nsamps,ntraces]=size(s);
if((nsamps-1)*(ntraces-1)==0)
   error('specdecomp is multichannel only, use spectraldecomp for single traces');
end

t=t(:);
if(length(t)~=nsamps)
    error('t has the wrong length')
end
dt=t(2)-t(1);

if(tinc>twin)
    error('tinc should be less than twin');
end

%determine time samples to use
itin=near(t,tmin,tmax);

tstart=t(1);
t=t-tstart;

%measurement sites
ttmp=(t(itin(1)):tinc:t(itin(end)))';

%output frequencies
fout=fmin:df:fmax;
nfout=length(fout);

%determine a number of samples that is a power of 2 and which exceeds
%8*twin. This is how long the gaussian windows will be
n0=round(8*twin/dt);
n2=2^nextpow2(n0);

s=[s;zeros(n2,ntraces)];%zero pad, this is so we don't have to test for the end of the trace

%output arrays
amptmp=zeros(length(ttmp),ntraces,nfout);
phstmp=amptmp;
%gs=zeros(length(t),length(tnot));

small=100*eps;
tpad=[t;(t(end)+dt:dt:t(end)+n2*dt)'];
%test for zero trace
tmp=sum(abs(s));
izero=tmp<small;
ilive=~izero;%flag the live traces
stmp=s(:,ilive);
nlive=size(stmp,2);
hbar=[];
if(iwait==1)
    hbar=WaitBar(0,length(ttmp),'Please wait for Spectral Decomp to complete','Spectral Decomposition');
    ievery=10;
end
tbegin=clock;
cancelled=false;
for k=1:length(ttmp)
    
    %make the gaussian
    %g=exp(-(tpad-tnot(k)).^2/twin^2);
    inot=round(ttmp(k)/dt)+1;%index of window center
    it0=max([1 inot-n2/2]);%index of window start
    it1=it0+n2-1;%index of window end
    it=it0:it1;
    g=gcausal(tpad(it),ttmp(k),twin,1);
    gg=g(:,ones(1,nlive));
    %window and transform
    [S,f]=fftrl(stmp(it,:).*gg,tpad(it));
    %interpolation to the output frequencies
    A=interp1(f,abs(S),fout);
    switch phaseflag
        case 0
            B=interp1(f,angle(S),fout);
        case 1
            B=interp1(f,real(S),fout)./A;
        case 2
            B=interp1(f,imag(S),fout)./A;
    end
    amptmp(k,ilive,:)=shiftdim(A',-1);
    if(phaseflag<3)
        phstmp(k,ilive,:)=shiftdim(B',-1);
    end
    if(rem(k,ievery)==0)
        timeused=etime(clock,tbegin);
        time_per_tnot=timeused/k;
        timeremaining=(length(ttmp)-k)*time_per_tnot;
        if(iwait==1)
            if(WaitBarContinue)
                WaitBar(k,hbar,['Estimated time remaining ' num2str(timeremaining,4) ' seconds']);
            else
                delete(hbar)
                cancelled=true;
                break
            end
        elseif(iwait>=0)
            disp(['finished time ' int2str(k) ' of ' int2str(length(ttmp)) ' total'])
            disp([' time used ' int2str(timeused) '(s), time remaining ' int2str(timeremaining) '(s) or ' num2str(timeremaining/60) '(m)'])
        end
    end
end
if(~cancelled)
    if(isgraphics(hbar))
        delete(hbar)
    end
    if(interpflag==1)
        tout=t(itin);
        amp=zeros(length(tout),ntraces,nfout);
        
        for k=1:nfout
            amp(:,ilive,k)=interp1(ttmp,amptmp(:,ilive,k),tout,'spline');
        end
        ind=find(amp<0);
        if(~isempty(ind))
            amp(ind)=0;
        end
        phs=zeros(length(tout),ntraces,nfout);
        if(sum(abs(phstmp(:)))>0)
            for k=1:nfout
                phs(:,ilive,k)=interp1(ttmp,phstmp(:,ilive,k),tout,'spline');
            end
        end
    else
        amp=amptmp;
        phs=phstmp;
        tout=ttmp;
    end
    if(iwait>=0)
        timeused=etime(clock,tbegin);
        disp(['total time ' num2str(timeused) '(s)'])
    end
    tout=tout+tstart;
else
    amp=[];
    phs=[];
    tout=[];
end
end

function gc=gcausal(t,tnot,twid,factor)

if(nargin<4)
    factor=5;
end
if(factor>0)
    twid2=twid/factor;
else
    twid2=twid;
    twid=twid/abs(factor);
end

ind=near(t,tnot,t(end));
ind2=near(t,t(1),tnot);

gc=zeros(size(t));
gc(ind)=exp(-(t(ind)-tnot).^2/twid^2);
gc(ind2)=exp(-(t(ind2)-tnot).^2/twid2^2);
end
