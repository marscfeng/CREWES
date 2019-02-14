seismig=fkmig(seis,t,x,v);
plotimage(seismig,t*v/2,x);
xlabel('meters');ylabel('meters');
seismig2=fkmig(seis2,t,x,v);
plotimage(seismig2,t*v/2,x);
xlabel('meters');ylabel('meters');
