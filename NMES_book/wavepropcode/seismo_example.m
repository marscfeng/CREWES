load data\logdata %contains sp (p-sonic), rho (density) and z (depth)
dt=.001; %sample rate (seconds) of wavelet and seismogram
fdom=60;%dominant frequency of wavelet
[w,tw]=ricker(dt,fdom,.2);%ricker wavelet
fmult=1;%flag for multiples. 1 multiples, 0 no multiples
fpress=0;%flag, 1 pressure (hydrophone), 0 displacement (geophone)
z=z-z(1);%adjust first depth to zero
tmin=0;tmax=1.0;%start and end times of seismogram
[spm,t,rcs,pm,p]=seismo(sp,rho,z,fmult,fpress,w,tw,tmin,tmax);
sp=convz(rcs,w);%make a primaries only seismogram
sp2=convz(p,w);%primaries with transmission losses