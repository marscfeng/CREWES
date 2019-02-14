function selectedcolor=colorchooser(hfig,oldcolor,colors_inuse,transfer)
%COLORCHOOSER ... interactive GUI tool for color choice
% 
% selectedcolor=colorchooser(hfig,oldcolor,colors_inuse,transfer)
%
% hfig ... handle of existing figure that will be used to determine position. The colorchooser figure
%       will be centered over this figure. The colorchooser figure is created as not modal.
% oldcolor ... rgb triplet specifying the current color that is to be changed.
% colors_inuse ... cell array of colors that are current in use. Each entry must be an rgb triple.
%       May also be provided as an Nx3 matrix of rbg triples where N is the number of colors in use. 
% transfer ... string containing an executable Matlab command that will be evaluated when the user
%       presses 'Done' or 'Cancel'. Typically this transfers control back to the function that needs
%       the color information.
%
% When the 'Done' or 'Cancel' button is pressed, you must do the following. 
%    1) Check the 'tag' of gcbo to determine if 'Done' or 'Cancel' was pressed. That is, if
%    strcmp(get(gcbo,'tag'),'done') evaluates to 1, then 'Done' was pressed and similarly for
%    cancel. Note that the 'tag' strings are lower case.
%    2) If done was pressed, then retrieve the selected color by
%       selectedcolor=colorchooser('getresult')
%       The returned value is an rgb trple.
%    3) Delete the colorchooser figure (be sure to get the selected color before deleting the figure)
%
% Example: colorchooser(gcf,[1 0 0],{},'disp(''Color selected'')')
%       After selecting a color, press 'Done' and then type the command:
%       newcolor=colorchooser('getresult')
%
% Example2: colorchooser(gcf,[1 0 0],{[0 1 0],[0 0 1],[.3 .7 .8]},'disp(''Color selected'')')
%       After selecting a color, press 'Done' and then type the command:
%       newcolor=colorchooser('getresult')
%
% Example3: colorchooser(gcf,[1 0 0],rand(20,3),'disp(''Color selected'')')
%       After selecting a color, press 'Done' and then type the command:
%       newcolor=colorchooser('getresult')
%
% G.F. Margrave, Devon Energy, 2018
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

if(ischar(hfig))
    action=hfig;
else
    action='init';
end
if(nargout>0)
    selectedcolor=[];
end
if(strcmp(action,'init'))
   figwid=800;fight=500;
   pos=get(hfig,'position');
   xc=pos(1)+.5*pos(3);yc=pos(2)+.5*pos(4);
   pos=[xc-.5*figwid,yc-.5*fight,figwid,fight];
   hdial=figure('position',pos,'userdata',hfig,'Name','Color Chooser','numbertitle','off',...
       'menubar','none','toolbar','none');
   xnot=.05;
   xnow=xnot;ynow=.7;wid=.2;ht=.2;
   ht2=.025;
   sep=.02;
   uicontrol(hdial,'style','text','string','Old color','units','normalized',...
       'position',[xnow,ynow,wid,ht],'fontweight','bold');
   ynow=ynow-ht2;
   uicontrol(hdial,'style','text','string','','tag','oldcolor','units','normalized',...
       'position',[xnow,ynow,wid,ht],'backgroundcolor',oldcolor);
   ynow=ynow-ht-3*sep;
   uicontrol(hdial,'style','text','string','New color','units','normalized',...
       'position',[xnow,ynow,wid,ht],'fontweight','bold');
   ynow=ynow-ht2;
   uicontrol(hdial,'style','text','string','','tag','newcolor','units','normalized',...
       'position',[xnow,ynow,wid,ht],'backgroundcolor',oldcolor);
   ynow=ynow-ht-2*sep;
   ht2=.05;
   uicontrol(hdial,'style','pushbutton','string','Done','tag','done','units','normalized',...
       'position',[xnow,ynow,wid,ht2],'callback',transfer);
   ynow=ynow-ht2-sep;
   uicontrol(hdial,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
       'position',[xnow,ynow,wid,ht2],'callback',transfer);
   xnow=xnow+wid+10*sep;
   wid=1-xnow-xnot;
   ht=wid;
   ynow=1-ht-.1;
   coloraxes(hdial,[xnow,ynow,wid,ht],6,'colorchooser(''clickcolor'');',oldcolor);
   
   xspace=wid/3;
   wid=wid/12;
   ht=ynow-.15+sep;
   ynow=ynow-ht-sep;
   xnow=xnow+xspace/2-wid/2;
   ht2=.05;
   uicontrol(gcf,'style','text','string','You can also choose a color by adjusting the sliders',...
       'units','normalized','position',[xnow,ynow-2*ht2,2.2*xspace,ht2],'fontweight','bold')
   kinc=.01;
   colorscale=linspace(0,1,round(1/kinc)+1);
   ival=near(colorscale,oldcolor(1));
   val=colorscale(ival(1));
   uicontrol(hdial,'style','slider','string','Red','units','normalized','tag','red',...
       'position',[xnow,ynow,wid,ht],'max',1,'min',0,'sliderstep',[kinc 10*kinc],'callback',...
       'colorchooser(''slidecolor'');','value',val,'backgroundcolor','r');
   
   uicontrol(hdial,'style','text','string','Red','units','normalized','position',[xnow,ynow-ht2,wid,ht2]);
   xnow=xnow+xspace;
   ival=near(colorscale,oldcolor(2));
   val=colorscale(ival(1));
   uicontrol(hdial,'style','slider','string','Green','units','normalized','tag','green',...
       'position',[xnow,ynow,wid,ht],'max',1,'min',0,'sliderstep',[kinc 10*kinc],'callback',...
       'colorchooser(''slidecolor'');','value',val,'backgroundcolor','g');
   uicontrol(hdial,'style','text','string','Green','units','normalized','position',[xnow,ynow-ht2,wid,ht2]);
   xnow=xnow+xspace;
   ival=near(colorscale,oldcolor(3));
   val=colorscale(ival(1));
   uicontrol(hdial,'style','slider','string','Blue','units','normalized','tag','blue',...
       'position',[xnow,ynow,wid,ht],'max',1,'min',0,'sliderstep',[kinc 10*kinc],'callback',...
       'colorchooser(''slidecolor'');','value',val,'backgroundcolor','b');
   uicontrol(hdial,'style','text','string','Blue','units','normalized','position',[xnow,ynow-ht2,wid,ht2]);
   
   if(~isempty(colors_inuse))
      xnow=xnot+.25;
      wid=.1;ht=.05;
      ynow=.8;
      uicontrol(hdial,'style','text','string',{'Colors','in use'},'units','normalized',...
          'position',[xnow,ynow,wid,ht],'fontweight','bold')
      xc=xnow+.5*wid;%center
      ht2=.05;wid=ht;
      nkols=floor((ynow-ht-ht2)/ht2);%number that will fit in a column
      ynot=ynow-ht2;
      if(iscell(colors_inuse))
          ncin=length(colors_inuse);
      else
          ncin=size(colors_inuse,1);
      end
      if(nkols>ncin)
          xnow=xc-.5*wid;%one column centered
          ynow=ynot;
          for k=1:nkols
              if(iscell(colors_inuse))
                  cin=colors_inuse{k};
              else
                  cin=colors_inuse(k,:);
              end
              uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid,ht2],...
                  'backgroundcolor',cin);
              ynow=ynow-ht2;
              if(k==ncin)
                  break;
              end
          end
      else
          xnow=xc-wid;%two columns
          ynow=ynot;
          for k=1:nkols
              if(iscell(colors_inuse))
                  cin=colors_inuse{k};
              else
                  cin=colors_inuse(k,:);
              end
              uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid,ht2],...
                  'backgroundcolor',cin);
              ynow=ynow-ht2;
          end
          xnow=xnow+wid;
          ynow=ynot;
          for k=nkols+1:2*nkols
              if(iscell(colors_inuse))
                  cin=colors_inuse{k};
              else
                  cin=colors_inuse(k,:);
              end
              uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid,ht2],...
                  'backgroundcolor',cin);
              ynow=ynow-ht2;
              if(k==ncin)
                  break;
              end
          end
      end
      
   end
elseif(strcmp(action,'clickcolor'))
    hpatch=gcbo;
    hcax=findobj(gcf,'tag','colors');
    udat=get(hcax,'userdata');
    iselected=udat{3};
    hp=udat{4};
    set(hp(iselected),'linewidth',.5);
    iselected=find(hp==hpatch);
    set(hp(iselected),'linewidth',3)
    selectedcolor=get(hpatch,'facecolor');
    hnew=findobj(gcf,'tag','newcolor');
    set(hnew,'backgroundcolor',selectedcolor);
    hred=findobj(gcf,'tag','red');
    set(hred,'value',selectedcolor(1));
    hgreen=findobj(gcf,'tag','green');
    set(hgreen,'value',selectedcolor(2));
    hblue=findobj(gcf,'tag','blue');
    set(hblue,'value',selectedcolor(3));
    
    udat{3}=iselected;
    udat{2}=selectedcolor;
    set(hcax,'userdata',udat);
elseif(strcmp(action,'slidecolor'))
    hred=findobj(gcf,'tag','red');
    hgreen=findobj(gcf,'tag','green');
    hblue=findobj(gcf,'tag','blue');
    selectedcolor=[hred.Value hgreen.Value hblue.Value];
    hnew=findobj(gcf,'tag','newcolor');
    set(hnew,'backgroundcolor',selectedcolor);
    hcax=findobj(gcf,'tag','colors');
    udat=get(hcax,'userdata');
    hp=udat{4};
    set(hp(udat{3}),'linewidth',.5);
    kols=udat{1};
    nkols=size(kols,1);
    colordist=sum(abs(kols-selectedcolor(ones(nkols,1),:)),2);
    [selectedcolor,iselected]=min(colordist);
    udat{2}=selectedcolor;
    udat{3}=iselected;
    set(hp(iselected),'linewidth',3);
    set(hcax,'userdata',udat)
elseif(strcmp(action,'getresult'))
    hnew=findobj(gcf,'tag','newcolor');
    selectedcolor=get(hnew,'backgroundcolor');
    return;
end

end

function hcax=coloraxes(hfig,pos,nbins,callback,selectedcolor)


hcax=axes(hfig,'position',pos);

npatches=nbins^3;
r=linspace(0,1,nbins);
g=r;
b=r;

n2=ceil(sqrt(npatches));
xlim([0,1]);
ylim([0 1]);

%s=1/n2;%size of patch
x=linspace(0,1,n2+1);
y=x;
kols=zeros(npatches,3);
ipatch=0;
for k1=1:nbins
    for k2=1:nbins
        for k3=1:nbins
            ipatch=ipatch+1;
            kols(ipatch,:)=[r(k1),g(k2),b(k3)];
        end
    end
end

%locate closest kols to selected color
colordist=sum(abs(kols-selectedcolor(ones(npatches,1),:)),2);
[selectedcolor,iselected]=min(colordist);

ipatch=0;
hp=zeros(1,npatches);
for k=1:n2
    for j=1:n2
        ipatch=ipatch+1;
        hp(ipatch)=patch([x(k) x(k+1) x(k+1) x(k)],[y(j) y(j) y(j+1) y(j+1)],kols(ipatch,:),...
            'buttondownfcn',callback,'userdata',ipatch);
        if(ipatch==iselected)
            set(hp(ipatch),'linewidth',3);
        end
        if(ipatch==npatches)
            break;
        end
    end
    if(ipatch==npatches)
        break;
    end
end
set(hcax,'xtick',[],'ytick',[],'userdata',{kols,selectedcolor,iselected,hp},'tag','colors',...
    'color',.94*ones(1,3))
title('Click a color to select it')
end