dt1=.0001;%pseudo continuous sample size
dt2=.004;%simulated sample size
tlen=.4;%length of Ormsby wavelet
tmax=1;%length of signal
[w,tw]=ormsby(5,10,100,120,tlen,dt1);%bandlimiting Ormsby wavelet
[r,t1]=reflec(tmax,dt1,.1,3,4);%reflectivity
s1=convz(r,w);%pseudo continuous seismogram
s1=s1/max(s1);%normalize
%Now sampling
s2=zeros(size(t1));%initialize for sampled signal
inc=round(dt2/dt1);%indicies of desired samples
s2(1:inc:end)=s1(1:inc:end);%the actual sampling
%Now Fourier transform
S1=abs(fftshift(fft(s1)));%amplitude spectrum of continuous signal
S2=abs(fftshift(fft(s2)));%amplitude spectrum of sampled signal
f1=freqfft(t1,length(t1));%frequency coordinate for plotting spectra
fnyq=.5/dt2;%Nyquist frequency
ind=near(f1,-fnyq,fnyq);%pointer to the principal frequency band