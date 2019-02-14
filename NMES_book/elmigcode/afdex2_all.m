dx=10;
laplacian=2;
afdexample2

%plot the velocity model
figure
bigfig
imagesc(x,z,vel,[vlow vhigh]);colormap(flipud(gray));colorbar
whitefig;xlabel('meters');ylabel('meters')
axis equal
xlim([0 xmax]);ylim([0 zmax]);
bigfont(gca,4,1);

print -depsc -noui elmiggraphics\afdvmodel2.eps

%plot reflectivity
global ICLIP_VALUE
ICLIP_VALUE=1;
r=afd_reflect(vel,0);
seisplot(r,z,x)
whitefig;xlabel('meters');ylabel('meters')
axis equal
xlim([0 xmax]);ylim([0 zmax]);
bigfont(gca,2,1);

print -depsc -noui elmiggraphics\afdex2ref.eps

%plot the seismogram
ICLIP_VALUE=6;
seisplot(seisfilt,t,x)
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\afdex2_a.eps

laplacian=2;
dx=5;
afdexample2

%plot the seismogram
ICLIP_VALUE=6;
seisplot(seisfilt,t,x)
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gca,2.5,1);
brighten(.5)

print -depsc -noui elmiggraphics\afdex2_b.eps


