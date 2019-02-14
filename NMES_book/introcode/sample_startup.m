% to use this, save it to your Matlab directory and rename it to startup.m
global SCALE_OPT GRAY_PCT NUMBER_OF_COLORS 
global CLIP COLOR_MAP NOBRIGHTEN NOSIG
global BIGFIG_X BIGFIG_Y BIGFIG_WIDTH BIGFIG_HEIGHT
%set parameters for plotimage
SCALE_OPT=2;
GRAY_PCT=20;
NUMBER_OF_COLORS=64;
CLIP=4;
COLOR_MAP='seisclrs';
NOBRIGHTEN=1;
NOSIG=1;
% set parameters for bigfig (used by prepfig)
% try to make the enlarged figure size 1100 pixels wide and 700 pixels high
scr=get(0,'screensize');
BIGFIG_X=1;
BIGFIG_Y=30;
if(scr(3)>1100)
    BIGFIG_WIDTH=1100;
else
    BIGFIG_WIDTH=scr(3)-BIGFIG_X;
end
if(scr(4)>730)
    BIGFIG_HEIGHT=700;
else
    BIGFIG_HEIGHT=scr(4)-BIGFIG_Y;
end
%
% By default, your working directory will be documents\matlab (under
% Windows) You startup.m file should reside in this directory. 
% If you wish to always begin working in another directory, for example
% \documents\matlab\work, then uncomment the following line
% cd work