global SCALE_OPT CLIP THRESH
SCALE_OPT=1;
CLIP=1;
close all

THRESH=.2;
pick_fb;
figure(1)
fs=1.5;
prepfig;bigfont(gca,fs,1);
hax=findobj(gcf,'tag','MAINAXES');
pos=get(hax,'position');
nudge=.05;
set(hax,'position',[pos(1) pos(2)+nudge pos(3) pos(4)-nudge])
print -depsc .\intrographics\shotfb
figure(2)
fs=1.65;
prepfig;bigfont(gcf,fs,1);
print -depsc .\intrographics\graphfb

%additional figures
%xtrace=520;
xtrace=340;
xmin=xtrace-4*20;
xmax=xtrace+4*20;
itrace=near(x,xtrace);
ix=itrace-20:itrace+20;
plotimage(seis,t,x);title('');
xlabel('distance (m)');ylabel('time (sec)')
hax=findobj(gcf,'tag','MAINAXES');
pos=get(hax,'position');
set(hax,'position',[pos(1) pos(2)+nudge pos(3) pos(4)-nudge])
ylim([.14 .38]);
xlim([xmin xmax])
ms=1;
h=line(xpick,tpick,'color','k','linestyle','none','marker','o','markersize',2*ms);
h2=line(xpick2,tpick2,'color','k','linestyle','none','marker','o','markersize',ms);
h3=line(xpick3,tpick3,'color','k','linestyle','none','marker','o','markersize',3*ms);
hl=legend([h2 h h3],{'thresh=.1','thresh=.2','thresh=.4'});
fs=1.5;
prepfig;bigfont(gcf,fs,1);
bigfont(hl,1,1);
%axeslabelsize(.5);
%set([h h2 h3],'markersize',.25*get(h2,'markersize'));
%xtick(460:20:600)
xtick(280:20:400)
print -depsc .\intrographics\shotfb_zoom

figure
it=near(t,.1,.4);
wtva(seis(:,itrace),t,'k',0,1,-1);
tp=nan*ones(size(t));
ind=near(t,tpick(itrace));
tp(ind)=seis(ind,itrace);
ms=2;
h=line(t,tp,'color','k','linestyle','none','marker','o','markersize',2*ms);
tp=nan*ones(size(t));
ind=near(t,tpick2(itrace));
tp(ind)=seis(ind,itrace);
h2=line(t,tp,'color','k','linestyle','none','marker','o','markersize',ms);
tp=nan*ones(size(t));
ind=near(t,tpick3(itrace));
tp(ind)=seis(ind,itrace);
h3=line(t,tp,'color','k','linestyle','none','marker','o','markersize',3*ms);
hl=legend([h2 h h3],{'thresh=.1','thresh=.2','thresh=.4'});
xlim([.2 .4]);
ylim([-.02 .02])
prepfig;bigfont(gcf,fs,1);
bigfont(hl,1,1);
xlabel('time (sec)');ylabel('amplitude')
grid
legendfontsize(1/1.1)
print -depsc .\intrographics\onetracefb

% pick_env
% figure(1)
% prepfig;bigfont(gca,.75,1);
% ylim([0 1.0])
% print -depsc ..\intrographics\shotenv
% figure(2)
% prepfig;bigfont(gcf,.75,1);
% hl=legend('event','Hilbert envelope');
% %bigfont(hl,.5);
% %axeslabelsize(.5);
% print -depsc ..\intrographics\graphenv
