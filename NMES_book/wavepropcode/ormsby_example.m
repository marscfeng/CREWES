%make ormsby wavelet
[w,tw]=ormsby(10,15,40,50,.4,.002);
%compute spectrum
[W,f]=fftrl(w,tw);
W=todb(W);