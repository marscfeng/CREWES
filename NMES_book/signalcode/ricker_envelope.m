%% envelope of a Ricker wavelet
[w,tw]=ricker(.0005,30,.2);%make a wavelet
env=abs(hilbert(w));
figure
%plot(tw,w,'k',tw,env,'r')
linesgray({tw,w,'-',.5,0},{tw,env,'-',1.5,.5});
xlabel('time (s)')
legend('30 Hz Ricker','Hilbert envelope','location','northeast')
xlim([-.1 .1])
prepfig
bigfont(gcf,2,1);boldlines(gcf,1.5)
print -depsc .\signalgraphics\ricker_envelope