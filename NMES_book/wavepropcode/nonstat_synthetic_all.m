nonstat_synthetic

trow=dt*(0:length(s)-1)';
%amplitude balance
a=1.5*norm(r)/norm(s);
figure
gl={0,0,0};lw=[1,1,1];
names={'reflectivity','stationary','nonstationary'};
fs=14;
trplot({t trow trow},{r,s*a,sn*a},'colors',gl,'linewidths',lw,'order','d','names',names,'fontsize',8);
prepfig
bigfont(gcf,2,1)
print -depsc wavepropgraphics\nonstatsyn.eps

figure
gl=[.7,.5,.3,0];lw=[1.25,1,.75,.5];
subplot(1,2,1)
tnots=[0,.6,1.2];twins=.6;
hh=tvdbspec(trow,s,tnots,twins);
title('Stationary seismogram');
ylim([-100 0])
hl=findobj(gcf,'type','legend');
set(hl,'position',[0.2816 0.7059 0.1750 0.2061])
subplot(1,2,2)
hh2=tvdbspec(trow,sn,tnots,twins);
title('Nontationary seismogram');
ylim([-100 0])
for k=1:4
set([hh(k),hh2(k)],'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
hl=findobj(gcf,'type','legend');
set(hl(1),'position',[0.7219 0.7059 0.1750 0.2061])
prepfig
bigfont(gcf,1.5,1)
print -depsc wavepropgraphics\nonstatspectra.eps