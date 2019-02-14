% put an event every 100 ms. Each event decreases in amplitude by 6 db.
r=zeros(501,1);dt=.002;ntr=100;
t=(0:length(r)-1)*dt;
amp=1;
for tk=.1:.1:1;
   k=round(tk/dt)+1;
   r(k)=(-1)^(round(tk/.1))*amp;
   amp=amp/2;
end
w=ricker(.002,60,.1);
s=convz(r,w);
seis=s*ones(1,ntr);
x=10*(0:ntr-1);
global SCALE_OPT GRAY_PCT
SCALE_OPT=2;GRAY_PCT=100;
plotimage(seis,t,x);ylabel('seconds')
hideui;

print -deps ..\intrographics\intro7

figure
plotseis(seis,t,x,1,1,1,1,'k');ylabel('seconds')

print -deps ..\intrographics\intro7a
