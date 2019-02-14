%% #1 make a synthetic seismogram
makeconvsynthetic

names={'reflectivity','trace noise-free',['trace s2n=' num2str(s2n)],...
    ['wavelet fdom=' num2str(fdom)]};

figure
subplot(1,2,1)
trplot(t,[r s sn pad_trace(w,r)],'order','d','normalize',1,'tracespacing',1.5);
legend(names,'location','south')
title('time domain')

subplot(1,2,2)
dbspec(t,[r s sn pad_trace(w,r)],'normoption',1);
legend(names,'location','southwest')
title('frequency domain')

prepfiga

%% #2 show the autocorrelation property
w=pad_trace(w,t);

nlags=floor(length(r)/2);
ar=ccorr(r,r,nlags);
as=ccorr(s,s,nlags);
asn=ccorr(sn,sn,nlags);
aw=ccorr(w,w,nlags);
tau=dt*(-nlags:nlags)';

traces=cell(1,4);
autos=traces;
names=traces;

traces{1}=r;
traces{2}=s*max(r)/max(s);
traces{3}=sn*max(r)/max(s);
traces{4}=w;

autos{1}=ar;
autos{2}=as;
autos{3}=asn;
autos{4}=aw;

names{1}='reflectivity';
names{2}='trace';
names{3}='trace noisy';
names{4}='wavelet';
x0=.05;y0=.1;sep=.02;wid=.87*(1-2*x0-sep)/2;ht=1-2*y0;
fs=10;
figure
subplot('position',[x0,y0,wid,ht])
trplot(t,traces,'order','d','normalize',1,'tracespacing',1.5,'color',zeros(1,4))
title('traces (time domain)');titlefontsize(1,1)

subplot('position',[x0+wid+sep,y0,wid,ht])
trplot(tau,autos,'order','d','normalize',1,'tracespacing',1.5,'names',names,'color',zeros(1,4),'fontsize',fs)
xlabel('lag time (sec)')
title('autocorrelations (lag domain)');titlefontsize(1,1)

prepfiga
bigfont(gcf,1.5,1)

print -depsc decongraphics\autocorr.eps

%% #3 examine the estimated wavelets
top=[.05 .1 .2 .3];
nop=round(top/dt);
stab=.00001;
names=cell(1,length(top)+1);
dop=cell(size(top));%decon operators no noise
dopn=dop;%noisy operators
west=cell(1,length(top)+1);%estimated wavelets (no noise)
westn=west;%wavelets with noise
td1=0.5;td2=1.5;
id=near(t,td1,td2);

west{1}=w;
westn{1}=w;
names{1}='true wavelet';
tws=cell(size(west));
tws{1}=tw;

for k=1:length(fsmo)
    [sd,d]=deconw(s,s(id).*mwindow(length(id)),nop(k),stab);
    dop{k}=d;
    west{k+1}=ifft(1./fft(d));
    [sd,d]=deconw(sn,sn(id).*mwindow(length(id)),nop(k),stab);
    dopn{k}=d;
    westn{k+1}=ifft(1./fft(d));
    names{k+1}=['top=' num2str(top(k))];
    tws{k+1}=dt*(0:length(west{k+1})-1)';
end

% [Sd,f]=fftrl(sn(id).*mwindow(length(id)),t(id));
% [Wtrue,fw]=fftrl(w,tw);

figure

subplot(1,2,1)
trplot(tws,west,'order','d','normalize',1)
xlim([0 .5])
legend(names)
title('Wavelet estimation noise free')

subplot(1,2,2)
trplot(tws,westn,'order','d','normalize',1)
xlim([0 .5])
legend(names)
title('Wavelet estimation noisey')

prepfig

figure

subplot(1,2,1)
dbspec(tws,west,'normoption',1);
ylim([-70 0])
legend(names)
title('Wavelet estimation noise free')

subplot(1,2,2)
dbspec(tws,westn,'normopt',1);
ylim([-70 0])
legend(names)
title('Wavelet estimation noisey')
prepfig
%% #4 examine estimated reflectivity versus operator length, noise-free case
top=[.05 .1 .2 .3];
nop=round(top/dt);
stab=0.000001;
%stab=0;
names=cell(1,length(top)+1);
rest=zeros(length(r),length(top));%estimated reflectivity (no noise)
restf=rest;
td1=.5;td2=1.5;
id=near(t,td1,td2);
fmax=200;
rest(:,1)=r;
rf=butterband(r,t,0,fmax,4,0);
restf(:,1)=rf;

names{1}='reflectivity';
ccv=cell(size(names));
ccvf=ccv;
ccv{1}='broadband';
ccvf{1}=['bandlimited to fmax=' num2str(fmax) 'Hz'];

for k=1:length(top)
    [sd,d]=deconw(s,s(id).*mwindow(length(id)),nop(k),stab);
    sd=butterband(sd,t,0,fmax,8,1);
    cc=maxcorr(r,sd);
    ccv{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    cc=maxcorr(rf,sd);
    ccvf{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    rest(:,k+1)=sd;
    restf(:,k+1)=sd;
    names{k+1}=['top=' num2str(top(k))];
end

% [Sd,f]=fftrl(sn(id).*mwindow(length(id)),t(id));
% [Wtrue,fw]=fftrl(w,tw);

figure
fs=12;
subplot(1,2,1)
trplot(t,rest,'order','d','normalize',1,'names',ccv,'fontsize',fs)
xlim([0 2.5]);
%legend(names)
title({'Time domain: Reflectivity estimation noise free',...
    'Correlations to broadband reflectivity'} )

subplot(1,2,2)
dbspec(t,rest);
ylim([-90 0]);
legend(names,'location','southwest')
title({'Frequency domain',...
    ['top=' num2str(top) ', stab=' num2str(stab) ', fmax=' num2str(fmax)]} )

prepfiga

figure

subplot(1,2,1)
trplot(t,restf,'order','d','normalize',1,'names',ccvf,'fontsize',fs)
xlim([0 2.5]);
%legend(names)
title({'Time domain: Reflectivity estimation noise free',...
    'Correlations to bandlimited reflectivity'} )

subplot(1,2,2)
dbspec(t,restf);
ylim([-90 0]);
legend(names,'location','southwest')
title({'Frequency domain',...
    ['top=' num2str(top) ', stab=' num2str(stab) ', fmax=' num2str(fmax)]} )

prepfiga

%% #5 examine estimated reflectivity versus operator length, noisy case
top=[.05 .1 .2 .3];
nop=round(top/dt);
stab=0.000001;
%stab=0;
names=cell(1,length(top)+1);
rest=zeros(length(r),length(top));%estimated reflectivity
restf=rest;
td1=.5;td2=1.5;
id=near(t,td1,td2);
phase=1;
fmax2=200;
fmax1=70;
rest(:,1)=r;
rf=butterband(r,t,0,fmax1,4,0);
restf(:,1)=rf;

names{1}='reflectivity';
ccv=cell(size(names));
ccvf=ccv;
ccv{1}='broadband';
ccvf{1}=['bandlimited to fmax=' num2str(fmax) 'Hz'];




for k=1:length(top)
    [sd,d]=deconw(sn,sn(id).*mwindow(length(id)),nop(k),stab);
    sd1=butterband(sd,t,0,fmax1,4,0);
    sd2=butterband(sd,t,0,fmax2,4,0);
    cc=maxcorr(r,sd2);
    ccv{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    cc=maxcorr(rf,sd1);
    ccvf{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    rest(:,k+1)=sd2;
    restf(:,k+1)=sd1;
    names{k+1}=['top=' num2str(top(k))];
end

% [Sd,f]=fftrl(sn(id).*mwindow(length(id)),t(id));
% [Wtrue,fw]=fftrl(w,tw);

figure
fs=12;
subplot(1,2,1)
trplot(t,rest,'order','d','normalize',1,'names',ccv,'fontsize',fs)
xlim([0 2.5]);
%legend(names)
title({'Time domain: Reflectivity estimation noisy case',...
    'Correlations to broadband reflectivity'} )

subplot(1,2,2)
dbspec(t,rest);
ylim([-90 0]);
legend(names,'location','southwest')
title({'Frequency domain',...
    ['top=' num2str(top) ', stab=' num2str(stab) ', fmax=' num2str(fmax2)]} )

prepfiga

figure

subplot(1,2,1)
trplot(t,restf,'order','d','normalize',1,'names',ccvf,'fontsize',fs)
xlim([0 2.5]);
%legend(names)
title({'Time domain: Reflectivity estimation noisy case',...
    'Correlations to bandlimited reflectivity'} )

subplot(1,2,2)
dbspec(t,restf);
ylim([-90 0]);
legend(names,'location','southwest')
title({'Frequency domain',...
    ['top=' num2str(top) ', stab=' num2str(stab) ', fmax=' num2str(fmax1)]} )

prepfiga