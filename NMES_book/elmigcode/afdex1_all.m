dx=5;
laplacian=2;
afdexample1

%compute times to top and bottom of channel
tchtop=2*(z1/vlow + (z2-z1)/v1 + (z3-z2)/v2 + (z4-z3)/v3);
tchbot=tchtop+2*(thk/vch);

%plot the velocity model
figure
bigfig
imagesc(x,z,vel,[vlow vhigh]);colormap(flipud(gray));colorbar
whitefig;xlabel('meters');ylabel('meters')
bigfont(gca,4,1);

print -depsc -noui elmiggraphics\afdvmodel.eps

%plot the seismogram
global ICLIP_VALUE
ICLIP_VALUE=1;
seisplot(seisfilt,t,x)
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gca,2.5,1);
brighten(.5)

%compute time of channel and annotate
h1=drawpick(xmax/2,tchtop,0,width);
h2=drawpick(xmax/2,tchbot,0,width);
set([h1,h2],'color','k','linewidth',2)

print -depsc -noui elmiggraphics\afdex1_a.eps

%%
dx=5;
laplacian=1;
afdexample1

%compute times to top and bottom of channel
tchtop=2*(z1/vlow + (z2-z1)/v1 + (z3-z2)/v2 + (z4-z3)/v3);
tchbot=tchtop+2*(thk/vch);

%plot the seismogram
global ICLIP_VALUE
ICLIP_VALUE=1;
seisplot(seisfilt,t,x)
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gca,2.5,1);
brighten(.5)

%compute time of channel and annotate
h1=drawpick(xmax/2,tchtop,0,width);
h2=drawpick(xmax/2,tchbot,0,width);
set([h1,h2],'color','k','linewidth',2)

print -depsc -noui elmiggraphics\afdex1_b.eps

%%
dx=10;
laplacian=1;
afdexample1

%compute times to top and bottom of channel
tchtop=2*(z1/vlow + (z2-z1)/v1 + (z3-z2)/v2 + (z4-z3)/v3);
tchbot=tchtop+2*(thk/vch);

%plot the seismogram
global ICLIP_VALUE
ICLIP_VALUE=1;
seisplot(seisfilt,t,x)
whitefig;xlabel('meters');ylabel('seconds')
bigfont(gca,2.5,1);
brighten(.5)

%compute time of channel and annotate
h1=drawpick(xmax/2,tchtop,0,width);
h2=drawpick(xmax/2,tchbot,0,width);
set([h1,h2],'color','k','linewidth',2)

print -depsc -noui elmiggraphics\afdex1_c.eps
