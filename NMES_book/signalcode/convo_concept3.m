%make a reflectivity

r=zeros(1001,1);
r(350)=.1;%a single non-zero sample
r(650)=-.2;%a single non-zero sample
dt=.001;%time sample size
t=(0:1000)*dt;%time coordinate vector
[wm,tm]=wavemin(.001,20,.4);%a minimum phase (causal wavelet)
[wz,tz]=ricker(.001,20,.4);%a zero phase wavelet
wm=wm/max(wm);%normalize to maximum of 1
wz=wz/max(wz);
%convolutions
sz=conv(r,wz);
sm=conv(r,wm);
figure
%compare the wavelets
subplot(2,1,1)
nw=1:length(wm);
%plot(nw,wm,'b',nw,wz,'r')
wm0=nan*zeros(size(wm));
wm0(1)=wm(1);
wz0=nan*zeros(size(wz));
iz=near(tz,0);
wz0(iz)=wz(iz);
hh=linesgray({nw,wm,'-',.5,0},{nw,wz,'-',.5,.5},{nw,wm0,'none',1,0,'.',15},{nw,wz0,'none',1,.5,'.',15});
grid
xtick(1:50:length(nw))
ylim([-1.5 1])
xlabel('sample number')
legend(hh(1:3),'w_m (minimum phase)','w_z (zero phase)','zero time sample')
%title('wavelets')
subplot(2,1,2)
nr=1:length(r);
ns=1:length(sm);
%plot(nr,r,'k',ns,sm+.2,'b',ns,sz+.4,'r')
linesgray({nr,r,'-',1,.7},{ns,sm+.2,'-',.5,0},{ns,sz+.4,'-',.5,.5})
grid
ylim([-.4 .6])
xtick(1:200:length(ns))
xlabel('sample number')
%title('reflectivity')
legend('r (reflectivity)','s_m = r \bullet w_m','s_z = r \bullet w_z')
prepfig
bigfont(gcf,.75,1)

%legendfontsize(.75)

print -depsc ..\signalgraphics\convoconcept3

% axestitlesize(.5);
% legendfontsize(.5);
% axeslabelsize(.5);