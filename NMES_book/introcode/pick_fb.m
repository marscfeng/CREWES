load smallshot
global THRESH

te=[.4 .02];xe=[0 1000];delt=.2;picktype=8;
[ap,ae,tpick,xpick]=picker(seis,t,x,te,xe,delt,picktype);
THRESH=.1;
[ap2,ae2,tpick2,xpick2]=picker(seis,t,x,te,xe,delt,picktype);
THRESH=.4;
[ap3,ae3,tpick3,xpick3]=picker(seis,t,x,te,xe,delt,picktype);

plotimage(seis,t,x);title('')
xlabel('distance (m)');ylabel('time (sec)')
h=line(xpick(1:2:end),tpick(1:2:end),'markeredgecolor','w',...
    'linestyle','none','marker','.','markersize',8);

figure;plot(xpick,tpick,'k');flipy
xlabel('distance (m)');ylabel('traveltime (s)')

