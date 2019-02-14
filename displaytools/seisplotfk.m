function datar=seisplotfk(seis,t,x,dname,fmax,gridy,gridx,spaceflag)
% SEISPLOTFK: plots a seismic gather and its fk spectrum side-by-side
%
% datar=seisplotfk(seis,t,x,dname,fmax,gridy,gridx,spaceflag)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic
% gather is plotted as an image in the left-hand-side and its f-k transform (amplitude spectrum)
% is plotted as an image in the right-hand-side. Controls are provided to adjust the clipping
% and to brighten or darken the image plots. The data should be regularly sampled in both t and
% x. This can also be used to create the 2D spatial transform of a time slice, in which case, t
% becomes y the row coordinate (usually inline) of the slice.
%
% seis ... input seismic matrix
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% x ... space coordinate vector for seis
% dname ... text string giving a name for the dataset that will annotate
%       the plots.
% ************ default dname =[] ************
% fmax ... maximum frequency to include on the frequency axis. (nan gets the default)
% ************ default = .5/(t(2)-t(1)) which is Nyquist ***********
% gridy ... grid spacing in the row direction in physical units.
% ************ default abs(t(2)-t(1)) ***********
% gridx ... grid spacing in the column direction in physical units.
% ************ default abs(x(2)-x(1)) ***********
% NOTE: gridy and gridx are useful when analyzing a time slice and the x and y coordinates are line
%       numbers. In this case the defaults for gridy and gridx will give unphysical values for
%       wavenumbers. This can be especially misleading if the x and y grid spacings are not equal
%       in physical units.
% spaceflag ... 0 means input is in (x,t) space, 1 means (x,z) space, 2 means (x,y) space, 3 means
%       (y,t) space
% ************ default 0 ***********
% 
%
% datar ... Return data which is a length 4 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the f-k axes
%           data{3} ... f coordinate vector for the spectrum
%           data{4} ... k coordinate vector for the spectrum
% These return data are provided to simplify plotting additional lines and
% text in either axes.
%
% 
% G.F. Margrave, Margrave-Geo, 2017-2019
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

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED
global NEWFIGVIS

if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match seismic');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match seismic');
    end
    fmaxfactors=[1,.5,.333,.25];%possible fmax limits as fractions of Fnyq
    if(nargin<4)
        dname=[];
    end
    if(nargin<5)
        fmax=nan;
    end
    if(nargin<6)
        gridy=abs(t(2)-t(1));
    end
    if(nargin<7)
        gridx=abs(x(2)-x(1));
    end
    if(nargin<8)
        spaceflag=0;
    end
    if(isnan(fmax))
        fmax=fmaxfactors(1)*.5/(t(2)-t(1));
    end
    fnyq=.5/gridy;
    iffactor=near(fmaxfactors*fnyq,fmax);
    fmax=fmaxfactors(iffactor)*fnyq;
    
    xwid=.35;
    yht=.75;
    xsep=.075;
    xnot=.1;
    ynot=.1;
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hax1=subplot('position',[xnot ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis);
    if(iclip==1)
        clim=[-amax amax];
    else
        clim=[am-clip*sigma am+clip*sigma];
    end
        
    imagesc(x,t,seis,clim);colormap(seisclrs)
%     brighten(.5);
    grid
%     dx=abs(x(2)-x(1));
%     dt=abs(t(2)-t(1));
    
    
    %draw bounding box
    pct=1;
    tinc=pct*(t(end)-t(1))/100;
    xinc=pct*abs(x(end)-x(1))/100;
    tmin=t(1)+tinc;
    tmax=t(end)-tinc;
    xmin=min(x)+xinc;
    xmax=max(x)-xinc;
    line([xmin xmax],[tmin tmin],'color','r','buttondownfcn','seisplotfk(''dragline'');','tag','tmin');
    line([xmin xmax],[tmax tmax],'color','r','buttondownfcn','seisplotfk(''dragline'');','tag','tmax');
    line([xmin xmin],[tmin tmax],'color','r','buttondownfcn','seisplotfk(''dragline'');','tag','xmin');
    line([xmax xmax],[tmin tmax],'color','r','buttondownfcn','seisplotfk(''dragline'');','tag','xmax');
    
    uicontrol(gcf,'style','text','string','Click and drag the red lines to define the transform region',...
        'fontsize',10,'backgroundcolor','w','units','normalized',...
        'position',[xnot+.1*xwid, .95, .8*xwid, .02],...
        'fontweight','bold','tag','instruct');
    if(length(dname)>80)
        fs=15;
    else
        fs=17;
    end
    switch spaceflag
        case 0
            ht=title({dname ,['x-t space dx=' num2str(gridx) ', dt=' num2str(gridy)]},'interpreter','none');
        case 1
            ht=title({dname ,['x-z space dx=' num2str(gridx) ', dz=' num2str(gridy)]},'interpreter','none');
        case 2
            ht=title({dname ,['x-y space dx=' num2str(gridx) ', dy=' num2str(gridy)]},'interpreter','none');
        case 3
            ht=title({dname ,['y-t space dy=' num2str(gridx) ', dt=' num2str(gridy)]},'interpreter','none');
    end
    ht.Interpreter='none';
    ht.FontSize=fs;
    maxmeters=7000;
    
    if(max(t)<10)
        ylabel('time (s)')
    elseif(max(t)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    if(max(x)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    
    %make a clip control
    pctfk=5;
    wid=.04;ht=.05;sep=.005;
%     nudge=.1*wid;
    xnow=xnot-2*wid;
    ynow=ynot+yht-ht;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clipxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfk(''clipxt'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax1,pct,pctfk,fmax,gridx,gridy,spaceflag},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,.95,.5*wid,.5*ht],'callback','seisplotfk(''info'');',...
        'backgroundcolor','y');
    ht=.5*ht;
    ynow=ynow-sep;
    uicontrol(gcf,'style','pushbutton','string','brighten','tag','brightenxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfk(''brightenxt'');',...
        'tooltipstring','push once or multiple times to brighten the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','darken','tag','darkenxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfk(''brightenxt'');',...
        'tooltipstring','push once or multiple times to darken the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','lvl 0','tag','brightnessxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','image brightness (both images)','userdata',0);
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);
    if(t(2)>t(1))
        tt=gridy*(0:length(t)-1)';
    else
        tt=gridy*(length(t)-1:-1:0)';
    end
    if(x(2)>x(1))
        xx=gridx*(0:length(x)-1);
    else
        xx=gridx*(length(x)-1:-1:0);
    end
    indx=near(x,xmin,xmax);
    indt=near(t,tmin,tmax);

    [seisfk,f,k]=fktran(seis(indt,indx),tt(indt),xx(indx),nan,nan,pctfk);
    ind=near(f,0,fmax);
    Afk=abs(seisfk(ind,:));
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(Afk);

    %clim=[amin am+clip*sigma];
    if(iclip==1)
        clim=[-amax amax];
    else
        clim=[am-clip*sigma am+clip*sigma];
    end
        
    imagesc(k,f(ind),Afk,clim);colormap(seisclrs);
%     brighten(.5);
    grid
    knyq=max(abs(k));
    fnyq=max(f);
    switch spaceflag
        case 0
            title(['kx-f space, kxnyq=' num2str(knyq) ', fnyq=' num2str(fnyq)],'interpreter','none');
            xlabel('kx wavenumber (m^{-1})');
            ylabel('frequency (Hz)');
        case 1
            title(['kx-kz space, kxnyq=' num2str(knyq) ', kznyq=' num2str(fnyq)],'interpreter','none');
            xlabel('kx wavenumber (m^{-1})');
            ylabel('kz wavenumber (m^{-1})');
        case 2
            title(['kx-ky space, kxnyq=' num2str(knyq) ', kynyq=' num2str(fnyq)],'interpreter','none');
            xlabel('kx wavenumber (m^{-1})');
            ylabel('ky wavenumber (m^{-1})');
        case 3
            title(['ky-f space, kynyq=' num2str(knyq) ', fnyq=' num2str(fnyq)],'interpreter','none');
            xlabel('ky wavenumber (m^{-1})');
            ylabel('frequency (Hz)');
    end
            
%     ytemporal=1;
%     if(max(t)<10)
%         ylabel('frequency (Hz)')
%     elseif(max(t)<maxmeters)
%         ylabel('wavenumber (m^{-1})')
%         ytemporal=0;
%     else
%         ylabel('wavenumber (ft^{-1})')
%         ytemporal=0;
%     end
%     if(ytemporal==1)
%         ht=title({'' ,['f-k space, knyq=' num2str(knyq) ', fnyq=' num2str(fnyq)]},'interpreter','none');
%     else
%         ht=title({'' ,['kx-ky space, kxnyq=' num2str(knyq) ', kynyq=' num2str(fnyq)]},'interpreter','none');
%     end
%     ht.Interpreter='none';
% 
%     if(max(x)<maxmeters)
%         xlabel('wavenumber (m^{-1})');
%     else
%         xlabel('wavenumber (ft^{-1})');
%     end
    %make a clip control
    nudge=.1*wid;
    xnow=xnot+2*xwid+xsep+nudge;
    ht=.025;
    ynow=ynot+yht-ht;
    %wid=.045;sep=.005;
    
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clipfk','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfk(''clipfk'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax2},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    ynow=ynow-ht;
%     fs=10;
    width=wid;
    ynudge=0;
    uicontrol(gcf,'style','radiobutton','string','Decibels','tag','decibels','value',0,...
        'units','normalized','position',[xnow ynow+ynudge width ht],...
        'callback','seisplotfk(''recompute'');','backgroundcolor','w');
    ynow=ynow-ht;
    uicontrol(gcf,'style','pushbutton','string','recompute','tag','recompute','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfk(''recompute'');',...
        'tooltipstring','recompute the f-k spectrum of the defined region');
    lims={'Nyq','Nyq/2','Nyq/3','Nyq/4'};
    xlimfactors=[1,.5,.333,.25]/(2*gridx);
    ylimfactors=fmaxfactors/(2*gridy);
    switch spaceflag
        case 0
            xname='kx axis lims:';
            yname='f axis lims:';
        case 1
            xname='kx axis lims:';
            yname='kz axis lims:';
        case 2
            xname='kx axis lims:';
            yname='ky axis lims:';
        case 3
            xname='ky axis lims:';
            yname='f axis lims:';
    end
    ynow=ynow-ht;
    uicontrol(gcf,'style','text','string',xname,'units','normalized','position',...
        [xnow,ynow-.25*ht,1.25*wid,ht],'backgroundcolor',.99*ones(1,3));
    uicontrol(gcf,'style','popupmenu','string',lims,'units','normalized','position',...
        [xnow+1.25*wid,ynow,wid,ht],'callback','seisplotfk(''lims'');','tag','xlim',...
        'userdata',xlimfactors);
    ynow=ynow-ht;
    uicontrol(gcf,'style','text','string',yname,'units','normalized','position',...
        [xnow,ynow-.25*ht,1.25*wid,ht],'backgroundcolor',.99*ones(1,3));
    uicontrol(gcf,'style','popupmenu','string',lims,'units','normalized','position',...
        [xnow+1.25*wid,ynow,wid,ht],'callback','seisplotfk(''lims'');','tag','ylim',...
        'userdata',ylimfactors,'value',iffactor);
        
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.2,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
    
    set(hax2,'tag','fk');
    
    switch spaceflag
        case 0
            titstr=['f-kx analysis for ' dname];
        case 1
            titstr=['kx-kz analysis for ' dname];
        case 2
            titstr=['kx-ky analysis for ' dname];
        case 3
            titstr=['f-ky analysis for ' dname];
    end
    
    set(gcf,'name',titstr,'closerequestfcn','seisplotfk(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,4);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=f(ind);
        datar{4}=k;
    end
elseif(strcmp(action,'lims'))
    hax=findobj(gcf,'tag','fk');
%     axis(hax);
    hxlim=findobj(gcf,'tag','xlim');
    hylim=findobj(gcf,'tag','ylim');
    xval=get(hxlim,'value');
    yval=get(hylim,'value');
    xlimfactors=get(hxlim,'userdata');
    ylimfactors=get(hylim,'userdata');
    hax.XLim=[-xlimfactors(xval) xlimfactors(xval)];
    hax.YLim=[0 ylimfactors(yval)];
elseif(strcmp(action,'clipxt'))
    hclip=findobj(gcf,'tag','clipxt');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
    amax=udat{4};
   % amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        clim=[-amax amax];
    else
        clip=clips(iclip);
        clim=[am-clip*sigma,am+clip*sigma];
    end
    set(hax,'clim',clim);
elseif(strcmp(action,'clipfk'))
    hclip=findobj(gcf,'tag','clipfk');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
    amax=udat{4};
    amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        %clim=[amin amax];
        if(amax~=0)
            clim=[-amax amax];
        else
            clim=[amin amax];
        end
    else
        clip=clips(iclip-1);
        clim=[am-clip*sigma,am+clip*sigma];
        %clim=[amin am+clip*sigma];
    end
    set(hax,'clim',clim);
elseif(strcmp(action,'brightenxt'))
    hbut=gcbo;
    hbright=findobj(gcf,'tag','brightenxt');
    if(hbut==hbright)
        inc=.1;
    else
        inc=-.1;
    end
    brighten(inc);
    hbrightness=findobj(gcf,'tag','brightnessxt');
    brightlvl=get(hbrightness,'userdata');
    brightlvl=brightlvl+inc;
    if(abs(brightlvl)<.01)
        brightlvl=0;
    end
    set(hbrightness,'string',['lvl ' num2str(brightlvl)],'userdata',brightlvl)
elseif(strcmp(action,'brightenfk'))
    hbut=gcbo;
    hbright=findobj(gcf,'tag','brightenfk');
    if(hbut==hbright)
        inc=.1;
    else
        inc=-.1;
    end
    brighten(inc);
    hbrightness=findobj(gcf,'tag','brightnessfk');
    brightlvl=get(hbrightness,'userdata');
    brightlvl=brightlvl+inc;
    if(abs(brightlvl)<.01)
        brightlvl=0;
    end
    set(hbrightness,'string',['lvl ' num2str(brightlvl)],'userdata',brightlvl)
elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{6};
    pct=udat{7};
    
    h1=findobj(haxe,'tag','tmin');
    yy=get(h1,'ydata');
    tmin=yy(1);
    h2=findobj(haxe,'tag','tmax');
    yy=get(h2,'ydata');
    tmax=yy(2);
    h3=findobj(haxe,'tag','xmin');
    xx=get(h3,'xdata');
    xmin=xx(1);
    h4=findobj(haxe,'tag','xmax');
    xx=get(h4,'xdata');
    xmax=xx(1);
    
    hi=findobj(haxe,'type','image');
    %seis=get(hi,'cdata');
    x=get(hi,'xdata');
    t=get(hi,'ydata');
    %dx=abs(x(2)-x(1));
    %dt=t(2)-t(1);
    xinc=pct*(max(x)-min(x))/100;
    tinc=pct*(t(end)-t(1))/100;
    Xmax=max(x)-xinc;
    Xmin=min(x)+xinc;
    Tmin=t(1)+tinc;
    Tmax=t(end)-tinc;
    tinc=.05*(Tmax-Tmin);
    xinc=.05*(Xmax-Xmin);
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on tmin
        DRAGLINE_MOTION='yonly';
        DRAGLINE_XLIMS=[Xmin Xmax];
        DRAGLINE_YLIMS=[Tmin tmax-tinc];
        DRAGLINE_PAIRED=[h1 h2];
    elseif(hnow==h2)
        %clicked on tmax
        DRAGLINE_MOTION='yonly';
        DRAGLINE_XLIMS=[Xmin Xmax];
        DRAGLINE_YLIMS=[tmin+tinc Tmax];
        DRAGLINE_PAIRED=[h1 h2];
    elseif(hnow==h3)
        %clicked on xmin
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[Xmin xmax-xinc];
        DRAGLINE_YLIMS=[Tmin Tmax];
        DRAGLINE_PAIRED=[h3 h4];
    elseif(hnow==h4)
        %clicked on xmax
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xmin+xinc Xmax];
        DRAGLINE_YLIMS=[Tmin Tmax];
        DRAGLINE_PAIRED=[h3 h4];
    end
    hrecompute=findobj(gcf,'tag','recompute');
    set(hrecompute,'backgroundcolor','y');
    dragline('click')
elseif(strcmp(action,'recompute'))
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{6};
    pctfk=udat{8};
    fmax=udat{9};
    gridx=udat{10};
    gridy=udat{11};
    h1=findobj(haxe,'tag','tmin');
    yy=get(h1,'ydata');
    tmin=yy(1);
    h2=findobj(haxe,'tag','tmax');
    yy=get(h2,'ydata');
    tmax=yy(2);
    h3=findobj(haxe,'tag','xmin');
    xx=get(h3,'xdata');
    xmin=xx(1);
    h4=findobj(haxe,'tag','xmax');
    xx=get(h4,'xdata');
    xmax=xx(1);
    
    hdb=findobj(gcf,'tag','decibels');
    db=get(hdb,'value');
    if(isempty(db))
        db=0;
    end
    
    hi=findobj(haxe,'type','image');
    seis=get(hi,'cdata');
    x=get(hi,'xdata');
    t=get(hi,'ydata');
    
    if(t(2)>t(1))
        tt=gridy*(0:length(t)-1)';
    else
        tt=gridy*(length(t)-1:-1:0)';
    end
    if(x(2)>x(1))
        xx=gridx*(0:length(x)-1);
    else
        xx=gridx*(length(x)-1:-1:0);
    end
    it=near(t,tmin,tmax);
    ix=near(x,xmin,xmax);
    [seisfk,f,k]=fktran(seis(it,ix),tt(it),xx(ix),nan,nan,pctfk);
    ind=near(f,0,fmax);
    if(db==1)
        Afk=real(todb(seisfk(ind,:)));
    else
        Afk=abs(seisfk(ind,:));
    end
    %[clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(Afk);
    hclip=findobj(gcf,'tag','clipfk');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
%     am=udat{2};
%     amax=udat{4};
%     %amin=udat{5};
%     sigma=udat{3};
    am=mean(Afk(:));
    amax=max(Afk(:));
    amin=min(Afk(:));
    sigma=std(Afk(:));
    udat{2}=am;
    udat{3}=sigma;
    udat{4}=amax;
    udat{5}=amin;
    set(hclip,'userdata',udat);
    if(iclip==1)
        %clim=[amin amax];
        if(db~=1)
            clim=[-amax amax];
        else
            clim=[amin amax];
        end
    else
        clip=clips(iclip-1);
        clim=[am-clip*sigma,am+clip*sigma];
        %clim=[amin am+clip*sigma];
    end
    haxefk=udat{6};
    axes(haxefk);
    ht=get(gca,'title');
    titstr=get(ht,'string');
    fw=get(gca,'fontweight');
    fs=get(gca,'fontsize');
    xlbl=get(get(gca,'xlabel'),'string');
    ylbl=get(get(gca,'ylabel'),'string');
    tag=get(gca,'tag');
    imagesc(k,f(ind),Afk,clim);
    set(gca,'fontweight',fw,'fontsize',fs,'tag',tag);
    xlabel(xlbl);
    ylabel(ylbl);
    grid
    title(titstr,'interpreter','none');
    if(db==1)
       pos=get(gca,'position');
       hc=colorbar;
       posc=get(hc,'position');
       set(gca,'position',pos);
       set(hc,'position',[.95 posc(2:4)])
    end
    seisplotfk('lims');
    hrecompute=findobj(gcf,'tag','recompute');
    set(hrecompute,'backgroundcolor',.94*ones(1,3));
elseif(strcmp(action,'close'))
    tmp=get(gcf,'userdata');
    if(iscell(tmp))
        hfigs=tmp{1};
    else
        hfigs=tmp;
    end
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
            delete(hfigs(k))
        end
    end
    %this last bit avoids deleting the tool figure if there is another close function to be called
    %(usually PI2D or PI3D)
    crf=get(gcf,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(gcf);
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    %see if one already exists
    udat=get(hthisfig,'userdata');
    for k=1:length(udat{1})
       if(isgraphics(udat{1}(k)))
          if(strcmp(get(udat{1}(k),'tag'),'info'))
              figure(udat{1}(k))
              return;
          end
       end
    end
    msg={['The f-k analysis tool shows the amplitude spectrum of the 2D Fourier transform of a seismic ',...
        'matrix. The left plot shows the seismic matrix and the Fourier transform is taken oven the ',...
        'region defined by the red lines. These lines can be adjusted by clicking and dragging them ',...
        'and the 2D spectrum of the newly defined region will show on the right after you push the ',...
        '"recompute" button. By default the spectrum is displayed with a linear amplitude scaled but ',...
        'a decibel scale is available by clicking the "Decibels" button. Each image plot has its own ',...
        'clipping control. ']};
    hinfo=showinfo(msg,'Instructions for f-k analysis');
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        ikill=length(udat{1});
        for k=1:length(udat{1})
           if(~isgraphics(udat{1}))
               ikill(k)=1;
           end
        end
        udat{1}(ikill)=[];
        udat{1}=[udat{1} hinfo];
    else
        udat={hinfo udat};
    end
    set(hthisfig,'userdata',udat);
end
end

function [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(data)
% data ... input data
%
% 
% clips ... determined clip levels
% clipstr ... cell array of strings for each clip level for use in popup menu
% clip ... starting clip level
% iclip ... index into clips where clip is found
% sigma ... standard deviation of data
% am ... mean of data
% amax ... max of data
% amin ... min of data

sigma=std(data(:));
am=mean(data(:));
amin=min(data(:));
amax=max(data(:));
nsigma=ceil((amax-amin)/sigma);%number of sigmas that span the data

clips=[20 15 10 8 6 4 3 2 1 .1 .01 .001 .0001]';
if(nsigma<clips(1))
    ind= clips<nsigma;
    clips=[nsigma;clips(ind)];
else
    n=floor(log10(nsigma/clips(1))/log10(2));
    newclips=zeros(n,1);
    newclips(1)=nsigma;
    for k=n:-1:2
        newclips(k)=2^(n+1-k)*clips(1);
    end
    clips=[newclips;clips];
end

clipstr=cell(size(clips));
nclips=length(clips);
clipstr{1}='none';
for k=2:nclips
    clipstr{k}=['clip= ' num2str(sigfig(clips(k),3))];
end
iclip=near(clips,3);
iclip=iclip(1);
clip=clips(iclip);

end