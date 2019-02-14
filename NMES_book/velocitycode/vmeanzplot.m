figure;
v=v0+c*z;
vave=c*z./(log(1+c*z/v0)+100*eps);
vm=v0+c*z/2;
plot(v,z,vave,z,vm,z);xlabel('velocity (m/s)');ylabel('depth (m)')
flipy;axis([1800 3600 0 3000]);
ind=near(vave,2500);puttext(vave(ind-80),z(ind),'v_{ave}');
ind=near(v,3000);puttext(v(ind+10),z(ind),'v_{ins}');
ind=near(vm,2500);puttext(vm(ind+10),z(ind),'v_{mean}');
%setfont(gca,'cmmi10')
%setfont
bigfont(gca,1.8,1)
