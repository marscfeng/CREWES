%make a velocity model
nx=128;dx=10;nz=128; %basic geometry
x=(0:nx-1)*dx;z=(0:nz-1)*dx;
v1=2000;v2=2800;v3=3500;v4=3000;%velocities
vmodel=v2*ones(nx,nz);
z1=(nz/2)*dx;
dx2=dx/2;
%planar interface
xpoly=[-dx2 max(x)+dx2 max(x)+dx2 -dx2];zpoly=[-dx2 -dx2 z1+dx2 z1+dx2];
vmodel=afd_vmodel(dx,vmodel,v1,xpoly,zpoly);

%lens
xpoly=[600 540 490 440 450 540 660 770 860 900 850 780 650];
zpoly=[210 230 230 275 345 360 370 380 360 264 230 230 210];
vmodel=afd_vmodel(dx,vmodel,v3,xpoly,zpoly);

%target
xpoly=[440 500 620 730 830];
zpoly=[z1  670 670 670 z1];
vmodel=afd_vmodel(dx,vmodel,v4,xpoly,zpoly);

dtstep=.001;%time step
dt=.004;tmax=1;%time sample rate and max time
xrec=x;%receiver locations
zrec=zeros(size(xrec));%receivers at zero depth
snap1=zeros(size(vmodel));
snap2=snap1;
xsource=max(x)/5;
ixs=near(x,xsource);
snap2(1:2,ixs(1):ixs(1)+1)=ones(2,2);%place the source

%fourth order laplacian
[seismogram4,seis4,t]=afd_shotrec(dx,dtstep,dt,tmax, ...
			vmodel,snap1,snap2,xrec,zrec,[5 10 30 40],0,2);
