%make a synthetic seismogram, its envelope, and phase rotations
dt=.001;
tmax=1;
tlen=.2;
fdom=30;
[w,tw]=ricker(dt,fdom,tlen);
[r,t]=reflec(tmax,dt,.2,3,pi);
s=convz(r,w);
sa=hilbert(s);
sh=-imag(sa);
env=abs(sa);
angles=[0:90:270];
stheta=zeros(length(t),length(angles));
for k=1:length(angles)
    stheta(:,k)=s*cosd(angles(k))+sh*sind(angles(k));
end

yl= .02;
figure
subplot(2,1,1)
%plot(t,s,'k',t,env,'r')
linesgray({t,s,'-',.5,0},{t,env,'-',1,.5})
%xlabel('time (sec)')
ylim([-yl yl])

subplot(2,1,2)
%hh=plot(t,stheta,t,env,'r',t,-env,'r');
hh=linesgray({t,stheta(:,2),':',.3,0},{t,stheta(:,3),':',.3,0},{t,stheta(:,1),'-',.5,0},...
    {t,env,'-',.75,.5},{t,-env,'-',1,.5});
xlabel('time (sec)')
ylim([-yl yl])
hl=legend([hh(3), hh(4) hh(1)],'trace','\pm Hilbert envelope','phase rotations',...
    'location','north');
set(hl,'position',[0.4447 0.3707 0.1569 0.1289]);
% lw=get(hh(1),'linewidth');
% set(hh(2:end-2),'linewidth',.25*lw);
% kols=get(gca,'colororder');
% set(hh(1),'color','k');
% set(hh(2),'color',kols(1,:));
% set(hh(3),'color',kols(3,:));
% set(hh(4),'color',kols(5,:));

% subplot(2,1,1)
% ht=text(0,.018,'a)');
% fs=1.5*get(ht,'fontsize');
% set(ht,'fontsize',fs);
% subplot(2,1,2)
% text(0,.018,'b)','fontsize',fs)

prepfig
bigfont(gcf,1.5,1);boldlines(gcf,1.5)
legendfontsize(.8)


print  -depsc .\signalgraphics\trace_env_rot
