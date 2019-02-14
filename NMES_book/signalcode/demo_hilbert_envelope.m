% before running this look at the help files for aec and hilbert
%
t=0:.001:1; %make a time axis
f=10; %we will make a 10 Hz signal
s=sin(2*pi*f*t); %10 Hz sine wave
figure
plot(t,s)
%% hilbert transform of sine and cosine
h=hilbert(s);%run hilbert
plot(t,real(h),t,imag(h))%note that the real part is s and the imaginary part is a negative cosine
c=cos(2*pi*f*t);%now try a cosine
h2=hilbert(c);
figure
plot(t,real(h2),t,imag(h2))%note that the imag part is a sine
cm90=phsrot(c,-90);%rotate the cosine by -90 degrees in phase
plot(t,real(h2),t,imag(h2),t,cm90,'r.')%so we see that the Hilbert transform is a -90 phase rotation
env=sqrt(real(h2).^2+imag(h2).^2);%the envelope is computed from h2
plot(t,real(h2),t,imag(h2),t,cm90,'r.',t,env)%note env is about 1.0. Why?
%% hilbert of a wavelet and construction of the envelope
[w,tw]=wavemin(.001,20,.2);%make a wavelet
h=hilbert(w);
figure
plot(tw,real(h),tw,imag(h))
env=abs(h);%the smart way to compute the envelope
plot(tw,real(h),tw,imag(h),tw,env)%display envelope on top of wavelet and its Hilbert transform
plot(tw,real(h),tw,imag(h),tw,env,'r',tw,-env,'r')%plot both env and -env
hold
plot(tw,phsrot(w,45),tw,phsrot(w,-70),tw,phsrot(w,120))%demonstrate that phase rotations stay inside the envelope
%%
% hilbert transform of a convolutional trace
[r,t]=reflec(1,.001);% make a reflectivity
s=convm(r,w);%a convolutional trace
env=abs(hilbert(s));%envelope the easy way
figure
plot(t,s,t,env,'r',t,-env,'r')%see how the envelope contains the trace
s2=s.*exp(-4*t);%apply some decay to the trace
figure
plot(t,s2)
env=abs(hilbert(s2));%calculate the envelope
plot(t,s2,t,env,'r',t,-env,'r')
envsmo=convz(env,ones(1,1))/1;%smooth the envelope with a 50 mil smoother
plot(t,s2,t,envsmo,'r',t,-envsmo,'r')
saec=s2./envsmo;%agc correction
subplot(2,1,2)
plot(t,saec)
title('after aec')
subplot(2,1,1)
plot(t,s2,t,envsmo,'r',t,-envsmo,'r')
title('decaying trace and it''s smoothed envelope')
