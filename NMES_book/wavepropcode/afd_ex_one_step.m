%illustrate a single time step
%first make a velocity model
dx=2;
xmax=1000;
zmax=1000;
dt=.0005;
x=0:dx:xmax;
z=0:dx:zmax;
v=2000;
vel=v*ones(length(x),length(z));
%assume a circular wave from a source at xnot,ynot.
xnot=0;znot=0;
snap1=zeros(size(vel));
snap2=snap1;
ix=near(x,xnot);
iz=near(z,znot);
snap2(iz,ix)=1;
tnot=.3;
dtsnap=100*dt;
tsnaps=[tnot-dtsnap tnot tnot+dtsnap];
[w,tw]=wavemin(dt,30,.2);
snaps=afd_makesnapshots(dx,dt,vel,snap1,snap2,tsnaps,2,2,-w);
snapm1=snaps{2};
snap0=snaps{3};
snapp1=snaps{4};
snapp1_op=snapp1+snapm1;

fs=12;
figure
%subplot(2,2,1,'align')
axes('position',[.1 .56 .4 .4])
amin=min(snapm1(:));
amax=max(snapm1(:));
imagesc(x,z,snapm1,[amin amax]);
axis equal
xlim([0 1000])
r=v*tnot;
xr=0:dx:r;
zr=sqrt(r.^2-xr.^2);
hr=line(xr,zr);
set(hr,'linestyle',':','color',.95*ones(1,3))
xtick(0:250:1000);
set(gca,'xticklabel',[]);
ytick(0:250:1000)
text(50,50,'a)','fontsize',fs)
text(200, 800, '\psi(x,z,t_0-\Delta t)','fontsize',fs,'fontangle','italic','interpreter','tex')
ylabel('meters')
grid

%subplot(2,2,2,'align')
axes('position',[.45 .56 .4 .4])
imagesc(x,z,snap0,[amin amax]);
axis equal
xlim([0 1000])
hr=line(xr,zr);
set(hr,'linestyle',':','color',.95*ones(1,3))
xtick(0:250:1000);ytick(0:250:1000);
set(gca,'xticklabel',[],'yticklabel',[]);
text(50,50,'b)','fontsize',fs)
text(200, 800, '\psi(x,z,t_0)','fontsize',fs,'fontangle','italic','interpreter','tex')
grid

%subplot(2,2,3,'align')
axes('position',[.1 .15 .4 .4])
imagesc(x,z,snapp1_op,[amin amax]);
axis equal
xlim([0 1000])
hr=line(xr,zr);
set(hr,'linestyle',':','color',.95*ones(1,3))
ytick(250:250:1000)
xtick(0:250:1000)
text(50,50,'c)','fontsize',fs)
text(200, 800, 'L_{\Delta t}\psi(x,z,t_0)','fontsize',fs,'fontangle','italic','interpreter','tex')
ylabel('meters')
xlabel('meters')
grid

%subplot(2,2,4,'align')
axes('position',[.45 .15 .4 .4])
imagesc(x,z,snapp1,[amin amax]);
axis equal
xlim([0 1000])
hr=line(xr,zr);
set(hr,'linestyle',':','color',.95*ones(1,3))
ytick(0:250:1000);
set(gca,'yticklabel',[]);
xtick(250:250:1000)
colormap seisclrs
text(50,50,'d)','fontsize',fs)
text(200, 800, '\psi(x,z,t_0+\Delta t)','fontsize',fs,'fontangle','italic','interpreter','tex')
xlabel('meters')
prepfig
bigfont(gcf,1.25,1)
set(gcf,'position',[173 173 1100 896])
grid

print -depsc wavepropgraphics/onestep
