td=0.1;stab=.0001;stabn=.1;%deconw parameters
n=round(td/dt);%operator length in samples
wndw=1;%window type, 1=boxcar, 2=triangle, 3=gaussian
fmin=10;fmax=150;fmaxn=60;%post-deconw filter parameters
ncc=40;%number of cc lags to examine
sd=deconw(s,s,n,stab,wndw);%noiseless deconw
[x,str]=maxcorr_phs(r,sd,ncc);%compute cc and phase
rb=butterband(r,t,fmin,fmax,4,0);%bandlimit the reflectivity
sdb=butterband(sd,t,fmin,fmax,4,0);%bandlimit the decon
[xb,strb]=maxcorr_phs(rb,sdb,ncc);%cc and phase after filter
sdn=deconw(sn,sn,n,stabn,wndw);%noisy deconw
[xn,strn]=maxcorr_phs(r,sdn,ncc);%compute cc and phase
sdnb=butterband(sdn,t,fmin,fmaxn,4,0);%bandlimit the decon
rbn=butterband(r,t,fmin,fmaxn,4,0);%bandlimit the reflectivity
[xbn,strnb]=maxcorr_phs(rbn,sdnb,ncc);%cc and phase after filter