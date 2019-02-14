load smallshot

[ap,ae,tpick,xpick]=picker(seis,t,x,[.45 .08],[0 1000],.05,6);
plotimage(seis,t,x);title('')
line(xpick,tpick,'color','r','linestyle','none','marker','.');

figure;plot(xpick,ae,xpick,ap)
xlabel('distance (m)');ylabel('amplitude')

