z=0:10:3000;
v0=1800;c=.6;
tau=log(1+c*z/v0)/c;
figure
plot(z,tau);xlabel('depth (m)');ylabel('time (s)')
flipy;axis([0 3000 0 1.2]);bigfont(gca,1.8,1);
figure
plot(tau,z);ylabel('depth (m)');xlabel('time (s)')
flipy;axis([0 1.2 0 3000 ]);bigfont(gca,1.8,1);
