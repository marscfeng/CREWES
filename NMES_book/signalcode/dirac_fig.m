x=-5:.001:5; 
b1=boxkar(x,0,5,1/5);
b2=boxkar(x,0,2,1/2);
b3=boxkar(x,0,1,1);
b4=boxkar(x,0,1/2,2);
b5=boxkar(x,0,1/5,5);

figure
plot(x,b1,'k',x,b2,'k',x,b3,'k',x,b4,'k',x,b5,'k')
grid
% plot(x,b1,x,b2,x,b3,x,b4,x,b5)

prepfig
ylim([0 5])
xtick(-5:1:5)
bigfont(gca,1.5,1)

print -depsc .\signalgraphics\diracfig