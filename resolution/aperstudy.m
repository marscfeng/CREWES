% APERSTUDY: study the aperture effect 
% The plot is made with black lines for the v(z) case and gray lines for constant velocity. 
% Linewidth indicates aperture with narrow-to-wide showing aperture increasing from 1000 to
% 20000. 
% The plot legend only points to the v(z) case but the constant velocity case has the same
% line-width to aperture encoding.

% Just run the script
figure;
vo=1800;c=.6;
A=[1000  4000  12000  20000];
z=0:25:20000;
vo1=3500;c1=0;
lw=.5;
h=zeros(size(A));
hc=h;
for k=1:length(A)
    theta=thaper(A(k),vo,c,z);
	thetac=thaper(A(k),vo1,c1,z);
    hc(k)=linesgray({z,thetac,'-',lw+(k-1)*.5,.5});
    h(k)=linesgray({z,theta,'-',lw+(k-1)*.5,0});
end


ylabel('scattering angle (degrees)')
xlabel('depth in meters')
set(gca,'xtick',0:5000:20000)
set(gca,'ytick',0:30:180)
set(gca,'ylim',[0 180])
legend(h,['Linear v(z) A = ' int2str(A(1))],['Linear v(z) A = ' int2str(A(2))],....
    ['Linear v(z) A = ' int2str(A(3))],['Linear v(z) A = ' int2str(A(4))])
prepfig
grid

	