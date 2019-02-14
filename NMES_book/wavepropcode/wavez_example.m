%make wavez wavelet
fdom=20;
[w1,tw]=wavez(.002,fdom,.2,2);
[w2,tw]=wavez(.002,fdom,.2,3);
[wr,tw]=ricker(.002,fdom,.2);
%compute spectrum
[W1,f]=fftrl(w1,tw);
W1=todb(W1);
[W2,f]=fftrl(w2,tw);
W2=todb(W2);
[Wr,f]=fftrl(wr,tw);
Wr=todb(Wr);