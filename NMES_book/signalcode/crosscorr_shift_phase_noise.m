
dt=.002;tmax=2;%time sample rate and record length
fdom=30;s2n=1;%dominant frequency and signal-to-noise ratio
phase=90;%phase rotation
nlag=100;%delay of the second reflectivity in samples
[r1,t]=reflec(tmax,dt,.2,3,5);%first reflectivity
r2=[zeros(nlag,1);r1(1:end-nlag)];%r2 is r1 but shifted by nlag samples
rtmp=reflec(2,dt,.2,3,9);%something to fill in the zeros on r2
r2(1:nlag)=rtmp(1:nlag);%fill in zeros
%wavelets
[w1,tw]=wavemin(dt,fdom,.2);w2=phsrot(w1,phase);
%signals
s1=convm(r1,w1);s21=convm(r2,w1);s22=convm(r2,w2);
%make noise
n1=rnoise(s1,s2n);n2=rnoise(s1,s2n);
%add noise to signals
s1n=s1+n1;s21n=s21+n2;s22n=s22+n2;
%correlations
maxlag=2*nlag;%we will search from -maxlag to maxlag
aflag=1;%we will pick positive values for cc
cc121=ccorr(s1,s21,maxlag);%the entire correlation function 
mcc121=maxcorr(s1,s21,maxlag,aflag);%the maximum and its lag 
cc122=ccorr(s1,s22,maxlag);
mcc122=maxcorr(s1,s22,maxlag,aflag);
cc121n=ccorr(s1n,s21n,maxlag);
mcc121n=maxcorr(s1n,s21n,maxlag,aflag);
cc122n=ccorr(s1n,s22n,maxlag);
mcc122n=maxcorr(s1n,s22n,maxlag,aflag);
tau=dt*(-maxlag:maxlag);%lag vector to plot correlations against
