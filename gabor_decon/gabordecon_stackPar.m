function stackg=gabordecon_stackPar(stack,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,t1,fmin,fmax,fmaxlim,fphase,max_atten,ipow,ipar,iwait)
% GABORDECON_STACKPAR: applies gabor decon to a stacked section, enabled for parallel
%
% stackg=gabordecon_stackPar(stack,t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,t1,fmin,fmax,fmaxlim,fphase,max_atten,iwait)
%
% GABORDECON_STACKPAR applies gabordecon to all traces in a stack. The main loop over traces is a
% parfor loop
%
% USE nan TO DEFAULT PARAMETERS
% stack ... stacked section as a matrix of traces. 
% t ... time coordinate for stack
% twin ... half width of gaussian temporal window (sec)
% tinc ... temporal increment between windows (sec)
% tsmo ... size of temporal smoother (sec)
% fsmo ... size of frequency smoother (Hz)
% ihyp ... 1 for hyperbolic smoothing, 0 for ordinary boxcar smoothing
%    Hyperbolic smoothing averages the gabor magnitude spectrum along
%    curves of t*f=constant.
% ************** Default = 1 ***********
% stab ... stability constant
%   ************* Default = 0.000001 **************
% phase ... 0 for zero phase, 1 for minimum phase
%   ************* Default = 0 **************
% The following parameters prescribe a hyperbolic bandpass filter that is applied simultaneously
% with the Gabor decon operator. This is effectively a post decon bandpass filter designed to limit
% the frequency band that is whitened to the signal band. Without this, Gabor decon will blow up too
% much noise. It is a good idea to reject both extremely low frequencies and extermely high ones.
% This is a time variant filter and is called hyperbolic because the upper limit of the passband
% (fmax) follows a hyperbolic path in the time-frequency plane. This path is defined by t*f=constant
% so specifying the value of t*f at one point defines the path. This is done by specifying a
% reference time (t1) and the value of the maximum frequency at that time (fmax). Then, the value of
% the maximum frequency at any other time (t2) is given by fmax2= fmax*t1/t2. From this it follows
% that when t2<t1, fmax2>fmax and when t2>t1 fmax2<fmax. Note that fmin does not vary with time.
% It is recommended that you use seisplotgabdecon to interactively determine appropriate values for
% this filter.
% t1 ... time at which filter specs apply
% **************** default .5*(t(end)-t(1)) *************
% fmin ... a two element vector specifying:
%         fmin(1) : 3db down point of filter on low end (Hz)
%         fmin(2) : gaussian width on low end
%    note: if only one element is given, then fmin(2) defaults
%          to 5 Hz. Set to [0 0] for a low pass filter 
% *************** default = [5 2] Hz ********
% fmax ... a two element vector specifying:
%         fmax(1) : 3db down point of filter on high end (Hz)
%         fmax(2) : gaussian width on high end
%    note: if only one element is given, then fmax(2) defaults
%          to 20% of (fnyquist-fmax(1)). Set to [0 0] for a high pass filter
% *************** default = [.5*fnyq .1*fnyq] **************
% fmaxlim ... Two element vector. After adjusting fmax for t~=t1, it will not be allowed to
%           exceed fmaxlim(1) or fall below fmaxlim(2).
% *************** default = [.75*fnyq .25*fnyq] **********
% fphase ... 0 means zero phase, 1 means minimum phase
% *************** default = 0 ****************
% max_atten ... maximum attenuation of the hyperbolic bandpass filter in decibels
%   ******* default= 80db *********
% ipow ... 1 means the output trace will be balanced in power to the input, 0 means not balancing.
%   **************** default =1 ************
% ipar ... 1 means use parfor loop 0 is not parallel
%   **************** default =1 **************
% iwait ... 1 means show a waitbar, 0 means dont. There is never a waitbar for Parallel
%   **************** default =0 **************
% 
% stackg ... deconvolved stack
%
% G.F. Margrave, Margrave-Geo, 2019
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

if(nargin<18)
    iwait=nan;
end
if(nargin<17)
    ipar=nan;
end
if(nargin<16)
    ipow=nan;
end
if(nargin<15)
    max_atten=nan;
end
if(nargin<14)
    fphase=nan;
end
if(nargin<13)
    fmaxlim=[nan nan];
end
if(nargin<12)
    fmax=[nan nan];
end
if(nargin<11)
    fmin=[nan nan];
end
if(nargin<10)
    t1=nan;
end
if(nargin<9)
    phase=nan;
end
if(nargin<8)
    stab=nan;
end
if(nargin<7)
    ihyp=nan;
end

dt=t(2)-t(1);
fnyq=.5/dt;

if(length(fmin)==1)
    fmin=fmin*[1,.5];
end

if(length(fmax)==1)
    fmax=[fmax .2*(fnyq-fmax)];
end

if(length(fmaxlim)==1)
    fmaxlim=[fmaxlim nan];
end

if(isnan(ihyp))
    ihyp=1;
end
if(isnan(stab))
    stab=.000001;
end
if(isnan(phase))
    phase=0;
end
if(isnan(t1))
    t1=.5*(t(end)-t(1));
end
if(isnan(fmin(1)))
    fmin(1)=5;
end
if(isnan(fmin(2)))
    fmin(2)=.5*fmin(1);
end
if(isnan(fmax(1)))
    fmax(1)=.5*fnyq;
end
if(isnan(fmax(2)))
    fmax(2)=.2*(fnyq-fmax(1));
end
if(isnan(fmaxlim(1)))
    fmaxlim(1)=.75*fnyq;
end
if(isnan(fmaxlim(2)))
    fmaxlim(2)=.25*fnyq;
end
if(isnan(fphase))
    fphase=0;
end
if(isnan(max_atten))
    max_atten=80;
end
if(isnan(ipow))
    ipow=1;
end
if(isnan(ipar))
    ipar=1;
end
if(isnan(iwait))
    iwait=0;
end


p=1;
gdb=60;
    
ntr=size(stack,2);

if(length(t)~=size(stack,1))
    error('invalid t coordinate vector')
end

stackg=zeros(size(stack));

small=100*eps;


t0=clock;
filtmask=makegaborfilter(t,twin,tinc,gdb,t1,fmin,fmax,fmaxlim,fphase,max_atten);
if(ipar==1)
    parfor k=1:ntr
        tmp=stack(:,k);
        if(sum(abs(tmp))>small)%avoid deconvolving a zero trace
            stackg(:,k)=gabordeconfilt(stack(:,k),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,filtmask,ipow);
        end
    end
else
    hbar=[];
    if(iwait==1)
        hbar=WaitBar(0,ntr,'Please wait for Gabor decon to complete','Gabor Decon (post stack)');
    end
    ievery=10;
    cancelled=false;
    for k=1:ntr
        tmp=stack(:,k);
        if(sum(abs(tmp))>small)%avoid deconvolving a zero trace
            stackg(:,k)=gabordeconfilt(stack(:,k),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,p,gdb,filtmask,ipow);
        end
        if(rem(k,ievery)==0)
            tnow=clock;
            time_used=etime(tnow,t0);
            time_per_trace=time_used/k;
            time_remaining=(ntr-k)*time_per_trace;
            if(iwait==1)
                if(WaitBarContinue)
                    WaitBar(k,hbar,['Estimated time remaining ' num2str(time_remaining,4) ' seconds']);
                else
                    delete(hbar)
                    cancelled=true;
                    break
                end
            else
                disp(['finished trace ' int2str(k) ' of ' int2str(ntr)])
                disp(['estimated time remaining ' int2str(time_remaining) ' sec'])
            end
        end
    end
    if(~cancelled)
        if(isgraphics(hbar))
            delete(hbar);
        end
    else
        stackg=0;
        disp('Gabor decon cancelled')
    end
end

% tnow=clock;
% time_used=etime(tnow,t0);
% time_per_trace=time_used/ntr;
% disp(['Finished Gabor, total time= ' num2str(time_used/60) ' min'])
% disp(['time-per-trace= ' int2str(1000*time_per_trace) ' ms'])

% amax=max(abs(stackg(:)));
% stackg=stackg/amax;
    

