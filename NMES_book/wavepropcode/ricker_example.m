%make ricker wavelet
[w,tw]=ricker(.002,40,.4);
%compute spectrum
[W,f]=fftrl(w,tw);
W=todb(W);