dt=.002;%time sample size
fdom=30;%dominant frequency
tmax=.5;%time length of reflectivity
tlen=.1;%time length of wavelet
[w,tw]=wavemin(dt,fdom,tlen);
[r,t]=reflec(tmax,dt,1,5,4);%reflectivity
W=convmtx(w,length(r));%build the convolution matrix
s=W*r;%perform the convolution