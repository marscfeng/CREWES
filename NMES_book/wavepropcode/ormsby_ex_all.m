ormsby_example
figure
subplot(2,1,1)
plot(tw,w,'k');
xlabel('seconds')
ylabel('amplitude')
%whitefig;bigfont(gca,1.8,1);
%boldlines
subplot(2,1,2)
plot(f,real(W),'k')
xlabel('Hertz')
ylabel('dB')
ylim([-100, 0])
%whitefig;bigfont(gca,1.8,1);
%boldlines
prepfig
bigfont(gcf,2,1)

print -depsc wavepropgraphics\ormsby.eps