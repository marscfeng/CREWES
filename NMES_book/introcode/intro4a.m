[seis2,t2,x2]=hardzoom(seis,t,x,[0 500 .1 .5]);
figure
plotseis(seis2,t2,x2,1,5,1,1,'k');ylabel('seconds')
xtick(0:250:500)
bigfont(gcf,2,1);

print -depsc .\intrographics\intro4a

