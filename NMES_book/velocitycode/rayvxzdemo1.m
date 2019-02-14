dg=10; %grid spacing
tstep=0:.004:3; %time step vector
x=0:dg:10000;z=x'; %x and z coordinates
v=1800+.6*(z*ones(1,length(x)))+.4*(ones(length(z),1)*x);%velocity
rayvelmod(v,dg);clear v;%initialize the velocity model
theta=pi*45/180;%takeoff angle
r0=[0,0,sin(theta)/1800,cos(theta)/1800]';%initial value of r
[t,r]=ode45('drayvec',tstep,r0);%solve for raypath
plot(r(:,1),r(:,2));flipy%plot
