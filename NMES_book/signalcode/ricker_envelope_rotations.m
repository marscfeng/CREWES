%hilbert envelope and phase rotations
dt=.0005;%time sample rate
tlen=.2;%wavelet length
fdom=30;%dominant frequency
[w,tw]=ricker(dt,fdom,tlen);
wa=hilbert(w);%analytic signal corresponding to Ricker
wh=-imag(wa);%Hilbert transform of Ricker
env=abs(wa);
angles=[0:45:315];%phase rotation angles
wrot=zeros(length(w),length(angles));%preallocate space for rotated wavelets
for k=1:length(angles)
    wrot(:,k)=w*cosd(angles(k))+wh*sind(angles(k));%phase rotations
end
figure
%hh=plot(tw,wrot,tw,env,'r',tw,-env,'r');%plot and capture hanles of the drawn lines
hh=ones(1,length(angles)+2);
sign=1.0;
for k=1:length(angles)
    hh(k)=linesgray({tw,wrot(:,k),'-',.5,.5+sign*.2});
    sign=sign*-1;
end
hh(k+1)=linesgray({tw,env,'-',1,.5});
hh(k+2)=linesgray({tw,-env,'-',1,.5});
set(hh(1),'color','k','linewidth',1);
xlabel('time (sec)')
xlim([-.05 .05])
xtick(-.04:.02:.04)
prepfig
hl=legend([hh(1), hh(end-1) hh(2) hh(3)],'Ricker wavelet','\pm Hilbert envelope','phase rotation','phase rotation');
set(hl,'position',[0.6757 0.6632 0.2425 0.2728])
% set(hh(1),'linewidth',5,'color','k')%adjust the first one which is the original Ricker
% set(hh(9),'linewidth',5);
% set(hh(10),'linewidth',5);
bigfont(gcf,2,1);boldlines(gcf,1.5)

print -depsc .\signalgraphics\ricker_env_and_rotations