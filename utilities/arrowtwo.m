function h=arrowtwo(x,y,txt,kol,lw,ls,ahead,pflag)
% ARROWTWO draws a two-headed arrow with a text label in the current axes
%
% h=arrowtwo(x,y,txt,kol,lw,ls,ahead,pflag)
%
% This works well only when the x and y axes have similar numerical values.
%
% x ... length(2) vector giving the x coordinates of the base and tip of
%       the arrow.
% y ... length(2) vector giving the y coordinates of the base and tip of
%       the arrow.
% note: the text is at the center of the arrow and an attempt is made to rotated the text to
% align with the arrow. If you need to rotate the text, then use the fourth return handle to
% set the 'rotation' property of the text.
% txt ... text. Set to '' for no text.
% kol ... color of the arrow and the text
%    ******** default 'k' *******
% lw ... line width. 0.5 is normal
%    ******** default =0.5 ******
% ls ... linestyle '-' is normal
%    ******** default ='-';
% ahead ... size of arrowhead as a fraction of the length
%    ******** default = .2 *********
% pflag ... 1 means arrowhead is simple lines, 1 means it is a filled patch
%    ******** default =1 ********
%
% h = {h1,h2,h3,h4,h5,h6} cell array where h1=handle of arrow body, h2,h3,h4,h5= handles of
%       arrowheads, h6=handle of text
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
if(length(x)~=length(y))
    error('x and y must be vectors of the same length');
end
if(length(x)==2)
    %tip. Tip is at x2,y2 but x2 and y2 may be less than x1,y1.
    %make arrow of proper length along x axis from the origin. Then translate
    %and rotate
    theta=atan2(diff(y),diff(x));
    L=sqrt(diff(x)^2+diff(y)^2);
    x1p=0;x2p=L;
    y1p=0;y2p=0;
    La=ahead*L;%size of arrowhead
    %draw arrowhead at beginning of line
    x3p=x1p+La;
    y3p=y1p+La;
    x4p=x3p;
    y4p=y2p-La;
    
    xp=[x1p x2p x3p x4p];
    yp=[y1p y2p y3p y4p];
    
    %rotate
    RR=[cos(theta) -sin(theta);sin(theta) cos(theta)];
    xyp=[xp;yp];
    xy=RR*xyp;
    xy(1,:)=xy(1,:)+x(1);
    xy(2,:)=xy(2,:)+y(1);
    %draw line
    h1=line(xy(1,1:2),xy(2,1:2),'linestyle',ls,'color',kol,'linewidth',lw);%main line of arrow
    %draw arrowhead
    if(pflag==0)
        h2=line(xy(1,[1 3]),xy(2,[1 3]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
        h3=line(xy(1,[1 4]),xy(2,[1 4]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
    else
        facecolor=kol;
        h2=patch(xy(1,[1 3 4]),xy(2,[1 3 4]),kol,'facecolor',facecolor);
        h3=[];
    end
    %draw arrowhead at end of line
    x3p=x2p-La;
    y3p=y2p+La;
    x4p=x3p;
    y4p=y2p-La;
    x5p=L/2;
    y5p=0;
    xp=[x1p x2p x3p x4p x5p];
    yp=[y1p y2p y3p y4p y5p];
    %translate by adding x(1) and y(1)
    % xp=xp+x(1);
    % yp=yp+y(1);
    %rotate
    RR=[cos(theta) -sin(theta);sin(theta) cos(theta)];
    xyp=[xp;yp];
    xy=RR*xyp;
    xy(1,:)=xy(1,:)+x(1);
    xy(2,:)=xy(2,:)+y(1);
    if(pflag==0)
        h4=line(xy(1,2:3),xy(2,2:3),'linestyle',ls,'color',kol,'linewidth',lw);%tip
        h5=line(xy(1,[2 4]),xy(2,[2 4]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
    else
        facecolor=kol;
        h4=patch(xy(1,2:4),xy(2,2:4),kol,'facecolor',facecolor);
        h5=[];
    end
    if(~isempty(txt))
        thetad=theta*180/pi;
        h6=text(xy(1,5),xy(2,5),txt,'color',kol,'rotation',-thetad,'horizontalalignment','center','backgroundcolor','w');
    else
        h6=[];
    end
    
    h={h1 h2 h3 h4 h5 h6};
else
    %tip. Tip is at x(end),y(end) but these may be less than x(1),y(1).
    %make arrow of proper length along x axis from the origin. Then translate
    %and rotate.
    theta=atan2(y(2)-y(1),x(2)-x(1));
    L=sqrt((x(end)-x(1))^2+(y(end)-y(1))^2);%not true length
    x1p=0;x2p=L;
    y1p=0;y2p=0;
    La=ahead*L;%size of arrowhead
    %draw arrowhead at beginning of line
    x3p=x1p+La;
    y3p=y1p+La;
    x4p=x3p;
    y4p=y2p-La;
    
    xp=[x1p x2p x3p x4p];
    yp=[y1p y2p y3p y4p];
    
    %rotate arrowhead
    RR=[cos(theta) -sin(theta);sin(theta) cos(theta)];
    xyp=[xp;yp];
    xy=RR*xyp;
    %translate arrowhead
    xy(1,:)=xy(1,:)+x(1);
    xy(2,:)=xy(2,:)+y(1);
    %draw line
    h1=line(x,y,'linestyle',ls,'color',kol,'linewidth',lw);%main line of arrow
    %draw arrowhead
    if(pflag==0)
        h2=line(xy(1,[1 3]),xy(2,[1 3]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
        h3=line(xy(1,[1 4]),xy(2,[1 4]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
    else
        facecolor=kol;
        h2=patch(xy(1,[1 3 4]),xy(2,[1 3 4]),kol,'facecolor',facecolor);
        h3=[];
    end
    %draw arrowhead at end of line
    theta2=atan2(y(end)-y(end-1),x(end)-x(end-1));
    x2p=x(end);
    y2p=y(end);
    x1p=x2p-L;
    x3p=x2p-La;
    y3p=y2p+La;
    x4p=x3p;
    y4p=y2p-La;
    x5p=L/2;
    y5p=0;
    xp=[x1p x2p x3p x4p x5p];
    yp=[y1p y2p y3p y4p y5p];
    %translate by adding x(1) and y(1)
    % xp=xp+x(1);
    % yp=yp+y(1);
    %rotate
    RR=[cos(theta2) -sin(theta2);sin(theta2) cos(theta2)];
    xyp=[xp;yp];
    xy=RR*xyp;
    %translate
    xy(1,:)=xy(1,:)+x(1);
    xy(2,:)=xy(2,:)+y(1);
    if(pflag==0)
        h4=line(xy(1,2:3),xy(2,2:3),'linestyle',ls,'color',kol,'linewidth',lw);%tip
        h5=line(xy(1,[2 4]),xy(2,[2 4]),'linestyle',ls,'color',kol,'linewidth',lw);%tip
    else
        facecolor=kol;
        h4=patch(xy(1,2:4),xy(2,2:4),kol,'facecolor',facecolor);
        h5=[];
    end
    if(~isempty(txt))
        thetad=theta*180/pi;
        h6=text(xy(1,5),xy(2,5),txt,'color',kol,'rotation',-thetad,'horizontalalignment','center','backgroundcolor','w');
    else
        h6=[];
    end
    
    h={h1 h2 h3 h4 h5 h6};
end