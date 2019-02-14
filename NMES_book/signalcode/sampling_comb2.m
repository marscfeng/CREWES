%show that a comb tranforms to a comb
dt=.0001;%sample rate in time
delt=[.05 .01 .004];%time-domain comb spacings
tmax=50;%maximum time (length of combs)
nt=round(tmax/dt);%initial number of samples
nt=2^(nextpow2(nt));%adjust to a power of 2
t=dt*(0:nt-1)';%time axis
c=zeros(length(t),length(delt));%array for time-domain combs
C=c;%array for frequency-domain combs
for k=1:length(delt)
    nt2=round(delt(k)/dt);%number of samples between teeth (time)
    c(:,k)=comb(t,nt2);%make time comb
    C(:,k)=abs(fftshift(fft(c(:,k))))/nt;%fft and normalize
end
f=freqfft(t,nt);%frequency coordinate for the spectrum