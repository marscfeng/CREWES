%Make sinc interpolation figure
n=8;%half width of sinc
m=2;%decay  constant of gaussian
dt1=.001;
dt=.004;
%Make a signal
[r,t1]=reflec(1,dt1,.1,3,4);
[w,tw]=wavemin(dt1,30,.2);
s=convm(r,w);
%bandlimit for .004
sbl=filtf(s,t1,0,[80 100],0);
s=sbl(1:4:end);
t=t1(1:4:end);
sm=max(s);
s=s/sm;
sbl=sbl/sm;

tint=185*dt+.003;%interpolation site
nt=length(t);

inc=10;
dt2=dt/inc;
tsinc=(-n*dt:dt2:n*dt)';
one_over_sigma=m/tsinc(end);%inverse of standard deviation of gaussian taper

ksinc0=near(tsinc,0);%sample number of tsinc==0
sinkun=sinc(tsinc/dt);
gwin=exp(-(one_over_sigma*tsinc).^2);
sink=sinkun.*gwin;


kint=(tint-t(1))/dt+1;%fractional sample number (in s2) of the interpolation site

kbefore=floor(kint)-n+1;%earliest point before
tbefore=t(kbefore);
kafter=ceil(kint)+n-1;%latest point after
tafter=t(kafter);
ksinc=(round((tbefore-tint)/dt2):inc:round((tafter-tint)/dt2))+ksinc0;
op=sink(ksinc);
sint=sum(op.*s(kbefore:kafter));
op=sinkun(ksinc);
sintun=sum(op.*s(kbefore:kafter));

inwin=near(t,tint-(1.5*n+1)*dt,tint+1.5*n*dt);%in window at .004
inwin1=near(t1,tint-(1.5*n+1)*dt,tint+(1.5*n+1)*dt);%in window at .001
inint=near(t,tint-(n)*dt,tint+(n-1)*dt);%in interpolation at .004
sinwin=s(inwin);
sinwin2=zeros(10*length(sinwin),1);
sinwin2(1:10:end)=sinwin;
tinwin=t(inwin);
tinwin2=tinwin(1)+.0004*(0:length(sinwin2)-1);
figure;
%{tinwin2,sinwin2,'-',.5,0}
hh=linesgray({t1(inwin1),sbl(inwin1),'-',1,.7},{tinwin,sinwin,'none',.5,.5,'o',6},...
    {t(inint),s(inint),'none',.5,0,'o',6},...
    {tsinc+tint,sinkun,':',.5,.2},{tsinc+tint,gwin,':',.5,.7},...
    {tsinc+tint,sink,'-',1,.5},{tint,sintun,'none',.5,0,'*',6},...
    {tint,sint,'none',.5,0,'s',8});
ylim([-.5 1.2]);ytick(-.5:.25:1)
legend([hh(1) hh(2) hh(3:8) ] ,'continuous signal','unused samples','used samples','actual sinc','Gaussian window','windowed sinc',...
    'interpolated with actual sinc','interpolated with windowed sinc',...
    'location','northwest');
xlabel('time (sec)')
xtick([.7 .72 .74 tint .76 .78])
set(gca,'xticklabel',{.7, .72, [], tint, .76, .78});
grid
prepfig
bigfont(gcf,.8,1)
legendfontsize(1.5)

print -depsc .\signalgraphics\sincinterpolation
