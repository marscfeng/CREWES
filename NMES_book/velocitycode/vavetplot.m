z=0:10:3000;v0=1800;c=.6;
t=log(1+c*z/v0)/c;
v=v0*exp(c*t);
vave=v0*(exp(c*t)-1)./(c*(t+100*eps));
plot(v,t,vave,t);xlabel('velocity (m/s)');ylabel('time (sec)')
flipy;axis([1800 3600 0 1.2])
ind=near(vave,2500);puttext(vave(ind+10),t(ind),'v_{ave}')
ind=near(v,3200);puttext(v(ind+10),t(ind),'v_{ins}')
bigfont(gca,1.8,1);
