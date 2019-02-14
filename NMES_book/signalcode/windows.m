close all
dt=.001;
tmax=1;
t=(-tmax/2:dt:tmax/2)';
t0=0;
twid=tmax/10;
%boxcar
box=boxkar(t,t0,twid,1,0);
%triangle
tri=triangle(t,t0,2*twid);
%gaussian
gau=gaussian(t,t0,2*twid);
%truncate the gaussian
ind=near(t,t0-2*twid,t0+2*twid);
gaut=zeros(size(gau));
gaut(ind)=gau(ind);
% f=0:500;
% gauf=gaussian(f,0,4/(pi*twid));
% gaufdb=20*log10(gauf);

figure
subplot(2,1,1)
linesgray({t,box,'-',1,.7},{t,tri,'-',.5,.7},{t,gau,'-',.5,0},{t(ind),gaut(ind),'-',1.25,.5});
ylim([-.5,1.5])
xlabel('time (sec)')
legend('boxcar','triangle','Gaussian','Truncated Gaussian')
subplot(2,1,2)
dbspec(t,[box tri gau gaut],'linestyles',{'-';'-';'-';'-'},'graylevels',[.7,.5,0,.25],...
    'linewidths',[1.25, .5, 1.25 .75],'markers',{'none';'none';'none';'none'},...
    'markersizes',1*ones(1,4));
%linesgray({f,gaufdb,':',.5,0})
ylim([-150 0])
prepfig
bigfont(gcf,1.75,1);
legendfontsize(1)

print -depsc .\signalgraphics\windows
%%
%taper the boxcar
dt=.001;
tmax=1;
t=(-tmax/2:dt:tmax/2)';
t0=0;
twid=tmax/10;
b1=boxkar(t,t0,twid,1,0);
ibox=b1>0;
boxtrunc=b1(ibox);
[Bt,f]=fftrl(boxtrunc,t(ibox));
b2=boxkar(t,t0,twid,1,10);
b3=boxkar(t,t0,twid*1.1,1,20);
%triangle
tri=triangle(t,t0,2*twid);

figure
subplot(2,1,1)
linesgray({t,b1,'-',1,.7},{t,b2,'-',.5,.5},{t,b3,'-',.5,0},{t,tri,'-',.5,.7})
ylim([-.5,1.5])
xlim([0 .1])
xlabel('time (sec)')
legend('boxcar no taper','boxcar 10% taper','wider boxcar 20% taper','triangle')
subplot(2,1,2)
dbspec(t,[tri b1 b2 b3 ],'linestyles',{'-';'-';'-';'-'},'graylevels',[.7,.5,.25,0],...
    'linewidths',[.5 1 1.25 .5 ])
ylim([-150 0])
prepfig
bigfont(gcf,1.75,1);
legendfontsize(1)

print -depsc .\signalgraphics\windows2