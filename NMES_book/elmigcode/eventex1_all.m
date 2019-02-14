global ICLIP_VALUE
ICLIP_VALUE=4;
eventexample1
seisplot(seis1,t1,x1)
xlabel('meters');ylabel('seconds');
whitefig;
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\eventex1.eps
