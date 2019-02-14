z=0:10:3000;v0=1800;c=.6;
%t=log(1+c*z/v0)/c;
v=v0+c*z;
vave=c*z./(log(1+c*z/v0)+100*eps);
plot(v,z,vave,z);xlabel('velocity (m/s)');ylabel('depth (m)')
flipy;axis([1800 3600 0 3000]);
ind=near(vave,2500);puttext(vave(ind+10),z(ind),'v_{ave}')
ind=near(v,3200);puttext(v(ind+10),z(ind),'v_{ins}')
bigfont(gca,1.8,1);
