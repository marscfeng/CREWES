%make a reflectivity

r=zeros(1001,1);
r(350)=.1;%a single non-zero sample
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
%compare the wavelets
subplot(2,1,1)
%plot(tm,wm,'b',tz,wz,'r')
linesgray({tm,wm,'-',.5,0},{tz,wz,'-',.5,.5})
grid
xlim([-.5 .5]);xtick(-.5:.1:.5)
ylim([-1.5 1])
xlabel('time (sec)')
legend('w_m (minimum phase)','w_z (zero phase)')
%title('wavelets')
subplot(2,1,2)
%plot(t,r,'k',t,sm+.2,'b',t,sz+.4,'r')
linesgray({t,r,'-',1,.7},{t,sm+.2,'-',.5,0},{t,sz+.5,'-',.5,.5})
grid
ylim([-.4 .6])
xtick(0:.1:1)
xlabel('time (sec)')
%title('reflectivity')
legend('r (reflectivity)','s_m = r \bullet w_m','s_z = r \bullet w_z')
prepfig
bigfont(gcf,.75,1)

%legendfontsize(.75)

print -depsc ..\signalgraphics\convoconcept1
