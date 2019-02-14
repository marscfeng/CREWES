v=2000;dx=10;dt=.004;%basic model parameters
x1=0:dx:2000;%x axis
t1=0:dt:2;%t axis
seis1=zeros(length(t1),length(x1));%allocate seismic matrix
seis1=event_hyp(seis1,t1,x1,.4,700,v,1,3);%hyperbolic event
seis1=event_dip(seis1,t1,x1,[.75 1.23],[700 1500],1);%linear event
[w,tw]=ricker(dt,40,.2);%make ricker wavelet
seis1=sectconv(seis1,t1,w,tw);%apply wavelet
