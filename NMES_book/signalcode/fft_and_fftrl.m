dt=.002;%time sample size
tmax=1;%maximum time
fdom=30;%wavelet dominant frequency
tlen=.3;%wavlet length
[r,tr]=reflec(tmax,dt,.2,3,4);%make a reflectivity
[w,tw]=wavemin(dt,fdom,tlen);%wavelet
s=conv(r,w);%use conv not convm to avoid truncation effects
t=(0:length(s)-1)*dt;%time coordinate for s
fnyq=.5/dt;%Nyquist frequency

[R,fr]=fftrl(r,tr);%one-sided spectrum of r
[W,fw]=fftrl(w,tw);%one-sided spectrum of w
[S,f]=fftrl(s,t);%one-sided spectrum of s
S2w=fft(s);%two sided spectrum of s (wrapped)
f2w=freqfft(t,length(s),1);%frequency coordinate for S2w
S2=fftshift(S2w);%two-sided spectrum unwrapped
f2=freqfft(t);%frequency coordinate for S2