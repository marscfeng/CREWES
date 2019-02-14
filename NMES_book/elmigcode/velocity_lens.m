%Figure 7.1b
%% first part just makes the background image
x=0:1:1000;
z=(0:1:1000)';
xx=x(ones(size(z)),:);
zz=z(:,ones(size(x)));
znot=300;
theta=15;
vmax=5000;
vmin=1000;
vmean=3000;
%define surface and reflector
xmin=0;xmax=1000;
zmin=0;zmax=500;
zr=znot+tand(theta)*x;
%define image
vel=vmean*ones(length(z),length(x));
in=inpolygon(xx,zz,[x(1) x(end) x(end) x(1)],[zr(1) zr(end) z(end) z(end)]);
vel(in)=vmax;

%lens
x0=590;z0=100;
r=80;
phi=0:1:360;
inz=near(z,z0-r,z0+r);
xc1=sqrt(r^2-(z(inz)-z0).^2)+x0;
xc2=-sqrt(r^2-(z(inz)-z0).^2)+x0;
xc=real([xc1;flipud(xc2)]);
zc=[z(inz);flipud(z(inz))];
sigma=r/2;
lim=3*r;
pow=3;
ind=find(xx>=x0-lim & xx<=x0+lim);
for k=1:length(ind)
    if(zz(ind(k))<=z0+lim)
        r2=sqrt((xx(ind(k))-x0)^2+(zz(ind(k))-z0^2));
        if(r2<lim)
            xnow=xx(ind(k));
            znow=zz(ind(k));
            rnow=sqrt((xnow-x0)^2+(znow-z0)^2);
            v=vmean-(vmean-vmin)*exp(-rnow^pow/sigma^pow);
            ix=near(x,xnow);
            iz=near(z,znow);
            vel(iz,ix)=v;
        end
    end
end
%% make the figure after the first part has been run
figure
imagesc(x,z,vel)
colormap(seisclrs);
axis equal
xlim([0 1000]);
ylim([0 600])

fs=14;
lw=1.5;kol=.5*ones(1,3);
line(x,zeros(size(x)),'color',kol,'linewidth',lw);%draw surface
line(x,zr,'color',kol,'linewidth',lw);%draw reflector
text(0,10,'surface','fontsize',fs)

%line(xc,z(inz);zc,'color',kol,'linewidth',lw)

%flipy
%xlim([-100 1100]);ylim([-100 1100])
set(gca,'visible','off')

del=100;
xnow=del;
xnow0=del;
ls='-';lw=1;kol=zeros(1,3);
ah=.05;
l0=0;
n=0;
kol2=.3*ones(1,3);
lw2=2;
while xnow0<max(x)
    n=n+1;
    ix=near(x,xnow);
    znow=zr(ix);
    xnow0=xnow+znow*tand(theta);
    len=sqrt((xnow-xnow0)^2+znow^2);
    if(l0==0); l0=len; end
    if(xnow0<max(x))
        if(n~=5)
            arrowtwo([xnow,xnow0],[znow,0],'',kol,lw,ls,ah*l0/len);
        else
            xray=[617;567;551;500];
            zray=[0;68;117;432];
            arrow(xray(1:2),zray(1:2),'',kol,lw,ls,5*ah*l0/len);
            line(xray(2:3),zray(2:3),'color',kol,'linewidth',lw);
            arrow(xray(3:4),zray(3:4),'',kol,lw,ls,1.3*ah*l0/len);
            xray2=[500;610;625;617];
            zray2=[432;135;78;0];
            arrow(xray2(1:2),zray2(1:2),'',kol,lw,ls,1.3*ah*l0/len);
            line(xray2(2:3),zray2(2:3),'color',kol,'linewidth',lw);
            arrow(xray2(3:4),zray2(3:4),'',kol,lw,ls,5*ah*l0/len);
        end
        text(xnow0,-20,['s/r' int2str(n)],'fontsize',fs,'horizontalalignment','center');
    end
    xnow=xnow+del;
end
xnow=xnow-1.5*del;
ix=near(x,xnow);
text(xnow,zr(ix)-20,'reflector','rotation',-theta,'fontsize',fs)
prepfig

print -depsc elmiggraphics\ZOSnis.eps