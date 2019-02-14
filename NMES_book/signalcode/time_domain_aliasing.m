close all
dt=.001;
tmax=1;
[r,t]=reflec(tmax,dt,.1,3,pi);%make a synthetic reflectivity
r(end-5)=.2;%insert a large spike at the end of the trace
rr=[zeros(size(r));r;zeros(size(r))];
ra=[r;r;r];
ta=dt*(-length(r):2*length(r)-1)';
figure;
subplot(2,1,1)
linesgray({ta,rr,'-',.5,0})
xlim([-1 2])
subplot(2,1,2)
linesgray({ta,ra,'-',.5,.5},{t,r,'-',.5,0})
xlim([-1 2])
xlabel('time (sec)')
prepfig
legend('time-domain aliases','original trace','location','northwest')
bigfont(gcf,1,1)

print -depsc ..\signalgraphics\timealias

%now make an impulse at t=0
imp=zeros(size(r));
imp(1)=1;
%filter the impulse to capture the impulse response of a minimum phase filter
imp=filtf(imp,t,[10 5],[40 10],1);%filtf operates in the frequency domain
w=imp(1:500);%truncate to 500 samples
sm=convm(r,w);%convolve with r
sm2=filtf(r,t,[10 5],[40 10],1);%apply the same filter directly to r
%theory say sm and sm2 should be identical. Are they?
figure;
subplot(2,1,1)
h1=linesgray({t,imp,'-',.5,.5});
subplot(2,1,2)
h2=linesgray({t,sm2,'-',1.5,.7},{t,sm,'-',.5,0});
xlabel('time (sec)')
legend([h1 h2],'Filter impulse response','Multiplication in Fourier domain','Direct convolution')
prepfig
bigfont(gcf,1,1)
print -depsc ..\signalgraphics\timedomainwraparound

%to avoid time-domain aliasing, we apply a zero pad to r before filtering
rp=pad_trace(r,1:1501);%this applies a 500 sample zero pad
tp=.001*(0:1500);%make a tp to plot against
rpa=[rp;rp;rp];
tpa=dt*(-length(rp):2*length(rp)-1)';
figure
subplot(2,1,1)
h3=linesgray({tpa,rpa,'-',.5,.5},{tp,rp,'-',.5,0});
xlabel('time (sec)')
xlim([-1.5 3])
legend(h3,'padded reflectivity','time-domain aliases');
%apply the filter to rp

smp=filtf(rp,tp,[10,5],[40,10],1);
subplot(2,1,2)
linesgray({tp,smp,'-',1.5,.7},{t,sm,'-',.5,0});
xlabel('time (sec)')
legend('Padded and filtered in freq. domain','Direct convolution');
prepfig
bigfont(gcf,1,1)

print(-