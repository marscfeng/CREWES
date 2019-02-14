close all
figure;

fft_speeds

legend(hh,'run times','Nlog(N)','N^2','powers of 2','location','northwest')
xlabel('signal length')
ylabel('time (s)')
xlim([50 1050])
prepfig
bigfont(gcf,1.5,1)
legendfontsize(1.5)

print -depsc .\signalgraphics\fftspeeds
