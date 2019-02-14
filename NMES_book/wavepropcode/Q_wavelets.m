%
dt=.0005;%time sample rate
tmax=1.5;%maximum record time
v=2000;%constant velocity
Q=50;%Q value
fdom=100;%dominant frequency of initial wavelet
fnot=12500;

x=[0 250 500 750 1000];%distances to examine (there should always be 5 entries)

[w,tw]=wavemin(dt,fdom,.2);%initial waveform
%array to hold propagated wavelets
wlet=zeros(length(x),round(tmax/dt)+1);%array for propagated wavelets
wlet2=wlet;%array for wavlets in retarded time
qimp=wlet;%array for Q impulse responses
qimp2=wlet;%array for Q impulse responses in retarded time
%function 'einar' is based on Kjartanssen (1979 Geophysics)
for k=1:length(x)
    [qimp(k,:),t]=einar(Q,x(k),v,dt,tmax,1,.95,fnot);%with delay
    qimp2(k,:)=einar(Q,x(k),v,dt,tmax,0,.95,fnot);%delay removed
    wlet(k,:)=convm(qimp(k,:),w);%apply initial wavelet
    wlet2(k,:)=convm(qimp2(k,:),w);%apply initial wavelet
end

