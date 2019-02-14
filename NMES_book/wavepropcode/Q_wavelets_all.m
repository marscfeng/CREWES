Q_wavelets


%plots
figure
inc=max(qimp(:))/8;
h1=zeros(length(x),2);
rightedge=tmax/2;
a0=.05;
fs=8;
for k=1:length(x)
    t0=x(k)/v;
%     inot=near(t,t0);
%     w0=zeros(size(t));
%     w0(inot)=a0;
%     linesgray({t,(k-1)*inc+w0,'--',.5,.5})
    h1(k,:)=wtva((k-1)*inc+qimp(k,:),t,'k',(k-1)*inc,1,-1);
    line(t0,(k-1)*inc,'linestyle','none','marker','+','color',.5*ones(1,3));
    text(rightedge,(k-.8)*inc,['Distance = ' num2str(x(k))],'horizontalalignment','center','fontsize',fs)
end
xlim([-.1 rightedge+.05])
prepfig
bigfont(gcf,2,1)
% yl=get(gca,'ylim');
set(gca,'ylim',[-.1 .6]);
xlabel('seconds')

print -depsc wavepropgraphics\qwaveimp.eps

figure
inc=1;
h2=zeros(length(x),2);
rightedge=.1;
for k=1:length(x)
    h2(k,:)=wtva((k-1)*inc+qimp2(k,:)/max(qimp2(k,:)),t,'k',(k-1)*inc,1,-1);
    text(rightedge,(k-.8)*inc,['Distance = ' num2str(x(k))],'horizontalalignment','left','fontsize',fs)
end
xlim([-.01 rightedge+.05])
prepfig
yl=get(gca,'ylim');
set(gca,'ylim',[-.05 yl(2)]);
xlabel('seconds')
bigfont(gcf,2,1)

print -depsc wavepropgraphics\qwaveimpnorm.eps

figure
inc=max(wlet(:))/4;
h3=zeros(length(x),2);
rightedge=tmax/2;
for k=1:length(x)
    t0=x(k)/v;
    h3(k,:)=wtva((k-1)*inc+wlet(k,:),t,'k',(k-1)*inc,1,-1);
    text(rightedge,(k-.8)*inc,['Distance = ' num2str(x(k))],'horizontalalignment','center','fontsize',fs)
    line(t0,(k-1)*inc,'linestyle','none','marker','+','color',.5*ones(1,3));
end
xlim([-.1 rightedge+.05])
prepfig
xlabel('seconds')

ylim([-.02 .10])
bigfont(gcf,2,1)
print -depsc wavepropgraphics\qwavewavelet.eps

figure
inc=2;
h4=zeros(length(x),2);
tcut=.08;
ind=near(t,0,tcut);
for k=1:length(x)
    h4(k,:)=wtva((k-1)*inc+wlet2(k,ind)/max(wlet2(k,ind)),t(ind),'k',(k-1)*inc,1,-1);
    text(tcut,(k-1)*inc,['Distance = ' num2str(x(k))],'horizontalalignment','left','fontsize',fs)
end
xlim([-.01 tcut+.04])
prepfig
xlabel('seconds')
bigfont(gcf,2,1)
xtick(0:.02:.08)
print -depsc wavepropgraphics\qwavewaveletnorm.eps

% examine spectra
figure
dbspec(t,wlet','windowflags',zeros(1,5),'graylevels',[0 .2 .4 .6 .8],'linewidths',[.5 .7 .9 1.1 1.3])
prepfig
bigfont(gcf,1.5,1)
legend(['Distance ' num2str(x(1)) 'm'],['Distance ' num2str(x(2)) 'm'],...
    ['Distance ' num2str(x(3)) 'm'],['Distance ' num2str(x(4)) 'm'],...
    ['Distance ' num2str(x(5)) 'm'],'location','southwest')

print -depsc wavepropgraphics\qwavespectra.eps