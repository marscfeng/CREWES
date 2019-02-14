% create the power spectrum
  powspec=tntamp(fdom,f,m).^2;
% create the autocorrelation
  auto=ifftrl(powspec,f);
% run this through Levinson
  nlags=tlength/dt+1;
  b=[1.0 zeros(1,nlags-1)]';
  winv=levrec(auto(1:nlags),b);
% invert the wavelet
  wavelet=real(ifft(1. ./(fft(winv))));
  twave=(dt*(0:length(wavelet)-1)'; 
% now normalize the wavelet
  wavelet=wavenorm(wavelet,twave,2);
