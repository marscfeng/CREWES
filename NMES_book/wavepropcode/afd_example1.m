%make a velocity model
nx=128;dx=10;nz=128; %basic geometry
x=(0:nx-1)*dx;z=(0:nz-1)*dx;
v1=2000;v2=2800;v3=3200;%velocities
vmodel=v3*ones(nx,nz);
z1=(nz/8)*dx;z2=(nz/2)*dx;
dx2=dx/2;
xpoly=[-dx2 max(x)+dx2 max(x)+dx2 -dx2];
zpoly=[-dx2 -dx2 z1+dx2 z1+dx2];
vmodel=afd_vmodel(dx,vmodel,v1,xpoly,zpoly);
zpoly=[z1+dx2 z1+dx2 z2+dx2 z2+dx2];
vmodel=afd_vmodel(dx,vmodel,v2,xpoly,zpoly);

dtstep=.001;%time step
dt=.004;tmax=1;%time sample rate and max time
xrec=x;%receiver locations
zrec=zeros(size(xrec));%receivers at zero depth
snap1=zeros(size(vmodel));
snap2=snap1;
snap2(1,length(x)/2)=1;%place the source
%second order laplacian
[seismogram2,seis2,t]=afd_shotrec(dx,dtstep,dt,tmax, ...
	vmodel,snap1,snap2,xrec,zrec,[5 10 30 40],0,1);
%fourth order laplacian
[seismogram4,seis4,t]=afd_shotrec(dx,dtstep,dt,tmax, ...
	vmodel,snap1,snap2,xrec,zrec,[5 10 30 40],0,2);
