dt=.002;%time sample size
tmax=1.022;%Picked to make the length a power of 2
[r,t]=reflec(tmax,dt,.2,3,4);%reflectivity
r(end-100:end)=0;%zero the last 100 samples
r(end-50)=.1;%put a spike in the middle of the zeros
fmin=[10 5];fmax=[60 20];%used for filtf
n=4;%Butterworth order
sfm=filtf(r,t,fmin,fmax,1);%minimum phase filtf
sfz=filtf(r,t,fmin,fmax,0);%zero phase filtf
sbm=butterband(r,t,fmin(1),fmax(1),2*n,1);%minimum phase butterworth
sbz=butterband(r,t,fmin(1),fmax(1),n,0);%zero phase butterworth
som=filtorm(r,t,fmin(1)-fmin(2),fmin(1),fmax(1),fmax(1)+fmax(2),1);
soz=filtorm(r,t,fmin(1)-fmin(2),fmin(1),fmax(1),fmax(1)+fmax(2),0);