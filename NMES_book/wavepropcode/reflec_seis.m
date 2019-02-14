%make wavelet
dt=.002;tmax=1;tmaxw=.2;m=2;
[wm,twm]=wavemin(dt,20,tmaxw,m); %20 Hz min phs
[wr,twr]=ricker(dt,40,tmaxw); %40 Hz Ricker
%make reflectivity
[r,t]=reflec(tmax,dt,.2);
%pad spike at end
ntw=tmaxw/dt;
r=[r;zeros(ntw/2,1);.2;zeros(ntw,1)];
t=dt*(0:length(r)-1);
%convolve and balance
s1=convz(r,wr);
s1=balans(s1,r);
s2=convm(r,wm);
s2=balans(s2,r);