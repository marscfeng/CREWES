function hpan=uiscrollpanel(parent,position,innerpanelheight,scrollbarwidth)
% UISCROLLPANEL ... create a scrollable panel UI tool
%
% hpan=uiscrollpanel(parent,position,innerpanelheight,scrollbarwidth)
% 
% parent ... handle of the parent object
% position ... 4 element vector giving position of the scrollpanel in the parent object. In
%       normalized coordinates.
% innerpanelheight ... scalar giving the height of the scrolling inner panel as a multiple of the
%       height of the outer panel. Should be greater than 1.
% ************ default =4 ************
% scrollbarwidth ... width of the scrollbar as a fraction of the outer panel width
% ************ default =.05 *************
% hpan ... vector of handles. hpan(1) is the handle of the outer panel, hpan(2) is the inner panel,
%       and hpan(3) is the scrollbar.
%

if(nargin<3)
    innerpanelheight=4;
end
if(nargin<4)
    scrollbarwidth=.05;
end
sep=scrollbarwidth/5;
hpan1=uipanel(parent,'tag','outer_panel','units','normalized','position',...
        position);

hpan2=uipanel(hpan1,'tag','innerpanel','units','normalized','position',...
    [0, 1-innerpanelheight,1-scrollbarwidth-sep,innerpanelheight]);

hpan3=uicontrol(hpan1,'style','slider','tag','scrollbar','units','normalized','position',...
        [1-scrollbarwidth,0,scrollbarwidth,1],'value',1,'Callback',{@scslider,hpan2});
    
hpan=[hpan1 hpan2 hpan3];

end

function scslider(src,eventdata,arg1) %#ok<INUSL>
val = get(src,'Value');
pos=get(arg1,'position');
set(arg1,'Position',[0 (1-pos(4))*val pos(3:4)])

end