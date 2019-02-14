N=128;
nu=0:N-1;
j=64;k=0:N-1;
result=zeros(1,length(k));
for m=1:length(k)
    zs=exp(1i*2*pi*nu*(j-k(m))/N);
    result(m)=sum(zs);
end
figure
subplot(2,1,1)
linesgray({k,imag(result),'-',1,.7},{k,real(result),'-',.25,0});
legend('imaginary','real')
ylabel('result')
xlabel('k')
xlim([0 130])
ylim([-10 140])
subplot(2,1,2)
linesgray({k,log10(abs(imag(result))),'-',1,.7},{k,log10(abs(real(result))),'-',.25,0});
ylabel('log10(abs(result))');
xlabel('k')
xlim([0 130])
ylim([-20 2])
grid
prepfig
bigfont(gcf,1.5,1);
print -depsc .\signalgraphics\discrete_ortho

