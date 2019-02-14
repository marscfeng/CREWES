sw=convm(impulse(s),w);
swp1=conv(sw,x1);
swp1a=[0;swp1(1:length(s)-1)];
swpg=conv(sw,xg);
swpga=[zeros(ngap,1);swpg(1:length(s)-ngap)];
swd1=sw-swp1a;
swdg=sw-swpga;

names={'input wavelet','predicted gap=1','unpredicted gap=1',['predicted gap=' int2str(ngap)],['unpredicted gap=' int2str(ngap)]};
ind=near(t,1.1,1.4);
figure
trplot(t(ind),[sw(ind),swp1a(ind),swd1(ind),swpga(ind),swdg(ind)],'normalize',0,'order','d','names',names,'fontsize',fs,...
    'color',zeros(1,5),'tracespacing',1.25,'namesalign','left','nameshift',0,'yaxis',ya,...
    'resample',3);
xlim([1.1 1.5])
xtick(1.1:.05:1.35)
prepfig