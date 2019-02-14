%% make a motivational figure
makeconvsynthetic

names={'reflectivity','trace noise-free',['trace s2n=' num2str(s2n)],...
    ['wavelet fdom=' num2str(fdom)]};

figure
subplot(1,2,1)
trplot(t,[r s sn pad_trace(w,r)],'order','d','normalize',1,'color',[0,.25, .5, .7],'linewidths',[.5 .7 .9 1.5], 'tracespacing',1.5);
legend(names,'location','south')
title('time domain')
titlefontsize(1,1)
subplot(1,2,2)
dbspec(t,[r s sn pad_trace(w,r)],'normoption',1,'graylevels',[0,.25, .5, .7],'linewidths',[.5 .7 .9 1.5]);
legend(names,'location','southwest')
title('frequency domain')
titlefontsize(1,1)
prepfig
bigfont(gcf,1.25,1)

print -depsc decongraphics\deconmotivation.eps

%% deconvolve noiseless and noisy traces with common parameters
makeconvsyntheticspike

deconf_test1

names={'reflectivity','noiseless input','deconf',['deconf fmax=' int2str(fmax)]};
namesn={'reflectivity','noisey input','deconf',['deconf fmax=' int2str(fmaxn)]};

figure
fs=8;
x0=.02;y0=.1;wid=.4;sep=.08;ht=1-2*y0;
ya='n';
bc='w';
zt=10;
subplot('position',[x0,y0,wid,ht])
trplot(t,[r,s,sd,sdb],'normalize',1,'order','d','names',names,'fontsize',fs,...
    'color',zeros(1,4),'tracespacing',1.25,'namesalign','left','nameshift',0,'yaxis',ya)
text(1,0,zt,str,'fontsize',fs,'backgroundcolor',bc)
text(1,-1.2,zt,strb,'fontsize',fs,'backgroundcolor',bc)
text(0.05,3.6,'A','fontsize',14,'fontweight','bold')
xlim([0 2.5])
subplot('position',[x0+wid+sep,y0,wid,ht])
trplot(t,[r,sn,sdn,sdnb],'normalize',1,'order','d','names',namesn,'fontsize',fs,...
    'color',zeros(1,4),'tracespacing',1.25,'namesalign','left','nameshift',0,'yaxis',ya)
text(1,0,zt,strn,'fontsize',fs,'backgroundcolor',bc)
text(1,-1.2,zt,strnb,'fontsize',fs,'backgroundcolor',bc)
text(0.05,3.6,'B','fontsize',14,'fontweight','bold')
xlim([0 2.5])

prepfig

print -depsc decongraphics\deconftest1_time.eps

%spectral picture
figure
lw=[.5 1 1.2 1.5];
gl=[0,.25,.5,.7];
ls={':','-','-','-'};
subplot(1,2,1)
dbspec(t,[r s sn pad_trace(w,r)],'normoption',1,'graylevels',gl,'linewidths',lw,'linestyles',ls);
names={'reflectivity','trace noise-free',['trace s2n=' num2str(s2n)],...
    ['wavelet fdom=' num2str(fdom)]};
legend(names,'location','southwest')
title('Before deconf')
subplot(1,2,2)
dbspec(t,[r sd sdn],'normoption',1,'graylevels',gl(1:3),'linewidths',lw(1:3),'linestyles',ls(1:3));
names={'reflectivity','trace noise-free',['trace s2n=' num2str(s2n)]};
legend(names,'location','southwest')
title('After deconf')
prepfig

print -depsc decongraphics\deconftest1_freq.eps

%% #2 examine spectral smoothing with different windows
fsmo=10;
df=1/tmax;
nop=round(fsmo/df);
names={'boxcar','triangle','gaussian'};
dop=cell(size(names));%decon operators
west=dop;%estimated wavelets
td1=.5;td2=1.5;
id=near(t,td1,td2);
stab=0;phase=1;

for k=1:length(names)
    [sd,specinv]=deconf(s,s(id).*mwindow(length(id)),nop,stab,phase,'smoothertype',names{k});
    dop{k}=real(ifft(fftshift(specinv)));
    west{k}=real(ifft(fftshift(1./specinv)));
end

[Sd,f]=fftrl(s(id).*mwindow(length(id)),t(id));
[Wtrue,fw]=fftrl(w,tw);

figure

subplot(1,2,1)
plot(f,todb(abs(Sd)));
hold on
names2=cell(1,length(names)+1);
names2{1}='design spectrum';
for k=1:length(names)
    [W,f2]=fftrl(west{k}(1:length(id)),t(id));
    A=abs(W);
    plot(f2,todb(A))
    names2{k+1}=names{k};
end
grid
ylabel('decibels');xlabel('frequency (Hz)')
xlim([0 200]);ylim([-80 0])
legend(names2)
title(['spectral smoothing with fsmo=' num2str(fsmo) 'Hz'])

subplot(1,2,2)
h=plot(fw,todb(abs(Wtrue)));
set(h,'linewidth',1.5)
hold on
names2=cell(1,length(names)+1);
names2{1}='wavelet spectrum';
for k=1:length(names)
    [W,f2]=fftrl(west{k}(1:length(id)),t(id));
    A=abs(W);
    plot(f2,todb(A))
    names2{k+1}=names{k};
end
grid
ylabel('decibels');xlabel('frequency (Hz)')
xlim([0 200]);ylim([-80 0])
legend(names2)
title(['wavelet estimation with fsmo=' num2str(fsmo) 'Hz'])

prepfig

%% #3 examine stab
fsmo=10;
df=1/tmax;
nop=round(fsmo/df);
stabs=[.0001; .001; .01; .1];
names=cell(size(stabs));
dop=cell(size(stabs));%decon operators
west=dop;%estimated wavelets
td1=.5;td2=1.5;
id=near(t,td1,td2);
phase=1;

for k=1:length(stabs)
    [sd,specinv]=deconf(sn,sn(id).*mwindow(length(id)),nop,stabs(k),phase);
    dop{k}=real(ifft(fftshift(specinv)));
    west{k}=real(ifft(fftshift(1./specinv)));
    names{k}=['stab=' num2str(stabs(k))];
end

[Sd,f]=fftrl(sn(id).*mwindow(length(id)),t(id));
[Wtrue,fw]=fftrl(w,tw);

figure

subplot(1,2,1)
plot(f,todb(abs(Sd)));
hold on
names2=cell(1,length(names)+1);
names2{1}='design spectrum';
for k=1:length(names)
    [W,f2]=fftrl(west{k}(1:length(id)),t(id));
    A=abs(W);
    plot(f2,todb(A));
    names2{k+1}=names{k};
end
grid
ylabel('decibels');xlabel('frequency (Hz)')
xlim([0 200]);ylim([-70 0])
legend(names2,'location','southwest')
title(['effect of stab factor on noisy spectrum'])

subplot(1,2,2)
h=plot(fw,todb(abs(Wtrue)));
set(h,'linewidth',1.5)
hold on
names2=cell(1,length(names)+1);
names2{1}='wavelet spectrum';
for k=1:length(names)
    [W,f2]=fftrl(west{k}(1:length(id)),t(id));
    A=abs(W);
    plot(f2,todb(A));
    names2{k+1}=names{k};
end
grid
ylabel('decibels');xlabel('frequency (Hz)')
xlim([0 200]);ylim([-70 0])
legend(names2,'location','southwest')
title(['wavelet estimation with fsmo=' num2str(fsmo) 'Hz'])

prepfig

%% #4 examine estimated wavelets versus smoother length
fsmo=[20 10 5 1];
df=1/tmax;
nop=round(fsmo/df);
stab=.00001;
names=cell(1,length(fsmo)+1);
dop=cell(size(fsmo));%decon operators no noise
dopn=dop;%noisy operators
west=cell(1,length(fsmo)+1);%estimated wavelets (no noise)
westn=west;%wavelets with noise
td1=0.5;td2=1.5;
id=near(t,td1,td2);
phase=1;

west{1}=w;
westn{1}=w;
names{1}='true wavelet';
tws=cell(size(west));
tws{1}=tw;

for k=1:length(fsmo)
    [sd,specinv]=deconf(s,s(id).*mwindow(length(id)),nop(k),stab,phase);
    dop{k}=real(ifft(fftshift(specinv)));
    west{k+1}=real(ifft(fftshift(1./specinv)));
    [sd,specinv]=deconf(sn,sn(id).*mwindow(length(id)),nop(k),stab,phase);
    dopn{k}=real(ifft(fftshift(specinv)));
    westn{k+1}=real(ifft(fftshift(1./specinv)));
    names{k+1}=['fsmo=' num2str(fsmo(k))];
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


%% #5 examine estimated reflectivity versus smoother length, noise-free case
fsmo=[20 10 5 1];
df=1/tmax;
nop=round(fsmo/df);
stab=0.000001;
%stab=0;
names=cell(1,length(fsmo)+1);
rest=zeros(length(r),length(fsmo));%estimated reflectivity (no noise)
restf=rest;
td1=.5;td2=1.5;
id=near(t,td1,td2);
phase=1;
fmax=200;
rest(:,1)=r;
rf=butterband(r,t,0,fmax,4,0);
restf(:,1)=rf;

names{1}='reflectivity';
ccv=cell(size(names));
ccvf=ccv;
ccv{1}='broadband';
ccvf{1}=['bandlimited to fmax=' num2str(fmax) 'Hz'];

for k=1:length(fsmo)
    [sd,specinv]=deconf(s,s(id).*mwindow(length(id)),nop(k),stab,phase);
    sd=butterband(sd,t,0,fmax,8,1);
    cc=maxcorr(r,sd);
    ccv{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    cc=maxcorr(rf,sd);
    ccvf{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    rest(:,k+1)=sd;
    restf(:,k+1)=sd;
    names{k+1}=['fsmo=' num2str(fsmo(k))];
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
    ['fsmo=' num2str(fsmo) ', stab=' num2str(stab) ', fmax=' num2str(fmax)]} )

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
    ['fsmo=' num2str(fsmo) ', stab=' num2str(stab) ', fmax=' num2str(fmax)]} )

prepfiga
%% #6 examine estimated reflectivity versus smoother length, noisy case
fsmo=[20 10 5 1];
df=1/tmax;
nop=round(fsmo/df);
stab=0.000001;
%stab=0;
names=cell(1,length(fsmo)+1);
rest=zeros(length(r),length(fsmo));%estimated reflectivity
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




for k=1:length(fsmo)
    [sd,specinv]=deconf(sn,sn(id).*mwindow(length(id)),nop(k),stab,phase);
    sd1=butterband(sd,t,0,fmax1,4,0);
    sd2=butterband(sd,t,0,fmax2,4,0);
    cc=maxcorr(r,sd2);
    ccv{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    cc=maxcorr(rf,sd1);
    ccvf{k+1}=['cc(1)=' num2str(sigfig(cc(1),2)) ', cc(2)=' num2str(cc(2))];
    rest(:,k+1)=sd2;
    restf(:,k+1)=sd1;
    names{k+1}=['fsmo=' num2str(fsmo(k))];
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
    ['fsmo=' num2str(fsmo) ', stab=' num2str(stab) ', fmax=' num2str(fmax2)]} )

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
    ['fsmo=' num2str(fsmo) ', stab=' num2str(stab) ', fmax=' num2str(fmax1)]} )

prepfiga