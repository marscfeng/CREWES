global ICLIP_VALUE
ICLIP_VALUE=4;
ndelx=30;
eventexample5
seis5a=seis5;
seisplot(seis5a,t5,x5)
xlabel('meters');ylabel('seconds');
title(['Hyperbola every ' num2str(ndelx) ' grid points']);titlefontsize(1,1)
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex5a.eps

ndelx=10;
eventexample5
seis5b=seis5;
seisplot(seis5b,t5,x5)
xlabel('meters');ylabel('seconds');
title(['Hyperbola every ' num2str(ndelx) ' grid points']);titlefontsize(1,1)
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex5b.eps

ndelx=5;
eventexample5
seis5c=seis5;
seisplot(seis5c,t5,x5)
xlabel('meters');ylabel('seconds');
title(['Hyperbola every ' num2str(ndelx) ' grid points']);titlefontsize(1,1)
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex5c.eps

ndelx=1;
eventexample5
seis5d=seis5;
seisplot(seis5d,t5,x5)
xlabel('meters');ylabel('seconds');
title(['Hyperbola every ' num2str(ndelx) ' grid points']);titlefontsize(1,1)
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex5d.eps