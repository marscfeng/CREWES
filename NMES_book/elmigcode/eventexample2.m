v=2000;dx=10;dt=.004;%basic model parameters
x2=0:dx:2000;%x axis
t2=0:dt:2;%t axis
seis2=zeros(length(t2),length(x2));%allocate seismic matrix
seis2=event_hyp(seis2,t2,x2,.4,700,v,1,3);%hyperbolic event
seis2=event_diph(seis2,t2,x2,v,250,800,600,37,1);%linear event
[w,tw]=ricker(dt,40,.2);%make ricker wavelet
seis2=sectconv(seis2,t2,w,tw);%apply wavelet
