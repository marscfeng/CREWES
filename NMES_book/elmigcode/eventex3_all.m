global ICLIP_VALUE
ICLIP_VALUE=4;
eventexample3
t3=t;
seisplot(seis3,t3,x3)
xlabel('meters');ylabel('seconds');
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex3a.eps

ICLIP_VALUE=12;
seisplot(seis3,t3,x3)
xlabel('meters');ylabel('seconds');
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex3b.eps

