z=0:10:3000;
v0=1800;c=.6;
v=v0+c*z;
plot(v,z);flipy;xlabel('velocity(m/s)');ylabel('depth(m)')
bigfont(gca,1.8,1)
