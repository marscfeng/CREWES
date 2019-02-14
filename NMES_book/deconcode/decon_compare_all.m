%% deconvolve noiseless and noisy traces with common parameters
makeconvsyntheticspike

decon_compare

names={'rb','sdfb','sdf2b','sdwb'};

figure
fs=10;
%x0=.02;y0=.1;wid=.4;sep=.08;ht=1-2*y0;
ya='n';
bc='none';
zt=10;
trplot(t,[rb,sdf,sdf2,sdw],'normalize',1,'order','d','names',names,'fontsize',fs,...
    'color',zeros(1,4),'tracespacing',1.25,'namesalign','left','nameshift',0,'yaxis',ya)
x0=.72;
text(x0,1.2,zt,['Compare sdfb with rb: ' strfb],'fontsize',fs,'backgroundcolor',bc)
text(x0,0,zt,['Compare sdf2b with rb: ' strf2b],'fontsize',fs,'backgroundcolor',bc)
text(x0,-1.2,zt,['Compare sdw with rb: ' strwb],'fontsize',fs,'backgroundcolor',bc)
text(x0,-1.6,zt,['Compare sdw with sdf2b: ' strwf],'fontsize',fs,'backgroundcolor',bc)
xlim([0 2.5])
prepfig
bigfont(gcf,1.25,1);
print -depsc decongraphics\deconcomp.eps

% %spectral picture
% figure
% lw=[.5 1 1.2 1.5];
% gl=[0,.25,.5,.7];
% ls={':','-','-','-'};
% subplot(1,2,1)
% dbspec(t,[r s sn pad_trace(w,r)],'normoption',1,'graylevels',gl,'linewidths',lw,'linestyles',ls);
% names={'reflectivity','trace noise-free',['trace s2n=' num2str(s2n)],...
%     ['wavelet fdom=' num2str(fdom)]};
% legend(names,'location','southwest')
% title('Before deconw')
% subplot(1,2,2)
% dbspec(t,[r sd sdn],'normoption',1,'graylevels',gl(1:3),'linewidths',lw(1:3),'linestyles',ls(1:3));
% names={'reflectivity','trace noise-free',['trace s2n=' num2str(s2n)]};
% legend(names,'location','southwest')
% title('After deconw')
% prepfig
% 
% print -depsc decongraphics\deconwtest1_freq.eps