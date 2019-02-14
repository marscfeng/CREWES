min_spec_ex
figure;
% plot(f,R1,f,R2,f,R3)
% hold
% plot(f,R4,'.',f,R5,'.',f,R6,'.')
linesgray({f,R1},{f,R2},{f,R3});
linesgray({f,R4,':'},{f,R5,':'},{f,R6,':'})
xlabel('Hertz')
ylabel('Amplitude')
legend(['f_{dom}=' int2str(fdom1) 'Hz, m=2'],['f_{dom}=' int2str(fdom2) 'Hz, m=2'],...
    ['f_{dom}=' int2str(fdom3) 'Hz, m=2'],['f_{dom}=' int2str(fdom1) 'Hz, m=3'],...
    ['f_{dom}=' int2str(fdom2) 'Hz, m=3'],['f_{dom}=' int2str(fdom3) 'Hz, m=3'],...
    'location','northeast');
prepfig
bigfont(gcf,2,1)
legendfontsize(1)

print -depsc wavepropgraphics\tntspec.eps