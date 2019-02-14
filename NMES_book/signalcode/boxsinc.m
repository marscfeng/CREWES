%close all
tmax=4;
dt=.001;
t0=.5;
t=(0:dt:tmax)';
a=[.2 .1 .01];
yshifts=-[0 .005 .01];
boxes=zeros(length(t),length(a));
df=1/tmax;
fnyq=.5/dt;
f=(-fnyq:df:fnyq)';
sincs=zeros(length(f),length(a));
h1=figure;
h2=figure;
lw=linspace(.5,1.5,length(a));
gl=linspace(0,.7,length(a));
for k=length(a):-1:1
    boxes(:,k)=boxkar(t,t0,2*a(k),1);
    figure(h1);
    %plot(t,boxes(:,k)+yshifts(k))
    linesgray({t,boxes(:,k)+yshifts(:,k),'-',lw(k),gl(k)});
    if(k==1); hold on; end
    sincs(:,k)=2*a(k)*sinc(2*a(k)*f);
    figure(h2)
    %plot(f,sincs(:,k))
    linesgray({f,sincs(:,k),'-',lw(k),gl(k)})
    if(k==1);hold on;end
end
figure(h1)
grid
ylim([-.1 1.1])
xlim([0 1])
xlabel('time (sec)')
legend(['a=' num2str(a(1))],['a=' num2str(a(2))],['a=' num2str(a(3))])
bigfont(gcf,1.5,1);
prepfig

print -depsc .\signalgraphics\boxcars

figure(h2)
grid
line(f,zeros(size(f)),'linestyle',':','color',.5*ones(1,3));
xlim([-60 60])
xtick(-60:20:60);
xlabel('frequency (Hz)')
legend(['a=' num2str(a(1))],['a=' num2str(a(2))],['a=' num2str(a(3))])
bigfont(gcf,1.5,1);
prepfig

print -depsc .\signalgraphics\sincs