%assumes that reflec_seis_all has been run
noise1=rnoise(s2,1,near(t,.1,.8));
noise2=rnoise(s2,2,near(t,.1,.8));
noise5=rnoise(s2,5,near(t,.1,.8));
noise10=rnoise(s2,10,near(t,.1,.8));
s2_1=s2+noise1;
s2_2=s2+noise2;
s2_5=s2+noise5;
s2_10=s2+noise10;
figure;
line(t,s2_1+.6,'color','k');text(max(t),.6,'s/n=1')
line(t,s2_2+.4,'color','k');text(max(t),.4,'s/n=2')
line(t,s2_5+.2,'color','k');text(max(t),.2,'s/n=5')
line(t,s2_10,'color','k');text(max(t),0,'s/n=10')
xlabel('seconds');ylabel('amplitude')
prepfig
bigfont(gcf,1.75,1)
print -depsc wavepropgraphics\reflecnoise.eps

[S1,f]=fftrl(s2_1,t);
[S2,f]=fftrl(s2_2,t);
[S5,f]=fftrl(s2_5,t);
[S10,f]=fftrl(s2_10,t);
S1=real(todb(S1));
S2=real(todb(S2))-30;
S5=real(todb(S5))-60;
S10=real(todb(S10))-90;
figure
line(f,S1,'color','k');text(max(f),S1(end),'s/n=1')
line(f,S2,'color','k');text(max(f),S2(end),'s/n=2')
line(f,S5,'color','k');text(max(f),S5(end),'s/n=5')
line(f,S10,'color','k');text(max(f),S10(end),'s/n=10')
hold
plot(fwm,Wm,'k:')
plot(fwm,Wm-30,'k:')
plot(fwm,Wm-60,'k:')
plot(fwm,Wm-90,'k:')
xlabel('frequency (Hz)');ylabel('decibels')
prepfig
bigfont(gcf,1.75,1)
print -depsc wavepropgraphics\reflecnoisespec.eps