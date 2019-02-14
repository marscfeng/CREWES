afd_example1

%raytracing
vp=[2000 2800 3200];zp=[0 z1 z2];
raycode=[0 1; z1 1; 0 1];
seisplot(vmodel-3000,z,x);hideui;
tray1=traceray(vp,zp,vp,zp,raycode,max(x)/4,1,-1,8,1,0,2);
raycode=[0 1; z1 1; 0 1;z1 1;0 1];
%plotimage(vmodel-3000,z,x);
tray2=traceray(vp,zp,vp,zp,raycode,max(x)/2,1,-1,8,1,0,2,500);
raycode=[0 1; z2 1; 0 1];
%plotimage(vmodel-3000,z,x);
tray3=traceray(vp,zp,vp,zp,raycode,max(x),1,-1,8,1,0,2);
boldlines
%bigfont(gca,1.8,1);
whitefig;xlabel('meters');ylabel('meters')
fs=12;fontwt='bold';
text(600,900,'v=3200 m/s','fontsize',fs,'fontweight',fontwt);
text(600, 300,'v=2800 m/s','fontsize',fs,'fontweight',fontwt);
text(400, 100,'v=2000 m/s','fontsize',fs,'fontweight',fontwt);
fs=20;
text(100, 80,'A','fontsize',fs,'fontweight',fontwt);
text(600, 80,'B','fontsize',fs,'fontweight',fontwt);
text(400, 410,'C','fontsize',fs,'fontweight',fontwt);
grid off
bigfont(gcf,1.8,1)

print -depsc wavepropgraphics\afdex1velmod.eps
%
raycode=[0 1; z1 1; 0 1];
tray1=traceray(vp,zp,vp,zp,raycode,x,1,-1,8,1,0,0);
raycode=[0 1; z1 1; 0 1;z1 1;0 1];
tray2=traceray(vp,zp,vp,zp,raycode,x,1,-1,8,1,0,0);
raycode=[0 1; z2 1; 0 1];
tray3=traceray(vp,zp,vp,zp,raycode,x,1,-1,8,1,0,0);
xray=x+max(x)/2;
seisplot(seismogram2,t,x);hideui
kol='k';
h1=line(xray,tray1,ones(size(tray1)),'color',kol,'linewidth',2);
h2=line(xray,tray2,ones(size(tray1)),'color',kol,'linewidth',2);
h3=line(xray,tray3,ones(size(tray1)),'color',kol,'linewidth',2);
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gcf,2,1)
print -depsc wavepropgraphics\afdex1seis2.eps
seisplot(seismogram4,t,x);hideui
h1a=line(xray,tray1,ones(size(tray1)),'color',kol,'linewidth',2);
h2a=line(xray,tray2,ones(size(tray1)),'color',kol,'linewidth',2);
h3a=line(xray,tray3,ones(size(tray1)),'color',kol,'linewidth',2);
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gcf,2,1)
print -depsc wavepropgraphics\afdex1seis4.eps

trc2=seismogram2(:,50);
trc4=seismogram4(:,50);
figure;
plot([trc2 trc4+.01],t);flipy
iz=near(t,.15,.7);
dbspec(t(iz),[trc2(iz) trc4(iz)])
