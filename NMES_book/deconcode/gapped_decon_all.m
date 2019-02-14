%% Analyze the performance of spiking and gapped decon on noiseless and noisy data
%This makes 4 consequtive figures in chapter 4. To get all four figures you must run this twice. Start with no
%open figures by "close all". On first run, uncomment line 2 in gapped_decon.m . Then on the second
%run, comment line 2.
makeconvsyntheticspike

gapped_decon

names={'reflectivity','no noise spiking',['no noise gap=' time2str(tgap) 's'],'noisy spiking',...
    ['noisy gap=' time2str(tgap) 's'],};

figure
xnot=.05;ynot=.15;sep=.025;wid=1*(1-2*xnot-sep)/2;ht=1-2*ynot;
subplot('position',[xnot,ynot,wid,ht])
fs=8;
ya='n';
bc='w';
zt=10;
x0=.75;
trplot(t,[r,sd,sdg,snd,sndg],'normalize',1,'order','d','fontsize',fs,...
    'color',zeros(1,5),'tracespacing',1.5,'namesalign','left','nameshift',0,'yaxis',ya,...
    'resample',3);
text(x0,1.9,zt,str,'fontsize',fs,'backgroundcolor',bc)
text(x0,.6,zt,strg,'fontsize',fs,'backgroundcolor',bc)
text(x0,-1.2,zt,strn,'fontsize',fs,'backgroundcolor',bc)
text(x0,-2.6,zt,strng,'fontsize',fs,'backgroundcolor',bc)
xlim([0 3]);ylim([-3 5])
xtick(0:.5:2)
title('unfiltered');titlefontsize(1,1)




subplot('position',[xnot+wid+sep,ynot,wid,ht])
ya='n';
bc='w';
zt=10;
x0=.75;
trplot(t,[rb,sdb,sdgb,sndb,sndgb],'normalize',1,'order','d','names',names,'fontsize',fs,...
    'color',zeros(1,5),'tracespacing',1.5,'nameslocation','beginning','namesalign','right','nameshift',-.2,'yaxis',ya,...
    'resample',3);
text(x0,1.9,zt,strb,'fontsize',fs,'backgroundcolor',bc)
text(x0,.6,zt,strgb,'fontsize',fs,'backgroundcolor',bc)
text(x0,-1.2,zt,strnb,'fontsize',fs,'backgroundcolor',bc)
text(x0,-2.6,zt,strngb,'fontsize',fs,'backgroundcolor',bc)
xlim([0 3]);ylim([-3 5])
xtick(0:.5:2)
title('filtered');titlefontsize(1,1)

prepfig
bigfont(gcf,1.25,1)
print(['decongraphics\gappeddecon' int2str(ngap) '.eps'],'-depsc')

sw=convm(impulse(s),w);
swp1=conv(sw,x1);
swp1a=[0;swp1(1:length(s)-1)];
swpg=conv(sw,xg);
swpga=[zeros(ngap,1);swpg(1:length(s)-ngap)];
swd1=sw-swp1a;
swdg=sw-swpga;

if(ngap==5)
    if(~exist('hw','var'))
        hw=figure;
        traces=zeros(size(t));
        gaps=zeros(1,3);
    end
    if(~isgraphics(hw))
        hw=figure;
        traces=zeros(size(t));
        gaps=zeros(1,3);
    end
    figure(hw)
    subplot('position',[xnot,ynot,wid,ht])
    names={'isolated wavelet','predicted gap=1','unpredicted gap=1',['predicted gap=' int2str(ngap)],['unpredicted gap=' int2str(ngap)]};
    ind=near(t,1.1,1.4);
    trplot(t(ind),[sw(ind),swp1a(ind),swd1(ind),swpga(ind),swdg(ind)],'normalize',0,'order','d','names',names,'fontsize',fs,...
        'color',zeros(1,5),'tracespacing',1.25,'namesalign','right','nameshift',.2,'yaxis',ya,...
        'resample',3,'zerolines','y');
    xlim([1.1 1.4])
    xtick(1.1:.05:1.35)
    set(gca,'ygrid','off');
    title(['Experiment with tgap=' time2str(tgap) 's']);titlefontsize(1,1)
    val=get(hw,'userdata');
    if(isempty(val)), val=0;end
    set(hw,'userdata',val+1);
    traces(:,1)=swd1;gaps(1)=1;
    traces(:,2)=swdg;gaps(2)=ngap;
    
else
    if(~exist('hw','var'))
        hw=figure;
        traces=zeros(size(t));
        gaps=zeros(1,3);
    end
    if(~isgraphics(hw))
        hw=figure;
        traces=zeros(size(t));
        gaps=zeros(1,3);
    end
    figure(hw);
    subplot('position',[xnot+wid+sep,ynot,wid,ht])
    names={'isolated wavelet','predicted gap=1','unpredicted gap=1',['predicted gap=' int2str(ngap)],['unpredicted gap=' int2str(ngap)]};
    ind=near(t,1.1,1.4);
    trplot(t(ind),[sw(ind),swp1a(ind),swd1(ind),swpga(ind),swdg(ind)],'normalize',0,'order','d','names',names,'fontsize',fs,...
        'color',zeros(1,5),'tracespacing',1.25,'namesalign','right','nameshift',.2,'yaxis',ya,...
        'resample',3,'zerolines','y');
    xlim([1.1 1.4])
    xtick(1.1:.05:1.35)
    set(gca,'ygrid','off');
    title(['Experiment with tgap=' time2str(tgap) 's']);titlefontsize(1,1)
    val=get(hw,'userdata');
    if(isempty(val)), val=0;end
    set(hw,'userdata',val+1);
    traces(:,3)=swdg;gaps(3)=ngap;
end
val=get(hw,'userdata');
if(val==2)
    prepfig;
    bigfont(gcf,1.25,1)
    print -depsc decongraphics\gappeddeconwavelets.eps
    
    %deconvolve traces to test minimum phaseness
    traces2=traces;
    top=.1;nop=round(top/dt);
    for k=1:3
        traces(:,k)=traces(:,k)/max(abs(traces(:,k)));
        tmp=deconw(traces(:,k),traces(:,k),nop,stab);
        tmp2=butterband(tmp,t,fmin,fmax,4,0);
        traces2(:,k)=tmp2/max((abs(tmp2)));
    end

    figure
    subplot('position',[xnot,ynot,wid,ht])
    names={'After spiking',['After gap=' int2str(gaps(2))],['After gap=' int2str(gaps(3))]};
    ind=near(t,1.1,1.4);
    trplot(t(ind),traces(ind,:),'normalize',0,'order','d','names',names,'fontsize',fs,...
        'color',zeros(1,3),'tracespacing',1.25,'namesalign','right','nameshift',.2,'yaxis',ya,...
        'resample',3,'zerolines','y');
    xlim([1.1 1.4])
    xtick(1.1:.05:1.35)
    ylim([-1.5 3.5])
    title('Before second deconvolution');titlefontsize(1,1)
    set(gca,'ygrid','off')
    subplot('position',[xnot+wid+sep,ynot,wid,ht])
    trplot(t(ind),traces2(ind,:),'normalize',0,'order','d','names',names,'fontsize',fs,...
        'color',zeros(1,3),'tracespacing',1.25,'namesalign','right','nameshift',.2,'yaxis',ya,...
        'resample',3,'zerolines','y');
    xlim([1.1 1.4])
    xtick(1.1:.05:1.35)
    ylim([-1.5 3.5])
    set(gca,'ygrid','off')
    title({'After second deconvolution',['and ' int2str(fmin) '-' int2str(fmax) ' bandpass filter']});titlefontsize(1,1)
    prepfig
    bigfont(gcf,1.25,1)
    print -depsc decongraphics\gappedwaveletstestmin.eps
end