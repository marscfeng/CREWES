%geometry
dt=.004;tmax=1.0;t=(0:dt:tmax)';%time coordinate
dx=7.5;xmax=1000;x=-xmax:dx:xmax;%x coordinate
%preallocate seismic matrices
seis=zeros(length(t),length(x));%for hyperbolic events
seisn=seis;seisfb=seis;%for first breaks and noise
%first breaks
vfbl=2000;vfbr=2500;%first break velocities to the left and right
afb=3;anoise=4;%amplitude of first breaks and noise
t1=0;t2=xmax/vfbr;%times at 0 and far offset for right first break
seisfb=event_dip(seisfb,t,x,[t1 t2],[0 xmax],afb);
t1=0;t2=xmax/vfbl;%times at 0 and far offset for left first break
seisfb=event_dip(seisfb,t,x,[t1 t2],[0 -xmax],afb);
%noise
vnoise=1000;%noise velocity
t1=0;t2=xmax/vnoise;%times at 0 and far offset for noise
seisn=event_dip(seisn,t,x,[t1 t2],[0 xmax],anoise);
seisn=event_dip(seisn,t,x,[t1 t2],[0 -xmax],anoise);
%reflectors
vstk=2500:500:4000;%hyperbolic velocities of reflections
t0=[.2 .35 .5 .6];a=[1 -1 -1.5 1.5];%zero offset times and amps
for k=1:length(t0)
    seis=event_hyp(seis,t,x,t0(k),0,vstk(k),a(k));
end
%filters
flow=10;delflow=5;fmax=60;delfmax=20;%bandpass filter params
ffbmax=80;delffb=10;%first break filter
fnoisemax=30;delnoise=10;%noise filter
seisf=filtf(seis,t,[flow delflow],[fmax delfmax],1);%filter on signal
seisnf=filtf(seisn,t,0,[fnoisemax delnoise],1);%lowpass fil on noise
seisfbf=filtf(seisfb,t,[flow delflow],[ffbmax delffb],1);%filter on FBs
seisf=seisf+seisnf+seisfbf;%combined section
%fk transform
[seisfk,f,kx]=fktran(seisf,t,x);