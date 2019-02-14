trdsign=pad_trace(trdsign,trin); %pad trdsign to length of trin
% generate the power spectrum
spec= fftshift(fft(trdsign));%note fftshift
power= real(spec).^2 + imag(spec).^2;
% stabilize the power spectrum
power=power+stab*max(power);
% smooth the power
smoo=ones(nn,1);%nn is an odd number of samples
power=convz(power,smoo,ceil(nn/2),length(power),0)/sum(abs(smoo));
n2=length(power);
power(n2/2+2:end)=power(n2/2:-1:2);%enforce symmetry
% compute the minimum phase spectrum
logspec=hilbert(.5*log(power));% .5 because power not amplitude
% compute the complex spectrum of the inverse operator
specinv= exp(-conj(logspec));%- sign for inverse
% deconvolve the input trace
specin=fftshift(fft(trin));%note fftshift
specout=specin.*specinv;%decon is just multiplication
trout=real(ifft(fftshift(specout)));%note fftshift and real