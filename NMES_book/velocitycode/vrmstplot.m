z=0:10:3000;v0=1800;c=.6;
t=log(1+c*z/v0)/c+100*eps;
v=v0*exp(c*t);
vave=v0*(exp(c*t)-1)./(c*(t));
vrms=v0*sqrt((exp(2*c*t)-1)./(2*c*t));
plot(v,t,vave,t,vrms,t);xlabel('velocity (m/s)');ylabel('time (sec)')
flipy;axis([1800 3600 0 1.2]);
ind=near(vave,2500);puttext(vave(ind-80),t(ind),'v_{ave}');
ind=near(v,3200);puttext(v(ind+10),t(ind),'v_{ins}');
ind=near(vrms,2400);puttext(vrms(ind+10),t(ind),'v_{rms}');
bigfont(gca,1.8,1)
