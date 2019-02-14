dt=.002;%time sample rate
Q=50;%Q value
tmax=2;%max time for reflectivity
fdom=20;%dominant frequency of wavelet
tlen=.5*tmax;%length of wavelet (this is overkill)
s2n=4;%signal-to-noise ratio
%change the last argument in reflec (currently pi) to any  
%other number to get a different reflectivity
r=reflec(tmax,dt,.1,3,pi);
tmax=tmax+.5;%pad out a bit
t=(0:dt:tmax)';%t coordinates
r=pad_trace(r,t);%pad r with zeros
[w,tw]=wavemin(dt,fdom,tlen);%the wavelet
qmat=qmatrix(Q,t,w,tw,1);
sq=qmat*r;%nonstationary synthetic
s=convm(r,w,0);%stationary synthetic
sn=s+rnoise(s,s2n);%add some noise to stationary
iz=near(t,1,1.5);%zone defining noise strength for nonstationary
sqn=sq+rnoise(sq,s2n,iz);%add some noise to nonstationary