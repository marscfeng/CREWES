function [fd,afd,sigma,tfd]=tv_afdom2(s,t,twin,tinc,fmt0,interpflag,p,fc)
% TVFDOM3: This is a vectorized version of tvfdom. It is called by tvfdom3D.
%
% [fd,afd,sigma,tfd]=tv_afdom(s,t,twin,tinc,fmt0,interpflag,fc)
% 
% If S is the Fourier transform of the input signal, then the dominant frequency is estimated by the
% centroid method fdom=Int(f*abs(S).^p)/Int(abs(S).^p) where f is frequency, Int is an integral over
% frequency, and p is typically 2. To make the calculation time variant, the signal is windowed with
% a sliding Gaussian of specified standard deviation and center time prior to the dominant frequency
% calculation. There will be one dominant frequency calculation for every discrete window position.
% The discrete window positions will be t(1):tinc:t(end) (tinc is the window increment). For best
% results tinc should be somewhat smaller than twin (twin is the window half-width) but somewhat
% greater than dt=t(2)-t(1). For example, if dt=.001, then twin=.01 and tinc=.004 are reasonable
% choices. However, all datasets are unique so it is best to try a several different choices.
%
% NOTE: tvfdom produces identical results to tvfdom3 or tvfdom3D but the latter are vectorized for
% speed on large datasets. The former is easier to understand but is slower. Use tvfdom on single
% traces or 2D data. If your data is organized as a 3D matrix use tvfdom3D. If it is a very large 2D
% matrix, and you are a confident coder, use tvfdom3 in a loop where you send it 1000 trace panels
% of data one at a time.
%
% s ... seismic trace or gather, one trace per column
% t ... time coordinate for s
% NOTE: Length of t must equal the number of rows of s
% twin ... width (seconds) of the Gaussian window (standard deviation)
% tinc ... temporal shift (seconds) between windows
% fmt0 ... length 2 vector specifying a maximum signal frequency at some
%           time. For example, if signal is known to be bounded by 100Hz at 1 second then
%           fmt0=[100,1]. This determines the maximum frequency of integration at that time. For all
%           other times, fm is hyperbolically interpolated. That is, for time tk, fmk will be
%           fmk=fmt0(1)*fmt0(2)/tk.
%           NOTE: fmt0 can be specified as a single scalar in which case it is assumed the maximum
%           frequency is fmt0 and not time variant.
% interpflag ... 0 means the fd values will fall of the sparse time grid of
%      tnot=t(1):tinc:t(end) while 1 means they will be interpolated with 1D spline to provide a
%      value for every t.
% ************ default is 1 ***********
% p ... small integer used in the calculation
% ************ default is 2 ***********
% fc ... causality factor, should be a value between -10 and 10. 1 means the
%       window is a symmetric Gaussian, while 10 means the Gaussian is asymmetric decaying 10 times
%       faster for times earlier than the center time. Negative numbers give an anticausal window.
% ************ default is 1 ***********
% NOTE: Values greater than 5 are not recommended. To get comparable resolution for two different
% calculations with fc=1 and fc=5, the value of twin for fc=1 should be half of that used for fc=5.
%
% fd ... vector or matrix with the same number of columns as s giving the
%      estimated dominant frequencies. The number of rows in fd depends on the choice for
%      interpflag.
% afd ... same size as fd where the sample values are amplitude not frequency.
% sigma ... same size as fd but estimates the standard deviation of the spectrum
% tfd ... time coordinate vector for fd.
% 

if(nargin<6)
    interpflag=1;
end
if(nargin<7)
    p=2;
end
if(nargin<8)
    fc=1;
end

[nsamps,ntraces]=size(s);
if((nsamps-1)*(ntraces-1)==0)
    s=s(:);
    ntraces=1;
    nsamps=length(s);
end

t=t(:);
if(length(t)~=nsamps)
    error('t has the wrong length')
end
dt=t(2)-t(1);

tstart=t(1);
t=t-tstart;

if(tinc>twin)
    error('tinc should be less than twin');
end

%measurement sites
tnot=(t(1):tinc:t(end))';
% if(interpflag==1)
%     fd=zeros(size(s));
% else
%     fd=zeros(length(tnot),ntraces);
% end

% ipad=1;
% if(ipad==1)
%     n2=2^nextpow2(length(t));
%     tpad=(t(2)-t(1))*(0:n2-1)';
% else
%     tpad=t;
% end

%determine a number of samples that is a power of 2 and which exceeds
%8*twin
n0=round(8*twin/dt);
n2=2^nextpow2(n0);

s=[s;zeros(n2,ntraces)];

fdtmp=zeros(length(tnot),ntraces);
afdtmp=fdtmp;
sigma=fdtmp;
%gs=zeros(length(t),length(tnot));
%tbegin=clock;
%ievery=200;
small=100*eps;
tpad=[t;(t(end)+dt:dt:t(end)+n2*dt)'];
%test for zero trace
tmp=sum(abs(s));
izero=tmp<small;
ilive=~izero;
stmp=s(:,ilive);
nlive=size(stmp,2);
stab=.00001;
small=10000*eps;
for k=1:length(tnot)
    
    %make the gaussian
    %g=exp(-(tpad-tnot(k)).^2/twin^2);
    inot=round(tnot(k)/dt)+1;
    it0=max([1 inot-n2/2]);
    it1=it0+n2-1;
    it=it0:it1;
    g=gcausal(tpad(it),tnot(k),twin,fc);
    gg=g(:,ones(1,nlive));
    %gs(:,k)=g(1:length(t));
    %pad the trace
    %stmp=pad(s(:,kk),tpad);
    %window and transform
    [S,f]=fftrl(stmp(it,:).*gg,tpad(it));
    nf=length(f);
    df=f(2);
    fnyq2=f(round(nf/2));
    %fnyq2=f(nf);
    %determine frequency range
    if(length(fmt0)==1)
        fmk=fmt0;
    else
        if(tnot(k)~=0)
            fmk=fmt0(1)*fmt0(2)/tnot(k);
            if(fmk>fnyq2)
                fmk=fnyq2;
            end
        else
            fmk=fnyq2;
        end
    end
    %         indf=near(f,0,fmk);
    %         %compute fdom
    %         fdtmp(k)=sum(f(indf).*abs(S(indf)).^p)/sum(abs(S(indf)).^p);
    Wf=ones(size(f));
    indf=near(f,fmk,f(end));
    sigma=.1*f(end);
    Wf(indf)=exp(-(f(indf)-fmk).^2/sigma^2);%Wf is a high frequency cutoff
    Wff=Wf(:,ones(1,nlive));
    A=abs(S.*Wff).^p;%sum amplitudes to power p with high freq cutoff
    ff=f(:,ones(1,nlive));
    AA=sum(A);
    Amax=max(AA);
    if(Amax<small)
        Amax=1;
    end
    BB=sum(ff.*A);
    fdtmp(k,ilive)=BB./(AA+stab*Amax);
    CC=sum(A.*(ff-fdtmp(k,ilive)).^2);
    sigma(k,ilive)=sqrt(CC./(AA+stab*Amax));
    indf=round(fdtmp(k,:)/df)+1;
    kay=0;
    for kk=1:size(fdtmp,2)
        if(ilive(kk))
            kay=kay+1;
            afdtmp(k,kk)=A(indf(kay),kay);
        end
    end
%     if(k==500)
%         disp('hey');
%     end
    %         ind=AA==0;
    %         fdtmp(k,ilive(~ind))=BB(~ind)./AA(~ind);
    %         fdtmp(k,ilive(ind))=0;
    %         if(rem(k,ievery)==0)
    %             timeused=etime(clock,tbegin);
    %             time_per_tnot=timeused/k;
    %             timeremaining=(length(tnot)-k)*time_per_tnot;
    %             disp(['finished time ' int2str(k) ' of ' int2str(length(tnot)) ' total'])
    %             disp([' time used ' int2str(timeused) '(s), time remaining ' int2str(timeremaining) '(s) or ' num2str(timeremaining/60) '(m)'])
    %         end
end

if(interpflag==1)
    fd=zeros(nsamps,ntraces);
    afd=fd;
    test=sum(abs(fdtmp(:)));
    if(test>0)
        fd(:,ilive)=interp1(tnot,fdtmp(:,ilive),t,'spline');
        afd(:,ilive)=interp1(tnot,afdtmp(:,ilive),t,'spline');
    end
    tfd=t;
else
    fd=fdtmp;
    afd=afdtmp;
    tfd=tnot;
end
tfd=tfd+tstart;
ind=find(fd<0);%this happens because of the interpolation
if(~isempty(ind))
    fd(ind)=0;
    afd(ind)=0;
end
    
%     timeused=etime(clock,tbegin);
%     disp(['total time ' num2str(timeused) '(s)'])

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
