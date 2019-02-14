v=2000;dx=5;dt=.004;%basic model parameters
x5=0:dx:3000;%x axis
t5=0:dt:1.5;%t axis
xcntr=max(x5)/2;
seis5=zeros(length(t5),length(x5));%allocate seismic matrix
seis5=event_diph2(seis5,t5,x5,v,0,500,1000,ndelx,0,.1);
seis5=event_diph2(seis5,t5,x5,v,500,xcntr-500,1000,ndelx,-45,.1);
seis5=event_diph2(seis5,t5,x5,v,xcntr-500,xcntr+500,500,ndelx,0,.1);
seis5=event_diph2(seis5,t5,x5,v,xcntr+500,max(x5)-500,500,ndelx,45,.1);
seis5=event_diph2(seis5,t5,x5,v,max(x5)-500,max(x5),1000,ndelx,0,.1);
[w,tw]=ricker(dt,40,.2);%make ricker wavelet
seis5=sectconv(seis5,t5,w,tw);%apply wavelet
