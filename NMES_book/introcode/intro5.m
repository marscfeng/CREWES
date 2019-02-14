figure;
global NOBRIGHTEN
 
NOBRIGHTEN=1;
s=seisclrs(64,50); %make a 50% linear gray ramp
sb=brighten(s,.5); %brighten it
sd=brighten(s,-.5); %darken it
plot(1:64,[s(:,1) sb(:,1) sd(:,1)],'k')
axis([0 70 -.1 1.1])
text(1,1.05,'white');text(50,-.02,'black')
xlabel('level number');ylabel('gray level');
prepfig
bigfont(gca,1.7,1)
print -depsc .\intrographics\intro5

figure; NOBRIGHTEN=0;
for k=1:5
   pct=max([100-(k-1)*20,1]);
   s=seisclrs(64,pct);
   line(1:64,s(:,1),'color','k');
   if(rem(k,2))tt=.1;else;tt=.2;end
   xt=near(s(:,1),tt);
   text(xt(1),tt,int2str(pct))
end
axis([0 70 -.1 1.1])
text(1,1.05,'white');text(50,-.02,'black')
xlabel('level number');ylabel('gray level');
prepfig
bigfont(gca,1.7,1)
print -depsc .\intrographics\intro5a
