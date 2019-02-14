rick_spec_ex
figure;
%plot(f,R1,f,R2,f,R3)
linesgray({f,R1},{f,R2},{f,R3});
xlabel('Hertz')
ylabel('Amplitude')
legend(['f_{dom}=' int2str(fdom1) 'Hz'],['f_{dom}=' int2str(fdom2) 'Hz'],['f_{dom}=' int2str(fdom3) 'Hz'],'location','northeast');
prepfig
bigfont(gcf,2,1)
print -depsc wavepropgraphics\rickspec.eps