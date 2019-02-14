zp=0:10:4000;vp=1800+.6*zp;vs=.5*vp;zs=zp;
xoff=1000:100:3000;
caprad=10;itermax=4;%cap radius, and max iter
pfan=-1;optflag=1;pflag=1;dflag=2;% default ray fan, and flags 

raycode=[0 1;1500 1;1300 1;2000 1;1800 1;3000 1;2000 1;2300 1;...
    1000 1; 1500 1; 0 1];
h1=figure;subplot(2,1,1);flipy
[t,p]=traceray(vp,zp,vs,zs,raycode,xoff,caprad,pfan,itermax,...
    optflag,pflag,dflag);
title('A P-P-P-P-P-P-P-P-P-P mode in vertical gradient media');
xlabel('meters');ylabel('meters')
line(xoff,zeros(size(xoff)),'color','b','linestyle','none',...
    'marker','v')
line(0,0,'color','r','linestyle','none','marker','*');grid
subplot(2,1,2);plot(xoff,t);
grid;flipy;xlabel('offset');ylabel('time')

raycode=[0 1;1500 2;1300 2;2000 2;1800 2;3000 1;2000 1;2300 1;...
    1000 1; 1500 2; 0 1];
h2=figure;subplot(2,1,1);flipy
[t,p]=traceray(vp,zp,vs,zs,raycode,xoff,caprad,pfan,itermax,...
    optflag,pflag,dflag);
title('A P-S-S-S-S-P-P-P-P-S mode in vertical gradient media');
xlabel('meters');ylabel('meters')
line(xoff,zeros(size(xoff)),'color','b','linestyle','none',...
    'marker','v')
line(0,0,'color','r','linestyle','none','marker','*');grid
subplot(2,1,2);plot(xoff,t);
grid;flipy;xlabel('offset');ylabel('time')
