load ..\data\smallshot

fmin=[10 5];
fmax=[20 20];

tic
seisb=butterband(seis,t,fmin(1),fmax(1),4,1);
t1=toc;

tic
seisf=filtf(seis,t,fmin,fmax,1);
t2=toc;

tic
seiso=filtorm(seis,t,fmin(1)-fmin(2),fmin(1),fmax(1),fmax(1)+fmax(2));
t3=toc;

plotimage(seisb,t,x)
title(['Butterworth, t=' num2str(t1) 's'])
plotimage(seisf,t,x)
title(['Filtf, t=' num2str(t2) 's'])
plotimage(seiso,t,x)
title(['Ormsby, t=' num2str(t3) 's'])