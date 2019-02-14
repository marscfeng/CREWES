%make a picture of convolution by matrix multiplication
dt=.002;
fdom=30;
tmax=.5;
tlen=.1;
ievery=20;%show every this many columns in the convolution matrix
[w,tw]=ricker(dt,fdom,tlen);
w=w/max(w);
[r,t]=reflec(tmax,dt,1,5,4);%make the maqx rc 1 to facilitate plotting
%s=conv(r,w);
W=convmtx(w,length(r));
s=W*r;
m=1:length(s);
n=1:length(r);
N=length(n);
M=length(m);
nhalf=(M-N)/2;

%COLORS
% c1='b';%convolution matrix
% c2='r';%diagonal line'
% c3='k';%reflectivity
% c4='r';%seismogram
c1='k';%convolution matrix
c2=.75*[1 1 1];%diagonal line'
c3='k';%reflectivity
c4='k';%seismogram


figure
fs=14;
h1=axes('position',[.1 .1 .5 .75]);%for the convolution matrix
h2=axes('position',[.62 .1 .1 .75]);%for the reflectivity
plotseis(W(:,1:ievery:end),m,n(1:ievery:end),1,[0.5 max(abs(w))],1,1,c1,h1);
xlabel('samples');ylabel('samples')
xtick(1:50:N);ytick(1:50:M)
hdiag=line([1 N],[nhalf+1 nhalf+N],[-1 -1],'color',c2,'linewidth',1,'linestyle',':');
ht1=text(-20,300,'a)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
set(gcf,'currentaxes',h2);
rr=nan*ones(size(m));

rr(nhalf+1:nhalf+N)=r;
% wtva(rr,m,'k',0,1,1);flipy
plot(rr,m,c3);flipy
ht2=text(-1,300,'b)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
set(h2,'xtick',[],'ytick',[])
%set(h2,'yaxislocation','right');
ylim([1 length(m)]);
h3=axes('position',[.75 .475 .05 .05]);
set(gcf,'currentaxes',h3);
he1=line([-.025 .025],[.025 .025],'color','k','linewidth',2);
he2=line([-.025 .025],[-.025 -.025],'color','k','linewidth',2);
axis square
set(h3,'visible','off')
%set(h3,'xtick',[],'ytick',[])
h4=axes('position',[.81 .1 .1 .75]);%for the seismogram
wtva(s,m,c4,0,1,1);flipy
ht4=text(-1,300,'c)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
ylabel('samples')
set(get(h4,'ylabel'),'rotation',-90);
set(h4,'yaxislocation','right');
set(h4,'xtick',[])
ylim([1 length(m)]);
ytick([1 51 101 201 251 301])
set([h1 h2 h4],'box','on')
prepfig
bigfont(gcf,.75)

print -depsc ..\signalgraphics\matmultzero