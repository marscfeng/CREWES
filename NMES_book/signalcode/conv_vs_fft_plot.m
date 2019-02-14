conv_vs_fft


figure
linesgray({N,tfft,'-',.5,.7},{N,tc,'-',.5,0},{N,tc2,'-',.5,.4});
legend('fft multiplication','long convolution','short convolution','location','northwest')
xlabel('N=array length')
ylabel('time (s)')
xlim([0 1050])
prepfig
bigfont(gcf,.8,1)
legendfontsize(.8)

print -depsc ..\signalgraphics\conv_vs_fft

save conv_fft N tc tc2 tfft