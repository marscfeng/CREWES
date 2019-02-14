% ALIASTUDY: study aliasing versus depth
% The plot is made with black lines for the v(z) case and gray lines for constant velocity. 
% Linewidth indicates spatial sample size, dx, with narrow-to-wide showing dx increasing from 20 to
% 160 meters. 
% The plot legend only points to the v(z) case but the constant velocity case has the same
% line-width to spatial sample size encoding.


% Just run the script
figure;
vo=1800;c=.6;
dx=[20 40 80 160];
z=0:25:20000;
f=60;
vo1=3500;
h=zeros(size(T));
hc=h;
for k=1:length(dx)
	thetac=thalias(dx(k),f,vo1,c1,z);
    theta=thalias(dx(k),f,vo,c,z);
    hc(k)=linesgray({z,thetac,'-',lw+(k-1)*.5,.5});
    h(k)=linesgray({z,theta,'-',lw+(k-1)*.5,0});
end

ylabel('scattering angle (degrees)')
xlabel('depth (meters)')
set(gca,'xtick',0:2500:20000)
set(gca,'ytick',0:30:90)
legend(h,['Linear v(z) \Delta x = ' int2str(dx(1))],['Linear v(z) \Delta x = '  int2str(dx(2))],....
    ['Linear v(z) \Delta x = ' int2str(dx(3))],['Linear v(z) \Delta x = ' int2str(dx(4))])
prepfig
	