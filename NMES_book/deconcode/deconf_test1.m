fsmo=10;stab=.000001;stabn=.01;%deconf parameters
nsmo=round(fsmo*max(t));%smoother length in samples
stype='gaussian';%smoother type
phase=1;%decon phase, 1 means minimum, can also choose 0
fmin=10;fmax=150;fmaxn=60;%post-deconf filter parameters
ncc=40;%number of cc lags to examine
sd=deconf(s,s,nsmo,stab,phase,'smoothertype',stype);%noiseless
[x,str]=maxcorr_phs(r,sd,ncc);%compute cc and phase
rb=butterband(r,t,fmin,fmax,4,0);%bandlimit the reflectivity
sdb=butterband(sd,t,fmin,fmax,4,0);%bandlimit the decon
[xb,strb]=maxcorr_phs(rb,sdb,ncc);%compute cc and phase 
sdn=deconf(sn,sn,nsmo,stabn,phase,'smoothertype',stype);%noisy 
[xn,strn]=maxcorr_phs(r,sdn,ncc);%compute cc and phase
sdnb=butterband(sdn,t,fmin,fmaxn,4,0);%bandlimit the decon
rbn=butterband(r,t,fmin,fmaxn,4,0);%bandlimit the reflectivity
[xbn,strnb]=maxcorr_phs(rbn,sdnb,ncc);%compute cc and phase