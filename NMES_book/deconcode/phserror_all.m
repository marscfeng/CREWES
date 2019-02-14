phserror

names={'reflectivity','trace','deconvolved','decon phase error'};
figure
trplot(t,[r,s,sd,sd2],'order','d','color',[0 0 0 0],'normalize',1,'names',names,...
    'namesalign','right','namesshift',-.2,'tracespacing',1.2,'fontsize',12)
xlim([0 1.1])

prepfig
bigfont(gcf,1.5,1)

print -depsc decongraphics\deconfperfecttest.eps

figure('position',[200 200 1400 1000])
W=fftshift(fft(pad_trace(w,specd)));
A=abs(W);
phi=unwrap(angle(W));
f=freqfft(t,length(specd));
subplot('position',[0.1300    0.5846    0.7750    0.3404] )
ind=1:4:512;
plot(f,real(todb(specd)-22),'k',f(ind),real(todb(1./A(ind))),'k.');
xlim([-250 250])
titlein('Amplitude spectrum');titlefontsize(1,1)
set(gca,'xticklabel','');ylabel('decibels')
legend('estimated','actual','location','southeast')

grid
subplot('position', [0.1300    0.15    0.7750    0.3404] )
plot(f,unwrap(angle(specd)),'k',f(ind),-phi(ind),'k.')
xlim([-250 250])
ytick(-pi:pi:pi)
set(gca,'yticklabel',{'- \pi','0','\pi'})
xlabel('frequency (Hz)');ylabel('radians')
titlein('Phase spectrum','t',.05);titlefontsize(1,1)
grid

whitefig
bigfont(gcf,3,1)
boldlines(gcf,5,3)
legendfontsize(1.25,gcf)
print -depsc .\decongraphics\deconfoperator.eps