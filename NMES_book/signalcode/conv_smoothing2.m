%demonstrate smoothing by convolution
dt=.001;%time sample size
tmax=1;%length in seconds of reflectivity
fdom=30;%dominant frequency of wavelet
tlen=.2;%wavelet length
s2n=.5;%signal--to-noise ratio
tsmo=.004*(1:.5:5);%averaging lengths
[r,t]=reflec(tmax,dt,.1,5,3);%create the reflectivity
[w,tw]=wavemin(dt,fdom,tlen);%create the wavelet
s=convm(r,w);%the noise-free seismogram
n=rnoise(s,s2n);%create the noise to be added
sn=s+n;%the noisy seismogram
sfilt=zeros(length(s),length(tsmo)+3);%to store filtered results
sfilt(:,1)=s;%noise free trace in position 1
sfilt(:,2)=sn;%noisy trace in position 2
for k=1:length(tsmo)
    nsmo=round(tsmo(k)/dt);%averaging size in samples
    box=ones(nsmo,1);%boxcar
    sfilt(:,k+2)=convz(sn,box/nsmo);%use convz to smooth
end
sfilt(:,k+3)=filtf(sn,t,0,[45 5]);%better low-pass filter

