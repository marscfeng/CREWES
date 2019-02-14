%show that a comb tranforms to a comb
dt=.0001;%sample rate in time
tmax=40;%maximum time
nt=round(tmax/dt);%initial number of samples
nt=2^(nextpow2(nt));%adjust to a power of 2
t=dt*(0:nt-1)';%time axis
delt=[.05 .01 .004];%time-domain comb spacings
sc=zeros(length(t),length(delt));
Sc=sc;
for k=1:length(delt)
    nt2=round(delt(k)/dt);%number of samples between teeth of time comb
    c=comb(t,nt2);%make time comb
    sigma=delt(k)/100;%standard deviation of gaussian
    tg=-2*delt(1):dt:2*delt(1);%time span of gaussian
    g=exp(-(tg/sigma).^2);%gaussian
    %sc(:,k)=convz(c,g);%convolve gaussian with comb
    sc(:,k)=c;
    Sc(:,k)=abs(fftshift(fft(sc(:,k))))/nt;%fft and normalize
end
f=freqfft(t,nt);
figure
nplot=0;
for k=1:length(delt)
    nplot=nplot+1;
    subplot(length(delt),2,nplot)
    plot(t,sc(:,k),'k')
    xlim([1.9 2.1])
    nplot=nplot+1;
    subplot(length(delt),2,nplot)
    plot(f,Sc(:,k),'k')
    xlim([-500 -250 0 250 500])
end
prepfig
