makeQsynthetic

%trace plot
figure
names={'stationary','stationary noisy','nonstationary','nonstationary noisy'};
trplot(t,[s,sn,sq,sqn],'order','d','color',zeros(1,4),'names',names,'namesalign','right','nameshift',.2);
prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\nonstattraces.eps

twin=.3;tinc=.05;
axwid=.38;axht=.38;
x0=.1;y0=.15;sepx=.07;sepy=.05;
figure
subplot('position',[x0,y0+axht+sepy,axwid,axht]);
[tvs,trow,fcol]=fgabor(s,t,twin,tinc,1,60,1,0);
ifreq=near(fcol,0,150);
clim=[-80 0];
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);colormap(seisclrs)
ylabel('time (s)');
xtick(0:25:150);
set(gca,'xticklabel','');grid
title('stationary');titlefontsize(1,1)
subplot('position',[x0+axwid+sepx,y0+axht+sepy,axwid,axht])
[tvs,trow,fcol]=fgabor(sn,t,twin,tinc,1,60,1,0);
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);
set(gca,'xticklabel','','yticklabel','');grid
xtick(0:25:150);
title('stationary noisy');titlefontsize(1,1)
subplot('position',[x0,y0,axwid,axht]);
[tvs,trow,fcol]=fgabor(sq,t,twin,tinc,1,60,1,0);
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);
ylabel('time (s)');xlabel('frequency (Hz)');grid
xtick(0:25:150);
hc=colorbar;
set(hc,'axislocation','in','position',[0.51 .3 0.0199    0.4002]);
set(gca,'position',[x0,y0,axwid,axht])
title('nonstationary');titlefontsize(1,1)
subplot('position',[x0+axwid+sepx,y0,axwid,axht])
[tvs,trow,fcol]=fgabor(sqn,t,twin,tinc,1,60,1,0);
imagesc(fcol(ifreq),trow,real(todb(tvs(:,ifreq))),clim);
xlabel('frequency (Hz)')
set(gca,'yticklabel','');grid
xtick(0:25:150);
title('nonstationary noisy');titlefontsize(1,1)
prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\nonstatspectra.eps


twin=.5;
twins=twin*ones(1,3);
tnots=[.3 1. 1.7];
tpad=length(t);
%gl=[0 .3 .5 .7];
%lw=[.5 .75 1 1.25];
gl=[0 .7 .5 .3];
lw=[.5 1.25 1 .75];
axwid=.38;axht=.4;
x0=.1;y0=.1;sepx=.07;sepy=.05;
figure
subplot(2,2,1);
hh=tvdbspec(t,s,tnots,twins,tpad,'');
for k=1:4
    set(hh(k),'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
xlabel('')
xlim([0 150]);
ylim([-80 0])
title('Stationary');titlefontsize(1,1)
hl=findobj(gcf,'type','legend');
set(hl,'position',[0.3600 0.7715 0.1456 0.1706])


subplot(2,2,2)
hh=tvdbspec(t,sn,tnots,twins,tpad,'');
for k=1:4
    set(hh(k),'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
xlabel('')
xlim([0 150]);
ylim([-80 0])
title('Stationary noisy');titlefontsize(1,1)
legend off

subplot(2,2,3);
hh=tvdbspec(t,sq,tnots,twins,tpad,'');
for k=1:4
    set(hh(k),'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
xlim([0 150]);
ylim([-80 0])
title('Nonstationary');titlefontsize(1,1)
legend off

subplot(2,2,4)
hh=tvdbspec(t,sqn,tnots,twins,tpad,'');
for k=1:4
    set(hh(k),'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
xlim([0 150]);
ylim([-80 0])
title('Nonstationary noisy');titlefontsize(1,1)
legend off

prepfiga
bigfont(gcf,1.5,1)
print -depsc decongraphics\tvspectra.eps

%% contour attenuation levels
t=(0:.01:2.5)';
f=0:250;
Q=[25 50 100];
figure
xnot=.1;ynot=.15;xsep=.05;
wid=(1-2*xnot-2*xsep)/3;
ht=.8;
xnow=xnot;
subplot('position',[xnow,ynot,wid,ht])
q=Q(1);
a=-27.3*t*f/q;
v=[-10:-10:-100 -150:-50:-500];
[c,h]=contour(f,t,a,v,'k');
fs=16;
clabel(c,h,'fontsize',fs);
title(['Attenuation (dB) Q=' num2str(q)]);titlefontsize(1,1)
flipy
ylabel('time (sec)');
xlabel('frequency (Hz)');
grid
xnow=xnow+xsep+wid;
subplot('position',[xnow,ynot,wid,ht])
q=Q(2);
a=-27.3*t*f/q;
[c,h]=contour(f,t,a,v,'k');
clabel(c,h,'fontsize',fs)
title(['Attenuation (dB) Q=' num2str(q)]);titlefontsize(1,1)
flipy
set(gca,'yticklabel','')
xlabel('frequency (Hz)');
grid
xnow=xnow+xsep+wid;
subplot('position',[xnow,ynot,wid,ht])
q=Q(3);
a=-27.3*t*f/q;
[c,h]=contour(f,t,a,v,'k');
clabel(c,h,'fontsize',fs)
title(['Attenuation (dB) Q=' num2str(q)]);titlefontsize(1,1)
flipy
set(gca,'yticklabel','')
xlabel('frequency (Hz)');
grid
prepfiga
pos=get(gcf,'position');
set(gcf,'position',[pos(1:3) 600])

print -depsc decongraphics\qcontours.eps