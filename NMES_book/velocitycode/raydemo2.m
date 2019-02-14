zp=0:10:4000;vp=1800+.6*zp;vs=.5*vp;zs=zp;%velocity model
zrec=500:100:2500;zsrc=0;zd=3000;xoff=1500;%geometry
caprad=10;itermax=4;%cap radius, and max iter
pfan=-2;optflag=1;pflag=1;dflag=2;% default ray fan, and flags
figure;subplot(2,1,1);flipy
t=zeros(size(zrec));
for kk=1:length(zrec)
	if(kk==1)dflag=-gcf;else;dflag=2;end
	[t(kk),p]=traceray_pp(vp,zp,zsrc,zrec(kk),zd,xoff,...
      caprad,pfan,itermax,optflag,pflag,dflag);
end
title([' VSP Vertical gradient simulation, P-P mode '])
line(xoff,zrec,'color','b','linestyle','none','marker','v')
line(0,zsrc,'color','r','linestyle','none','marker','*')
grid;xlabel('meters');ylabel('meters');
subplot(2,1,2);plot(t,zrec);
xlabel('seconds');ylabel('depth (meters)');grid;flipy;

figure;subplot(2,1,1);flipy;
t=zeros(size(zrec));
for kk=1:length(zrec)
	if(kk==1)dflag=-gcf;else;dflag=2;end
	[t(kk),p]=traceray_ps(vp,zp,vs,zs,zsrc,zrec(kk),zd,xoff,...
      caprad,pfan,itermax,optflag,pflag,dflag);
end
title([' VSP Vertical gradient simulation, P-S mode '])
line(xoff,zrec,'color','b','linestyle','none','marker','v')
line(0,zsrc,'color','r','linestyle','none','marker','*')
grid;xlabel('meters');ylabel('meters');
subplot(2,1,2);plot(t,zrec);
xlabel('seconds');ylabel('depth (meters)');grid;flipy;
