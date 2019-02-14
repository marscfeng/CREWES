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
s=qmat*pm;

e=env(s);
tsmo=.2;
stab=.01;
nsmo=round(tsmo/dt);
esmo=convz(e,ones(nsmo,1))/nsmo;
emax=max(esmo);
sg=s./(esmo+stab*emax);


figure
% names={'s(t)=impulse response','envelope of s(t)','smoothed envelope','s_g(t)= AEC corrected trace'};
% % trplot(t,[s,e,esmo,sg*emax],'yaxis','n','order','d','color',{'k','k','k','k'},'names',names)
% linesgray({t,s+8*emax,'-',.5,0},{t,e+3*emax,'-',1,.5},{t,esmo+3*emax,':',.5,0},{t,sg*emax,'-',.75,.3})
% legend(names)
%xlim([.1 1.3]);%ylim([-.1 .6])
% names={'s(t)=impulse response','envelope of s(t)','smoothed envelope','s_g(t)= AEC corrected trace'};
y0=.1;ht=(1-2*y0)/3;sep=0.04;
subplot('position',[.1,y0+2*ht+2*sep,.8,ht])
linesgray({t,s,'-',.5,0});
set(gca,'xticklabel','','xgrid','on','ygrid','on');xlabel('')
xlim([0 1])
titlein('s(t)=attenuated impulse response');
titlefontsize(1,1)
subplot('position',[.1,y0+ht+sep,.8,ht])
linesgray({t,e,'-',1,.5},{t,esmo,'-',.5,0});
set(gca,'xticklabel','','xgrid','on','ygrid','on');xlabel('')
xlim([0 1])
titlein('envelope and smoothed envelope');
titlefontsize(1,1)
subplot('position',[.1,y0,.8,ht])
linesgray({t,sg,'-',.5,0});
set(gca,'xgrid','on','ygrid','on');xlabel('time(sec)')
xlim([0 1])
titlein('s_g(t)=AEC corrected trace');
titlefontsize(1,1)
prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\aec_method.eps