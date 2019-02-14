fsmo=10;stab=.0001;%deconf parameters
nsmo=round(fsmo*max(t));%smoother length in samples
stype='gaussian';%smoother type
phase=1;%decon phase, 1 means minimum, can also choose 0
fmin=10;fmax=150;fmaxn=60;%post-deconf filter parameters
ncc=40;%number of cc lags to examine
sdf=deconf(s,s,nsmo,stab,phase,'smoothertype',stype);%staboption max
sdfb=butterband(sdf,t,fmin,fmax,4,0);%bandlimit the decon
%deconf with staboption mean
sdf2=deconf(s,s,nsmo,stab,phase,'smoothertype',stype,'staboption','mean');
sdf2b=butterband(sdf2,t,fmin,fmax,4,0);%bandlimit the decon
rb=butterband(r,t,fmin,fmax,4,0);%bandlimit the reflectivity
td=1/fsmo;%deconw operator length
n=round(td/dt);%operator length in samples
wndw=3;%window type, 1=boxcar, 2=triangle, 3=gaussian
sdw=deconw(s,s,n,stab,wndw);%noiseless deconw
sdwb=butterband(sdw,t,fmin,fmax,4,0);%bandlimit the decon
[xb,strfb]=maxcorr_phs(rb,sdfb,ncc);%compare sdfb to rb
[xb,strf2b]=maxcorr_phs(rb,sdf2b,ncc);%compare sdf2b to rb
[xb,strwb]=maxcorr_phs(rb,sdwb,ncc);%compare sdwb to rb
[xb,strwf]=maxcorr_phs(sdf2b,sdwb,ncc);%compare sdf2b to sdwb