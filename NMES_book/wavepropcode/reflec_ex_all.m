reflec_example
figure(h1)
axis([0 .9 -.5 4])
prepfig
xlabel('seconds')
bigfont(gcf,1.75,1)
print -depsc wavepropgraphics\reflec.eps

figure(h2)
axis([-.4 .4 -1 9])
prepfig
xlabel('lag time (seconds)')
bigfont(gcf,1.75,1)
print -depsc wavepropgraphics\reflec_auto.eps
