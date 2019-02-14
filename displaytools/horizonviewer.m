function horstruct=horizonviewer(arg1,arg2,arg3,arg4)
% NORIZONVIEWER: view and assign properties to 3D horizons
%
% horizonviewer(horstruct,x,y,transfer)
%
% HORIZONVIEWER provides a facility to view the horizons in a structure and to assign colors and
% linewidths for their display. At some future time, it may also provide the ability to edit the
% horizon values themselves. At present it can only change the fields 'colors' and 'linewidths' in
% the hoirzon structure.
%
% horstruct ... Horizon structure. THis is used by SANE and plotimage3D and has the fields:
%       horstruct.horizons ... a 3D matrix with a horizon in each slice of constant dimension 1.
%           Dimension 2 is x and dimension 3 is y.
%       horstruct.filenames ... cell array of file names indiating where the horizons came from.
%            Length of this array equals size(horstruct.horizons,1)
%       horstruct.names ... cell array of short names of the horizons.
%       horstruct.showflags ... numeric array of 1/0 flags for the horizons, indicating show or not.
%       horstruct.colors ... cell array of colors for the horizons. This is used in plotting.
%       horstruct.linewidths .. numeric array of linewidths for the horizons. This is used in
%           drawing them on screen.
% x ... x coordinate for the horizons. length(x) must equal size(horstruct.horizons,2).
% ********** default x=1:length(horstruct.horizons,2) ************
% y ... y coordinate for the horizons. length(y) must equal size(horstruct.horizons,3).
% ********** default y=1:length(horstruct.horizons,3) ************
% transfer ... String containing a valid Matlab command that will be executed when the 'Done' or
%       buttons are pressed. 
% ********** default transfer='' **************
% NOTE: Argument transfer provides a way to transfer control to a calling program once the horizon
%       view/edit has completed. When 'Done' is pressed then you must do the
%       following in your code:
%    1) Check the state of the horizonviewer to determine if 'Done' or 'Cancel' was pressed. That is,
%       if strcmp(horizonviewer('getstate'),'done') evaluates to 1, then 'Done' was pressed and
%       similarly for cancel. Note that the state strings are lower case.
%    2) If done was pressed, then retrieve the possibly altered horizon structure by
%       horstruct=horizonviewer('getresult')
%    3) Delete the horizonviewer figure
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

if(isstruct(arg1))
    horstruct=arg1;
    action='init';
elseif(ischar(arg1))
    action=arg1;
else
    error('unknown invocation');
end

if(strcmp(action,'init'))
   %arg1 in the input horizon structure
   %a horstruct has the fields
   %horstruct.horizons ... a 3D matrix with a horizon in each slice of constant dimension 1
   %horstruct.filenames ... cell array of file names indiating where the horizons came from. Length
   %            of this array equals size(horstruct.horizons,1)
   %horstruct.names ... cell array of short names of the horizons
   %horstruct.showflags ... numeric array of 1/0 flags for the horizons, indicating show or not.
   %horstruct.colors ... cell array of colors for the horizons.
   %horstruct.linewidths .. numeric array of linewidths for the horizons
   if(nargin<2)
       x=1:size(horstruct.horizons,2);
   else
       x=arg2;
   end
   if(nargin<3)
       y=1:size(horstruct.horizons,3);
   else
       y=arg3;
   end
   if(nargin<4)
       transfer='';
   else
       transfer=arg4;
   end
   hcallingfig=gcf;
   pos=get(hcallingfig,'position');%assume gcf is calling figure
   xc=pos(1)+.5*pos(3);
   yc=pos(2)+.5*pos(4);
   
   figwid=1000;
   fight=600;
   hfig=figure('position',[xc-.5*figwid,yc-.5*fight,figwid,fight],'Name','Horizon viewer',...
       'userdata',hcallingfig,'menubar','none','numbertitle','off','toolbar','figure',...
       'closerequestfcn','horizonviewer(''close'');','tag','horizonviewer');
   
      klrs=[     0       0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];%these are the default colors for an axis
   
   %check the colors field and complete if needed
   nhors=length(horstruct.names);
   for k=1:nhors
       if(isempty(horstruct.colors{k}))
           horstruct.colors{k}=klrs(cycle(k,size(klrs,1)),:);
       end
   end
   
   
   xnow=.1;ynow=.85;
   wid=.1;ht=.05;
   uicontrol(hfig,'style','popupmenu','string',horstruct.names,'tag','names','units','normalized',...
       'position',[xnow,ynow,wid,ht],'callback','horizonviewer(''switchhor'');',...
       'userdata',horstruct);
   ynow=ynow-ht;
   uicontrol(hfig,'style','radiobutton','string','Show','tag','show','units','normalized',...
       'position',[xnow,ynow,wid,ht],'callback','horizonviewer(''show'')',...
       'value',horstruct.showflags(1));

   fgc=[0 0 0];
   if(max(horstruct.colors{1}>.6))
       fgc=[1 1 1];
   end
   ynow=ynow-2*ht;
   uicontrol(hfig,'style','pushbutton','string','Color','backgroundcolor',horstruct.colors{1},...
       'tag','colors','units','normalized','position',[xnow,ynow,wid,ht],...
       'callback','horizonviewer(''colors'');','foregroundcolor',fgc);
   
   ynow=ynow-2*ht;
   uicontrol(hfig,'style','text','string','Linewidth:','units','normalized',...
       'position',[xnow,ynow,wid,ht]);
   ynow=ynow-.5*ht;
   lws=[0.5,1,1.5,2,2.5,3];
   lwsstr=num2strcell(lws);
   ilw=near(lws,horstruct.linewidths(1));
   uicontrol(hfig,'style','popupmenu','string',lwsstr,'units',...
       'normalized','position',[xnow,ynow,wid,ht],'callback','horizonviewer(''linewidth'');',...
       'tag','linewidth','userdata',lws,'value',ilw);
   ynow=ynow-ht;
   uicontrol(hfig,'style','radiobutton','string','Apply to all','value',1,'units','normalized',...
       'position',[xnow,ynow,wid,ht],'callback','horizonviewer(''linewidth'');','tag','toall');
   
   ynow=ynow-6*ht;
   uicontrol(hfig,'style','pushbutton','string','Done','tag','done','units','normalized',...
       'position',[xnow,ynow,wid,ht],'callback','horizonviewer(''done'');','userdata',transfer);
   ynow=ynow-1.5*ht;
   uicontrol(hfig,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
       'position',[xnow,ynow,wid,ht],'callback','horizonviewer(''cancel'');','userdata',transfer);
   
   xnow=xnow+2*wid;
   ynow=.2;
   axes('position',[xnow,ynow,.6,.7]);
   imagesc(x,y,squeeze(horstruct.horizons(1,:,:))');
   colorbar
   title(horstruct.names{1})
   flipy;
   
   xnow=.1;
   ynow=.09;
   uicontrol(hfig,'style','text','string','Source file:','units','normalized','position',...
       [xnow,ynow,wid,ht],'horizontalalignment','right');
   xnow=xnow+wid;
   uicontrol(hfig,'style','text','string',horstruct.filenames{1},'tag','filename',...
       'units','normalized','position',[xnow,ynow,1-xnow-.1,ht],'fontweight','bold');
   
elseif(strcmp(action,'switchhor'))
   hfig=gcf;
   hhor=findobj(hfig,'tag','names');
   ihor=get(hhor,'value');
   horstruct=get(hhor,'userdata');
   hi=findobj(hfig,'type','image');
   set(hi,'cdata',squeeze(horstruct.horizons(ihor,:,:))');
   title(horstruct.names{ihor});
   
   hshow=findobj(hfig,'tag','show');
   set(hshow,'value',horstruct.showflags(ihor));
   
   hcolor=findobj(hfig,'tag','colors');
   fgc=[0 0 0];
   if(max(horstruct.colors{ihor}>.6))
       fgc=[1 1 1];
   end
   set(hcolor,'backgroundcolor',horstruct.colors{ihor},'foregroundcolor',fgc);
   
   hlw=findobj(hfig,'tag','linewidth');
   lws=get(hlw,'userdata');
   ilw=near(lws,horstruct.linewidths(ihor));
   set(hlw,'value',ilw)
   
   hfile=findobj(gcf,'tag','filename');
   set(hfile,'string',horstruct.filenames{ihor});
   
elseif(strcmp(action,'show'))
    hn=findobj(gcf,'tag','names');
    horstruct=get(hn,'userdata');
    ihor=get(hn,'value');
    hshow=findobj(gcf,'tag','show');
    horstruct.showflags(ihor)=get(hshow,'value');
    set(hn,'userdata',horstruct);
   
elseif(strcmp(action,'colors'))
    %hc=gcbo;
    hn=findobj(gcf,'tag','names');
    horstruct=get(hn,'userdata');
    ihor=get(hn,'value');
    %newcolor=uisetcolor(horstruct.colors{ihor});
    colorchooser(gcf,horstruct.colors{ihor},horstruct.colors,'horizonviewer(''colors2'');');
    return;
elseif(strcmp(action,'colors2'))
    %check done or cancel
    if(strcmp(get(gcbo,'tag'),'cancel'))
        delete(gcf);
        return;
    end
    newcolor=colorchooser('getresult');
    delete(gcf);
    hv=findobj(0,'name','Horizon viewer');
    figure(hv);
    hn=findobj(hv,'tag','names');
    horstruct=get(hn,'userdata');
    ihor=get(hn,'value');
    hc=findobj(hv,'tag','colors');
    fgc=[0 0 0];
    if(max(newcolor>.6))
        fgc=[1 1 1];
    end
    set(hc,'backgroundcolor',newcolor,'foregroundcolor',fgc);
    horstruct.colors{ihor}=newcolor;
    set(hn,'userdata',horstruct);
elseif(strcmp(action,'linewidth'))
    hlw=findobj(gcf,'tag','linewidth');
    htoall=findobj(gcf,'tag','toall');
    toall=get(htoall,'value');
    lws=get(hlw,'userdata');
    ilw=get(hlw,'value');
    hn=findobj(gcf,'tag','names');
    horstruct=get(hn,'userdata');
    if(toall==1)
        nhors=length(horstruct.names);
        for k=1:nhors
            horstruct.linewidths(k)=lws(ilw);
        end
    else
        ihor=get(hn,'value');
        horstruct.linewidths(ihor)=lws(ilw);
    end
    set(hn,'userdata',horstruct);
elseif(strcmp(action,'getresult'))
    hn=findobj(gcf,'tag','names');
    horstruct=get(hn,'userdata');
    return
elseif(strcmp(action,'close'))
    if(strcmp(get(gcf,'tag'),'horizonviewer'))
        reply=questdlg('Save first?','Closing Horizon Viewer','Yes','No','Yes');
        if(strcmp(reply,'Yes'))
            horizonviewer('done');
        else
            horizonviewer('cancel');
        end
    end
elseif(strcmp(action,'done'))
    hdone=findobj(gcf,'tag','done');
    transfer=get(hdone,'userdata');
    set(hdone,'userdata','done');
    eval(transfer);
elseif(strcmp(action,'cancel'))
    hdone=findobj(gcf,'tag','done');
    transfer=get(hdone,'userdata');
    set(hdone,'userdata','cancel');
    eval(transfer);
elseif(strcmp(action,'getstate'))
    hdone=findobj(gcf,'tag','done');
    tmp=get(hdone,'userdata');
    if(strcmp(tmp,'done')||strcmp(tmp,'cancel'))
        horstruct=tmp;
    else
        horstruct='working';
    end
end
