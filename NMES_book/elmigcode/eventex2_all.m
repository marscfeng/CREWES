global ICLIP_VALUE
ICLIP_VALUE=4;
eventexample2
seisplot(seis2,t2,x2)
xlabel('meters');ylabel('seconds');
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex2.eps
