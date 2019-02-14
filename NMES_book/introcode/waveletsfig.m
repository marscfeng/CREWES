dt=.001;%time sample size
fdom=30;%dominant frequency for ricker and wavemin
fmin=10;%beginning of passband for ormsby and klauder
fmax=70;%end of passband for ormsby and klauder
tlen=2;%temporal length of each wavelet
slen=8;%sweep length (klauder)
staper=.5;%sweep taper (klauder)
m=3.5;%spectral decay control in wavemin

[wm,twm]=wavemin(dt,fdom,tlen,m);
[wr,twr]=ricker(dt,fdom,tlen);
[wo,two]=ormsby(fmin-5,fmin,fmax,fmax+10,tlen,dt);
[wk,twk]=klauder(fmin,fmax,dt,slen,tlen,staper);

[Wm,fwm]=fftrl(wm,twm);
[Wr,fwr]=fftrl(wr,twr);
[Wo,fwo]=fftrl(wo,two);
[Wk,fwk]=fftrl(wk,twk);

figure
inc=.1;
%plot(twm,wm,twr,wr+inc,two,wo+2*inc,twk,wk+3*inc);
linesgray({twm,wm,'-',.4,0},{twr,wr+inc,'-',.9,.3},...
    {two,wo+2*inc,'-',.9,.5},{twk,wk+3*inc,'-',1.1,.7});
xlabel('time (sec)')
xlim([-.25 .25]);ylim([-.1 .45])
legend('Minimum phase','Ricker','Ormsby','Klauder')
grid
prepfig;bigfont(gca,1.8,1)

figure
%plot(fwm,abs(Wm),fwr,abs(Wr),fwo,abs(Wo),fwk,abs(Wk))
linesgray({fwm,abs(Wm),'-',.4,0},{fwr,abs(Wr),'-',.9,.3},...
    {fwo,abs(Wo),'-',.9,.5},{fwk,abs(Wk),'-',1.1,.7});
xlabel('frequency (Hz)')
xtick([0 10 30 50 70 100 150])
legend('Minimum phase','Ricker','Ormsby','Klauder')
xlim([0 150]);ylim([0 1.1])
grid
prepfig;bigfont(gca,1.8,1)

