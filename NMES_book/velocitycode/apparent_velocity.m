figure %6.8a
%note I've made some assumptions in this that only work if the angle is 45 degrees
xmin=0;xmax=1000;
zmin=0;zmax=1000;
lw=1;kol=.5*ones(1,3);
line([xmin xmax],[zmin zmin],'color',kol,'linewidth',lw);
line([xmax xmax],[zmin zmax],'color',kol,'linewidth',lw);
line([xmax-30 xmax-30],[zmin zmax],'color',kol,'linewidth',lw);
flipy
xlim([-100 1100]);ylim([-100 1100])
set(gca,'visible','off')
%Draw xticks
dtic=20;
ticht=30;
ntics=round(xmax/dtic)+1;
xnow=xmin;
for k=1:ntics
    line([xnow xnow],[zmin zmin-ticht],'color','k')
    xnow=xnow+dtic;
end
fs=10;
text(800,-2*ticht,'Receivers','fontsize',fs)
%Draw zticks
dtic=20;
ticht=30;
ntics=round(zmax/dtic)+1;
znow=zmin;
for k=1:ntics
    line([xmax-ticht xmax],[znow znow],'color','k')
    znow=znow+dtic;
end
fs=10;
text(xmax+ticht,2*ticht,'Receivers','rotation',-90,'fontsize',fs)
%first wavefront
x0=xmin+ticht;
x1=xmax-ticht;
theta=45;%don't change
z0=zmin;
z1=zmin+(x1-x0)/tand(theta);
kol=0*ones(1,3);
lw=1.5;
line([x0,x1],[z0,z1],'color',kol,'linewidth',lw)
axis equal
fs2=12;
text(x0,zmin-2*ticht,'x','fontangle','italic','fontweight','bold','fontsize',fs2,'horizontalalignment','center')
%second wavefront
delx=400;
x2=x0+delx;
x3=x1;
z3=zmin+(x3-x2)/tand(theta);
hw=line([x2,x3],[z0,z3],'color',kol,'linewidth',lw);
text(x2,zmin-2*ticht,'x+\Delta x','fontangle','italic','fontweight','bold','fontsize',fs2,'horizontalalignment','center')
%arrow 1
lambda=delx*sind(theta);%wave separation
xa1=x2-lambda*sind(theta);
xa2=x2;
za1=zmin+lambda*cosd(theta);
arrow([xa1 xa2],[za1 zmin],'','k',lw,':',.1,1);
%wavefront labels
s=1.2;
ht=text(s*xa1+2*ticht,s*za1,'wavefront at time','fontsize',fs2,'fontweight','bold','rotation',-theta);
ext=get(ht,'extent');
shft=30;
text(ext(1)+ext(3)-shft,ext(2)-shft,'t','fontsize',fs2,'fontweight','bold','rotation',-theta,'fontangle','italic');
s=1;
xshift=100;
ht=text(s*xa2+2*ticht+xshift,s*zmin+xshift,'time','fontsize',fs2,'fontweight','bold','rotation',-theta);
ext=get(ht,'extent');
shft=20;
ht2=text(ext(1)+ext(3)-shft,ext(2)-shft,'t + \Delta t','fontsize',fs2,'fontweight','bold','rotation',-theta,'fontangle','italic');
%arrow 2
delz=(xmax-ticht-delx-x0)/tand(theta);
za2=zmin+delz;
xa2=xmax-ticht;
xa1=xa2-lambda*sind(theta);
za1=za2+lambda*cosd(theta);
ha=arrow([xa1 xa2],[za1 za2],'','k',lw,':',.1,1);
%theta annotation
text(x0+3*ticht,zmin+1.5*ticht,'\theta','fontsize',fs2,'fontweight','bold')
%z annotation
text(xmax+.5*ticht,z1-.5*ticht,'z','fontsize',fs2,'fontweight','bold','fontangle','italic')
text(xmax+.5*ticht,z3-.5*ticht,'z - \Delta z','fontsize',fs2,'fontweight','bold','fontangle','italic')
hl=legend([hw ha{1}],{'wavefronts','raypaths'},'location','southwest');
pos=get(hl,'position');
set(hl,'position',[.38 .3 pos(3:4)]);
prepfig

print -depsc velocitygraphics\appvel.eps
%%
figure %6.8b
%note I've made some assumptions in this that only work if the angle is 45 degrees
xmin=0;xmax=1000;
zmin=0;zmax=1000;
lw=1;kol=.5*ones(1,3);
line([xmin xmax],[zmin zmin],'color',kol,'linewidth',lw);
line([xmax xmax],[zmin zmax],'color',kol,'linewidth',lw);
line([xmax-30 xmax-30],[zmin zmax],'color',kol,'linewidth',lw);
flipy
xlim([-100 1100]);ylim([-100 1100])
set(gca,'visible','off')
%Draw xticks
dtic=20;
ticht=30;
ntics=round(xmax/dtic)+1;
xnow=xmin;
for k=1:ntics
    line([xnow xnow],[zmin zmin-ticht],'color','k')
    xnow=xnow+dtic;
end
fs=10;
text(800,-2*ticht,'Receivers','fontsize',fs)
%Draw zticks
dtic=20;
ticht=30;
ntics=round(zmax/dtic)+1;
znow=zmin;
for k=1:ntics
    line([xmax-ticht xmax],[znow znow],'color','k')
    znow=znow+dtic;
end
fs=10;
text(xmax+ticht,2*ticht,'Receivers','rotation',-90,'fontsize',fs)
%first wavefront
x0=xmin+ticht;
x1=xmax-ticht;
theta=45;%don't change
z0=zmin;
z1=zmin+(x1-x0)/tand(theta);
kol=0*ones(1,3);
lw=1.5;
line([x0,x1],[z0,z1],'color',kol,'linewidth',lw)
axis equal
fs2=12;
text(x0,zmin-2*ticht,'x','fontangle','italic','fontweight','bold','fontsize',fs2,'horizontalalignment','center')
%second wavefront
delx=400;
x2=x0+delx;
x3=x1;
z3=zmin+(x3-x2)/tand(theta);
hw=line([x2,x3],[z0,z3],'color',kol,'linewidth',lw);
text(x2,zmin-2*ticht,'x+\Delta x','fontangle','italic','fontweight','bold','fontsize',fs2,'horizontalalignment','center')
%arrow 1
lambda=delx*sind(theta);%wave separation
lambdax=lambda/sind(theta);
lambdaz=lambda/cosd(theta);
xa1=(x0+x1)/2;
xa2=xa1+lambda*sind(theta);
za1=(xa1-x0)*tand(theta);
za2=za1-lambda*cosd(theta);
ha=arrowtwo([xa1 xa2],[za1 za2],'\lambda','k',lw,':',.05,1);
set(ha{6},'rotation',0,'fontsize',fs2,'fontweight','bold')
% %wavefront labels
% s=1.2;
% ht=text(s*xa1+2*ticht,s*za1,'wavefront at time','fontsize',fs2,'fontweight','bold','rotation',-theta);
% ext=get(ht,'extent');
% shft=30;
% text(ext(1)+ext(3)-shft,ext(2)-shft,'t','fontsize',fs2,'fontweight','bold','rotation',-theta,'fontangle','italic');
% s=1;
% xshift=100;
% ht=text(s*xa2+2*ticht+xshift,s*zmin+xshift,'time','fontsize',fs2,'fontweight','bold','rotation',-theta);
% ext=get(ht,'extent');
% shft=20;
% ht2=text(ext(1)+ext(3)-shft,ext(2)-shft,'t + \Delta t','fontsize',fs2,'fontweight','bold','rotation',-theta,'fontangle','italic');
%arrow 2
xa1=xa2-lambdax;
za1=za2;
ha=arrowtwo([xa1 xa2],[za1 za2],'\lambda_x','k',lw,':',.05,1);
set(ha{6},'rotation',0,'fontsize',fs2,'fontweight','bold')
%arrow 3
xa1=xa2;
za1=za2+lambdaz;
ha=arrowtwo([xa1 xa2],[za1 za2],'\lambda_z','k',lw,':',.05,1);
set(ha{6},'rotation',0,'fontsize',fs2,'fontweight','bold')
%theta annotation
text(x0+3*ticht,zmin+1.5*ticht,'\theta','fontsize',fs2,'fontweight','bold')
%z annotation
text(xmax+.5*ticht,z1-.5*ticht,'z','fontsize',fs2,'fontweight','bold','fontangle','italic')
text(xmax+.5*ticht,z3-.5*ticht,'z - \Delta z','fontsize',fs2,'fontweight','bold','fontangle','italic')
%third wavefront
x1=x0;
z1=zmin+lambdaz;
z2=zmax;
x2=(zmax-zmin)*tand(theta)+x1-lambdax;
kol=.5*ones(1,3);
line([x1,x2],[z1,z2],'color',kol,'linewidth',lw,'linestyle','-')
%fourth wavefront
x1=x0+2*lambdax;
z1=zmin;
x2=xmax-ticht;
z2=(x2-x1)/tand(theta)-z1;
hw2=line([x1,x2],[z1,z2],'color',kol,'linewidth',lw,'linestyle','-');
hl=legend([hw hw2],{'wavecrests of interest','other wavecrests'},'location','southwest');
pos=get(hl,'position');
set(hl,'position',[.3 .3 pos(3:4)]);
prepfig

print -depsc velocitygraphics\appvelfk.eps
