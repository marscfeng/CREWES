%make a wavenumber plot
close all
f=30;
v=2000;
theta=30;
L=v/f;
Lx=L/sind(theta);
Lz=L/cosd(theta);
n=10;
xmax=n*L;
x=linspace(-xmax,xmax)/L;
z=x;
figure
for k=1:2:3*n
    x0=(-xmax+(k-2)*L)/L;
    zl=(x-x0)*tand(theta);
    ind=between(-n,n,zl);
    hw=linesgray({x(ind),zl(ind),'-',2,.9});
end
fs=12;
Ax=-.5*sind(theta);Az=.5*cosd(theta);
Bx=.5*sind(theta);Bz=-.5*cosd(theta);
Cx=.5*sind(theta)-Lx/L;Cz=-.5*cosd(theta);
Dx=Bx;Dz=Bz+Lz/L;
text(Ax,Az,'A','horizontalalignment','right','fontsize',fs,'verticalalignment','bottom');
text(Bx,Bz,'B','horizontalalignment','left','fontsize',fs,'verticalalignment','top');
text(Cx,Cz,'C','horizontalalignment','right','fontsize',fs,'verticalalignment','bottom');
text(Dx,Dz,'D','horizontalalignment','center','fontsize',fs,'verticalalignment','bottom');
hl=linesgray({[Cx Bx],[Cz Bz],'-',1,.4},{[Bx Dx],[Bz Dz],'-',1,.7},...
    {[Ax Bx],[Az Bz],'-',1,0});
axis equal
xlim([-2.5 1.5])
ylim([-2 2])
xtick([]);ytick([])
set(gca,'xticklabel','','yticklabel','')
xlabel('x axis');ylabel('z axis')
legend([hw hl(3) hl(1:2)],' wavefronts',' \lambda (AB)',' \lambda_x (BC)',' \lambda_z (BD)',...
    'location','northwest')
%angles
phi=0:theta;
xang=Cx+.5*cosd(phi);zang=Cz+.5*sind(phi);
linesgray({xang,zang,':',.3,0})
text(mean(xang)+.05,mean(zang),'\theta')
xang=Bx-.5*sind(phi);zang=Bz+.5*cosd(phi);
linesgray({xang,zang,':',.3,0})
text(mean(xang)+.05,mean(zang),'\theta','horizontalalignment','right',...
    'verticalalignment','bottom')
grid
prepfig
bigfont(gca,.8,1)

print -depsc ..\signalgraphics\wavelengths