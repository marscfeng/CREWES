% RECSTUDY: Study record length limit on scattering angle
% The plot is made with black lines for the v(z) case and gray lines for constant velocity. 
% Linewidth indicates record length with narrow-to-wide showing record length increasing from 2 to
% 8 seconds. 
% The plot legend only points to the v(z) case but the constant velocity case has the same
% line-width to record length encoding.

% Just run the script
figure;
vo=1800;c=.6;
T=[2. 4.  6. 8];
z=0:.1:31000;
vo1=3500;c1=0;
h=zeros(size(T));
hc=h;
for k=1:length(T)
	thetac=threc(T(k),vo1,c1,z);
    theta=threc(T(k),vo,c,z);
    ind=find(imag(theta)~=0);
    theta(ind)=nan*ind;
    ind=find(imag(thetac)~=0);
    thetac(ind)=nan*ind;
    hc(k)=linesgray({z,thetac,'-',lw+(k-1)*.5,.5});
    h(k)=linesgray({z,theta,'-',lw+(k-1)*.5,0});
end
set(gca,'ytick',0:20:150)
ylabel('scattering angle (degrees)')
xlabel('depth (meters)')
legend(h,['Linear v(z) T = ' int2str(T(1))],['Linear v(z) T = ' int2str(T(2))],....
    ['Linear v(z) T = ' int2str(T(3))],['Linear v(z) T = ' int2str(T(4))])
prepfig

	