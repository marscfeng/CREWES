global ICLIP_VALUE
ICLIP_VALUE=4;
eventexample4
seisplot(seis4,t4,x4)
xlabel('meters');ylabel('seconds');
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex4a.eps

ICLIP_VALUE=12;
seisplot(seis4,t4,x4)
xlabel('meters');ylabel('seconds');
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex4b.eps
