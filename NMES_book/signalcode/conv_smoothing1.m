%demonstrate smoothing by convolution
dt=.001;tmax=1;
t=0:dt:tmax;
f1=5;
a1=.1;a2=1;
s=a1*sin(2*pi*f1*t)+a2*t;
n=.2*randn(size(t));
sn=s+n;
figure
subplot(2,1,1)
plot(t,sn,'b',t,s,'r')
legend('noisy signal','actual signal')
%
tsmo=.1;
nsmo=round(tsmo/dt);
box=ones(1,nsmo);
sbox=convz(sn,box/nsmo);
triang=conv(box,box);
striang=convz(sn,triang/sum(triang));
subplot(2,1,2)
%
tsmog=2*tsmo;
sigma=tsmog/4;
tg=-tsmog/2:dt:tsmog/2;
g=exp(-(tg/sigma).^2);
sg=convz(sn,g/sum(abs(g)));
plot(t,sbox,'b',t,sg,'k',t,striang,'m',t,s,'r')
legend('boxcar smoothed','gaussian smoothed','triangle smoothed','actual signal')
