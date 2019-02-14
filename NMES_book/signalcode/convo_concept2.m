%make a reflectivity
% close all
r=zeros(1001,1);
r(350)=.1;%a single non-zero sample
r(200)=-.1;
r(600)=.1;
r(650)=-.2;%a single non-zero sample
dt=.001;%time sample size
t=(0:1000)*dt;%time coordinate vector
[wm,tm]=wavemin(.001,20,.4);%a minimum phase (causal wavelet)
[wz,tz]=ricker(.001,20,.4);%a zero phase wavelet
wm=wm/max(wm);%normalize to maximum of 1
wz=wz/max(wz);
%convolutions
sz=convz(r,wz);
sm=convm(r,wm);
figure
%compare the traces
subplot(2,1,1)
%plot(t,r,'k',t,sm+.2,'b',t,sz+.4,'r')
linesgray({t,r,'-',1,.7},{t,sm+.2,'-',.5,0},{t,sz+.4,'-',.5,.5})
xtick(0:.1:1);
grid
ylim([-.4 .6])
xlabel('time (sec)')
%title('reflectivity')

subplot(2,1,2)
r=reflec(1,.001,.2,7,1);
%convolutions
sz=convz(r,wz);
sm=convm(r,wm);
%compare the traces
%plot(t,r,'k',t,sm+.2,'b',t,sz+.4,'r')
linesgray({t,r,'-',1,.7},{t,sm+.2,'-',.5,0},{t,sz+.4,'-',.5,.5})
xtick(0:.1:1)
grid
ylim([-.4 .6])
xlabel('time (sec)')
%title('reflectivity')
legend('r (reflectivity)','s_m = r \bullet w_m','s_z = r \bullet w_z')

prepfig
bigfont(gcf,.75,1)

% legendfontsize(.75)

print -depsc ..\signalgraphics\convoconcept2

