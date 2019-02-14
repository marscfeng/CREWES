seismo_example

wimp=convz(impulse(t),w)*max(sp)/max(w);

figure
fs=8;
subplot(2,1,2)
names={'wavelet','primaries no transmission loss','primaries and multiples','multiples'};
trplot(t,[wimp,sp,spm,spm-sp2],'yaxis','n','order','d','color',{'k','k','k','k'},'names',names,'fontsize',fs)
title(['seismograms with ' int2str(fdom) 'Hz Ricker wavelet'])
titlefontsize(1,1)
xlim([.1 1.3]);ylim([-.02 .17])
subplot(2,1,1)
names={'reflectivity','primaries and multiples','primaries with transmission loss','multiples'};
trplot(t,[rcs,pm,p,pm-p],'yaxis','n','order','d','color',{'k','k','k','k'},'names',names,'fontsize',fs)
title('seismograms with spike wavelet')
titlefontsize(1,1)
xlim([.1 1.3]);ylim([-.1 .6])
set(gca,'xticklabel','');xlabel('')
prepfig
bigfont(gcf,1.5,1)
print -depsc wavepropgraphics\seismo.eps

figure
dbspec(t,[wimp,sp,spm],'graylevels',[0,.7,0],'linewidths',[.5 1.5 .75],'linestyles',{'-','-',':'},'normoption',1);
ylim([-150 0])
legend('wavelet','primaries only','primaries+multiples')
prepfig
bigfont(gcf,1.5,1)
print -depsc wavepropgraphics\seismospec.eps

%% compare rcs in time with and without Goupillaud
imp=rho.*vp;
rz=(imp(2:end)-imp(1:end-1))./(imp(2:end)+imp(1:end-1));
tz=2*vint2t(vp,z);
rcs2=zeros(size(rz));
for k=1:length(rcs)
    ii=near(tz(2:end),t(k));
    rcs2(ii(1))=rcs(k);
end

figure
subplot(2,1,1)
%trplot({tz(2:end),t},{rz,rcs},'colors',{'k','k'},'yaxis','y','order','d','linewidth',[.5 1]);
linesgray({tz(2:end),rcs2,'-',1,.5},{tz(2:end),rz,'-',.5,0})
hl=legend('after Goupillaud at 0.001 sec','directly from logs','location','north');
set(hl,'position',[0.4600 0.8380 0.3137 0.1050]);
subplot(2,1,2)
linesgray({tz(2:end),rcs2,'-',1,.5},{tz(2:end),rz,'-',.5,0})
legend('after Goupillaud at 0.001 sec','directly from logs','location','northwest')
xlim([.7 .8])
prepfig
bigfont(gcf,1.5,1)
print -depsc wavepropgraphics\rcs_tz.eps

%% compute seimograms at different sample rates to show effects
load data\logdata %contains vectors sp (p-wave sonic), rho (density) and z (depth)
dts=[.004 .002 .001 .0005];
spms=cell(size(dts));
sps=spms;
spts=spms;
sms=spms;
ts=spms;
rcss=spms;
names=spms;
fmult=1;%flag for multiple inclusion. 1 for multiples, 0 for no multiples
fpress=0;%flag,  1 for pressure (hydrophone) or 0 for displacement (geophone)
z=z-z(1);%adjust first depth to zero
fdom=60;%dominant frequency of wavelet
tmin=0;tmax=1.0;%start and end times of seismogram
for k=1:length(dts)
    dt=dts(k); %sample rate (seconds) of wavelet and seismogram
    [w,tw]=ricker(dt,fdom,.2);%ricker wavelet
    [spms{k},ts{k},rcss{k},pm,p]=seismo(sp,rho,z,fmult,fpress,w,tw,tmin,tmax);%using Ricker wavelet
    sps{k}=convz(rcss{k},w);%make a primaries only seismogram
    spts{k}=convz(p,w);%primaries with transmission losses
    sms{k}=convz(pm-p,w);%multiples only
    names{k}=['\Delta t =' num2str(dt)];
end

normopt=1;
figure
fs=6;
subplot(3,1,1)
trplot(ts,sps,'color',{'k','k','k','k'},'order','d','names',names,'normalize',normopt,...
    'tracespacing',1.5,'yaxis','n','zerolines','y','fontsize',fs)
title('Seismograms of primaries only');set(gca,'xticklabel','');xlabel('');
titlefontsize(.8,1)
set(gca,'ygrid','off')
if(normopt==1)
    ylim([-3 4])
end
subplot(3,1,2)
trplot(ts,spts,'color',{'k','k','k','k'},'order','d','names',names,'normalize',normopt,...
    'tracespacing',1.5,'yaxis','n','zerolines','y','fontsize',fs)
title('Seismograms of primaries + transmission loss');set(gca,'xticklabel','');xlabel('');
titlefontsize(.8,1)
set(gca,'ygrid','off')
if(normopt==1)
    ylim([-3 4])
end
subplot(3,1,3)
trplot(ts,spms,'color',{'k','k','k','k'},'order','d','names',names,'normalize',normopt,...
    'tracespacing',1.5,'yaxis','n','zerolines','y','fontsize',fs)
title('Seismograms of primaries+multiples')
titlefontsize(.8,1)
set(gca,'ygrid','off')
if(normopt==1)
    ylim([-3 4])
end
prepfig
bigfont(gcf,1.5,1)
print -depsc wavepropgraphics\goupillauddt.eps
%% show transmission loss
ind=near(t,0,.8);
rmax=max(rcs);
tloss=(1-abs(p(ind)./rcs(ind)));
tloss2=(1-abs(pm(ind)./rcs(ind)));

figure
plot(t(ind),tloss,'k',t(ind),tloss2,'k:')
title('transmission loss')
prepfig

figure
plot(t,env(rcs),t,env(p),t,env(pm))


%% include noise
s2n=2;
ind=near(t,t(1),t(end));
noise1=rnoise(sr,s2n,ind,1);
noise0=rnoise(sr,s2n,ind,0);
srn1=sr+noise1;
srn0=sr+noise0;
figure
subplot(2,1,1)
names={'noise free','with normally distributed noise',...
    'with uniformly distributed noise'};
trplot(t,[sr srn1 srn0],'order','d','names',names,'yaxis','y');
title(['Noise free and noisy seismograms with Ricker wavelet s2n=' num2str(s2n)])
xlim([.1 1.2*t(end)])
subplot(2,1,2)
trplot(t,[noise1 noise0],'names',{'normally distributed noise','uniformly distributed noise'},...
    'yaxis','y')
xlim([.1 1.2*t(end)])

prepfig

figure
dbspec(t,[sr srn1 srn0])
legend(names)
title(['Noise free and noisy seismograms with Ricker wavelet s2n=' num2str(s2n)])
xlim([0 250])
ylim([-100 0])
prepfig
boldlines(gcf,2)

figure
subplot(2,1,1)
histogram(noise1,50);
title('normally distributed');
subplot(2,1,2)
histogram(noise0,50)
title('uniformly distributed');
prepfig

%% build and apply a Q matrix
Q=50;
qmat=qmatrix(Q,t,wm,twm);
sn=qmat*rcs;%nonstationary seismogram by matrix vector multiplication
s=convm(rcs,wm);%stationary seismogram for comparison

figure
subplot(2,1,1)
names={'stationary','nonstationary'};
trplot(t,[s sn],'order','d');
title(['stationary and nonstationary seismograms for Q=' int2str(Q)])
subplot(2,1,2)
dbspec(t,[s sn])
title(['Amplitude spectra for stationary and nonstationary seismograms with Q=' int2str(Q)])
legend(names)
prepfig

%spectra in three windows
tw1=[.2 .4];
tw2=[.45 .65];
tw3=[.7 .9];
iw1=near(t,tw1(1),tw1(2));
iw2=near(t,tw2(1),tw2(2));
iw3=near(t,tw3(1),tw3(2));
wflags=ones(1,3);
sl=512;
figure
names={[num2str(tw1(1)) ' to ' num2str(tw1(2)) ' sec'],...
    [num2str(tw2(1)) ' to ' num2str(tw2(2)) ' sec'],...
    [num2str(tw3(1)) ' to ' num2str(tw3(2)) ' sec']};
subplot(1,2,1)
dbspec(t(iw1),[s(iw1) s(iw2) s(iw3)],'windowflags',wflags,'signallength',sl);
title('stationary case')
subplot(1,2,2)
dbspec(t(iw1),[sn(iw1) sn(iw2) sn(iw3)],'windowflags',wflags,'signallength',sl);
title(['nonstationary case Q=' int2str(Q)])
legend(names)
prepfig