% Piece of an exponential ramp
Fs = 1024;
t = linspace(0,1,Fs);
x = exp(t).*(t>.4).*(t<.7);
% zero pad for interpolated amplitude spectrum
xlen = length(x);
xf=fft([x,zeros(1,31*xlen)]); 
A=abs(xf);
% Compute the phase via Hilbert transform
Ph = ifft(log(max(A,.001*max(A)))); % stability factor .001 to avoid zero
n = length(Ph);
Ph([1 n/2+1]) = 0;   % zero out DC and Nyquist
Ph((n/2+2):n) = - Ph((n/2+2):n);  % flip signs, for Hilbert transform
Ph = fft(Ph);
% construct the minimum phase version
xfmin = A.*exp(Ph);
xmin=real(ifft(xfmin));
xmin=xmin(1:xlen);   % truncate back to original size
plot(t,x,'--k',t,xmin,'-k')