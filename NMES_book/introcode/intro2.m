[r,t]=reflec(1,.002,.2); %make a synthetic reflectivity
[w,tw]=wavemin(.002,20,.2); %make a wavelet
s=convm(r,w); % make a synthetic seismic trace
n2=round(length(s)/2);
win=0*(1:length(s));%initialize window to all zeros
win(n2-50:n2+50)=1;%100 samples in the center of win are 1.0
swin=s.*win; % apply the window to the trace
