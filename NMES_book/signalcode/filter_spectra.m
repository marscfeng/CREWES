close all
dt=.002;
tmax=5;
flow=20;dflow=5;
fhigh=100;dfhigh=20;
fmin=[flow dflow];
fmax=[fhigh dfhigh];
%Lowpass
[flowpass,f]=filtspec(dt,tmax,0,fmax,1);
%highpass
fhighpass=filtspec(dt,tmax,fmin,0,1);
%bandpass
fbandpass=filtspec(dt,tmax,fmin,fmax,1);

fs=18;
figure
subplot(2,1,1)
linesgray({f,todb(abs(fbandpass)),'-',1.5,.8},{f,todb(abs(flowpass)),'-',.3,0},...
    {f,todb(abs(fhighpass)),':',.5,0});
xlabel('frequency (Hz)')
legend('bandpass','lowpass','highpass');
text(5,-85,'a)','fontsize',fs);
grid
ylim([-100 5])
ytick([-80 -40 0])
ls='-.';
line(fhigh*ones(1,2),[-100 5],'linestyle',ls,'color',.75*ones(1,3));
text(fhigh,-10,'fhigh','horizontalalignment','right');
line((fhigh+dfhigh)*ones(1,2),[-100 5],'linestyle',ls,'color',.75*ones(1,3));
text(fhigh+dfhigh,-10,'fhigh+dfhigh','horizontalalignment','left');
line(flow*ones(1,2),[-100 5],'linestyle',ls,'color',.75*ones(1,3));
text(flow,-10,'flow','horizontalalignment','left');
line((flow-dflow)*ones(1,2),[-100 5],'linestyle',ls,'color',.75*ones(1,3));
text(flow-dflow,-15,'flow-dflow','horizontalalignment','right');
ylabel('decibels')

subplot(2,1,2)
linesgray({f,unwrap(angle(fbandpass)),'-',1.5,.8},{f,unwrap(angle(flowpass)),'-',.3,0},...
    {f,unwrap(angle(fhighpass)),':',.5,0});
xlabel('frequency (Hz)')
ytick(pi*(-2:2));
text(5,-2*pi,'b)','fontsize',fs)
set(gca,'yticklabel',{'-2\pi','-\pi','0','\pi','2\pi'})
ylabel('radians')
grid
% ylim([-pi pi])

prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)

print -depsc ..\signalgraphics\filterspectra

%impulse responses
t=0:dt:tmax;
n=near(t,2.5);
imp=impulse(t,n);
wlowz=filtf(imp,t,0,fmax,0);
wlowm=filtf(imp,t,0,fmax,1);
whighz=filtf(imp,t,fmin,0,0);
whighm=filtf(imp,t,fmin,0,1);
wbandz=filtf(imp,t,fmin,fmax,0);
wbandm=filtf(imp,t,fmin,fmax,1);

tbeg=2.4;tend=2.6;
dt2=dt/10;
t2=tbeg:dt2:tend;
iwin=near(t,tbeg,tend);
wbandz2=interpbl(t(iwin),wbandz(iwin),t2);
wlowz2=interpbl(t(iwin),wlowz(iwin),t2);
whighz2=interpbl(t(iwin),whighz(iwin),t2);
figure
subplot(2,1,1)
linesgray({t2,wbandz2,'-',1.5,.8},{t2,wlowz2,'-',.3,0},{t2,whighz2,':',.5,0});
xtick(2.46:.02:2.54);
xlabel('time (sec)')
xlim([2.45 2.55])
grid
legend('bandpass','lowpass','highpass');
text(2.452,-.3,'a)','fontsize',fs)
subplot(2,1,2)
wbandm2=interpbl(t(iwin),wbandm(iwin),t2);
wlowm2=interpbl(t(iwin),wlowm(iwin),t2);
whighm2=interpbl(t(iwin),whighm(iwin),t2,4);
linesgray({t2,wbandm2,'-',1.5,.8},{t2,wlowm2,'-',.3,0},{t2,whighm2,':',.5,0});
xlabel('time (sec)')
xlim([2.45 2.55])
xtick(2.46:.02:2.54);
grid
text(2.452,-.7,'b)','fontsize',fs)
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)

print -depsc ..\signalgraphics\filterimpulses