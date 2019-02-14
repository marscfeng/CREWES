ricker_example
figure
subplot(2,1,1)
plot(tw,w,'k');
xlabel('seconds')
ylabel('amplitude')
xlim([-.2 .2])

subplot(2,1,2)
plot(f,real(W),'k')
xlabel('Hertz')
ylabel('dB')
ylim([-100 0])

prepfig
bigfont(gcf,2,1)

print -depsc wavepropgraphics\ricker.eps