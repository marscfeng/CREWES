v=[1200 2700 3500 3000 4000];z=[0 500 1400 1600 2000];
z2=0:10:2000;v2=pwlint(z,v,z2);
subplot(1,2,1);plot(v2,z2,v,z,'r*');flipy
xlabel('meters/sec');ylabel('meters');
t2=vint2t(v2,z2);
t=interp1(z2,t2,z);
subplot(1,2,2);plot(v2,t2,v,t,'r*');flipy;
xlabel('meters/sec');ylabel('seconds');
