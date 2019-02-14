zp=0:10:4000;vp=1800+.6*zp;vs=.5*vp;zs=zp;% velocity model
zsrc=100;zrec=500;zd=3000;%source receiver and reflector depths
xoff=1000:100:3000;caprad=10;itermax=4;%offsets, cap radius, and max iter
pfan=-1;optflag=1;pflag=1;dflag=2;% default ray fan, and various flags
% create P-P reflection
figure;subplot(2,1,1);flipy;
[t,p]=traceray_pp(vp,zp,zsrc,zrec,zd,xoff,caprad,pfan,itermax,optflag,...
   pflag,dflag);
title(['Vertical gradient simulation, P-P mode zsrc=' ...
   num2str(zsrc) ' zrec=' num2str(zrec)])
line(xoff,zrec*ones(size(xoff)),'color','b','linestyle','none','marker','v')
line(0,zsrc,'color','r','linestyle','none','marker','*')
grid;xlabel('meters');ylabel('meters');
subplot(2,1,2);plot(xoff,t);grid;
xlabel('meters');ylabel('seconds');flipy
% P-S reflection
figure;subplot(2,1,1);flipy;
[t,p]=traceray_ps(vp,zp,vs,zs,zsrc,zrec,zd,xoff,caprad,pfan,itermax,...
   optflag,pflag,dflag);
title(['Vertical gradient simulation, P-S mode zsrc=' ...
   num2str(zsrc) ' zrec=' num2str(zrec)])
line(xoff,zrec*ones(size(xoff)),'color','b','linestyle','none','marker','v')
line(0,zsrc,'color','r','linestyle','none','marker','*')
grid;xlabel('meters');ylabel('meters');
subplot(2,1,2);plot(xoff,t);grid;
xlabel('meters');ylabel('seconds');flipy;
