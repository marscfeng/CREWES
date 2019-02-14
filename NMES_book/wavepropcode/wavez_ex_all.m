wavez_example
figure
subplot(2,1,1)
%plot(tw,w1,tw,w2+.2,tw,wr+.4);
linesgray({tw,w1,'-',1,0},{tw,w2+.2,'-',1.25,.5},{tw,wr+.4,'-',1.5,.7});
axis([-.08 .08 -.1 .6])
xlabel('seconds')
ylabel('amplitude')
legend('wavez m=2','wavez m=3','Ricker');

subplot(2,1,2)
%plot(f,real(W1),f,real(W2),f,real(Wr))
linesgray({f,real(W1),'-',1,0},{f,real(W2),'-',1.25,.5},{f,real(Wr),'-',1.5,.7});
xlabel('Hertz')
ylabel('decibels')
ylim([-80, 0])

prepfig
bigfont(gcf,1.75,1)

print -depsc wavepropgraphics\wavez.eps
