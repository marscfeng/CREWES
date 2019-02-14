dt=.0005;%time sample rate
tlen=.2;%wavelet length
fdom=30;%dominant frequency
[w,tw]=ricker(dt,fdom,tlen);
wa=hilbert(w);%analytic signal corresponding to Ricker
wh=-imag(wa);%Hilbert transform of Ricker
env=abs(wa);
angles=[0:45:315];%phase rotation angles
wrot=zeros(length(w),length(angles));%preallocate space 
for k=1:length(angles)
    wrot(:,k)=w*cosd(angles(k))+wh*sind(angles(k));%phase rotations
end
figure
hh=plot(tw,wrot,tw,env,'r',tw,-env,'r');
xlabel('time (sec)')
xlim([-.1 .1])
prepfig
set(hh(1),'linewidth',5,'color','k')