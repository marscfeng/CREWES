
dt=.004;
fdom=10;
tlen=.6;%make length a power of two
[w,tw]=wavemin(dt,fdom,tlen);%make min phase wavelet
W=fft(w);
W=fftshift(W);
f=freqfft(tw);
Rw=real(W);
Iw=imag(W);
Aw=abs(W);
Phiw=angle(W);


fs=12;
figure
subplot(3,1,1)
it=near(tw,0,.4);
plot(tw(it),w(it),'k');
xlabel('time (s)')
text(.01,-.05,'a)','fontsize',fs,'fontweight','b')

subplot(3,1,2)
%plot(f,Rw,f,Iw,f,Aw,'k')
linesgray({f,Rw,'-',.5,.3},{f,Iw,'-',.5,.7},{f,Aw,'-',.75,0});
ylim([-1 1]);
xlim([-125 125])
xtick(-100:50:100);
legend('Real part','Imaginary part','Amplitude')
text(-120,-.5,'b)','fontsize',fs,'fontweight','b')
grid

subplot(3,1,3)
%hh=plot(f,unwrap(Phiw),'r:',f,Phiw);
linesgray({f,unwrap(Phiw),':',.5,0},{f,Phiw,'-',.5,0});
xlim([-125 125])
xtick(-100:50:100);
ytick([-pi 0 pi])
set(gca,'yticklabel',{'-\pi' 0 '\pi'})
text(-120,-pi,'c)','fontsize',fs,'fontweight','b')
grid
xlabel('frequency (Hz)')
legend('Unwrapped phase','Phase')
legendfontsize(1.25)

prepfig
bigfont(gcf,.75,1)

print -depsc ..\signalgraphics\fouriersymmetries