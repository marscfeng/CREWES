%% construct the depth and time pictures of a vertical array of scatterpoints
% What do the asymptotes tell you? What is the macimum possible time dip?

%constant velocity
znot=[200 400 600 800 1000];%these are the scatterpoint depths
xmax=2000;%line length
zmax=1000;%max depth
xnot=xmax/2;%x coordinate of the diffractor

v=2000;
dx=2;
dt=.002;
tmax=2;
x=0:dx:xmax;
t=0:dt:tmax;
z=0:dx:zmax;
filtparms=[5,10,80,100]; %filter specification Ormsby style
%Create the diffraction

seis=zeros(length(t),length(x));
seis2=seis;
for k=1:length(znot)
    tnot=2*znot(k)/v;
    seis=event_hyp(seis,t,x,tnot,xnot,v,1);
    if(k==2)
       seis2=event_hyp(seis2,t,x,tnot,xnot,v,1);
    end
end
seis=filtf(seis,t,[filtparms(2) filtparms(2)-filtparms(1)],[filtparms(3) filtparms(4)-filtparms(3)]);
seis2=filtf(seis2,t,[filtparms(2) filtparms(2)-filtparms(1)],[filtparms(3) filtparms(4)-filtparms(3)]);
%migrate seis2
seis2m=wavefrontmig(seis2,t,x,v,xmax,filtparms,[1 100]);
% % create the depth section
% depth=zeros(length(z),length(x));
% for k=1:length(znot)
%     ix=near(x,xnot);
%     iz=near(z,znot(k));
%     depth(iz,ix)=1;
% end
% g=gaus_radial(dx,5*dx);
% depth=conv2(depth,g,'same');
figure
subplot(1,2,1)
fact=4;
ampinfo=[2*max(seis(:)) 2*min(seis(:)) mean(seis(:)) std(seis(:))];
seisplota(seis,t,x,ampinfo,3);
ta=2*abs(x-xnot)/v;
h=line(x,ta,'linestyle','--','color','k');
%ylabel('time (seconds)')
legend(h,'hyperbolic asymptotes','location','south')
fs=14;
text(100,.1,'A','fontsize',fs)
subplot(1,2,2)
seisplota(10*(seis2m+seis2)+seis,t,x,ampinfo,1);
text(100,.1,'B','fontsize',fs)
prepfig
bigfont(gcf,1.5,1)

print -depsc .\elmiggraphics\diffchart.eps 