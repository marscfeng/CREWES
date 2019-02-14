%An aliasing experiment
%make a sine wave of 200 Hz sampled at 1 mil, 2 mils and 4 mils
dt=.001;%base sample rate
t1=0:dt:1;%time coordinates at 1 mil
f=200;%frequency of sine wave
s1=sin(2*pi*f*t1);%base sine wave
%sample at 2 mil
s2=s1(1:2:end);%take every other sample from base sine wave
t2=t1(1:2:end);
%sample at 4 mil
s4=s1(1:4:end);%take every 4th sample from base sine wave
t4=t1(1:4:end);
%spectra (one-sided)
[S1,f1]=fftrl(s1,t1);
[S2,f2]=fftrl(s2,t2);
[S4,f4]=fftrl(s4,t4);

% attempt recovery of the continuous signal by interpolation
% sinc function interpolation
dt2=dt/4;%we will interpolate to 0.00025s
tint=t1(1):dt2:t1(end);%we will interpolate samples at these points
s1i=interpbl(t1,s1,tint);
s2i=interpbl(t2,s2,tint);
s4i=interpbl(t4,s4,tint);