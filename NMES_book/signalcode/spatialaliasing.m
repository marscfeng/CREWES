%make a shot record
close all

makesyntheticshot

%take every third trace
seisf2=seisf(:,1:3:end);
x2=x(1:3:end);
%zero every other trace
seisf3=seisf;
for k=1:length(x)
    if(rem((k-1),3))
        seisf3(:,k)=zeros(size(t));
    end
end
[seisfk2,f2,k2]=fktran(seisf2,t,x2);
[seisfk3,f3,k3]=fktran(seisf3,t,x);

%labels
fbl='FBL';
fbr='FBR';
noi='N';
hyp='H';
fbla='FBL*';
fbra='FBR*';
noia='N*';

fs=8;tnudge=.05;
figure
ha1=subplot(2,1,1);
p=get(ha1,'position');
inc=.4-p(4);
set(ha1,'position',[p(1) p(2)-inc p(3) .4])
imagesc(x,t,seisf);
ylabel('time (s)');
text( -950,.05,'a)','fontsize',1.5*fs);
ht1a=text(-750,750/vfbl-tnudge,fbl,'fontsize',fs,'horizontalalignment','right');
ht1b=text(750,750/vfbr-tnudge,fbr,'fontsize',fs);
ht2a=text(-900,900/vnoise+tnudge,noi,'fontsize',fs);
ht2b=text(900,900/vnoise+tnudge,noi,'fontsize',fs,'horizontalalignment','right');
text(0,t0(1)+tnudge,hyp,'fontsize',fs,'horizontalalignment','center');
text(0,t0(2)+tnudge,hyp,'fontsize',fs,'horizontalalignment','center');
text(0,t0(3)+tnudge,hyp,'fontsize',fs,'horizontalalignment','center');
text(0,t0(4)+tnudge,hyp,'fontsize',fs,'horizontalalignment','center');
set(gca,'xticklabel','')
grid

ha2=subplot(2,1,2);
p=get(ha2,'position');
set(ha2,'position',[p(1) p(2) p(3) .4])
imagesc(x2,t,seisf2);
text( -950,.05,'b)','fontsize',1.5*fs);
xlabel('distance (m)');ylabel('time (s)');
grid
colormap seisclrs(256)
prepfig
bigfont(gcf,.8,1);
pos=get(gcf,'position');
set(gcf,'position',[pos(1:2) 674 850]);

print -depsc ..\signalgraphics\spatialaliasingtx

fnudge=5;
figure
A=max(abs(seisfk(:)));
ha1=subplot(3,1,1);
p=get(ha1,'position');
inc=.25-p(4);
set(ha1,'position',[p(1) p(2)-inc p(3) .25])
imagesc(kx,f,abs(seisfk),[-A A]);
ylabel('Frequency (Hz)');
text(-.06,110,'a)','fontsize',1.5*fs)
text(-.03,.03*vnoise-fnudge,noi,'fontsize',fs,'horizontalalignment','right');
text(.03,.03*vnoise-fnudge,noi,'fontsize',fs);
text(-.04,.04*vfbl-fnudge,fbl,'fontsize',fs,'horizontalalignment','right');
text(.03,.03*vfbr-fnudge,fbr,'fontsize',fs);
text(0,40,hyp,'fontsize',fs,'horizontalalignment','center');
set(gca,'xticklabel','')
grid


ha1=subplot(3,1,2);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
A=max(abs(seisfk3(:)));
imagesc(kx,f,abs(seisfk3),[-A A]);
ylabel('Frequency (Hz)');
text(-.06,110,'b)','fontsize',1.5*fs);
grid

colormap seisclrs(256)
kn=.5/(x2(2)-x2(1));
fn=.5/dt;
linesgray({[-kn -kn kn kn -kn],[0 fn fn 0 0],'-',.5,0});



ha1=subplot(3,1,3);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
A=max(abs(seisfk2(:)));
imagesc(k2,f,abs(seisfk2),[-A A]);
xlabel('wavenumber (m^{-1})');ylabel('Frequency (Hz)');
text(-.02,110,'c)','fontsize',1.5*fs);
text(-.015,.015*vnoise-fnudge,noi,'fontsize',fs);
text(.015,.015*vnoise-fnudge,noi,'fontsize',fs);
text(-.02,30,noia,'fontsize',fs);
text(.018,30,noia,'fontsize',fs);
text(-.02,.02*vfbl+fnudge,fbl,'fontsize',fs);
text(.015,.015*vfbr+fnudge,fbr,'fontsize',fs,'horizontalalignment','right');
text(-.019,77,fbra,'fontsize',fs);
text(.01,75,fbla,'fontsize',fs);
text(0,50,hyp,'fontsize',fs,'horizontalalignment','center');
xtick(-.02:.01:.02);
grid

prepfig
bigfont(gcf,.6,1);
pos=get(gcf,'position');
set(gcf,'position',[pos(1:2) 674 850]);

print -depsc .\signalgraphics\spatialaliasingfk

%%
%filter slices of noise panel
iuse1=60:3:90;%traces to use at aliased spacing
iuse2=60:90;%traces to use at unaliased spacing
ntr1=length(iuse1);
ntr2=length(iuse2);
traces1=seisnf(:,iuse1);
traces2=seisnf(:,iuse2);
traces1(:,1)=0;traces1(:,end)=0;
traces2(:,1:3)=0;traces2(:,end-2:end);
knyq=0.5/(3*dx);
fwid=3;%width of filter slices
fcrit=vnoise*knyq;
fmaxs=(-2:3)*fwid+fcrit;
fmins=fmaxs-fwid;
panel1=zeros(length(t),length(fmaxs)*ntr1);
panel2=zeros(length(t),length(fmaxs)*ntr2);
for k=1:length(fmaxs)
    fmax=[fmaxs(k) fwid/5];
    fmin=[fmins(k) fwid/5];
    k1=(k-1)*ntr1+1;
    k1end=k1+ntr1-1;
    k2=(k-1)*ntr2+1;
    k2end=k2+ntr2-1;
    tmp1=filtf(traces1,t,fmin,fmax,0);
    panel1(:,k1:k1end)=tmp1/max(abs(tmp1(:)));
    tmp2=filtf(traces2,t,fmin,fmax,0);
    panel2(:,k2:k2end)=tmp2/max(abs(tmp2(:)));
end

fs=10;
figure
subplot(2,1,1)
p1=get(gca,'position');
inc=.4-p1(4);
set(gca,'position',[p1(1) p1(2)-inc p1(3) .4])
x1=1:size(panel1,2);
imagesc(x1,t,panel1)
for k=1:length(fmaxs)
    text((k-1)*ntr1+ntr1/4,.95,[int2str(fmins(k)) '-' int2str(fmaxs(k)) 'Hz']...
        ,'fontsize',fs,'backgroundcolor',.99*ones(1,3))
end
text(1,.1,'a)','fontsize',1.5*fs)
ylabel('time (s)')
xtick([])
subplot(2,1,2)
p2=get(gca,'position');
inc=.4-p2(4);
set(gca,'position',[p2(1) p2(2) p2(3) .4])
x2=1:size(panel2,2);
imagesc(x2,t,panel2)
for k=1:length(fmaxs)
    text((k-1)*ntr2+ntr2/4,.95,[int2str(fmins(k)) '-' int2str(fmaxs(k)) 'Hz'],...
        'fontsize',fs,'backgroundcolor',.99*ones(1,3))
end
text(3,.1,'b)','fontsize',1.5*fs)
colormap seisclrs(256)
xtick([])
prepfig
bigfont(gcf,.8,1)
ylabel('time (s)')

print -depsc .\signalgraphics\spatialaliasing



