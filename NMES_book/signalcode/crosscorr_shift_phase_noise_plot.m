close all

crosscorr_shift_phase_noise;

figure
inc=.05;
linesgray({t,s1,'-',.5,0},{t,s21+inc,'-',.5,0},{t,s22+2*inc,'-',.5,0},...
    {t,s1n+3*inc,'-',.5,0},{t,s21n+4*inc,'-',.5,0},{t,s22n+5*inc,'-',.5,0});
xlabel('time (s)')
grid
xlim([-.2, tmax])
x0=-.18;fs=10;
text(x0,0,'s_1','fontsize',fs);
text(x0,inc,'s_{21}','fontsize',fs);
text(x0,2*inc,'s_{22}','fontsize',fs);
text(x0,3*inc,'sn_1','fontsize',fs);
text(x0,4*inc,'sn_{21}','fontsize',fs);
text(x0,5*inc,'sn_{22}','fontsize',fs);
prepfig
bigfont(gcf,.8,1)

print -depsc ..\signalgraphics\ccshift1

figure
inc=1;
linesgray({tau,cc121,'-',.5,0},{tau,cc122+inc,'-',.5,0},...
    {tau,cc121n+2*inc,'-',.5,0},{tau,cc122n+3*inc,'-',.5,0});
xlabel('lag time (s)')
grid
x0=-.18;y0=.5;inc=1;
text(x0,y0,['cc_{max}= ' num2str(sigfig(mcc121(1),2)) ', lag= ' num2str(mcc121(2)*dt)],'fontsize',fs)
text(x0,y0+inc,['cc_{max}= ' num2str(sigfig(mcc122(1),2)) ', lag= ' num2str(mcc122(2)*dt)],'fontsize',fs)
text(x0,y0+2*inc,['cc_{max}= ' num2str(sigfig(mcc121n(1),2)) ', lag= ' num2str(mcc121n(2)*dt)],'fontsize',fs)
text(x0,y0+3*inc,['cc_{max}= ' num2str(sigfig(mcc122n(1),2)) ', lag= ' num2str(mcc122n(2)*dt)],'fontsize',fs)
xlim([-.6 .4]);
x0=-.59;
text(x0,0,'s_1 \otimes s_{21}','fontsize',fs);
text(x0,inc,'s_1 \otimes s_{22}','fontsize',fs);
text(x0,2*inc,'sn_1 \otimes sn_{21}','fontsize',fs);
text(x0,3*inc,'sn_1 \otimes sn_{22}','fontsize',fs);
prepfig
bigfont(gcf,.8,1);

print -depsc ..\signalgraphics\ccshift2

%make the Hilbert envelope plot
aflag=2;%we will pick positive values for cc
mcc121=maxcorr(s1,s21,maxlag,aflag);%the maximum and its lag 
mcc122=maxcorr(s1,s22,maxlag,aflag);
mcc121n=maxcorr(s1n,s21n,maxlag,aflag);
mcc122n=maxcorr(s1n,s22n,maxlag,aflag);
cc121e=abs(hilbert(cc121));
cc122e=abs(hilbert(cc122));
cc121ne=abs(hilbert(cc121n));
cc122ne=abs(hilbert(cc122n));

figure
inc=1;
hh=linesgray({tau,cc121,'-',.5,0},{tau,cc121e,'-',.5,.5},...
    {tau,cc122+inc,'-',.5,0},{tau,cc122e+inc,'-',.5,.5},...
    {tau,cc121n+2*inc,'-',.5,0},{tau,cc121ne+2*inc,'-',.5,.5},...
    {tau,cc122n+3*inc,'-',.5,0},{tau,cc122ne+3*inc,'-',.5,.5});
xlabel('lag time (s)')
legend(hh(1:2),'CC function','Hilbert envelope','location','west');
grid
x0=-.18;y0=.5;inc=1;
text(x0,y0,['cc_{max}= ' num2str(sigfig(mcc121(1),2)) ', lag= ' num2str(mcc121(2)*dt)],'fontsize',fs)
text(x0,y0+inc,['cc_{max}= ' num2str(sigfig(mcc122(1),2)) ', lag= ' num2str(mcc122(2)*dt)],'fontsize',fs)
text(x0,y0+2*inc,['cc_{max}= ' num2str(sigfig(mcc121n(1),2)) ', lag= ' num2str(mcc121n(2)*dt)],'fontsize',fs)
text(x0,y0+3*inc,['cc_{max}= ' num2str(sigfig(mcc122n(1),2)) ', lag= ' num2str(mcc122n(2)*dt)],'fontsize',fs)
xlim([-.6 .4]);
x0=-.59;
text(x0,0,'s_1 \otimes s_{21}','fontsize',fs);
text(x0,inc,'s_1 \otimes s_{22}','fontsize',fs);
text(x0,2*inc,'sn_1 \otimes sn_{21}','fontsize',fs);
text(x0,3*inc,'sn_1 \otimes sn_{22}','fontsize',fs);
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8);

print -depsc ..\signalgraphics\ccshift3
