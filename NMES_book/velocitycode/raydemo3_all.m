raydemo3
prepfig
axis([1000 3000 4.6 4.9])
subplot(2,1,1);bigfont(gcf,1.2,1);
axis([0 3000 0 3000])
titlefontsize(1,1)

print -depsc velocitygraphics\multiple.eps


figure(h1);
prepfig
subplot(2,1,2);bigfont(gcf,1.2,1);
axis([1000 3000 3.2 3.4])
subplot(2,1,1);bigfont(gcf,1.2,1);
axis([0 3000 0 3000])
titlefontsize(1,1)

print -depsc velocitygraphics\multimode.eps