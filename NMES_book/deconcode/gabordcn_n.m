twin=.3;%Gaussian window width (standard deviation)
tinc=.05;%spacing between windows
tsmob=.3;%temporal smoother for boxcar
fsmob=5;%frequency smoother for boxcar
stab=0.001;%Stability factor
ihyp=0;%flag for no hyperbolic
sgbn=gabordecon(sqn,t,twin,tinc,tsmob,fsmob,ihyp,stab);%boxcar smo
tsmoh=1;%temporal smoother for hyperbolic
ihyp=1;%flag for hyperbolic smoothing
sghn=gabordecon(sqn,t,twin,tinc,tsmob,fsmob,ihyp,stab);%hyperbolic smo
%hyperbolic filtering
f0=70;t0=1;fmaxmax=100;fmaxmin=30;
sgbnf=filt_hyp(sgbn,t,t0,[0 0],[f0 10],[fmaxmax fmaxmin]);
sghnf=filt_hyp(sghn,t,t0,[0 0],[f0 10],[fmaxmax fmaxmin]);