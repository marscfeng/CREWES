load data\logdata %contains vectors vp and z
Q=[50 80 120];
tdr=zeros(length(z),length(Q));
f1=30;%%seismic frequency
f0=12500;%logging frequency
z=z-z(1);%set first depth to zero
for k=1:length(Q)
    %adjust velocity to frequency f1
    v1=vp./((1-(1./(pi*Q(k))).*log(f1/f0)));
    %compute times at f0
    t0=vint2t(vp,z);
    %compute times at f1
    t1=vint2t(v1,z);
    tdr(:,k)=t1-t0;%will be a positive quantity if f0>f1
end