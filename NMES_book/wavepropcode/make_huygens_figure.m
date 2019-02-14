%make Huygens picture
v=2000;
x=0:1000;
z=0:1000;
tnot=.3;
dt=.05;
r=v*tnot;
r1=r-v*dt;
r2=r+v*dt;
npts=500;
ievery=50;

thetah=80:-15:5;
nwaves=round(npts/ievery);
xr=linspace(0,r,500);
zr=sqrt(r^2-xr.^2);
xr1=linspace(0,r1,500);
zr1=sqrt(r1^2-xr1.^2);
xr2=linspace(0,r2,500);
zr2=sqrt(r2^2-xr2.^2);

figure
h1=linesgray({xr,zr,'-',2,.5},{xr1,zr1,'-',1,.7},{xr2,zr2,'-',1,.7});
dr=dt*v;
theta=0:10:360;
xnot=zeros(size(thetah));
znot=xnot;
for k=1:length(thetah)
    xnot(k)=r*cosd(thetah(k));znot(k)=r*sind(thetah(k));
    xh=xnot(k)+dr*cosd(theta);
    zh=znot(k)+dr*sind(theta);
    h2=linesgray({xh,zh,'-',.25,0});
end
h3=linesgray({xnot,znot,'none',.5,0,'*',12});
legend([h1(1) h1(2) h2 h3],'Wavefront at t_0','Predicted wavefronts at t_0\pm \Delta t',...
    'Huygens Wavelets','Huygens wavelet centers','location','southeast')
flipy
axis equal
xlim([0 1000])
ylim([0 1000])
xtick(0:250:1000)
ytick(0:250:1000)
xlabel('meters');ylabel('meters')
grid
prepfig
bigfont(gcf,1.25,1)

print -depsc wavepropgraphics\huygens