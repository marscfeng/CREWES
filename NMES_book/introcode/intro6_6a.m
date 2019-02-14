global SCALE_OPT CLIP
load smallshot
SCALE_OPT=2;
plotimage(seis,t,x)
hax=findobj(gca,'tag','MAINAXES');
pos=get(hax,'position');
nudge=.05;
set(hax,'position',[pos(1) pos(2)+nudge pos(3) pos(4)-nudge]);
title('')
bigfont(gcf,4,1)
hideui;

print -deps .\intrographics\intro6

SCALE_OPT=1;
CLIP=1;
plotimage(seis,t,x)
hax=findobj(gca,'tag','MAINAXES');
set(hax,'position',[pos(1) pos(2)+nudge pos(3) pos(4)-nudge]);
title('')
bigfont(gcf,4,1)
hideui;

print -deps .\intrographics\intro6a