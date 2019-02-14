close all

makesyntheticshot

%fkfilter
%designed to reject vn=1000;
va1=950;
va2=1050;
dv=150;
xpad=500;tpad=.5;
[seisfff,mask,fm,km]=fkfanfilter(seisf,t,x,va1,va2,dv,0,xpad,tpad);
%make an impulse response
seisimp=zeros(size(seisf));
ix=near(x,0);
it=near(t,.5);
seisimp(it,ix)=1;
seisimpff=fkfanfilter(seisimp,t,x,va1,va2,dv,0,xpad,tpad);

%[tmp,a]=lsqsubtract(seisf(:),seisfff(:));
seiserr=seisf-seisfff;

[seisfk,f,kx]=fktran(seisf,t,x);
seisfkff=fktran(seisfff,t,x);
seisfkerr=fktran(seiserr,t,x);


fs=8;tnudge=.05;
figure
ha1=subplot(3,1,1);
p=get(ha1,'position');
inc=.25-p(4);
set(ha1,'position',[p(1) p(2)-inc p(3) .25])
A=max(abs(seis(:)));
imagesc(x,t,seisf,[-A A]);
ylabel('time (s)');
text(-950,.1,'a)','fontsize',1.5*fs);

set(gca,'xticklabel','')
grid


ha1=subplot(3,1,2);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
imagesc(x,t,seisfff,[-A A]);
ylabel('time (s)');
text(-950,.1,'b)','fontsize',1.5*fs);
grid
set(gca,'xticklabel','')

colormap seisclrs(256)

ha1=subplot(3,1,3);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
%imagesc(x,t,seiserr,[-A A]);
A=0.05*max(abs(seisimpff(:)));
imagesc(x,t,seisimpff,[-A A]);
xlabel('distance (m)');ylabel('time (s)');
text(-950,.1,'c)','fontsize',1.5*fs);
grid

prepfig
bigfont(gcf,.8,1);
pos=get(gcf,'position');
set(gcf,'position',[pos(1:2) 674 850]);

print -depsc .\signalgraphics\fanfiltertx

figure
knyq=.5/(x(2)-x(1));
A=max(abs(seisfk(:)));
ha1=subplot(3,1,1);
p=get(ha1,'position');
inc=.25-p(4);
set(ha1,'position',[p(1) p(2)-inc p(3) .25])
imagesc(kx,f,abs(seisfk),[-A A]);
ylabel('Frequency (Hz)');
text(-.9*knyq,10,'a)','fontsize',1.5*fs);
set(gca,'xticklabel','')
grid


ha1=subplot(3,1,2);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
imagesc(kx,f,abs(seisfkff),[-A A]);
ylabel('Frequency (Hz)');
text(-.9*knyq,10,'b)','fontsize',1.5*fs);
grid
set(gca,'xticklabel','')

colormap seisclrs(256)

ha1=subplot(3,1,3);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
%imagesc(kx,f,abs(seisfkerr),[-A A]);
imagesc(kx,f,1-mask,[0 1]);
xlabel('wavenumber (m^{-1})');ylabel('Frequency (Hz)');
text(-.9*knyq,10,'c)','fontsize',1.5*fs);
grid

prepfig
bigfont(gcf,.8,1);
pos=get(gcf,'position');
set(gcf,'position',[pos(1:2) 674 850]);

print -depsc .\signalgraphics\fanfilterfk

%% fkfilter on aliased record
% close all

makesyntheticshot


seisf=seisf(:,1:3:end);
x=x(1:3:end);

%fkfilter
%designed to reject vn=1000;
va1=950;
va2=1050;
dv=150;
xpad=500;tpad=.5;
[seisfff,mask,fm,km]=fkfanfilter(seisf,t,x,va1,va2,dv,0,xpad,tpad);
%make an impulse response
seisimp=zeros(size(seisf));
ix=near(x,0);
it=near(t,.5);
seisimp(it,ix)=1;
seisimpff=fkfanfilter(seisimp,t,x,va1,va2,dv,0,xpad,tpad);

%[tmp,a]=lsqsubtract(seisf(:),seisfff(:));
seiserr=seisf-seisfff;

[seisfk,f,kx]=fktran(seisf,t,x);
seisfkff=fktran(seisfff,t,x);
seisfkerr=fktran(seiserr,t,x);


fs=8;tnudge=.05;
figure
ha1=subplot(3,1,1);
p=get(ha1,'position');
inc=.25-p(4);
set(ha1,'position',[p(1) p(2)-inc p(3) .25])
A=max(abs(seis(:)));
imagesc(x,t,seisf,[-A A]);
ylabel('time (s)');
text(-950,.1,'a)','fontsize',1.5*fs);

set(gca,'xticklabel','')
grid


ha1=subplot(3,1,2);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
imagesc(x,t,seisfff,[-A A]);
ylabel('time (s)');
text(-950,.1,'b)','fontsize',1.5*fs);
grid
set(gca,'xticklabel','')

colormap seisclrs(256)

ha1=subplot(3,1,3);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
%imagesc(x,t,seiserr,[-A A]);
A=0.05*max(abs(seisimpff(:)));
imagesc(x,t,seisimpff,[-A A]);
xlabel('distance (m)');ylabel('time (s)');
text(-950,.1,'c)','fontsize',1.5*fs);
grid

prepfig
bigfont(gcf,.8,1);
pos=get(gcf,'position');
set(gcf,'position',[pos(1:2) 674 850]);

print -depsc .\signalgraphics\fanfiltertxa

figure
knyq=.5/(x(2)-x(1));
A=max(abs(seisfk(:)));
ha1=subplot(3,1,1);
p=get(ha1,'position');
inc=.25-p(4);
set(ha1,'position',[p(1) p(2)-inc p(3) .25])
imagesc(kx,f,abs(seisfk),[-A A]);
ylabel('Frequency (Hz)');
text(-.9*knyq,10,'a)','fontsize',1.5*fs);
set(gca,'xticklabel','')
grid


ha1=subplot(3,1,2);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
imagesc(kx,f,abs(seisfkff),[-A A]);
ylabel('Frequency (Hz)');
text(-.9*knyq,10,'b)','fontsize',1.5*fs);
grid
set(gca,'xticklabel','')

colormap seisclrs(256)

ha1=subplot(3,1,3);
p=get(ha1,'position');
set(ha1,'position',[p(1) p(2) p(3) .25])
%imagesc(kx,f,abs(seisfkerr),[-A A]);
imagesc(kx,f,1-mask,[0 1]);
xlabel('wavenumber (m^{-1})');ylabel('Frequency (Hz)');
text(-.9*knyq,10,'c)','fontsize',1.5*fs);
grid

prepfig
bigfont(gcf,.8,1);
pos=get(gcf,'position');
set(gcf,'position',[pos(1:2) 674 850]);

print -depsc .\signalgraphics\fanfilterfka