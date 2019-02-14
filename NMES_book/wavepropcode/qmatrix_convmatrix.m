%make a picture of convolution by matrix multiplication
dt=.002;
fdom=30;
tmax=1;
tlen=.1;
Q=50;
ievery=20;%show every this many columns in the convolution matrix
[w,tw]=wavemin(dt,fdom,tlen);
w=w/max(w);
[r,t]=reflec(tmax,dt,1,5,4);%make the maqx rc 1 to facilitate plotting
%s=conv(r,w);
W=convmtx(w,length(r));
[WN,trow]=qmatrix(Q,t,w,tw,3,2);
s=W*r;
sn=WN*r;
[M,N]=size(W);
% m=1:length(s);
% n=1:length(r);
% N=length(n);
% M=length(m);

%COLORS
c1='k';%convolution matrix
c2=.75*[1 1 1];%diagonal line'
c3='k';%reflectivity
c4='k';%seismogram
tmax=max(trow);
figure
fs=10;
h1=axes('position',[.1 .1 .5 .75]);%for the convolution matrix
h2=axes('position',[.62 .1 .1 .75]);%for the reflectivity
axes(h1);
plotseis(W(:,1:ievery:end),trow,t(1:ievery:end),1,[1.5 max(abs(w))],1,1,c1,h1);
xlabel('time');ylabel('time')
xtick(t(1:100:N));ytick(trow(1:100:M))
hdiag=line([t(1) t(N)],[t(1) t(N)],[-1 -1],'color',c2,'linewidth',1,'linestyle',':');
ht1=text(-.033,tmax,'a)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
set(gca,'ygrid','on')
%set(gcf,'currentaxes',h2);
ylim([0 tmax]);
axes(h2)
rr=nan*ones(M,1);
rr(1:N)=r;
% wtva(rr,m,'k',0,1,1);flipy
plot(rr,trow,c3);flipy
ht2=text(-1,tmax,'b)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
set(h2,'xtick',[],'ytick',0:.2:1,'yticklabel',[])
%set(h2,'yaxislocation','right');
ylim([0 tmax]);
set(gca,'ygrid','on')
h3=axes('position',[.75 .475 .05 .05]);%for = sign
%set(gcf,'currentaxes',h3);
axes(h3)
he1=line([-.025 .025],[.025 .025],'color','k','linewidth',2);
he2=line([-.025 .025],[-.025 -.025],'color','k','linewidth',2);
axis square
set(h3,'visible','off')
%set(h3,'xtick',[],'ytick',[])
h4=axes('position',[.81 .1 .1 .75]);%for the seismogram
wtva(s,trow,c4,0,1,1);flipy
ht4=text(-3,tmax,'c)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
ylabel('time')
set(get(h4,'ylabel'),'rotation',-90);
set(h4,'yaxislocation','right');
set(h4,'xtick',[])
ylim([0 tmax]);
ytick(t(1:100:end))
set(gca,'yticklabel',{'0' '0.2' '0.4' ''  '0.8' '1.0'})
set(gca,'ygrid','on')
set([h1 h2 h4],'box','on')
prepfig
bigfont(gcf,1.5,1)

print -depsc wavepropgraphics\convmtx.eps


figure
h1=axes('position',[.1 .1 .5 .75]);%for the convolution matrix
h2=axes('position',[.62 .1 .1 .75]);%for the reflectivity
axes(h1);
plotseis(WN(:,1:ievery:end),trow,t(1:ievery:end),1,[1.5 max(abs(w))],1,1,c1,h1);
xlabel('time');ylabel('time')
xtick(t(1:100:N));ytick(trow(1:100:M))
hdiag=line([t(1) t(N)],[t(1) t(N)],[-1 -1],'color',c2,'linewidth',1,'linestyle',':');
ht1=text(-.033,tmax,'a)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
set(gca,'ygrid','on')
%set(gcf,'currentaxes',h2);
ylim([0 tmax]);
axes(h2)
rr=nan*ones(M,1);
rr(1:N)=r;
% wtva(rr,m,'k',0,1,1);flipy
plot(rr,trow,c3);flipy
ht2=text(-1,tmax,'b)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
set(h2,'xtick',[],'ytick',0:.2:1,'yticklabel',[])
%set(h2,'yaxislocation','right');
ylim([0 tmax]);
set(gca,'ygrid','on')
h3=axes('position',[.75 .475 .05 .05]);%for = sign
%set(gcf,'currentaxes',h3);
axes(h3)
he1=line([-.025 .025],[.025 .025],'color','k','linewidth',2);
he2=line([-.025 .025],[-.025 -.025],'color','k','linewidth',2);
axis square
set(h3,'visible','off')
%set(h3,'xtick',[],'ytick',[])
h4=axes('position',[.81 .1 .1 .75]);%for the seismogram
wtva(sn,trow,c4,0,1,1);flipy
ht4=text(-3,tmax,'c)','fontsize',fs,'backgroundcolor','w','verticalalignment','bottom');
ylabel('time')
set(get(h4,'ylabel'),'rotation',-90);
set(h4,'yaxislocation','right');
set(h4,'xtick',[])
ylim([0 tmax]);
ytick(t(1:100:end))
set(gca,'yticklabel',{'0' '0.2' '0.4' ''  '0.8'  '1.0'})
set(gca,'ygrid','on')
set([h1 h2 h4],'box','on')
prepfig
bigfont(gcf,1.5,1)

print -depsc wavepropgraphics\qmtx.eps