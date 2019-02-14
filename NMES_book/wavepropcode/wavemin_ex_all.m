wavemin_example
figure
subplot(2,1,1)
%plot(tw,w1,tw,w2);
linesgray({tw,w1,'-',1,0},{tw,w2,'-',1.5,.5});
xlabel('seconds')
ylabel('amplitude')
legend('m=2','m=3');

subplot(2,1,2)
%plot(f,real(W1),f,real(W2))
linesgray({f,real(W1),'-',1,0},{f,real(W2),'-',1.5,.5});
xlabel('Hertz')
ylabel('decibels')
ylim([-80, 0])
xlim([0 250])

prepfig
bigfont(gcf,1.75,1)

print -depsc wavepropgraphics\wavemin.eps
