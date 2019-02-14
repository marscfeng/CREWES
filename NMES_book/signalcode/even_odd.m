%show even and odd parts of a wavelet
dt=.001;
tlen=.2;
fdom=30;
[w,t]=wavemin(dt,fdom,tlen);
t2=-max(t):dt:max(t);
ipos=near(t2,0,max(t));
w2=zeros(size(tw));
w2(ipos)=w;
we=.5*(w2+flipud(w2));
wo=.5*(w2-flipud(w2));
figure
plot(t2,w2,'k',t2,we+.1,'k',t2,wo+.2,'k')
line([0 0],[-.1 .25],'linestyle',':')
ytick([0 .1 .2])
set(gca,'yticklabel','')
xtick(-.1:.05:.1);
xlim([-.1 .1])
xlabel('time(s)')
grid
nudgex=.025;
nudgey=0;
text(tlen/2+.8*nudgex,nudgey,'w(t)','horizontalalignment','right')
text(tlen/2+nudgex,nudgey+.1,'w_e(t)','horizontalalignment','right')
text(tlen/2+nudgex,nudgey+.2,'w_o(t)','horizontalalignment','right')

prepfig
axis square
bigfont(gca,1.2,1)

print -deps .\signalgraphics\even_odd