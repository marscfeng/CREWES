[y,Fs] = audioread('ShortScale.wav');
sound(y,Fs);
%%
spectrogram(x,2^14,2^13,linspace(0,.01,20),'yaxis')

%%
%[tvs,tout,fout,normf_tout]=fgabor(trin,t,twin,tinc,p,gdb,normflag,pow2option)
x=y(:,1);
trin=x;
t = (1:length(trin))/Fs;
twin = .1;
tinc = twin/2;
p = 1;
gdb = 60;
normflag = 0;
pow2option = 1;
[tvs,tout,fout,normf_tout]=fgabor(trin,t,twin,tinc,p,gdb,normflag,pow2option);
imagesc(tvs)
%%
tsize=60;
fsize=3000;
imagesc(tout(1:tsize), -fout(1500:fsize), -abs((tvs(1:tsize,1500:fsize)')))
colormap(gray)
title("Time Frequency Display")
xlabel("Time (s)")
ylabel("Frequency (Hz)")
prepfig()

%%
z = abs(fft(x));
zstart = 1000;
zend = 2500;
f = linspace(Fs*zstart/length(z),Fs*zend/length(z),zend-zstart+1);
plot(f,z(zstart:zend),'k')
title("Frequency Display")
xlabel("Frequency (Hz)")
ylabel("Amplitude")
prepfig()

