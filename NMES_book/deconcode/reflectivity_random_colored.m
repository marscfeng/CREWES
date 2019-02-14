%compare impulse response and reflectivity
load data\logdata %contains vectors sp (p-wave sonic), rho (density) and z (depth)
dt=.0005; %sample rate (seconds) of wavelet and seismogram
w=[1 0];
tw=[0 dt];
fmult=1;%flag for multiple inclusion. 1 for multiples, 0 for no multiples
fpress=0;%flag,  1 for pressure (hydrophone) or 0 for displacement (geophone)
z=z-z(1);%adjust first depth to zero
[spm,t,rcs,pm,p]=seismo(sp,rho,z,fmult,fpress,w,tw);%using Ricker wavelet

r=reflec(max(t),dt,max(rcs),3,pi);

figure
fs=8;
subplot(1,2,1)
names={'random reflectivity','well reflectivity'};
trplot(t,[r,rcs],'yaxis','y','order','d','color',{.5,0'},'names',names,'linewidths',[1,.5],...
    'nameslocation','end','namesalign','right','namesshift',-.5,'fontsize',fs)
subplot(1,2,2)
dbspec(t,[.01*r,rcs],'graylevels',[.5 0],'linewidths',[1,.5],'signallength',8192)
xlim([0 500])
legend(names,'location','southeast')
prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\realandfakercs.eps