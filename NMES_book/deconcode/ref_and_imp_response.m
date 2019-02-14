%compare impulse response and reflectivity
load data\logdata %contains vectors sp (p-wave sonic), rho (density) and z (depth)
dt=.001; %sample rate (seconds) of wavelet and seismogram
fdom=60;%dominant frequency of wavelet
[w,tw]=ricker(dt,fdom,.2);%ricker wavelet
fmult=1;%flag for multiple inclusion. 1 for multiples, 0 for no multiples
fpress=0;%flag,  1 for pressure (hydrophone) or 0 for displacement (geophone)
z=z-z(1);%adjust first depth to zero
tmin=0;tmax=1.0;%start and end times of seismogram
[spm,t,rcs,pm,p]=seismo(sp,rho,z,fmult,fpress,w,tw,tmin,tmax);%using Ricker wavelet
pm=-pm;
wimp=convz(impulse(t),w)*max(sp)/max(w);

Q=80;

qmat=qmatrix(Q,t,[1 0],[0 dt],3);

rcsq=qmat*rcs;
pmq=qmat*pm;

figure
fs=10;
names={'reflectivity','impulse response','attenuated reflectivity','attenuated impulse response'};
trplot(t,[rcs,pm,rcsq,pmq],'yaxis','n','order','d','color',{'k','k','k','k'},'names',names,...
    'normalize',1,'fontsize',fs)
%title('Reflectivity versus impulse responses')
xlim([.1 1.3]);%ylim([-.1 .6])
pos=get(gca,'position');
set(gca,'position',[pos(1)-.05 pos(2:4)])
prepfig
bigfont(gcf,1.25,1)

print -depsc decongraphics\rvsimp.eps