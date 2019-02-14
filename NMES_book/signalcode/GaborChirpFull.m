% One second chirp at 8000 sample rate
Fs = 8000;
t = linspace(0,1,Fs);
x = sin(2*pi*2000*t.^2);
% Gabor window, length and step size
wlen = 128;
wstep = wlen/2;
win = exp(-linspace(-1,1,wlen).^2);
% Gabor transform, 101 windows
gg = zeros(wlen,100);
for k=1:100
    gg(:,k) = abs(fft(x( k*wstep + (1:wlen) ).*win));
end
imagesc([0,1],[0,-Fs],-abs(gg)), colormap(gray)
xlabel("Time (s)")
ylabel("Frequency (Hz)")
prepfig
bigfont(gcf,1.2,1)
print(gcf, 'GaborChirp', '-djpeg')