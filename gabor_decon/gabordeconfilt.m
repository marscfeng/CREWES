function [trout,tvs_op]=gabordeconfilt(trin,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,filtmask,ipow)
% GABORDECONFILT: nonstationary seismic deconvolution using the Gabor transform plus filtering
%
% [trout,tvs_op]=gabordeconfilt(trin,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,filtmask,ipow)
%
% GABORDECON deconvolves a seismic trace using the Gabor transform as described by Margrave and
% Lamoureux (2001). This version uses modified Gaussian windowing and designs the operator from
% the Fourier-Gabor spectrum of the data. Spectral smoothing may be boxcar or hyperbolic. The
% operator may be split between analysis and synthesis windows or applied entirely in either
% one. Usually analysis only windowing (p=1)works best.
% BOXCAR smoothing: In this mode, the Gabor amplitude spectrum of the trace is convolved with a
% 2D boxcar whose dimensions are tsmo and fsmo. Prior to smoothing the stability value of
% stab*amax (amax is the maximum of the Gabor amp spectrum) is added to the spectrum. The
% inverse of this smoothed spectrum is then the Gabor operator amplitude spectrum and the phase
% is determined by Hilbert transform or set to zero.
% HYPERBOLIC smoothing: The stability constant is added to the Gabor amplitude spectrum and
% then its average values are calculated along t*f=constant contours (hyperbolas). This is
% taken to be an estimate of the attenuation function. The input amplitude spectrum is then
% divided by this attenuation estimate and the result is boxcar smoothed and this is taken as
% an estimate of the source wavelet spectrum. The product of the attenuation and the wavelet is
% then inverted to estimate the ampltide spectrum of the Gabor operator. Phase is computed by
% Hilbert transform or set to zero.
% NOTE: Generally, tsmo should be much larger for Hyperbolic smoothing than for boxcar
% smoothing and this helps to preserve relative amplitude variation. A typical value for boxcar
% smoothing is about 0.3 seconds but this has an AGC like effect tending to suppress relative
% amplitude information on scales larger than tsmo. For hyperbolic smoothing, tsmo can be 1.0
% seconds of more. In theory the source wavelet should be time invariant and this can be forced
% by making tsmo equal to the trace length. However, this not only slows things down but
% usually leads to reduced performance. This is because the hyperbolic smoothing produces an
% imperfect estimate of the attenuation and this is somewhat compensated by allowing some time
% variation into the source waveform.
% NOTE2: fsmo is much easier to choose and controls the 'strength' of the deconvolution.
% Roughly 1/fsmo is the length of an equivaluent time domain inverse operator. So, fsmo=10
% correspods to a time-domain operator length of 100 milliseconds. fsmo=5 is 200 milliseconds.
% Shorter fsmo means a more aggressive decon and tendes to estimate the spectral shape better,
% especially at the low end.
%
% trin ... input trace
% t ... time coordinate for trin
% twin ... half width of gaussian temporal window (sec)
% tinc ... temporal increment between windows (sec)
% tsmo ... size of temporal smoother (sec)
% fsmo ... size of frequency smoother (Hz)
% ihyp ... 1 for hyperbolic smoothing, 0 for ordinary boxcar smoothing
%    Hyperbolic smoothing averages the gabor magnitude spectrum along
%    curves of t*f=constant.
% ************** Default = 1 ***********
% stab ... stability constant
%   ************* Default = 0 **************
% phase ... 0 for zero phase, 1 for minimum phase
%   ************* Default = 1 **************
% p ... exponent that determines the analysis and synthesis windows. If g
%   is a modified Gaussian forming a partition, then the analysis window is
%   g.^p and the synthesis window is g.^(1-p). p mus lie in the interval
%   [0,1]. p=1 means the synthesis window is unity and p=0 means the
%   analysis window is unity.
% ***************** default p=1 ********************************
% ********* values other than 1 not currently recommended ******
% gdb ... number of decibels below 1 at which to truncate the Gaussian
%   windows. Used by fgabor. This should be a positive number. Making this
%   larger increases the size of the Gabor transform but gives marginally
%   better performance. Avoid values smaller than 20. Note that many gdb
%   values will result in identical windows because the truncated windows
%   are always expanded to be a power of 2 in length.
% ************** default = 60 ***************
% filtmask ... filter mask defining the post-Gabor byperbolic bandpass filter. Use makegaborfilter
%   to determine this. The parameters t,twin,tinc must be exactly the same in makegaborfilter as in
%   gabordeconfilt.
% ************* default is no filter *******************
% ipow ... 1 means the output trace will be balanced in power to the input, 0 means not balancing.
%   **************** default =1 ************
%
% trout ... deconvolved result
% tvs_op ... complex-valued gabor spectrum of the operator. That is,
%   GaborSpectrum(trout) = GaborSpectrum(trin).*tvs_op
%
% by G.F. Margrave, May 2001 updated July 2009, July 2011, Feb 2013
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

%hidden parameters
% transforms ... must be one of [1,2,3] with the meaning
%               1 : use old transforms without normalization
%               2 : use old transforms with normalization
%               3 : use new transforms without normalization
%               4 : use new transforms with normalization
% ************* default = 3 ************
% taperpct = size of taper applied to the end of the trace (max time)
%                 expressed as a percent of twin
% ************** default = 50% *********************
% taperpct has a mysteriously beneficial effect. Setting it to zero
% degrades the result in the latter half of the trace

if(nargin<7); ihyp=1; end
if(nargin<8); stab=0; end
if(nargin<9); phase=1; end
if(nargin<10); p=1; end
if(nargin<11); gdb=60; end
if(nargin<12); filtmask=[]; end
if(nargin<13); ipow=1; end
transforms=3;
taperpct=50;
normflag=0;
if(transforms==2 || transforms == 4)
    normflag=1;%means we will normalize the Gaussians 
end
% dtinput=t(2)-t(1);
[m,n]=size(trin);
if((m-1)*(n-1)~=0)
    error('gabordecon can currently handle only single traces. You need to write a loop')
end
if(m==1)
    trin=trin.';
    %force column vector
end

%scale taperpct to the trace length
taperpct=taperpct*twin/max(t);
taperpct=min([10 taperpct]);
%taper trace
if(taperpct>0)
   trin=trin.*mwhalf(length(trin),taperpct);
end

%check for a zero trace
if(sum(abs(trin))==0)
    trout=zeros(size(trin));
    tvs_op=[];
    return
end


%compute the tvs
if(transforms==1 || transforms==2)
    padflag=1;
    [tvs,trow,fcol]=fgabor_old(trin,t,twin,tinc,padflag,normflag,0);
else
    [tvs,trow,fcol,normf_tout]=fgabor(trin,t,twin,tinc,p,gdb,normflag); %#ok<ASGLU>
end

%stabilize
%find the minimum maximum
tmp=max(abs(tvs),[],2);%Find the maxima of each spectrum
amax=abs(max(tmp));%adjusted to maximum maximum

dt=trow(2)-trow(1);
df=fcol(2)-fcol(1);
nt=round(tsmo/dt)+1;
nf=round(fsmo/df)+1;

if(~ihyp)
	% smooth with a boxcar
	tvs_op=conv2(abs(tvs)+stab*amax,ones(nt,nf),'same')/(nt*nf);
    maskhyp=ones(size(tvs_op));
else
    %hyperbolic smoothing
    if(normflag==1)
%         [tvsh,smooth,smodev,tflevels]=hypersmooth(abs(tvs).*normf_tout(:,ones(size(fcol))),trow,fcol,100);
        [tvsh,smooth,smodev,tflevels]=hypersmooth(abs(tvs)+stab*amax,trow,fcol,100); %#ok<ASGLU>
    else
        [tvsh,smooth,smodev,tflevels]=hypersmooth(abs(tvs),trow,fcol,100); %#ok<ASGLU>
    end
    iz=find(tvsh==0, 1);
    if(~isempty(iz))
        tvsh=conv2(tvsh,ones(3,3),'same');
    end
    %hyperbolic filter
    %this is a filter designed to suppress the output at large t*f values.
    %These are values with high attenuation and usually show artefacts if not
    %suppressed. The idea is to define the supppression contour based on the
    %value of stab*amax which is the white noise level. The white noise level
    %is compared to tvsh to determine this.
    ind=near(tvsh(:,end),.5*stab*amax);
    maskhyp=hypfiltmask(trow,fcol,fcol(end)*trow(ind(1)),.1*fcol(end)*trow(ind(1)));
    %estimate wavelet
    w=conv2(abs(tvs)./tvsh,ones(nt,nf),'same')/(nt*nf);
    %propagating wavelet (amp only)
    tvs_op=w.*tvsh;
end

%phase if required and invert
if phase==1
    L1=1:length(fcol);L2=length(fcol)-1:-1:2;
    symspec=[tvs_op(:,L1) tvs_op(:,L2)];%create neg freqs for Hilbert transform
    symspec2=herbert(log(symspec')).';%transposing to force herbert to work along frequency
    tvs_op=exp(-conj(symspec2(:,L1)));%toss negative freqs
else
    tvs_op=1 ./tvs_op;
end

%deconvolve

tvs=tvs.*tvs_op;

%hyperbolic filter mask
%and hyperbolic bandpass
%probably don't need both of the above. The maskhyp was done first historically and the filtmask was
%later. filtmask is probably the more important but it seems that there is no harm in letting
%maskhyp remain.
%tvs=tvs.*maskhyp.*filtbp(trow,fcol,t1,fmin,fmax,fmaxlim,fphase,max_atten);
if(~isempty(filtmask))
    tvs=tvs.*maskhyp.*filtmask;
else
    tvs=tvs.*maskhyp;
end

ind=find(isnan(tvs));
if(~isempty(ind))
    tvs(ind)=stab*amax;
end

%inverse transform
if(transforms==1 || transforms==2 )
    trout=igabor_old(tvs,fcol);
else
    trout=igabor(tvs,trow,fcol,twin,tinc,p,gdb,normflag);
end
trout=trout(1:length(trin));%truncate to length of input
if(ipow==1)
    trout=balans(trout,trin);%balance rms power to that of input
end
end


function mask=hypfiltmask(trow,fcol,tfcut,tfwid)
trow=trow(:);
mask=ones(length(trow),length(fcol));
for k=1:length(fcol)
    tf=trow*fcol(k);
    ind=find(tf>tfcut);
    if(~isempty(ind))
        mask(ind,k)=mask(ind,k).*exp(-((tf(ind)-tfcut)/tfwid).^2);
    end
end
end

% function filtmask=filtbp(trow,fcol,t1,fmin,fmax,fmaxlim,fphase,max_atten)
% filtmask=zeros(length(trow),length(fcol));
% for k=1:length(trow)
%     if(t1==-1)
%         fmn=fmin;
%         fmx=fmax;
%     else
%         fmn=fmin;
%         f2=fmax(1)*t1/trow(k);
%         if(f2>fmaxlim(1)); f2=fmaxlim(1); end
%         if(f2<fmaxlim(2)); f2=fmaxlim(2); end
%         fmx=[f2 fmax(2)];
%     end
%     dt=.5/fcol(end);
%     tmax=.5/fcol(2);
%     filtmask(k,:)=(filtspec(dt,tmax,fmn,fmx,fphase,max_atten))';
% end
% end