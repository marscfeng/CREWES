clear; load testtrace.mat
figure
subplot(2,1,1);plot(t,tracefar,'k');
title('1000 m offset');xlabel('seconds')
subplot(2,1,2);plot(t,tracenear,'k');
title('10 m offset');xlabel('seconds')
prepfig
bigfont(gcf,1.3,1)

print -depsc intrographics\intro3.eps

envfar = abs(hilbert(tracefar)); %compute Hilbert envelope
envnear = abs(hilbert(tracenear)); %compute Hilbert envelope
envdbfar=todb(envfar,max(envnear)); %decibel conversion
envdbnear=todb(envnear); %decibel conversion
figure
plot(t,[envdbfar envdbnear],'k');xlabel('seconds');ylabel('decibels');
grid;axis([0 3 -140 0])
prepfig
bigfont(gcf,1.3,1)
ht=text(1.2,-40,'Near trace envelope');
fs=get(ht,'fontsize');
set(ht,'fontsize',3*fs);
ht=text(1,-100,'Far trace envelope');
set(ht,'fontsize',3*fs);

print -depsc intrographics\intro3_1.eps
