function h=arrowm(x,y,txt,kol,lw,ls,ahead,pflag)
% ARROWM draws an arrow with a text label in the current axes
%
% h=arrowm(x,y,txt,kol,lw,ls,ahead,pflag)
%
% This works well only when the x and y axes have similar numerical values. It differs from
% arrow in the placement of the text label. arrow puts the label at the bebinning of the arrow.
% arrowm puts the label at the midpoint of the label and rotates it to align with the arrow.
%
% x ... length(2) vector giving the x coordinates of the base and tip of
%       the arrow.
% y ... length(2) vector giving the y coordinates of the base and tip of
%       the arrow.
% note: the arrowhead is at x(2),y(2) and the text is at x(1),y(1)
% txt ... text. Set to '' for no text.
% kol ... color of the arrow and the text
%    ******** default 'k' *******
% lw ... line width. 0.5 is normal
%    ******** default =0.5 ******
% ls ... linestyle '-' is normal
%    ******** default ='-';
% ahead ... size of arrowhead as a fraction of the length
%    ******** default = .2 *********
% pflag ... 0 means arrowhead is simple lines, 1 means it is a filled patch
%    ******** default =1 ********
%
% h = [h1,h2,h3,h4] where h1=handle of arrow body, h2,h3= handles of
%       arrowhead, h4=handle of text
%
%
% by G.F. Margrave, 2018
% 
% 
if(nargin<8)
    pflag=1;
end
if(nargin<7)
    ahead=.2;
end
if(nargin<6)
    ls='-';
end
if(nargin<5)
    lw=0.5;
end
if(nargin<4)
    kol='k';
end

%tip. Tip is at x2,y2 but x2 and y2 may be less than x1,y1.
%make arrow of proper length along x axis from the origin. Then rotate
%and translate
theta=atan2(diff(y),diff(x));
L=sqrt(diff(x)^2+diff(y)^2);
x1p=0;x2p=L;
y1p=0;y2p=0;
La=ahead*L;%size of arrowhead
x3p=x2p-La;
y3p=y2p+La;
x4p=x3p;
y4p=y2p-La;
xp=[x1p x2p x3p x4p];
yp=[y1p y2p y3p y4p];
%rotate
RR=[cos(theta) -sin(theta);sin(theta) cos(theta)];
xyp=[xp;yp];
xy=RR*xyp;
%translate
xy(1,:)=xy(1,:)+x(1);
xy(2,:)=xy(2,:)+y(1);
h1=line(xy(1,1:2),xy(2,1:2),'linestyle',ls,'color',kol,'linewidth',lw);%main line of arrow
if(pflag==0)
h2=line(xy(1,2:3),xy(2,2:3),'linestyle',ls,'color',kol,'linewidth',lw);%tip
h3=line(xy(1,[2 4]),xy(2,[2 4]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
else
    facecolor=kol;
    h2=patch(xy(1,2:4),xy(2,2:4),kol,'facecolor',facecolor);
    h3=[];
end
if(~isempty(txt))
    xm=mean(x);ym=mean(y);
    h4=text(xm,ym,txt,'color',kol,'rotation',180-180*theta/pi,'horizontalalignment','center');
else
    h4=[];
end

h={h1 h2 h3 h4};