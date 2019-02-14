xmax=2500;zmax=1000; %maximum line length and maximum depth
vhigh=4000;vlow=2000; % high and low velocities
vrange=vhigh-vlow;
vs=vlow+(0:4)*vrange/5;
width=20;thk=50;zch=398;%channel dimensions
vch=vlow+vrange/6;%channel velocity
[vel,x,z]=channelmodel(dx,xmax,zmax,vhigh,vlow,zch,width,thk,vch,...
    4,1,[100,200,271,398 zmax],vs);
%create the exploding reflector model
dt=.004; %temporal sample rate
dtstep=.001; %modeling step size
tmax=2*zmax/vlow; %maximum time
[seisfilt,seis,t]=afd_explode(dx,dtstep,-dt,tmax, ...
 		vel,x,zeros(size(x)),[10 15 40 50],0,laplacian);