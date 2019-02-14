%% deconvolve noiseless and noisy traces with common parameters
makeconvsyntheticwater

deconpr_water

names={'reflectivity (10-150 Hz)','input trace','spiking short op','spiking long op',['gapped gap=' time2str(tgap) 's'],'spiking after gapped',};


figure
fs=10;
%x0=.02;y0=.1;wid=.4;sep=.08;ht=1-2*y0;
ya='n';
bc='none';
zt=10;
x0=.75;
trplot(t,[rb,sm,smdb,smd2b,smdg,smdgdb],'normalize',1,'order','d','names',names,'fontsize',fs,...
    'color',zeros(1,6),'tracespacing',1.5,'namesalign','left','nameshift',0,'yaxis',ya,...
    'resample',3);
text(x0,2.8,zt,strm,'fontsize',fs,'backgroundcolor',bc)
text(x0,1.6,zt,strmdb,'fontsize',fs,'backgroundcolor',bc)
text(x0,.1,zt,strmd2b,'fontsize',fs,'backgroundcolor',bc)
text(x0,-1.5,zt,strmdg,'fontsize',fs,'backgroundcolor',bc)
text(x0,-3,zt,strmdgdb,'fontsize',fs,'backgroundcolor',bc)
xlim([0 3]);ylim([-3.5 6])
xtick(0:.5:2)

prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\deconprwater.eps
