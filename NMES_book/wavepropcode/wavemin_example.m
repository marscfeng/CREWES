%make wavemin wavelet
[w1,tw]=wavemin(.001,20,.2,2);
[w2,tw]=wavemin(.001,20,.2,3);
%compute spectrum
[W1,f]=fftrl(w1,tw);
W1=todb(W1);
[W2,f]=fftrl(w2,tw);
W2=todb(W2);