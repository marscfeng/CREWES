f1=20;
f2=60;
dt=.001;
tlen=1;
p=[1 2 3];
[w1,tw1]=wavemin(dt,f1,tlen);
[w2,tw2]=wavemin(dt,f2,tlen);
w3=2*w1+w2;
[W1,fw]=fftrl(w1,tw1);
W2=fftrl(w2,tw1);
W3=fftrl(w3,tw1);
sym={'+';'+';'+'};

fd=zeros(length(p),3);
ad=fd;
for k=1:length(p)
    fd(k,1)=dom_freq(w1,tw1,p(k));
    fd(k,2)=dom_freq(w2,tw1,p(k));
    fd(k,3)=dom_freq(w3,tw1,p(k));
    ii=near(fw,fd(k,1));
    ad(k,1)=abs(W1(ii));
    ii=near(fw,fd(k,2));
    ad(k,2)=abs(W2(ii));
    ii=near(fw,fd(k,3));
    ad(k,3)=abs(W3(ii));
end


figure
inc=.1;fs=10;
nudge=.01;
subplot(2,1,1)
%plot(tw1,w1,'b',tw1,w2+inc,'r',tw1,w3+2*inc,'k')
ind=near(tw1,0,.15);
linesgray({tw1(ind),w1(ind),'-',.75,.7},{tw1(ind),w2(ind)+inc,'-',.75,.4},{tw1(ind),w3(ind)+2*inc,'-',.5,0})
ttxt=.15;
text(ttxt,nudge,'w_1(t)','fontsize',fs,'horizontalalignment','left');
text(ttxt,inc+nudge,'w_2(t)','fontsize',fs,'horizontalalignment','left');
text(ttxt,2*inc+nudge,'2*w_1(t)+w_2(t)','fontsize',fs,'horizontalalignment','left');
xlim([0 .2]);ylim([-.1 .4]);xtick(0:.05:.15)
xlabel('time (s)')
subplot(2,1,2)
%hh=plot(fw,abs(W1),'b',fw,abs(W2),'r',fw,abs(W3),'k');
hh=linesgray({fw,abs(W1),'-',.75,.7},{fw,abs(W2),'-',.75,.4},{fw,abs(W3),'-',.5,0});
h=zeros(1,length(p));
% leg=cell(1,length(p));

xinc=[-5 1 1;1 1 1;-5 1 1];
yinc=[0 .1 -.1;0 .1 -.1;.1 .1 .1];
%xinc=zeros(3,3);yinc=xinc;
ht=cell(length(p),3);
fs=12;
for k=1:length(p)    
    %h(k)=line(fd(k,:),ad(k,:),'linestyle','none','marker',sym{k},'color',get(hh(j),'color'));
    for j=1:3
        line(fd(k,j),ad(k,j),'linestyle','none','marker',sym{k},'color',get(hh(j),'color'));
        ht{k,j}=text(fd(k,j)+xinc(k,j),ad(k,j)+yinc(k,j),int2str(p(k)),'fontsize',fs,'color',get(hh(j),'color'));
%         ht{k,j}=text(fd(k,j),ad(k,j),int2str(p(k)),'horizontalalignment','center',...
%              'verticalalignment','middle','fontsize',fs,'color',get(hh(j),'color'));
%     leg{k}=['p=' int2str(p(k))];
    end
end
xlabel('frequency (Hz)')
xlim([0 200])
%legend(hh,['f_d=' int2str(fd1)],['f_d=' int2str(fd2)],['f_d=' int2str(fd3)]);
%legend(h,leg)
prepfig
bigfont(gcf,1.5,1)
boldlines(gcf,1.5)
for k=1:length(p)
    for j=1:3
        set(ht{k,j},'color',get(hh(j),'color'));
    end
end

print -depsc .\signalgraphics\fdom