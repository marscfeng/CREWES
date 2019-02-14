close all
dt=.001;
tmax=1;
fdom=30;
tlen=tmax;
[r,t]=reflec(1,dt,.1,3,4);
[w,tw]=wavemin(dt,fdom,tlen);
s=convm(r,w);

%analysis at tmax/2, window=tmax/10;
box=boxkar(t,tmax/2,tmax/10,1,0);
ibox=box>0;
tri=triangle(t,tmax/2,tmax/5);
gau=gaussian(t,tmax/2,tmax/5);

sb=s.*box;
st=s.*tri;
sg=s.*gau;

w=w*max(abs(s))/max(abs(w));

[SB,fb]=fftrl(s(ibox).*box(ibox),t(ibox));
sm=max(abs(s));
figure
fs=10;
subplot(3,1,1)
linesgray({t,s,'-',.5,0},{t,sm*box,'-',.5,.5},{t,sm*tri,'-',.5,.7},{t,sm*gau,'-',.5,.3})
legend('trace','boxcar','triangle','gaussian');
xlabel('time (sec)')
text(.01,-0.005,'a)','fontsize',fs);
subplot(3,1,2)
h1=dbspec(t,[s sb w],'graylevels',[.8, .4, 0],'linewidths',[.5 .5 .5],...
    'normoption',1);
h2=linesgray({fb,todb(abs(SB)),'-',.5,.7,'*',3});
legend([h1(1:2) h2 h1(3)],'total trace','boxcar windowed',...
    'boxcar truncated','wavelet','location','northeast')
ylim([-100 0])
text(5,-75,'b)','fontsize',fs);
subplot(3,1,3)
dbspec(t,[s st sg w],'graylevels',[.8 .3 .3 0],...
    'linewidths',[.5,.5,.5,.5],'normoption',1,'linestyles',{'-',':','-','-'});
legend('total trace','triangle windowed','gaussian windowed','wavelet',...
    'location','northeast')
ylim([-100 0])
text(5,-75,'c)','fontsize',fs);
prepfig
bigfont(gcf,.8,1)
legendfontsize(.8)

print -depsc ..\signalgraphics\windowedspectra