%explore Gabor decon
%% make the nostationary synthetic. Skip if already made
makeQsynthetic;
%% examine the gabor spectra of the parts and the Gabor factorization

mw=mwhalf(length(t),10);%window to slightly taper the end of the signal

twin=.15;%Gaussian window width
tinc=.025;%spacing between windows
[tvsr,trow,fcol]=fgabor(r.*mw,t,twin,tinc);
tmax=2;
ind=near(trow,0,tmax);
tvsr=tvsr(ind,:);
trow=trow(ind);

Atten=exp(-pi*trow(:)*fcol/Q);
[W,f]=fftrl(w,tw,0,2048);
Aw=abs(W)';
TVSw=Aw(ones(size(trow)),:);

%make picture showing the three factors
figure
tdel=.5*max(t)/length(trow);
xnot=.1;ynot=.15;
xnow=xnot;ynow=ynot;
xsep=0.02;
ht=1-2*ynot;wid=.1;
subplot('position',[xnow,ynow,wid,ht])
plot(r,t,'k');flipy
ylabel('time (sec)');
set(gca,'xtick','')
title('Reflectivity');titlefontsize(1,1)
ylim([-tdel max(trow)+tdel])
grid
xnow=xnow+wid+xsep;
wid=(1-2*xnot-3*xsep-wid)/3;
subplot('position',[xnow,ynow,wid,ht]);
clim=([-40 0]);
imagesc(fcol,trow,real(todb(tvsr)),clim);colormap(flipud(gray))
xlabel('frequency (Hz)');
set(gca,'yticklabel','','gridcolor',.9*ones(1,3));
grid
title('Gabor spectrum of reflectivity');titlefontsize(1,1)

xnow=xnow+wid+xsep;
subplot('position',[xnow,ynow,wid,ht])
imagesc(fcol,trow,real(todb(Atten)),clim);
xlabel('frequency (Hz)');
set(gca,'yticklabel','');
grid
title('Attenuation \alpha(t,f)');titlefontsize(1,1)

xnow=xnow+wid+xsep;
subplot('position',[xnow,ynow,wid,ht])
imagesc(fcol,trow,real(todb(TVSw)),clim)
xlabel('frequency (Hz)');
set(gca,'yticklabel','');
grid
title('Source signature (wavelet)');titlefontsize(1,1)
h=colorbar;
posa=get(gca,'position');
posc=get(h,'position');
set(gca,'position',[posa(1:2) posa(3)+posc(3) posa(4)])
set(h,'position',[posa(1)+posa(3)+posc(3)+.25*xsep posc(2:4)])

prepfiga
bigfont(gcf,1.25,1)
print -depsc decongraphics\gaborfactors.eps

%make piture showing the factors assembled
TVSwp=TVSw.*Atten;% the propagating wavelet
tvsQ=fgabor(sq.*mw,t,twin,tinc);%gabor spec of the trace
tvsQ=tvsQ(ind,:);
TVSmod=TVSwp.*abs(tvsr);%model gabor spec

figure
tdel=.5*max(t)/length(trow);
xnot=.1;ynot=.15;
xnow=xnot;ynow=ynot;
xsep=0.02;
ht=1-2*ynot;wid0=.1;
wid=(1-2*xnot-3*xsep-wid0)/3;
clim=[-80 0];
ha=subplot('position',[xnow,ynow,wid,ht]);
imagesc(fcol,trow,real(todb(TVSwp)),clim);colormap(flipud(gray))
xlabel('frequency (Hz)');ylabel('time (sec)');
title('Propagating wavelet');titlefontsize(1,1)
grid
h=colorbar;

xnow=xnow+wid+xsep+posc(3);
subplot('position',[xnow,ynow,wid,ht])
imagesc(fcol,trow,real(todb(TVSmod)),clim);
xlabel('frequency (Hz)');
set(gca,'yticklabel','');
title('Gabor spectrum model');titlefontsize(1,1)
grid

xnow=xnow+wid+xsep;
subplot('position',[xnow,ynow,wid,ht])
imagesc(fcol,trow,real(todb(tvsQ)),clim);
xlabel('frequency (Hz)');
set(gca,'yticklabel','');
title('Actual Gabor spectrum');titlefontsize(1,1)
grid

xnow=xnow+wid+xsep;
subplot('position',[xnow,ynow,wid0,ht]);
plot(sq,t,'k');flipy
set(gca,'xtick','','yticklabel','')
title('Nonstationary trace');titlefontsize(1,1)
ylim([-tdel max(trow)+tdel])
grid
prepfiga
bigfont(gcf,1.25,1)
posc=get(h,'position');
posa=get(ha,'position');
set(ha,'position',[posa(1:2) posa(3)+posc(3) posa(4)])
set(h,'position',[posa(1)+posa(3)+posc(3)+.25*xsep posc(2:4)])
print -depsc decongraphics\gabormodel.eps


%% run gabordecon on the nonstationary noisefree synthetic
gabordcn

%normalize
sgb=sgb*max(r)/max(sgb);
sgh=sgh*max(r)/max(sgh);

%measure cc stats in 3 windows
t1=[.25,.75,1.25];
t2=t1+.5;
iwin=near(t,t1(1),t2(1));%window1
ncc=40;%number of correlation lags
mw=mwindow(length(iwin));
[x,strb1]=maxcorr_ephs(r(iwin).*mw,sgb(iwin).*mw,ncc);%measure cc and phase
[x,strh1]=maxcorr_ephs(r(iwin).*mw,sgh(iwin).*mw,ncc);%measure cc and phase
iwin=near(t,t1(2),t2(2));%window2
ncc=40;%number of correlation lags
[x,strb2]=maxcorr_ephs(r(iwin).*mw,sgb(iwin).*mw,ncc);%measure cc and phase
[x,strh2]=maxcorr_ephs(r(iwin).*mw,sgh(iwin).*mw,ncc);%measure cc and phase
iwin=near(t,t1(3),t2(3));%window3
ncc=40;%number of correlation lags
[x,strb3]=maxcorr_ephs(r(iwin).*mw,sgb(iwin).*mw,ncc);%measure cc and phase
[x,strh3]=maxcorr_ephs(r(iwin).*mw,sgh(iwin).*mw,ncc);%measure cc and phase

%make trace plot
ind=near(t,0,2.2);
figure
names={'reflectivity','Gabor boxcar','Gabor hyperbolic'};
trplot(t(ind),[r(ind),sgb(ind),sgh(ind)],'order','d','names',names,'color',zeros(1,3),'tracespacing',1.5,'yaxis','y');
%annotate statistics
yb=0;fs=8;inc=.02;
text(.5,yb,1,strb1,'fontsize',fs);
text(1,yb-inc,1,strb2,'fontsize',fs);
text(1.5,yb-2*inc,1,strb3,'fontsize',fs);
yh=-.15;
text(.5,yh,1,strh1,'fontsize',fs);
text(1,yh-inc,1,strh2,'fontsize',fs);
text(1.5,yh-2*inc,1,strh3,'fontsize',fs);
%indicate windows
y1=.15;y2=.3;
line([t1(1) t1(1)],[y1,y2],'linestyle','--','color',.2*ones(1,3),'linewidth',1)
text(t1(1),y2-inc,1,'window 1','fontsize',fs);
line([t1(2) t1(2)],[y1,y2],'linestyle','--','color',.2*ones(1,3),'linewidth',1)
text(t1(2),y2-inc,1,'window 2','fontsize',fs);
line([t1(3) t1(3)],[y1,y2],'linestyle','--','color',.2*ones(1,3),'linewidth',1)
text(t1(3),y2-inc,1,'window 3','fontsize',fs);
line([t2(3) t2(3)],[y1,y2],'linestyle','--','color',.2*ones(1,3),'linewidth',1)

xlim([0,2.7])
xtick(0:.25:2);
ylim([-.2 .3])
prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\gabordecon1.eps

%% run gabordecon on the nonstationary noisey synthetic
gabordcn_n

%normalize
sgbn=sgbn*max(r)/max(sgbn);
sghn=sghn*max(r)/max(sghn);
sgbnf=sgbnf*max(r)/max(sgbnf);
sghnf=sghnf*max(r)/max(sghnf);
%measure cc stats in 3 windows
t1=[.25,.75,1.25];
t2=t1+.5;
iwin=near(t,t1(1),t2(1));%window1
ncc=40;%number of correlation lags
mw=mwindow(length(iwin));
[x,strb1]=maxcorr_ephs(r(iwin).*mw,sgbnf(iwin).*mw,ncc);%measure cc and phase
[x,strh1]=maxcorr_ephs(r(iwin).*mw,sghnf(iwin).*mw,ncc);%measure cc and phase
iwin=near(t,t1(2),t2(2));%window2
ncc=40;%number of correlation lags
[x,strb2]=maxcorr_ephs(r(iwin).*mw,sgbnf(iwin).*mw,ncc);%measure cc and phase
[x,strh2]=maxcorr_ephs(r(iwin).*mw,sghnf(iwin).*mw,ncc);%measure cc and phase
iwin=near(t,t1(3),t2(3));%window3
ncc=40;%number of correlation lags
[x,strb3]=maxcorr_ephs(r(iwin).*mw,sgbnf(iwin).*mw,ncc);%measure cc and phase
[x,strh3]=maxcorr_ephs(r(iwin).*mw,sghnf(iwin).*mw,ncc);%measure cc and phase

%make trace plot

ind=near(t,0,2.2);
figure
fs=8;
names={'reflectivity','Gabor boxcar','boxcar filtered','Gabor hyperbolic','hyperbolic filtered'};
trplot(t(ind),[r(ind),sgbn(ind),sgbnf(ind),sghn(ind),sghnf(ind)],'order','d','names',names,...
    'color',zeros(1,5),'tracespacing',1.5,'fontsize',fs);
%annotate statistics
yb=0.06;fs=7;inc=.02;
text(.5,yb,1,strb1,'fontsize',fs);
text(1,yb-inc,1,strb2,'fontsize',fs);
text(1.5,yb-2*inc,1,strb3,'fontsize',fs);
yh=-.25;
text(.5,yh,1,strh1,'fontsize',fs);
text(1,yh-inc,1,strh2,'fontsize',fs);
text(1.5,yh-2*inc,1,strh3,'fontsize',fs);
%indicate windows
y1=.35;y2=.5;
line([t1(1) t1(1)],[y1,y2],'linestyle','--','color',.2*ones(1,3))
text(t1(1),y2-inc,1,'window 1','fontsize',fs);
line([t1(2) t1(2)],[y1,y2],'linestyle','--','color',.2*ones(1,3))
text(t1(2),y2-inc,1,'window 2','fontsize',fs);
line([t1(3) t1(3)],[y1,y2],'linestyle','--','color',.2*ones(1,3))
text(t1(3),y2-inc,1,'window 3','fontsize',fs);
line([t2(3) t2(3)],[y1,y2],'linestyle','--','color',.2*ones(1,3))

title(['stab=' num2str(stab) ', f_0=' num2str(f0) ', t_0=' num2str(t0)]);titlefontsize(1,1)

xlim([0,2.7])
xtick(0:.25:2);
ylim([-.34 .5])
prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\gabordecon2.eps

%make some Gabor plots
twin=.3;tinc=.05;
figure
xnot=.1;ynot=.15;xsep=.05;
wid=(1-2*xnot-2*xsep)/3;
ht=.8;
xnow=xnot;
subplot('position',[xnow,ynot,wid,ht])
[tvs,trow,fcol]=fgabor(sqn,t,twin,tinc,1,60,1,0);
ifreq=near(fcol,0,150);
clim=[-80 0];
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);colormap(seisclrs)
ylabel('time (s)');
xtick(0:25:150);
grid
title('Before Gabor decon');titlefontsize(1,1)
xlabel('frequency (Hz)');
grid
xnow=xnow+xsep+wid;
subplot('position',[xnow,ynot,wid,ht])
[tvs,trow,fcol]=fgabor(sghn,t,twin,tinc,1,60,1,0);
ifreq=near(fcol,0,150);
clim=[-80 0];
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);colormap(seisclrs)
ylabel('time (s)');
xtick(0:25:150);
grid
title('After Gabor decon');titlefontsize(1,1)
xlabel('frequency (Hz)');
grid
xnow=xnow+xsep+wid;
subplot('position',[xnow,ynot,wid,ht])
[tvs,trow,fcol]=fgabor(sghnf,t,twin,tinc,1,60,1,0);
ifreq=near(fcol,0,150);
clim=[-80 0];
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);colormap(seisclrs)
ylabel('time (s)');
xtick(0:25:150);
title('After hyperfilt');titlefontsize(1,1)
xlabel('frequency (Hz)');
grid
prepfiga
bigfont(gcf,1.25,1)
pos=get(gcf,'position');
set(gcf,'position',[pos(1:3) 600])

print -depsc decongraphics\gabordecon3.eps
%% study the effect of different stab values
tsmoh=1;%temporal smoother for boxcar
fsmoh=5;%frequency smoother for boxcar
stabs=[.01 .001 0.0001 0.00001 0.000001 0.0000001];%stability factors
ihyp=1;%flag for hyperbolic
sghs=zeros(length(sq),length(stabs));
names=cell(1,length(stabs)+1);
names{1}='reflectivity';
for k=1:length(stabs)
    tmp=gabordecon(sq,t,twin,tinc,tsmob,fsmob,ihyp,stabs(k));%hyperbolic, no noise
    sghs(:,k)=tmp*max(r)/max(tmp);
    names{k+1}=['stab = ' num2str(stabs(k))];
end
ind=near(t,0,2.2);
figure
trplot(t(ind),[r(ind) sghs(ind,:)],'order','down','names',names,'color',zeros(size(names)));
prepfig


