theta=0:30:90;v=2000;%dip and velocity
fmax=60;delfmax=20;%lowpass filter params
dt=.004;tmax=1;t=0:dt:tmax;%time coordinate
dx=10;xmax=1000;x=-xmax:dx:xmax;%x coordinate
seis1=zeros(length(t),length(x));%preallocate seismic matrix
seis2=seis1;%preallocate second seismic matrix
for k=1:length(theta)
    t1=.2;%time at beginning of event
    t2=t1+sind(theta(k))*(x(end)-x(1))/v;%time at end of event
    %install event dipping to the right
    seis1=event_dip(seis1,t,x,[t1 t2],[-xmax xmax],length(theta)-k+1);
    %install event dipping to the left
    seis2=event_dip(seis2,t,x,[t1 t2],[xmax -xmax],length(theta)-k+1);
end
seis1f=filtf(seis1,t,0,[fmax delfmax]);%lowpass filter on seis1
seis2f=filtf(seis2,t,0,[fmax delfmax]);%lowpass filter on seis2
[seis1fk,f,k]=fktran(seis1f,t,x);%fk transform of seis1
[seis2fk,f,k]=fktran(seis2f,t,x);%fk transform of seis2