[wavem,t]=wavemin(.001,20,1);
[Wavem,f]=fftrl(wavem,t);
Amp=abs(Wavem);
dbAmp=20*log10(Amp/max(Amp));
figure
subplot(3,1,1);plot(t,wavem);xlabel('time (sec)');xlim([0 .2])
subplot(3,1,2);plot(f,abs(Amp));xlabel('Hz');ylabel('linear scale');
ylim([0 1.01])
subplot(3,1,3);plot(f,dbAmp);xlabel('Hz');ylabel('dB')
prepfiga
bigfont(gcf,2,1)

print -deps .\intrographics\intro1a.eps