dt=.001;tmax=1;fdom=20;tlen=.3;
[r,t]=reflec(tmax,dt,.1,3,pi);%make a synthetic reflectivity
r(end-5)=.2;%insert a large spike near the end of the trace
[w,tw]=wavemin(dt,fdom,tlen);% a minimum phase wavelet
s_td=convm(r,w);%time domain convolution
wimp=pad_trace(w,r);%pad wavelet with zeros to length of r
s_fd=ifft(fft(r).*fft(wimp));%frequency domain multiplication
%to avoid time-domain aliasing, apply a zero pad before filtering
rp=pad_trace(r,1:1301);%this applies a 300 sample zero pad
tp=.001*(0:1300);%t coordinate for rp
wimp2=pad_trace(w,rp);%pad wavelet with zeros to length of rp
s_fdp=ifft(fft(rp).*fft(wimp2));%frequency domain multiplication