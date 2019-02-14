xmax=2500;zmax=1000; %maximum line length and maximum depth
vhigh=4000;vlow=2000; % high and low velocities
[vel,x,z]=wedgemodel(dx,xmax,zmax,vhigh,vlow);
%do a finite-difference model
dt=.004; %temporal sample rate
dtstep=.001;
tmax=2*zmax/vlow; %maximum time
%[w,tw]=wavemin(dt,30,.2); %minimum phase wavelet
%[w,tw]=ricker(dt,70,.2); %ricker wavelet
[seisfilt,seis,t]=afd_explode(dx,dtstep,dt,tmax, ...
 		vel,x,zeros(size(x)),[5 10 40 50],0,laplacian);