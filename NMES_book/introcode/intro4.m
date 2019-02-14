global NOSIG;NOSIG=1;
[r,t]=reflec(1,.002,.2,3,sqrt(pi));%make reflectivity
nt=length(t);
[w,tw]=wavemin(.002,20,.2);%make wavelet
s=convm(r,w);%make convolutional seismogram
ntr=100;%number of traces
seis=zeros(length(s),ntr);%preallocate seismic matrix
shift=round(20*(sin([1:ntr]*2*pi/ntr)+1))+1; %a time shift for each trace
%load the seismic matrix
for k=1:ntr
   seis(1:nt-shift(k)+1,k)=s(shift(k):nt);
end
x=(0:99)*10; %make an x coordinate vector
figure
plotseis(seis,t,x,1,5,1,1,'k');ylabel('seconds')
xtick(0:250:1000)
bigfont(gcf,2,1)

print -depsc .\intrographics\intro4