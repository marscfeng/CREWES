global SCALE_OPT CLIP
SCALE_OPT=1;
CLIP=1;
close all

pick_fb;
figure(1)
prepfig;bigfont(gca,.75,1);
print -depsc ..\intrographics\shotfb
figure(2)
prepfig;bigfont(gcf,.75,1);
print -depsc ..\intrographics\graphfb

pick_env
figure(3)
prepfig;bigfont(gca,.75,1);
print -depsc ..\intrographics\shotenv
figure(4)
prepfig;bigfont(gcf,.75,1);
print -depsc ..\intrographics\graphenv
