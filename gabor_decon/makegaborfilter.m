function filtmask=makegaborfilter(t,twin,tinc,gdb,t1,fmin,fmax,fmaxlim,fphase,max_atten)
% MAKEGABORFILT ... design a time-variant bandpass filter mask to be applied in gabordeconfilt
% 
% filtmask=makegaborfilter(t,twin,tinc,gdb,t1,fmin,fmax,fmaxlim,fphase,max_atten)
%
% This function designs a filter mask for a hyperbolic hyperbolic bandpass filter to be applied
% simultaneously with the Gabor decon operator in gabordeconfilt. This is effectively a post decon
% bandpass filter designed to limit the frequency band that is whitened to the signal band. Without
% this, Gabor decon will blow up too much noise. It is a good idea to reject both extremely low
% frequencies and extermely high ones. This is a time variant filter and is called hyperbolic
% because the upper limit of the passband (fmax) follows a hyperbolic path in the time-frequency
% plane. This path is defined by t*f=constant so specifying the value of t*f at one point defines
% the path. This is done by specifying a reference time (t1) and the value of the maximum frequency
% at that time (fmax). Then, the value of the maximum frequency at any other time (t2) is given by
% fmax2= fmax*t1/t2. From this it follows that when t2<t1, fmax2>fmax and when t2>t1 fmax2<fmax.
% Note that fmin does not vary with time. It is recommended that you use seisplotgabdecon to
% interactively determine appropriate values for this filter.
% NOTE: The values of t,twin,tinc must be exactly the same as those used in gabordeconfilt
% 
% t ... time coordinate for trin
% twin ... half width of gaussian temporal window (sec)
% tinc ... temporal increment between windows (sec)
% gdb ... number of decibels below 1 at which to truncate the Gaussian
%   windows. Used by fgabor. This should be a positive number. Making this
%   larger increases the size of the Gabor transform but gives marginally
%   better performance. Avoid values smaller than 20. Note that many gdb
%   values will result in identical windows because the truncated windows
%   are always expanded to be a power of 2 in length.
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
% fphase ... pahse of the hyperbolic bandpass filter, 0 for zero phase, 1 for minimum phase
%  ********* default = 0 **********
% max_atten ... maximum attenuation of the hyperbolic bandpass filter in decibels
%   ******* default= 80db *********
% 
% filtmask ... filter mask to be applied in gabordeconfilt. This is a (t,f) multiplier. To see what
%       it is, do this:
% fnyq=.5/(t(2)-t(1));
% f=linspace(0,fnyq,size(filtmask,2));
% tf=(0:size(filtmask,1)-1)*tinc;
% figure;imagesc(f,tf,filtmask);colorbar
% xlabel('frequency');ylabel('time')
%If you choose fphase=1 then the filtmask will be complex and you must choose either amplitude,
%phase, real or imaginary in the imagesc command.
%

if(nargin<9)
    fphase=0;
end
if(nargin<10)
    max_atten=80;
end
if(length(fmin)==1)
    fmin=fmin*[1,.5];
end
dt=t(2)-t(1);
fnyq=.5/dt;
if(length(fmax)==1)
    fmax=[fmax .2*(fnyq-fmax)];
end

[tvs,trow,fcol,normf_tout]=fgabor(rand(size(t)),t,twin,tinc,1,gdb,0); %#ok<ASGLU>

filtmask=zeros(length(trow),length(fcol));
for k=1:length(trow)
    if(t1==-1)
        fmn=fmin;
        fmx=fmax;
    else
        fmn=fmin;
        f2=fmax(1)*t1/trow(k);
        if(f2>fmaxlim(1)); f2=fmaxlim(1); end
        if(f2<fmaxlim(2)); f2=fmaxlim(2); end
        fmx=[f2 fmax(2)];
    end
    dt=.5/fcol(end);
    tmax=.5/fcol(2);
    filtmask(k,:)=(filtspec(dt,tmax,fmn,fmx,fphase,max_atten))';
end