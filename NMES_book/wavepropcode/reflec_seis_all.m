reflec_seis
figure
plot(t,r,'k',t,s2+.2,'k',t,s1+.4,'k')
grid
set(gca,'yticklabel','')
%axis([0 .9 -.5 4])
prepfig
xlabel('seconds')
bigfont(gcf,1.75,1)
print -depsc wavepropgraphics\reflecseis.eps

reflec_spec_all
bigfont(gcf,1.75,1)
print -depsc wavepropgraphics\reflecspec.eps