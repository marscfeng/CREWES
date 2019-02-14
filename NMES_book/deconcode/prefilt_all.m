%% deconvolve noiseless and noisy traces with common parameters
makeconvsyntheticspike

prefilt

tpre=dt*(1:length(spre))';
names={'reflectivity','trace (s)','predictable (spre)','unpredictable (sun)','unpredictable (scaled)'};

%normalize things
a=max(r)/max(s);
sa=a*s;
sprea=a*spre;
suna=sun*a;
sun2=sun*max(r)/max(sun);


figure
fs=10;
%x0=.02;y0=.1;wid=.4;sep=.08;ht=1-2*y0;
ya='n';
bc='none';
zt=10;

trplot({t t ,tpre t t},{r,sa,sprea,suna,sun2},'normalize',0,'order','d','names',names,'fontsize',fs,...
    'color',zeros(1,5),'tracespacing',1.25,'namesalign','left','nameshift',0,'yaxis',ya)
xlim([0 3])
xtick(0:.5:2)

prepfig
bigfont(gcf,1.25,1)
print -depsc decongraphics\prefilt.eps