%figure 7.50a
A=2500;
T=3;
v=3500;
c=0;
dx=20;
f=60;
z=0:6000;
dipspect(A,T,dx,f,v,c,z);
legend(['Record length limit, T=' num2str(T) ' sec'],...
	['Aperture limit, A=' int2str(A) ' m'],...
	['Spatial aliasing limit, dx=' int2str(dx) ' m, f=' ...
	int2str(f) ' Hz']);
xlabel('depth (m)')
title('')
prepfig
bigfont(gcf,1.8,1)
print -depsc elmiggraphics\constscatter.eps

%% figure 7.50b

A=2500;
T=3;
v=1500;
c=.6;
dx=20;
f=60;
z=0:4000;
dipspect(A,T,dx,f,v,c,z);
legend(['Record length limit, T=' num2str(T) ' sec'],...
	['Aperture limit, A=' int2str(A) ' m'],...
	['Spatial aliasing limit, dx=' int2str(dx) ' m, f=' ...
	int2str(f) ' Hz']);
xlabel('depth (m)')
title('')
prepfig
bigfont(gcf,1.8,1)
print -depsc elmiggraphics\varscatter.eps