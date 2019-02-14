fft_and_fftrl

figure
subplot(3,1,1);
linesgray({f2w,abs(S2w),'-',.5,0})
xlabel('frequency (Hz)')
text(5,1.5,'a)');
subplot(3,1,2)
linesgray({f2,abs(S2),'-',.5,0})
xlabel('frequency (Hz)')
text(-fnyq+5,1.5,'b)');
subplot(3,1,3)
linesgray({f,abs(S),'-',.5,0})
xlabel('frequency (Hz)')
text(5,1.5,'c)');

prepfig
bigfont(gcf,.8,1)

print -depsc ..\signalgraphics\spectra_one_two_sided

Amax=max(abs(R));

figure
subplot(2,1,1)
hh=linesgray({t,.2*s/max(s),'-',.5,0},{tr,r,'-',.5,.5},{tw,w+.2,':',.5,0});
xlabel('time (s)')
legend('seismic trace','reflectivity','wavelet','location','northeast');
subplot(2,1,2)
hh=linesgray({fr,todb(abs(R),Amax),'-',.5,.5},{f,todb(abs(S),Amax),'-',.5,0},{fw,todb(abs(W),Amax),':',.5,0});
xlabel('frequency (Hz)');ylabel('decibels')
legend('reflectivity','seismic trace','wavelet','location','southwest');

prepfig
bigfont(gcf,.8,1)

print -depsc ..\signalgraphics\spectra_w_r_s