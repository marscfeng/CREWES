%run eventexample1 through eventexample5 before this
global ICLIP_VALUE
ICLIP_VALUE=4;
%example1
seismig1=fkmig(seis1,t1,x1,v);
seisplot(seismig1,t1*v/2,x1);
xlabel('meters');ylabel('meters');
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\fkmig1.eps

%example2
seismig2=fkmig(seis2,t2,x2,v);
seisplot(seismig2,t2*v/2,x2);
xlabel('meters');ylabel('meters');

bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\fkmig2.eps

%example3
seismig3=fkmig(seis3,t3,x3,v);
seisplot(seismig3,t3*v/2,x3);
xlabel('meters');ylabel('meters');

bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\fkmig3.eps

%example4
seismig4=fkmig(seis4,t4,x4,v);
seisplot(seismig4,t4*v/2,x4);
xlabel('meters');ylabel('meters');

bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\fkmig4.eps

%example5a
seismig5a=fkmig(seis5a,t5,x5,v);
seisplot(seismig5a,t5*v/2,x5);
xlabel('meters');ylabel('meters');

bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\fkmig5a.eps

%fk spectrum
[fk5a,kz,kx]=fktran(seismig5a,t5*v/2,x5);
seisplot(abs(fk5a),kz,kx);
xlabel('wavenumber (1/meters)')
ylabel('wavenumber (1/meters)')
prepfig
bigfont(gcf,.8,1)
print -depsc -noui elmiggraphics\fkmigspec2.eps

%example5d
seismig5d=fkmig(seis5d,t5,x5,v);
seisplot(seismig5d,t5*v/2,x5);
xlabel('meters');ylabel('meters');

bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\fkmig5d.eps

%fk spectrum
[fk5d,kz,kx]=fktran(seismig5d,t5*v/2,x5);
seisplot(abs(fk5d),kz,kx);
xlabel('wavenumber (1/meters)')
ylabel('wavenumber (1/meters)')
prepfig
bigfont(gcf,.8,1)
