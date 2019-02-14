makeconvsyntheticwater

w=pad_trace(w,t);

nlags=floor(length(r)/2);
ar=ccorr(r,r,nlags);
as=ccorr(s,s,nlags);
asm=ccorr(sm,sm,nlags);
aw=ccorr(w,w,nlags);
awm=ccorr(wm,wm,nlags);
tau=dt*(-nlags:nlags)';

traces=cell(1,5);
autos=traces;
names=traces;

traces{1}=r;
traces{4}=s;
traces{5}=sm;
traces{2}=w;
traces{3}=wm;

autos{1}=ar;
autos{4}=as;
autos{5}=asm;
autos{2}=aw;
autos{3}=awm;

names{1}='reflectivity';
names{4}='trace no multiples';
names{5}='trace w/multiples';
names{2}='source wavelet';
names{3}='extended wavelet w/multiples';
x0=.05;y0=.1;sep=.01;wid=.87*(1-2*x0-sep)/2;ht=1-2*y0;
fs=12;
figure


subplot('position',[x0+wid+sep,y0,wid,ht])
%trplot(tau,autos,'order','d','normalize',1,'tracespacing',1.5,'names',names,'color',zeros(1,5),'fontsize',fs)
trplot(tau,autos,'order','d','normalize',1,'tracespacing',1.5,'color',zeros(1,5),'fontsize',fs)
yl=get(gca,'ylim');
line([-twater -twater],yl,'linestyle','--','linewidth',.5,'color','k');
line([twater twater],yl,'linestyle','--','linewidth',.5,'color','k');
xlabel('lag time (sec)')
title('autocorrelations (lag domain)');titlefontsize(1,1)
xtick(-1:.5:1.5)

subplot('position',[x0,y0,wid,ht])
trplot(t,traces,'order','d','normalize',1,'tracespacing',1.5,'color',zeros(1,5),'fontsize',fs,...
    'names',names,'namesalign','center','nameshift',.2)
title('signals (time domain)');titlefontsize(1,1)

prepfiga
bigfont(gcf,1.25,1)
print -depsc decongraphics\waterbtm.eps