v=2000;dx=10;dt=.004;%basic model parameters
x3=0:dx:2000;%x axis
t3=0:dt:2;%t axis
seis3=zeros(length(t),length(x3));%allocate seismic matrix
tic
seis3=event_diph(seis3,t3,x3,v,250,1500,200,0,1,1);
seis3=event_diph(seis3,t3,x3,v,250,1500,200,20,1,1);
seis3=event_diph(seis3,t3,x3,v,250,1500,200,40,1,1);
seis3=event_diph(seis3,t3,x3,v,250,1500,200,60,1,1);
seis3=event_diph(seis3,t3,x3,v,250,1500,200,80,1,1);
toc
[w,tw]=ricker(.004,40,.2);
seis3=sectconv(seis3,t3,w,tw);
