dt=.001;tmax=1;
[r,t]=reflec(tmax,dt,.1,3,pi);%make a synthetic reflectivity
r(end-5)=.2;%insert a large spike near the end of the trace
s_fd=filtf(r,t,[10 5],[40 10],1);%apply a filter to r in the frequency domain
%Capture the impulse response of filtf
imp=zeros(size(r));%Make an impulse
imp(1)=1;
%filter the impulse to capture the impulse response of a minimum phase filter
wimp=filtf(imp,t,[10 5],[40 10],1);%filtf operates in the frequency domain
w=wimp(1:500);%truncate to 500 samples
s_td=convm(r,w);%convolve with r


%to avoid time-domain aliasing, we apply a zero pad to r before filtering
rp=pad_trace(r,1:1501);%this applies a 500 sample zero pad
tp=.001*(0:1500);%t coordinate for rp

s_fdp=filtf(rp,tp,[10,5],[40,10],1);
