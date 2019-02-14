%script to demonstrate the properties of fkplots

%% not in Book
%make a single linear event with positive time dip
dt=.004;t=(0:250)*dt;dx=10;x=(-100:100)*dx;
seis=zeros(length(t),length(x));
seis=event_dip(seis,t,x,[.01 .2],[0 1000],1);
seisf=filtf(seis,t,[0 0],[60 10]);
plotimage(seis,t,x)
title('Unfiltered event')
[fks,f,k]=fktran(seis,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum before filter')
plotimage(seisf,t,x)
title('Filtered event')
[fks,f,k]=fktran(seisf,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum  after filter')
%% plane wave figure IN BOOK
%close all
theta=15;
dx=1;
dz=dx/5;
fmax=100;
delfmax=50;
xmax=1000;
xmin=0;
v=2000;
x=(xmin:dx:xmax);
zmax=xmax/3;
z=(0:dz:zmax)';

z1=0;
z2=z1+(xmax-xmin)*tand(theta);
snap=zeros(length(z),length(x));
snap=event_dip(snap,z,x,[z1 z2],[xmin xmax],1);
snapf=filtf(snap,z,0,[fmax/v delfmax/v],1);
fs=12;

figure('position',[200 200 1000 1000]);
ha1=subplot(2,1,1);
p1=get(ha1,'position');
set(ha1,'position',[p1(1) .49 p1(3) .41])
amax=max(abs(snapf(:)));
imagesc(x,z,snapf,[-amax amax]);colormap('seisclrs')
%xlabel('meters');
ylabel('meters');
axis equal
ylim([0 zmax])
%set(gca,'xaxislocation','top')
%set(gca,'xticklabel','')
title('')
%draw normal ray
x1=(xmax-xmin)/2;
z1=x1*tand(theta);
z2=0;
x2=x1+z1*tand(theta);
h=arrow([x1 x2],[z1 z2],'','k',.5,'-',.1,1);
%angle
angles=linspace(0,theta,100);
R=300;
xa=R*cosd(angles);
za=R*sind(angles);
linesgray({xa,za,':',.5,1});
ht=text(mean(xa),mean(za),['\theta = ' int2str(theta) '^o']);
set(ht,'color','w','fontsize',fs,'fontweight','normal');
grid
text(10,300,'a)','fontsize',fs);

ha2=subplot(2,1,2);
dt=0.0001;
tmax=max(z)/v;
t=0:dt:tmax;
t1=0;
t2=t1+(xmax-xmin)*sind(theta)/v;
zos=zeros(length(t),length(x));
zos=event_dip(zos,t,x,[t1 t2],[xmin xmax],1);
zosf=filtf(zos,t,0,[fmax delfmax],1);
imagesc(x,t,zosf,[-amax amax]);colormap('seisclrs')
xlabel('meters');ylabel('seconds');
ylim([0 zmax/v])
% set(gca,'xaxislocation','top')
grid
text(10,.15,'b)','fontsize',fs);
%prepfig
whitefig
title('');
bigfont(gcf,3,1);boldlines(gcf,3)
p1=get(ha1,'position');
p2=get(ha2,'position');
set(ha1,'position',[p2(1) p1(2) p2(3) p1(4)]);

print -depsc .\signalgraphics\planewave
%% fan of dips IN BOOK
close all

make_dip_fans

figure('position',[200,200,1000,1000]);
amax=.5*max(abs(seis1(:)));
fs=12;
subplot(2,2,1)
imagesc(x,t,seis1f,[-amax amax]);
xlabel('distance (meters)');ylabel('time (seconds)')
text(-950,.1,'a)','fontsize',fs)
grid
subplot(2,2,2)
imagesc(k,f,abs(seis1fk),[-amax amax]);
xlabel('wavenumber (meters^{-1})');ylabel('frequency (Hz)')
text(-.045,10,'b)','fontsize',fs)
grid
subplot(2,2,3)
imagesc(x,t,seis2f,[-amax amax]);
xlabel('distance (meters)');ylabel('time (seconds)')
text(-950,.1,'c)','fontsize',fs)
grid
subplot(2,2,4)
imagesc(k,f,abs(seis2fk),[-amax amax]);
xlabel('wavenumber (meters^{-1})');ylabel('frequency (Hz)')
text(-.045,10,'d)','fontsize',fs)
colormap('seisclrs');
grid
whitefig
bigfont(gcf,1.7,1);

print -depsc .\signalgraphics\dipfan

%% fkspectrum of a diffraction hyperbola IN BOOK
%make a diffraction in a seismic section
close all
vstk=2100;%hyperbolic event velocity
t0=.2;%apex time
x0=0;%spatial position
flow=10;delflow=5;fmax=60;delfmax=20;%bandpass filter params
dt=.004;tmax=1;t=0:dt:tmax;%time coordinate
dx=7.5;xmax=1000;x=-xmax:dx:xmax;%x coordinate
seis=zeros(length(t),length(x));%preallocate seismic matrix
%diffraction
seis=event_hyp(seis,t,x,t0,x0,vstk,1);
seisf=filtf(seis,t,[flow delflow],[fmax delfmax],1);%bandpass filter
[seisfk,f,k]=fktran(seisf,t,x);

fs=12;
figure
subplot(1,2,1)
smax=.5*max(seisf(:));
imagesc(x,t,seisf,[-smax smax]);
xlabel('meters');ylabel('seconds');
text(-950,0.05,'a)','fontsize',fs);
colormap seisclrs(256)
subplot(1,2,2)
A=abs(seisfk);
Amax=max(A(:));
imagesc(k,f,A,[-Amax Amax])
xlabel('meters^{-1}');ylabel('Hz')
text(-.06,5,'b)','fontsize',fs);
prepfig
bigfont(gcf,1.5,1)

print -depsc .\signalgraphics\fkhyperbola

seis1=zeros(size(seis));
seis2=seis1;seis3=seis1;
ind=between(-xmax/5,xmax/5,x,2);
seis1(:,ind)=seisf(:,ind);%central offsets
ind1=between(-3*xmax/5,-xmax/5,x,2);
ind2=between(xmax/5,3*xmax/5,x,2);
seis2(:,[ind1 ind2])=seisf(:,[ind1 ind2]);%intermediate offsets
ind1=between(-xmax,-3*xmax/5,x,2);
ind2=between(3*xmax/5,xmax,x,2);
seis3(:,[ind1 ind2])=seisf(:,[ind1 ind2]);%far offsets
seis1fk=fktran(seis1,t,x);
seis2fk=fktran(seis2,t,x);
seis3fk=fktran(seis3,t,x);

fs=12;
figure
subplot(3,2,1)
imagesc(x,t,seis1,[-smax smax])
xlabel('meters');ylabel('seconds');
text(-950,0.07,'a)','fontsize',fs);
subplot(3,2,2)
imagesc(k,f,abs(seis1fk),[-Amax Amax])
xlabel('meters^{-1}');ylabel('Hz')
text(-.06,10,'b)','fontsize',fs);
subplot(3,2,3)
imagesc(x,t,seis2,[-smax smax])
xlabel('meters');ylabel('seconds');
text(-950,0.07,'c)','fontsize',fs);
subplot(3,2,4)
imagesc(k,f,abs(seis2fk),[-Amax Amax])
xlabel('meters^{-1}');ylabel('Hz')
text(-.06,10,'d)','fontsize',fs);
subplot(3,2,5)
imagesc(x,t,seis3,[-smax smax])
xlabel('meters');ylabel('seconds');
text(-950,0.07,'e)','fontsize',fs);
subplot(3,2,6)
imagesc(k,f,abs(seis3fk),[-Amax Amax])
xlabel('meters^{-1}');ylabel('Hz')
text(-.06,10,'f)','fontsize',fs);
colormap seisclrs(256)
prepfig
bigfont(gcf,1.35,1)

print -depsc .\signalgraphics\fkhyperbola2


%% NOT IN BOOK
%make a many events with the same time dip
dt=.004;t=(0:250)*dt;dx=10;x=(-100:100)*dx;
seis=zeros(length(t),length(x));
delt=[.01 .2];delx=[0 1000];
seis=event_dip(seis,t,x,delt,delx,1);
seisf=filtf(seis,t,[0 0],[60 10]);
plotimage(seisf,t,x)
[fks,f,k]=fktran(seisf,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum, single event')
%add other events with the same dip
seis=event_dip(seis,t,x,delt,delx-200,1);
seis=event_dip(seis,t,x,delt+.3,delx-300,1);
seis=event_dip(seis,t,x,delt+.5,delx-500,1);
seis=event_dip(seis,t,x,delt+.1,delx-1000,1);
seisf=filtf(seis,t,[0 0],[60 10]);
plotimage(seisf,t,x)
[fks,f,k]=fktran(seisf,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum, many events')
%% NOT IN BOOK
close all
%make a single linear event with positive time dip
dt=.004;t=(0:250)*dt;dx=10;x=(-100:100)*dx;
seis=zeros(length(t),length(x));
seis=event_dip(seis,t,x,[.01 .2],[0 1000],1);
seisf=filtf(seis,t,[0 0],[60 10]);
plotimage(seis,t,x)
title('Unfiltered event')
[fks,f,k]=fktran(seis,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum before filter')
plotimage(seisf,t,x)
title('Filtered event')
[fks,f,k]=fktran(seisf,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum  after filter')
%% NOT IN BOOK
%add in the corresponsing event with negative time dip
seis=event_dip(seis,t,x,[.01 .2],[0 -1000],1);
seisf=filtf(seis,t,[0 0],[60 10]);
plotimage(seisf,t,x)
[fks,f,k]=fktran(seisf,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum')
%% NOT IN BOOK
close all
%put in some much steeper (slower) events
%we diliberately make events with different slopes left and right
seis=event_dip(seis,t,x,[.01 .8],[0 1000],1);
seis=event_dip(seis,t,x,[.01 1],[0 -1000],1);
seisf=filtf(seis,t,[0 0],[60 10]);
plotimage(seisf,t,x)
[fks,f,k]=fktran(seisf,t,x);
plotimage(abs(fks),f,k);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum')
%% NOT IN BOOK
%resample in x by selecting every other trace
seisf2=seisf(:,1:2:end);
x2=x(1:2:end);
plotimage(seisf2,t,x2)
[fks,f,k2]=fktran(seisf2,t,x2);
plotimage(abs(fks),f,k2);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum, every 2nd trace')
%% NOT IN BOOK
%filter the previous back to 20 Hz
seisf2f=filtf(seisf2,t,[0 0],[20 5]);
plotimage(seisf2f,t,x2)
[fks,f,k2]=fktran(seisf2f,t,x2);
plotimage(abs(fks),f,k2);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum, every 2nd trace, 0-20Hz')
%% NOT IN BOOK
%highpass filter above 30 hz
seisf2fh=filtf(seisf2,t,[30 5],[0 0]);
plotimage(seisf2fh,t,x2)
[fks,f,k2]=fktran(seisf2fh,t,x2);
plotimage(abs(fks),f,k2);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum, every 2nd trace, 30 Hz and above')
%% NOT IN BOOK
%resample in x by selecting every third trace
seisf3=seisf(:,1:3:end);
x3=x(1:3:end);
plotimage(seisf3,t,x3)
[fks,f,k3]=fktran(seisf3,t,x3);
plotimage(abs(fks),f,k3);
xlabel('Wavenumber k_x (m^{-1})');ylabel('Frequency (Hz)');
title('FK spectrum, every 3rd trace')