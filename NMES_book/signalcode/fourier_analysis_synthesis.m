%% Fourier analysis: meaning to find the weights and phases of the basis functions that reconstruct the signal
%make a signal to study
dt=.002;
tlen=dt*511;
fdom=20;
[w,t]=wavemin(dt,fdom,tlen);
[W,f]=fftrl(w,t);
figure
subplot(3,1,1)
plot(t,w)
xlabel('time (s)')
title('Signal to analyze')
subplot(3,1,2)
plot(f,abs(W))
xlabel('frequency (Hz)')
title('Amplitude spectrum')
subplot(3,1,3)
plot(f,angle(W))
xlabel('frequency (Hz)')
title('Phase spectrum')
prepfig
h1=gcf;
%make a suite of basis functions
basisfuncs=exp(1i*2*pi*t*f');
%multiply the basis functions by the spectrum
nf=length(f);
nt=length(t);
analysis=(ones(size(t))*(W.')).*basisfuncs;
%plotseismic(real(analysis),t,f)
plotimage(real(analysis),t,f)
xlabel('Frequency (Hz)')
ylabel('Time (sec)')
title('Real part of the analysis')
prepfig
boldlines(gca,.5)
h2=gcf;
%plotseismic(imag(analysis),t,f)
plotimage(imag(analysis),t,f)
xlabel('Frequency (Hz)')
ylabel('Time (sec)')
title('Imaginary part of the analysis')
prepfig
boldlines(gca,.5)
figure(h2);figure(h1);

%% Fourier synthesis: reconstruction of the signal from the weighted basis functions
w2=2*sum(real(analysis),2)/length(w);
figure
plot(t,w,t,w2,'r.')
err=sum(abs(w-w2))/length(w);
title('W avelet and its Fourier reconstruction')
% title(['Average error=' num2str(err) ', machine precision=' num2str(eps)])
legend('Original wavelet','Fourier reconstruction')
prepfig
%% Another analysis
%make two signals to illustrate the fat-skinny rule
dt=.002;
tlen=dt*511;
[w1,t]=ormsby(5,10,40,50,tlen,dt);
[w2,t]=ormsby(5,10,80,100,tlen,dt);
[W1,f]=fftrl(w1,t);
[W2,f]=fftrl(w2,t);
figure
subplot(2,1,1)
plot(t,w1,t,w2)
legend('w_1=Ormsby 5,10,40,50','w_2=Ormsby 5,10,80,100')
xlabel('time (s)')
title('Signals to analyze')
xlim([-.1 .1])
subplot(2,1,2)
plot(f,abs(W1),f,abs(W2))
legend('w1','w2')
xlabel('frequency (Hz)')
title('Amplitude spectrum')
prepfig
h1=gcf;

%make a suite of basis functions
basisfuncs=exp(1i*2*pi*t*f');
%multiply the basis functions by the spectrum
nf=length(f);
nt=length(t);
analysis1=(ones(size(t))*(W1.')).*basisfuncs;
plotseismic(real(analysis1),t,f)
xlabel('Frequency (Hz)')
ylabel('Time (sec)')
title('Real part of the analysis for Wavelet 1')
prepfig
boldlines(gca,.5)
h2=gcf;

analysis2=(ones(size(t))*(W2.')).*basisfuncs;
plotseismic(real(analysis2),t,f)
xlabel('Frequency (Hz)')
ylabel('Time (sec)')
title('Real part of the analysis for Wavelet 2')
prepfig
boldlines(gca,.5)

figure(h2);figure(h1)