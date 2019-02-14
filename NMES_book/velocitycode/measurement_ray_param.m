figure %6.12

xmin=0;xmax=1000;
zmin=0;zmax=500;
lw=1.5;kol=.5*ones(1,3);
line([xmin xmax],[zmin zmin],'color',kol,'linewidth',lw);%draw surface
line([xmin xmax],[zmax zmax],'color',kol,'linewidth',lw);%draw reflector

axis equal
flipy
xlim([-100 1100]);ylim([-100 1100])
set(gca,'visible','off')
%Draw xticks
dtic=20;
ticht=30;
xnow=200;
ntics=round((xmax-xnow)/dtic)+1;
for k=1:ntics
    line([xnow xnow],[zmin zmin-ticht],'color','k')
    xnow=xnow+dtic;
end
fs=10;
text(800,-2*ticht,'receivers','fontsize',fs)
text(800,zmax+ticht,'reflector','fontsize',fs)
%draw source
xsource=50;
line(xsource,zmin,.5,'linestyle','none','marker','*','linewidth',lw,'markersize',16,'color','k');
text(xsource,zmin-2*ticht,'source','fontsize',fs,'horizontalalignment','center')
%draw downgoing wavefronts
v=2000;
tr=zmax/v;%time to reflector
nw=3;%number of wavefronts
delt=tr/nw;%time between wavefronts
kol=.7*ones(1,3);
lw=1;
dtheta=.1;
theta=-145:dtheta:180;
for k=1:2*nw
   r=k*delt*v;%radius
   x=r*sind(theta)+xsource;
   z=r*cosd(theta);
%    ind1=x>=xmin & x<=xmax;
%    ind2=z(ind1)>=zmin & z(ind1)<=zmax;
%     ind1=find(x>=xmin & x<=xmax);
%     ind2=find(z(ind1)>=zmin & z<=zmax);
    in=inpolygon(x,z,[xsource xmax xmax xsource],[zmin zmin zmax zmax]);
   hd=line(x(in),z(in),'color',kol,'linewidth',lw,'linestyle','-');
end
%draw upgoing wavefronts
theta=-145:dtheta:180;
kol=.3*ones(1,3);
for k=1:2*nw
   r=(.75*tr+k*delt)*v;
   x=r*sind(theta)+xsource;
   z=r*cosd(theta)+2*zmax;
%    ind1=x>=xmin & x<=xmax;
%    ind2=z(ind1)>=zmin & z(ind1)<=zmax;
%     ind1=find(x>=xmin & x<=xmax);
%     ind2=find(z(ind1)>=zmin & z<=zmax);
    in=inpolygon(x,z,[xsource xmax xmax xsource],[zmin zmin zmax zmax]);
   hu=line(x(in),z(in),'color',kol,'linewidth',lw);
   if(k==4)
       hup=hu;
   end
end
%draw two rays
x1=340;%emergence point of ray 1
x2=420;%emergence point of ray 2
lw=.5;
kol=zeros(1,3);
hr=line([xsource .5*(x1-xsource)],[0 zmax],'color',kol,'linewidth',lw);
ha=arrow([.5*(x1-xsource) x1],[zmax zmin],'',kol,lw,'-',.03,1);
line([xsource .5*(x2-xsource)],[0 zmax],'color',kol,'linewidth',lw);
arrow([.5*(x2-xsource) x2],[zmax zmin],'',kol,lw,'-',.03,1);
hl=legend([hd,hu,hr],{'downgoing wavefronts','upgoing wavefronts','raypaths'});
set(hl,'position',[0.4142 0.905 0.1906 0.0739])
%after drawing the above, the lower half of the axis is blank thanks to the axis equal command
%I now enlarge the region 320<x<450, -20<z<50 and show it in the bottom half. To do this I
%define a linear transformation that takes x->xp such that xp=0 when x=320 and xp=1000 when
%x=450. Similarly another linear transformation takes z->zp such that zp=650 when z=0 and
%zp=10354.6 when z=50. The xp transformation is xp=(1000/130)*x-2461.5 and zp=7.69*z+650. The
%odd value of zp is required to preserve the aspect ratio so that angles are also preserved.

a=1000/130;b=-2461.5;c=7.69;d=650;
xmin=320;xmax=450;
zmin=0;zmax=50;
xpmin=0;xpmax=1000;
zpmin=650;zpmax=1233;
%draw box around enlargement zone
lw=.5;
kol=zeros(1,3);
line([xmin xmax xmax xmin xmin],[zmin-35 zmin-35 zmax zmax zmin-35],'linestyle',':','linewidth',lw,'color',kol)
%draw enlargement arrows
h=arrowm([xmin xpmin],[zmin zpmin],'Enlarge',kol,lw,':',.02,1);
pos=get(h{4},'position');
set(h{4},'backgroundcolor','w','position',[pos(1:2) .5]);
h=arrowm([xmax xpmax],[zmin zpmin],'Enlarge',kol,lw,':',.02,1);
ang=get(h{4},'rotation');
pos=get(h{4},'position');
set(h{4},'backgroundcolor','w','rotation',ang+180,'position',[pos(1:2) .5]);

lw=1.5;kol=.5*ones(1,3);
line([xpmin xpmax],[zpmin zpmin],[-1 -1],'color',kol,'linewidth',lw);%draw surface
%Draw xticks
dtic=20;
ticht=40;
xnow=xmin;
xpnow=a*xnow+b;
ntics=round((xmax-xnow)/dtic);
for k=1:ntics
    if(k==2) 
        line([xpnow xpnow],[zpmin zpmin-2*ticht],'color','k')
        xr1=xpnow;
    elseif(k==6)
        line([xpnow xpnow],[zpmin zpmin-2*ticht],'color','k')
        xr2=xpnow;
    else
        line([xpnow xpnow],[zpmin zpmin-ticht],'color','k')
    end
    xnow=xnow+dtic;
    xpnow=a*xnow+b;
end
%draw wavefront
xw=get(hup,'xdata');
zw=get(hup,'ydata');
xwp=a*xw+b;
zwp=c*zw+d;
in=inpolygon(xwp,zwp,[xpmin xpmax xpmax xpmin],[zpmin zpmin zpmax zpmax]);
kol=.3*ones(1,3);
lw=1;
line(xwp(in),zwp(in),'color',kol,'linewidth',lw)
% draw rays
%first ray is from (.5*(x1-xsource),zmax) to (x1,zmin) with zmin=0 and zmax=500. Need its equation
x1r=.5*(x1-xsource);
slope=(500-0)/(x1r-x1);
int=500-slope*x1r;
%new first point at depth 50
z0new=50;
x0new=(z0new-int)/slope;
x0newp=a*x0new+b;
z0newp=c*z0new+d;
%second point
x1p=a*x1+b;
z1p=zpmin;
lw=.5;
kol=zeros(1,3);
arrow([x0newp x1p],[z0newp z1p],'ray 0',kol,lw,'-',.03,1);
%second ray is from (.5*(x2-xsource),zmax) to (x2,zmin) with zmin=0 and zmax=500. Need its equation
x2r=.5*(x2-xsource);
slope=(500-0)/(x2r-x2);
int=500-slope*x2r;
%new first point at depth 50
z0new=50;
x0new=(z0new-int)/slope;
x0newp=a*x0new+b;
z0newp=c*z0new+d;
%second point
x1p=a*x2+b;
z1p=zpmin;
lw=.5;
kol=zeros(1,3);
ha=arrow([x0newp x1p],[z0newp z1p],'ray 1',kol,lw,'-',.03,1);
set(ha{1},'zdata',[1 1])
%extend second ray slightly
z2p=zpmin-2*ticht;
m=(z1p-z0newp)/(x1p-x0newp);%slope
x2p=(z2p-z0newp)/m+x0newp;
line([x1p x2p],[z1p z2p],'linestyle',':','linewidth',.5,'color','k');
%right angle symbol  
line([656 672.479 707],[808.1744 777.1117 790],'linestyle',':','linewidth',.5,'color','k')
%double arrow for delta r
h=arrowtwo([xr1 xr2],(zpmin-1.5*ticht)*ones(1,2),'\Delta r','k',1,':',.02,1);
pos=get(h{6},'position');
set(h{6},'position',[pos(1:2) .5])
%double arrow for delta s
h=arrowtwo([715 791],[829 650],'\Delta s','k',1,':',.08,1);
pos=get(h{6},'position');
set(h{6},'position',[pos(1:2) .5])
%annotate emergence angle
text(386,690,'\theta_0','fontsize',10)
text(777,576,'\theta_0','fontsize',8)
%draw another box
lw=.5;
kol=zeros(1,3);
line([xpmin xpmax xpmax xpmin xpmin],[zpmin-100 zpmin-100 1100 1100 zpmin-100],'linestyle',':','linewidth',lw,'color',kol)

prepfig
print -depsc velocitygraphics\measurep.eps