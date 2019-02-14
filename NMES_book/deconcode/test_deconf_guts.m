clear

dt=.002;%time sample size
t=dt*(0:511)';%t is 512 samples long
tmax=t(end);%max time
r=impulse(t);%a simgle impulse in the middle
fdom=20;%dominant frequency
delf=5;%deconf smoother in frequency
n=round(delf*tmax);%deconf smoother in samples
stab=0.00001;%mu the stability constant
[w,tw]=wavemin(dt,fdom,tmax/2);%min phase wavelet
s=convm(r,w);%trace

trin=s;trdsign=s;
nn=2*floor(n/2)+1;
deconf_guts

sd=trout;

names={'reflectivity','trace','deconvolved'};
figure
trplot(t,[r,s,sd],'order','d','color',[0 0 0],'normalize',1,'names',names,'tracespacing',1.2)
xlim([0 1.2])

prepfig


figure
f=freqfft(t,length(specinv));
subplot(2,1,1)
plot(f,real(todb(specinv)),'k');
titlein('Amplitude spectrum')
set(gca,'xticklabel','');ylabel('decibels')
subplot(2,1,2)
plot(f,unwrap(angle(specinv)),'k')
xlabel('frequency (hz)');ylabel('radians')
titlein('Phase spectrum','t',.1)

prepfig
