makeQsynthetic

deconfQsynthetic;

figure
x0=.1;wid=.8;
y0=.95;ht=.3;
xnow=x0;
ynow=y0-ht;
subplot('position',[xnow,ynow,wid,ht])
names={'reflectivity','stationary->deconf','nonstationary->deconf'};
trplot(t,[r,sd,sqd],'order','d','color',zeros(1,3),'names',names,'namesalign','right','nameshift',.2);
ylim([-.1 .4]);
text(1,.09,1,strstat);
text(1,-.05,1,strnon);
text(0, .28, 1,'A)');
% inc=max(abs(r));
% plot(t,r+2*inc,t,sd+inc,t,sqd)


ht=.35;ysep=.15;
wid=.35;xsep=.1;
ynow=ynow-ht-ysep;
subplot('position',[xnow,ynow,wid,ht]);
twin=.5;
twins=twin*ones(1,3);
tnots=[.3 1. 1.7];
tpad=length(t);
gl=[0 .7 .5 .3];
lw=[.5 1.25 1 .75];
hh=tvdbspec(t,sd,tnots,twins,tpad,'');
for k=1:4
    set(hh(k),'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
xlim([0 250]);
ylim([-80 0])
text(0,-5,1,'B)');
legend off
title('Stationary trace spectra');titlefontsize(1,1)

xnow=xnow+wid+xsep;
subplot('position',[xnow,ynow,wid,ht]);
hh=tvdbspec(t,sqd,tnots,twins,tpad,'');
for k=1:4
    set(hh(k),'color',gl(k)*ones(1,3),'linewidth',lw(k));
end
xlim([0 250]);
ylim([-80 0])
text(0,-5,1,'C)');
title('Nonstationary trace spectra');titlefontsize(1,1)
hl=findobj(gcf,'type','legend');
set(hl,'position',[0.7438 0.3170 0.1500 0.1750]);
prepfig
bigfont(gcf,1.1,1)
print -depsc decongraphics\deconfqsynthetic.eps