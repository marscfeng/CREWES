v=2000;dx=10;dt=.004;%basic model parameters
x4=0:dx:3000;%x axis
t4=0:dt:1.5;%t axis
zreef=600;hwreef=200;hreef=100;%depth, half-width, and height of reef
xcntr=max(x4)/2;
xpoly=[xcntr-hwreef xcntr-.8*hwreef xcntr+.8*hwreef xcntr+hwreef];
zpoly=[zreef zreef-hreef zreef-hreef zreef];
seis4=zeros(length(t4),length(x4));%allocate seismic matrix
seis4=event_diph(seis4,t4,x4,v,0,xcntr-hwreef,zreef,0,.1);%left
seis4=event_diph(seis4,t4,x4,v,xcntr+hwreef,max(x4),zreef,0,.1);%right
seis4=event_diph(seis4,t4,x4,v,xcntr-hwreef,xcntr+hwreef,zreef,0,.2);%base
seis4=event_pwlinh(seis4,t4,x4,v,xpoly,zpoly,-.1*ones(size(zpoly)));%top
[w,tw]=ricker(dt,40,.2);%make ricker wavelet
seis4=sectconv(seis4,t4,w,tw);%apply wavelet
