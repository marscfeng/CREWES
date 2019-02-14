%% Cell 3: Read well 1409 and block it in prep for a more complex model
%load a well log and block it

% define the overbuden and blocking parameters
vp0=1600;%p-wave velocity at the surface
vs0=900;%s-wave velocity at the surface (not used in this simulation)
rho0=1800;%density at the surface
dzblk=1;%blocking size
dzout=1;%sample size
%Note: dzout should be <= dzblk

%define the fake Q parameters
Q1=20; %low reference Q
Q2=200; %high reference Q
vp1=1500; %velocity corresponding to Q1
vp2=4500; %velocity corresponding to Q2
rho1=1800; %density corresponding to Q1
rho2=3000; %density corresponding to Q2

%specify wavelet and time sampling
waveflag=1;%make 0 for Ricker, 1 for min phase
fdom=30;%wavelet dominant frequency
dt=0.002;%time sample interval
tmax=3;%maximum record length

wellfile='data\alberta_well.las';%las file to read

%read the LAS file, block the logs, and attach the overburden
[vp,vs,rho,z]=blocklogs(filename,dzblk,dzout,vp0,vs0,rho0);

%make the fake Q
[Q,Qrand]=fakeq(vp,rho,Q1,Q2,2,vp1,vp2,rho1,rho2,1,1);

figure
plot(vp,z,rho,z,10*Q,z);flipy
title(['Well ' wellfile, ', dzblk=' num2str(dzblk) ', dzout=' num2str(dzout)])
ylabel('Depth (m)');
xlabel('Velocity or Density (MKS units) and Q')
legend('Velocity','Density','10*Q');
prepfig
posnfig
h1=gcf;

if(waveflag==0)
    [w,tw]=ricker(dt,fdom,.2);
elseif(waveflag==1)
    [w,tw]=wavemin(dt,fdom,.2);
else
    error('invalid waveflag')
end
figure
plot(tw,w)
title('Wavelet')
xlabel('time (s)')
prepfig
posnfig(gcf,.6,.5)
figure(h1)
%% Cell 4: create the VSP on the blocked logs model from Cell 3
%specify receivers
zrec1=0;%first receiver depth
zrecmax=1500;%maximum receiver depth
dzrec=10;%interval between receivers
zr=zrec1:dzrec:zrecmax;
rflag=0;
fpress=0;
fmult=1;%we want multiples
f0=12500;% f0 ... frequency at which vp has been measured

%DO NOT MAKE EDITS PAST HERE in Cell 4

[vspq,tq,upq,downq]=vspmodelq(vp,rho,Q,z,w,tw,tmax,zr,f0,rflag,fpress,fmult);

%compute a time depth curve from the well velocities
tz=vint2t(vp,z);
%interpolate times at each receiver depth
trec=interp1(z,tz,zr);
%compute drift times
td=tdrift(Q,z,vp,fdom,f0);
%interpolate at the receiver depth
tdr=interp1(z,td,zr);

seisplot(vspq',zr,tq);
title(['Total field, dzblk=' num2str(dzblk) ', dzout=' num2str(dzout)]);
ylabel('receiver depth');
xlabel('time');
title(['Total field, dzblk=' num2str(dzblk) ', dzout=' num2str(dzout)]);
posnfig(gcf,.3,.6)
h1=gcf;

seisplot(upq',zr,tq);
title(['Upgoing field, dzblk=' num2str(dzblk) ', dzout=' num2str(dzout)]);
ylabel('receiver depth');
xlabel('time');
posnfig(gcf,.7,.6);
h2=gcf;

seisplot(downq',zr,tq);
hline1=line(trec,zr,'color','r');
hline2=line(trec+tdr,zr,'color','g');
title(['Downgoing field, dzblk=' num2str(dzblk) ', dzout=' num2str(dzout)]);
ylabel('receiver depth');
xlabel('time');
legend([hline1 hline2],'time at well velocity','time at seismic velocity');
posnfig(.3,.4);
h3=gcf;

figure
trace=downq(:,end);
amp=max(abs(trace))/3;
ind=near(tq,trec(end-1));
p1=zeros(size(tq));
p1(ind)=amp;
ind=near(tq,trec(end-1)+tdr(end-1));
p2=zeros(size(tq));
p2(ind)=amp;
plot(tq,trace,tq,p1,'r',tq,p2,'k')
title('Downgoing field at deepest receiver') 
xlabel('Time (s)')
legend('Deepest receiver','Well velocity time','Seismic velocity time')
posnfig(gcf,.7,.4);
figure(h3);figure(h2);figure(h1);