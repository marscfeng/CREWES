tgap=0.026;%prediction gap (seconds)
%tgap=0.01;%prediction gap (seconds)
td=0.1;%operator length (seconds)
stab=0.0001;%stability constant
n=round(td/dt);%operator length in samples
ngap=round(tgap/dt);%prediction gap in samples
fmin=10;fmax=150;fmaxn=60;%post-decon filter parameters
ncc=40;%number of cc lags to examine
[sd,x1]=deconpr(s,s,n,1,stab);%noiseless deconpr as spiking
[x,str]=maxcorr_phs(r,sd,ncc);%compute cc and phase
[sdg,xg]=deconpr(s,s,n,ngap,stab);%noiseless deconpr gapped
[x,strg]=maxcorr_phs(r,sdg,ncc);%compute cc and phase
snd=deconpr(sn,sn,n,1,stab);%noisy deconpr as spiking
[x,strn]=maxcorr_phs(r,snd,ncc);%compute cc and phase
sndg=deconpr(sn,sn,n,ngap,stab);%noisy deconpr gapped
[x,strng]=maxcorr_phs(r,sndg,ncc);%compute cc and phase
%apply filters
rb=butterband(r,t,fmin,fmax,4,0);%bandlimit the reflectivity
sdb=butterband(sd,t,fmin,fmax,4,0);%bandlimit the spiking decon
[x,strb]=maxcorr_phs(rb,sdb,ncc);%compute cc and phase
sdgb=butterband(sdg,t,fmin,fmax,4,0);%bandlimit the gapped decon
[x,strgb]=maxcorr_phs(rb,sdgb,ncc);%compute cc and phase
rbn=butterband(r,t,fmin,fmax,4,0);%bandlimit the reflectivity
sndb=butterband(snd,t,fmin,fmaxn,4,0);%bandlimit the spiking decon noisy
[x,strnb]=maxcorr_phs(rbn,sndb,ncc);%compute cc and phase
sndgb=butterband(sndg,t,fmin,fmaxn,4,0);%bandlimit the gapped decon noisy
[x,strngb]=maxcorr_phs(rbn,sndgb,ncc);%compute cc and phase