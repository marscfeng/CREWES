function a=climslider(haxe,hfig,pos,N,xn)
%
% climslider(haxe,hfig,pos,N,xn)
%
% haxe ... handle of the axes to control
% hfig ... handle of the figure to put the tool in
% pos ... position in hfig (normalized) of the tool
% N,xn ... the return values from [N,xn]=hist(data(:),100)
%
% - Refresh the histogram
%       climslider('refresh',hfig,N,xn)
% here hfig is the handle of the Figure containing the slider, N and xn are the new histogram
% - Get the clim values from the slider window
%       lims=climslider('getlims',hfig)
% Again hfig is the handle of the Figure containing the slider while lims will be a length2 vector
% containing the slider limit positions (smallest first)
% - Set the clim values
%       climslider('setlims',hfig,lims)
% Arguments as in previous example

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED 

if(ischar(haxe))
    action=haxe;
else
    action='init';
end

a=[];
axsize=[.1 .3 .8 .5];

if(strcmp(action,'init'))
    hclim=findobj(hfig,'tag','clim');
    if(isempty(hclim))
        
        if(verLessThan('matlab','R2017a'))
            figure(hfig);
            hax=axes('position',axsize,'fontsize',8);
            hclim=uicontrol(hfig,'style','text','visible','off','tag','clim');
        else
            hclim=uipanel(hfig,'position',pos,'tag','clim');
            hax=axes(hclim,'position',axsize);
        end
        kol2=[1 0 0];%color of clim lines
        clim=get(haxe(1),'clim');
        %horizontal orientation
        bar(xn,N,'k');
        set(hax,'ytick',[]);ylabel('histogram');xlabel('amplitude')
        xl=get(gca,'xlim');
        xrange=xl(2)-xl(1);
        yl=get(gca,'ylim');
        line([clim(1) clim(1)],yl,'color',kol2,'buttondownfcn','climslider(''dragline'');',...
            'tag','clim1');
        line([clim(2) clim(2)],yl,'color',kol2,'buttondownfcn','climslider(''dragline'');',...
            'tag','clim2');
%         set(hax,'xlim',[min([xl(1)-.2*xrange, clim(1)-.2*xrange]) max([xl(2)+.2*xrange clim(2)+.2*xrange])]);
        set(hax,'xlim',[max([xl(1)-.2*xrange, 3*clim(1)]) min([xl(2)+.2*xrange 3*clim(2)])]);
        hax.FontSize=8;
        title('drag the red lines');
        set(hclim,'userdata',haxe);
        xn=.9;yn=.9;
        w=.1;h=.1;
        uicontrol(hfig,'style','pushbutton','string','?','units','normalized','position',[xn,yn,w,h],...
            'callback','climslider(''info'');','tag','info','backgroundcolor','y');
        set(hfig,'closerequestfcn','climslider(''close'');');
    end
    hax=findobj(hfig,'type','axes');
    axes(hax);
    climslider('setclim');
elseif(strcmp(action,'info'))
    hclim=gcf;
    hinfo=get(hclim,'userdata');
    if(isgraphics(hinfo))
        figure(hinfo)
        return;
    end
    msg={'This window enables interactive control of clipping for an image display. The histogram ',...
        'shows the distribution of amplitudes in the image and the vertical red lines show the ',...
        'current extent of the colorbar. Amplitudes between the red lines are faithfully mapped to ',...
        'color in the current colormap as displayed by the colorbar. Amplitudes outside this range ',...
        'are "clipped" meaning that they are assigned to either end of the colorbar. You can adjust ',...
        'the extent of the colorbar by clicking and dragging the red lines to new positions. ',...
        'The initial placment of the red lines, and the extent of the amplitude axis of the histogram ',...
        'are determined by the choice of a numerical clipping value displayed before choosing "graphical"',...
        'clipping. For example, if this "clip" value was 3, then the red lines are placed a +/- 3 standard ',...
        'deviations from the mean value and the axis range is triple the "clip" value. Therefore if ',...
        'you wish to drag the red lines beyond the range of the axis, first choose a larger numerical ',...
        'clip value and then choose graphical clipping. Similarly, if you need more detail in the ',...
        'central part of the histogram, then first choose a smaller clip value and the choose "graphical".'};
    pos=get(hclim,'position');
    xc=pos(1)+.5*pos(3);
    yc=pos(2)+.5*pos(4);
    w=pos(3);h=pos(4);
    hinfo=showinfo(msg,'Graphical clipping',[xc+.2*w,yc-1.2*h],[1.2*w,h],6);
    set(hclim,'userdata',hinfo);
elseif(strcmp(action,'setclim'))
    h1=findobj(gca,'tag','clim1');
    %hclim=get(gca,'parent');
    hclim=findobj(gcf,'tag','clim');
    haxe=get(hclim,'userdata');
    xx=get(h1,'xdata');
    clim1=xx(1);
%     yy=get(h1,'ydata');
%     if(diff(yy)==1)
%         clim1=xx(1);
%     else
%         clim1=yy(1);
%     end
    h2=findobj(gca,'tag','clim2');
    xx=get(h2,'xdata');
    clim2=xx(2);
%     yy=get(h2,'ydata');
%     if(diff(yy)==1)
%         clim2=xx(1);
%     else
%         clim2=yy(1);
%     end
    set(haxe,'clim',[clim1 clim2])
elseif(strcmp(action,'dragline'))
    hh=gco;
    xl=get(gca,'xlim');
    h1=findobj(gca,'tag','clim1');
    h2=findobj(gca,'tag','clim2');
    xx=get(h1,'xdata');
    clim1=xx(1);
%     yy=get(h1,'ydata');
%     if(diff(yy)==1)
%         clim1=xx(1);
%     else
%         clim1=yy(1);
%     end
    xx=get(h2,'xdata');
    clim2=xx(2);
%     yy=get(h2,'ydata');
%     if(diff(yy)==1)
%         clim2=xx(1);
%     else
%         clim2=yy(1);
%     end
    DRAGLINE_MOTION='xonly';
    if(hh==h1)
        %we are dragging h1
        DRAGLINE_XLIMS=[xl(1) clim2];
        DRAGLINE_PAIRED=h2;
    else
        %we are dragging h2
        DRAGLINE_XLIMS=[clim1 xl(2)];
        DRAGLINE_PAIRED=h1;
    end
    DRAGLINE_YLIMS=[];
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='climslider(''setclim'');';
    dragline('click')
elseif(strcmp(action,'refresh'))
    xn=N;
    N=pos;
    figure(hfig);
    hax=findobj(hfig,'type','axes');
    hbar=findobj(hax,'type','bar');
    delete(hbar);
    set(hfig,'currentaxes',hax);
    hold on
    bar(xn,N,'k');
    hold off
    hclim=findobj(gcf,'tag','clim');
    haxe=get(hclim,'userdata');%the axes under control
    clim=get(haxe(1),'clim');
    hcaxe=get(hfig,'currentaxes');
    h1=findobj(hcaxe,'tag','clim1');
    h2=findobj(hcaxe,'tag','clim2');
    y1=0;y2=sigfig(1.2*max(N),2);
    set(h1,'ydata',[y1 y2],'xdata',[clim(1) clim(1)])
    set(h2,'ydata',[y1 y2],'xdata',[clim(2) clim(2)])
    ylim([y1 y2])
    delcl=diff(clim);
    x2=max([max(xn) clim(2)+.2*delcl]);
    x1=min([min(xn) clim(1)-.2*delcl]);
%     xl=get(gca,'xlim');
%     if(clim(2)>xl(2))
%         delcl=diff(clim);
%         xl(2)=clim(2)+.2*delcl;
%     end
%     if(clim(1)<xl(1))
%         delcl=diff(clim);
%         xl(1)=clim(1)-.2*delcl;
%     end
%     delxl=diff(xl);
%     delcl=diff(clim);
%     if(delxl>2*delcl)
%         xl=[clim(1)-.2*delcl clim(2)+.2*delcl];
%     end
    xlim([x1 x2]);
elseif(strcmp(action,'getlims'))
    hcaxe=get(hfig,'currentaxes');
    h1=findobj(hcaxe,'tag','clim1');
    h2=findobj(hcaxe,'tag','clim2');
    if(isempty(h1) || isempty (h2))
        return;
    end
    xx=get(h1,'xdata');
    clim1=xx(1);
    xx=get(h2,'xdata');
    clim2=xx(2);
    a=[clim1 clim2];
elseif(strcmp(action,'setlims'))
    hcaxe=get(hfig,'currentaxes');%using second argument
    h1=findobj(hcaxe,'tag','clim1');
    h2=findobj(hcaxe,'tag','clim2');
    if(isempty(h1) || isempty (h2) || nargin~=3)
        return;
    end
    clims=pos;%third argument
    set(h1,'xdata',clims(1)*ones(1,2));
    set(h2,'xdata',clims(2)*ones(1,2));
    figure(hfig);
    climslider('setclim');
elseif(strcmp(action,'close'))
    hfig=gcf;
    ud=get(hfig,'userdata');
    if(isgraphics(ud))
        delete(ud);
    end
    delete(hfig);
end