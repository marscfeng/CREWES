z=0:10:3000;v0=1800;c=.6;
t=log(1+c*z/v0)/c;
v=v0*exp(c*t);
plot(v,t);xlabel('velocity (m/s)');ylabel('time (sec)')
flipy;axis([1800 3600 0 1.2]);bigfont(gca,1.8,1);
