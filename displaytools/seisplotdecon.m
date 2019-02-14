function datar=seisplotdecon(seis1,t1,x1,dname1)
% SEISPLOTDECON: Interactive deconvolution of a seismic stack or gather
%
% datar=seisplotdecon(seis,t,x,dname)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% gather is platted as an image in the left-hand-side and a deconvolved and bandpass filtered gather
% is plotted as an image in the right-hand-side. Initial display uses default parameters which will
% probably please no one. Controls are provided to adjust the deconvolution and filter and re-apply.
% The data should be regularly sampled in both t and x.
%
% seis ... seismic matrix
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
%   *********** default = 1:number_of_traces ************
% dname ... text string nameing the seismic matrix.
%   *********** default = 'Input data' **************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the input seismic axes
%           data{2} ... handle of the filter seismic axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
% 
% G.F. Margrave, Margrave-Geo, 2018
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

global DRAGLINE_MOTION DRAGLINE_XLIMS DRAGLINE_YLIMS DRAGLINE_SHOWPOSN DRAGLINE_CALLBACK DRAGLINE_MOTIONCALLBACK DRAGLINE_PAIRED %#ok<NUSED>
global DECONGATE_TOP DECONGATE_BOT DECON_OP DECON_STAB DECON_FMIN DECON_FMAX
global NEWFIGVIS
if(~ischar(seis1))
    action='init';
else
    action=seis1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(nargin<2)
        error('at least 3 inputs are required');
    end
    if(nargin<3)
        x1=1:size(seis1,2);
    end
    if(nargin<4)
        dname1='Input data';
    end
    
    x2=x1;
    t2=t1;
    dt=t1(2)-t1(1);
    fnyq=.5/dt;
    if(isempty(DECON_FMAX))
        fmax=round(.4*fnyq);
    else
        fmax=DECON_FMAX;
    end
    if(isempty(DECON_FMIN))
        fmin=5;
    else
        fmin=DECON_FMIN;
    end
    if(isempty(DECON_OP))
        top=.1;
    else
        top=DECON_OP;
    end
    if(isempty(DECON_STAB))
        stab=.001;
    else
        stab=DECON_STAB;
    end

    
    %seis2=filter_stack(seis1,t1,fmin,fmax,'method','filtf');
    %dname2=[dname1 ' filtered, fmin=' num2str(fmin) ', fmax=' num2str(fmax)];
    seis2=seis1;
    
    if(length(t1)~=size(seis1,1))
        error('time coordinate vector does not match first seismic matrix');
    end
    if(length(x1)~=size(seis1,2))
        error('space coordinate vector does not match first seismic matrix');
    end
    if(length(t2)~=size(seis2,1))
        error('time coordinate vector does not match second seismic matrix');
    end
    if(length(x2)~=size(seis2,2))
        error('space coordinate vector does not match second seismic matrix');
    end
    
    if(iscell(dname1))
        dname1=dname1{1};
    end

    xwid=.35;
    yht=.8;
    xsep=.1;
    xnot=.05;
    ynot=.1;
    

    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hax1=subplot('position',[xnot ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis1);
    clim=[am-clip*sigma am+clip*sigma];
        
    hi=imagesc(x1,t1,seis1,clim);colormap(seisclrs);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces);
    uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
    uimenu(hcm,'label','f-x phase','callback',@showfxphase);
    uimenu(hcm,'label','f-x amp','callback',@showfxamp);
    uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
    set(hi,'uicontextmenu',hcm);
    brighten(.5);
    grid
    ht=title(dname1);
    ht.Interpreter='none';
    maxmeters=7000;
    if(max(t1)<10)
        ylabel('time (s)')
    elseif(max(t1)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    xlabel('line coordinate')
    
    %draw decon gate
    tbot=nan;
    if(~isempty(DECONGATE_TOP))
        ttop=DECONGATE_TOP*ones(1,2);
        if(DECONGATE_BOT<t1(end))
            tbot=DECONGATE_BOT*ones(1,2);
        end
    end
            
    if(isnan(tbot))
        trange=t1(end)-t1(1);
        ttop=t1(1)+.25*trange*ones(1,2);
        tbot=ttop+.5*trange;
    end
    lw=.5;
    xs=[x1(1) x1(end)];
    h1=line(xs,ttop,'color','r','linestyle','-','buttondownfcn','seisplotdecon(''dragline'');','tag','ttop','linewidth',lw);
    h2=line(xs,tbot,'color','r','linestyle','--','buttondownfcn','seisplotdecon(''dragline'');','tag','tbot','linewidth',lw);
    
    legend([h1 h2],'design gate top','design gate bottom','location','southeast')
    
    %set gates to published value
    xnow=xnot+xwid;
    ynow=ynot+yht;
    wid=.055;ht=.05;sep=.005;
    uicontrol(gcf,'style','pushbutton','string','Use published gate','tag','setgate','units','normalized',...
        'position',[xnow ynow 1.5*wid .5*ht],'callback','seisplotdecon(''setgate'');',...
        'tooltipstring','Sets the decon gate to the last published value');
    
    %make a clip control
    xnow=xnot+xwid;
    ynow=ynot+yht-ht;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''clip1'')','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax1},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
     
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+2.5*ht,.5*wid,.5*ht],'callback','seisplotdecon(''info'');',...
        'backgroundcolor','y');
    
    ht=.5*ht;
    ynow=ynow-sep;
    uicontrol(gcf,'style','pushbutton','string','brighten','tag','brighten','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''brighten'')',...
        'tooltipstring','push once or multiple times to brighten the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','darken','tag','darken','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''brighten'')',...
        'tooltipstring','push once or multiple times to darken the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','lvl 0','tag','brightness','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','image brightness (both images)','userdata',0);
    
    %the hide seismic button
    xnow=xnot;
    ynow=.97;
    uicontrol(gcf,'style','pushbutton','string','Hide input','tag','hideshow','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''hideshow'');','userdata','hide');
    %the toggle button
    ynow=ynow-ht;
    uicontrol(gcf,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''toggle'');','visible','off');
    
    set(hax1,'tag','seis1');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis2);
    clim=[am-clip*sigma am+clip*sigma];
        
    imagesc(x2,t2,seis2,clim);colormap(seisclrs)
    brighten(.5);
    grid
%     dname2=dname1;
%     ht=title(dname2);
%     ht.Interpreter='none';
    
    if(max(t2)<10)
        ylabel('time (s)')
    elseif(max(t2)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('(depth (ft)')
    end
%     if(max(x2)<maxmeters)
%         xlabel('distance (m)')
%     else
%         xlabel('distance (ft)')
%     end
    xlabel('line coordinate')
    %make a clip control

    xnow=xnot+2*xwid+xsep;
    ht=.05;
    ynow=ynot+yht-ht;
    %wid=.045;sep=.005;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''clip2'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax2},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    %decon parameters
    ht=.025;
    ynow=ynow-ht-sep;
    xnow=xnow+sep;
    uicontrol(gcf,'style','text','string','Decon parameters:','units','normalized',...
        'position',[xnow,ynow,1.2*wid,ht],'tooltipstring','These are for spiking decon (Wiener, aka deconw)');
    ynow=ynow-ht-sep;
    wid=wid*.5;
    uicontrol(gcf,'style','text','string','oplen:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','decon operator length in seconds');
    uicontrol(gcf,'style','edit','string',num2str(top),'units','normalized','tag','oplen',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds between 0 and 1');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','stab:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','stability or white noise constant');
    uicontrol(gcf,'style','edit','string',num2str(stab),'units','normalized','tag','stab',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value between 0 and 1');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Apply Decon','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'callback','seisplotdecon(''applydecon'');',...
        'tooltipstring','Apply current decon and filter specs','tag','deconbutton',...
        'backgroundcolor','y');
    
    %filter parameters
    ynow=ynow-2*ht-sep;
    %xnow=xnow+sep;
    wid=wid*2;
    uicontrol(gcf,'style','text','string','Filter parameters:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','These are for a post-decon bandpass');
    ynow=ynow-ht-sep;
    wid=wid*.5;
    uicontrol(gcf,'style','text','string','Fmin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(gcf,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
     uicontrol(gcf,'style','text','string','dFmn:','units','normalized',...
        'position',[xnow+2*(wid+sep),ynow,wid,ht],'tooltipstring',...
        'This is the rolloff width on the lowend. Leave blank for the default which is .5*Fmin');
    uicontrol(gcf,'style','edit','string','','units','normalized','tag','dfmin',...
        'position',[xnow+3*(wid+sep),ynow,wid,ht],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht]);
    uicontrol(gcf,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(gcf,'style','text','string','dFmx:','units','normalized',...
        'position',[xnow+2*(wid+sep),ynow,wid,ht],'tooltipstring',...
        'This is the rolloff width on the high end. Leave blank for the default which is 10 Hz');
    uicontrol(gcf,'style','edit','string','','units','normalized','tag','dfmax',...
        'position',[xnow+3*(wid+sep),ynow,wid,ht],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    ynow=ynow-ht-sep;
    wid=0.03;
    uicontrol(gcf,'style','text','string','Phase:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Phase of post-decon filter');
    uicontrol(gcf,'style','popupmenu','string',{'zero','minimum'},'units','normalized','tag','phase',...
        'position',[xnow+wid+sep,ynow,1.3*wid,ht],'tooltipstring','Usually choose zero');
    ynow=ynow-ht-sep;
    wid=0.055;
    uicontrol(gcf,'style','pushbutton','string','Apply Filter','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''applyfilter'');',...
        'tooltipstring','Apply current filter specs','backgroundcolor','y');
    
    ynow=ynow-2*(ht+sep);
    uicontrol(gcf,'style','radiobutton','string','TE on design window','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'tooltipstring','Trace equalize over design window',...
        'tag','te','value',1);
    
    %spectra
    ynow=ynow-2*ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Show spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''spectra'');',...
        'tooltipstring','Show spectra in separate window','tag','spectra','userdata',[]);
    
    
    ynow=ynow-2*ht-sep;
     uicontrol(gcf,'style','text','string','Compute performace:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'tooltipstring','For decon only');
    ynow=ynow-ht-sep;
     uicontrol(gcf,'style','text','string','','units','normalized','tag','performance',...
        'position',[xnow,ynow,1.5*wid,ht]);
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(gcf,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplotdecon(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(gcf,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplotdecon(''equalzoom'');');
    
    %results popup
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid=pos(3);
    ht=3*ht;
    fs=14;
    uicontrol(gcf,'style','popupmenu','string','Diddley','units','normalized','tag','results',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''select'');','fontsize',fs,...
        'fontweight','bold')
    
    %delete button
    xnow=xnow+wid+sep;
    wid=.075;
    ht=ht/3;
    %userdata of the delete button is the number of the current selection
    uicontrol(gcf,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow+1.75*ht,wid,ht],'callback','seisplotdecon(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.2,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
    
    set(hax2,'tag','seis2');
    seisplotdecon('applydecon');
%     if(iscell(dname2))
%         dn2=dname2{1};
%     else
%         dn2=dname2;
%     end
    set(gcf,'name',['Spiking decon analysis for ' dname1],'closerequestfcn','seisplotdecon(''close'');',...
        'numbertitle','off','menubar','none','toolbar','figure');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
elseif(strcmp(action,'clip1'))
    hmasterfig=gcf;
    hclip=findobj(hmasterfig,'tag','clip1');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
%     amax=udat{4};
%     amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        %doing graphical
        posf=get(hmasterfig,'position');
        posc=get(hclip,'position');
        fwid=300;fht=150;
        x0=posf(1)+posc(1)*posf(3);
        y0=posf(2)+posc(2)*posf(4);
        hi=findobj(hax,'type','image');
        data=hi.CData;
        ind= data~=0;
        [N,xn]=hist(data(ind),100);
        tmp=[];
        if(length(udat)>6)
            tmp=udat{7};
        end
        if(isgraphics(tmp))
            %means a graphical widow already exists
            return;
        else
            hfig=figure('position',[x0,y0,fwid,fht],'menubar','none','toolbar','none',...
                'numbertitle','off','name','Colorbar limits chooser');
        end
        tmp=get(hmasterfig,'userdata');
        if(~iscell(tmp))
            ud{2}=tmp;
            ud{1}=hfig;%list of Figures to close if master closes
        else
            ud=tmp;
            if(ud{1}==-999.25)
                ud{1}=hfig;
            else
                ud{1}=[ud{1} hfig];
            end
        end
        set(hmasterfig,'userdata',ud);
        udat{7}=hfig;
        set(hclip,'userdata',udat);
        WinOnTop(hfig,true);
        climslider(hax,hfig,[0 0 1 1],N,xn);
    else
        if(length(udat)>6)
            if(isgraphics(udat{7}))
                close(udat{7});
            end
        end
        clip=clips(iclip);
        clim=[am-clip*sigma,am+clip*sigma];
        set(hax,'clim',clim);
    end
    
elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
    hclip=findobj(hmasterfig,'tag','clip2');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
%     amax=udat{4};
%     amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        %doing graphical
        posf=get(hmasterfig,'position');
        posc=get(hclip,'position');
        fwid=300;fht=150;
        x0=posf(1)+posc(1)*posf(3);
        y0=posf(2)+posc(2)*posf(4);
        pos=figpos_ur([x0 y0 fwid fht]);
        hi=findobj(hax,'type','image');
        data=hi.CData;
        ind= data~=0;
        [N,xn]=hist(data(ind),100);
        tmp=[];
        if(length(udat)>6)
            tmp=udat{7};
        end
        if(isgraphics(tmp))
            return;
        else
            hfig=figure('position',pos,'menubar','none','toolbar','none',...
                'numbertitle','off','name','Colorbar limits chooser');
        end
        tmp=get(hmasterfig,'userdata');
        if(~iscell(tmp))
            ud{2}=tmp;
            ud{1}=hfig;%list of Figures to close if master closes
        else
            ud=tmp;
            if(ud{1}==-999.25)
                ud{1}=hfig;
            else
                ud{1}=[ud{1} hfig];
            end
        end
        set(hmasterfig,'userdata',ud);
        udat{7}=hfig;
        set(hclip,'userdata',udat);
        WinOnTop(hfig,true);
        climslider(hax,hfig,[0 0 1 1],N,xn);
    else
        if(length(udat)>6)
            if(isgraphics(udat{7}))
                close(udat{7});
            end
        end
        clip=clips(iclip-1);
        clim=[am-clip*sigma,am+clip*sigma];
        set(hax,'clim',clim);
    end
    
    hresult=findobj(hmasterfig,'tag','results');
    results=get(hresult,'userdata');
    if(~isempty(results))
        iresult=get(hresult,'value');
        results.iclips{iresult}=iclip;
        if(iclip==1)
            lims=climslider('getlims',hfig);
            results.clims{iresult}=lims;
        else
            results.clims{iresult}=[];
        end
        set(hresult,'userdata',results)    
    end
elseif(strcmp(action,'brighten'))
    hbut=gcbo;
    hbright=findobj(gcf,'tag','brighten');
    if(hbut==hbright)
        inc=.1;
    else
        inc=-.1;
    end
    brighten(inc);
    hbrightness=findobj(gcf,'tag','brightness');
    brightlvl=get(hbrightness,'userdata');
    brightlvl=brightlvl+inc;
    if(abs(brightlvl)<.01)
        brightlvl=0;
    end
    set(hbrightness,'string',['lvl ' num2str(brightlvl)],'userdata',brightlvl)
elseif(strcmp(action,'equalzoom'))
    hbut=gcbo;
    hseis1=findobj(gcf,'tag','seis1');
    hseis2=findobj(gcf,'tag','seis2');
    tag=get(hbut,'tag');
    switch tag
        case '1like2'
            xl=get(hseis2,'xlim');
            yl=get(hseis2,'ylim');
            set(hseis1,'xlim',xl,'ylim',yl);
            
        case '2like1'
            xl=get(hseis1,'xlim');
            yl=get(hseis1,'ylim');
            set(hseis2,'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'hideshow'))
    hbut=gcbo;
    option=get(hbut,'userdata');
    hclip1=findobj(gcf,'tag','clip1');
    %     udat1=get(hclip1,'userdata');
    hax1=findobj(gcf,'tag','seis1');
    hclip2=findobj(gcf,'tag','clip2');
    %udat2=get(hclip2,'userdata');
    hax2=findobj(gcf,'tag','seis2');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    htoggle=findobj(gcf,'tag','toggle');
    hbrite=findobj(gcf,'tag','brighten');
    hdark=findobj(gcf,'tag','darken');
    hbness=findobj(gcf,'tag','brightness');
    hresults=findobj(gcf,'tag','results');
    hdelete=findobj(gcf,'tag','delete');
    hsetgate=findobj('tag','setgate');
    
    switch option
        case 'hide'
            pos1=get(hax1,'position');
            pos2=get(hax2,'position');
            x0=pos1(1);
            y0=pos1(2);
            wid=pos2(1)+pos2(3)-pos1(1);
            ht=pos1(4);
            set(hax1,'visible','off','position',[x0,y0,wid,ht]);
            set(hi1,'visible','off');
            set(hclip1,'visible','off');
            set(hax2,'position',[x0,y0,wid,ht]);
            set(htoggle,'userdata',{pos1 pos2})
            set(hbut,'string','Show input','userdata','show')
            set(htoggle,'visible','on');
            set([hbrite hdark hbness hsetgate],'visible','off');
        case 'show'
            udat=get(htoggle,'userdata');
            pos1=udat{1};
            pos2=udat{2};
            set(hax1,'visible','on','position',pos1);
            set([hi1 hclip1],'visible','on');
            set(hax2,'visible','on','position',pos2);
            set(htoggle','visible','off')
            set(hbut,'string','Hide input','userdata','hide');
            set([hi2 hclip2],'visible','on');
            set([hbrite hdark hbness hresults hdelete hsetgate],'visible','on');
    end
elseif(strcmp(action,'toggle'))
%     hclip1=findobj(gcf,'tag','clip1');
%     udat1=get(hclip1,'userdata');
    hax1=findobj(gcf,'tag','seis1');
    hclip2=findobj(gcf,'tag','clip2');
%     udat2=get(hclip2,'userdata');
    hax2=findobj(gcf,'tag','seis2');
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    
    option=get(hax1,'visible');

    hresults=findobj(gcf,'tag','results');
    hdelete=findobj(gcf,'tag','delete');
    
    switch option
        case 'off'
            %ok, turning on seismic
            set([hax1 hi1],'visible','on');
            set([hax2 hclip2 hi2],'visible','off');
            set([hresults hdelete],'visible','off');
        case 'on'
            %ok, turning off seismic
            set([hax1 hi1],'visible','off');
            set([hax2 hclip2 hi2],'visible','on');
            set([hresults hdelete],'visible','on');
    end
elseif(strcmp(action,'dragline'))
    hnow=gcbo;
%     hclipxt=findobj(gcf,'tag','clipxt');
%     udat=get(hclipxt,'userdata');
%     haxe=udat{6};
%     t1s=udat{7};
%     twins=udat{8};
%     twin=.25*min(twins);
    
    hseis1=findobj(gcf,'tag','seis1');

    h1=findobj(hseis1,'tag','ttop');
    yy=get(h1,'ydata');
    ttop=yy(1);
   
    h2=findobj(hseis1,'tag','tbot');
    yy=get(h2,'ydata');
    tbot=yy(2);

    
    hi=findobj(hseis1,'type','image');
    t=get(hi,'ydata');
    tmin=t(1);tmax=t(end);
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on ttop
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin tbot];
        DRAGLINE_PAIRED=h2;
    elseif(hnow==h2)
        %clicked on tbot
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[ttop tmax];
        DRAGLINE_PAIRED=h1;
    end
    
    dragline('click')
elseif(strcmp(action,'applydecon'))
    %plan: apply the decon parameters and update the performace label. Then put the result in
    %userdata of the decon button and call 'apply filter'. Apply filter will produce the label and
    %the saved result. The most-recent decon without a filter remains in the button's user data so
    %that a different filter can be applied. Save results will always have both decon and filter
    hseis1=findobj(gcf,'tag','seis1');
    hi=findobj(hseis1,'type','image');
    seis=get(hi,'cdata');
    t=get(hi,'ydata');
    %get the design gate
    htop=findobj(hseis1,'tag','ttop');
    yy=get(htop,'ydata');
    ttop=yy(1);
    hbot=findobj(hseis1,'tag','tbot');
    yy=get(hbot,'ydata');
    tbot=yy(1);
%     idesign=near(t,ttop,tbot);
    %get the operator length 
    hop=findobj(gcf,'tag','oplen');
    val=get(hop,'string');
    top=str2double(val);
    if(isnan(top))
        msgbox('oplen is not recognized as a number','Oh oh ...');
        return;
    end
    if(top<0 || top>1)
        msgbox('oplen is unreasonable, enter a value in seconds');
        return;
    end
    %get the stab 
    hstab=findobj(gcf,'tag','stab');
    val=get(hstab,'string');
    stab=str2double(val);
    if(isnan(stab))
        msgbox('stab is not recognized as a number','Oh oh ...');
        return;
    end
    if(stab<0 || stab>1)
        msgbox('stab is unreasonable, enter a value between 0 and 1');
        return;
    end
    %deconvolve
    t1=clock;
    seisd=deconw_stack(seis,t,0,ttop,tbot,1,top,stab);
    DECONGATE_TOP=ttop;
    DECONGATE_BOT=tbot;
    DECON_OP=top;
    DECON_STAB=stab;
    t2=clock;
    timepertrace=round(100000*etime(t2,t1)/size(seis,2))/1000;
    hperf=findobj(gcf,'tag','performance');
    set(hperf,'string',[num2str(timepertrace) ' ms/trace'])
    hdbut=findobj(gcf,'tag','deconbutton');
    set(hdbut,'userdata',{seisd,ttop,tbot,top,stab});
    seisplotdecon('applyfilter');
elseif(strcmp(action,'applyfilter'))
    hdbut=findobj(gcf,'tag','deconbutton');
    udat=get(hdbut,'userdata');
    seisd=udat{1};
    ttop=udat{2};
    tbot=udat{3};
    top=udat{4};
    stab=udat{5};
    hseis2=findobj(gcf,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    t=get(hi,'ydata');
    fnyq=.5/(t(2)-t(1));
    hobj=findobj(gcf,'tag','fmin');
    val=get(hobj,'string');
    fmin=str2double(val);
    if(isnan(fmin))
        msgbox('Fmin is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmin<0 || fmin>fnyq)
        msgbox(['Fmin must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    hobj=findobj(gcf,'tag','dfmin');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmin=str2double(val);
        if(isnan(dfmin))
            msgbox('dFmin is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmin<0 || dfmin>fmin)
            msgbox(['dFmin must be greater than 0 and less than ' num2str(fmin)],'Oh oh ...');
            return;
        end
    else
        dfmin=.5*fmin;
    end
    hobj=findobj(gcf,'tag','fmax');
    val=get(hobj,'string');
    fmax=str2double(val);
    if(isnan(fmax))
        msgbox('Fmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(fmax<0 || fmax>fnyq)
        msgbox(['Fmax must be greater than 0 and less than ' num2str(fnyq)],'Oh oh ...');
        return;
    end
    if(fmax<=fmin && fmax~=0)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    hobj=findobj(gcf,'tag','dfmax');
    val=get(hobj,'string');
    if(~isempty(val))
        dfmax=str2double(val);
        if(isnan(dfmax))
            msgbox('dFmax is not recognized as a number','Oh oh ...');
            return;
        end
        if(dfmax<0 || dfmax>fnyq-fmax)
            msgbox(['dFmax must be greater than 0 and less than ' num2str(fnyq-fmax)],'Oh oh ...');
            return;
        end
    else
        dfmax=10;
    end
    hobj=findobj(gcf,'tag','phase');
    ival=get(hobj,'value');
    phase=ival-1;
    hobj=findobj(gcf,'tag','te');
    teflag=get(hobj,'value');
    
    seis2=filter_stack(seisd,t,fmin,fmax,'method','filtf','phase',phase,'dflow',dfmin,'dfhigh',dfmax);
    if(teflag==1)
        %trace equalize design window
        ntr=size(seis2,2);
        anom=zeros(1,ntr);
        for k=1:ntr
            tmp=seis2(:,k);
            idesign=near(t,ttop,tbot);
            anom(k)=norm(tmp(idesign));
        end
        ilive= anom~=0;
        a0=mean(anom(ilive));
        for k=1:ntr
            if(anom(k)~=0)
                seis2(:,k)=seis2(:,k)*a0/anom(k);
            end
        end
    end

    DECON_FMIN=fmin;
    DECON_FMAX=fmax;
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces);
    uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
    uimenu(hcm,'label','f-x phase','callback',@showfxphase);
    uimenu(hcm,'label','f-x amp','callback',@showfxamp);
    uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
    set(hi,'cdata',seis2,'uicontextmenu',hcm);
    axes(hseis2);
    dname=['Decon oplen=' num2str(top) ', stab=' num2str(stab) ', gate ' time2str(ttop) '-' time2str(tbot)];
    name=[dname ', & [' num2str(fmin) ',' num2str(dfmin) ']-[' num2str(fmax) ',' num2str(dfmax) '] filter'];
    %update clipping
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis2);
    clim=[am-clip*sigma am+clip*sigma];
    hclip2=findobj(gcf,'tag','clip2');
    set(hclip2,'string',clipstr','value',iclip,'userdata',{clips,am,sigma,amax,amin,hseis2});
    set(hseis2,'clim',clim);
    seisplotdecon('clip2');
    %save the results and update hresults
    hresults=findobj(gcf,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.data={seis2};
        results.datanf={seisd};
        results.top={top};
        results.ttop={ttop};
        results.tbot={tbot};
        results.stab={stab};
        results.fmins={fmin};
        results.dfmins={dfmin};
        results.fmaxs={fmax};
        results.dfmaxs={dfmax};
        results.phases={phase};
        results.iclips={iclip};
        results.clims={};
        results.teflag={teflag};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.data{nresults}=seis2;
        results.datanf{nresults}=seisd;
        results.top{nresults}=top;
        results.ttop{nresults}=ttop;
        results.tbot{nresults}=tbot;
        results.stab{nresults}=stab;
        results.fmins{nresults}=fmin;
        results.dfmins{nresults}=dfmin;
        results.fmaxs{nresults}=fmax;
        results.dfmaxs{nresults}=dfmax;
        results.phases{nresults}=phase;
        results.iclips{nresults}=iclip;
        results.clims{nresults}=[];
        results.teflag{nresults}=teflag;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    %update the userdata of hdelete
    hdelete=findobj(gcf,'tag','delete');
    set(hdelete,'userdata',nresults);
    
    %see if spectra window is open
    hspec=findobj(gcf,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotdecon('spectra');
    end
    
elseif(strcmp(action,'spectra'))
    hfig=gcf;
    name=get(hfig,'name');
    ind=strfind(name,'Spectral display');
    if(isempty(ind)) %#ok<STREMP>
        hmaster=hfig;
    else
        hmaster=get(hfig,'userdata');
    end
    hseis1=findobj(hmaster,'tag','seis1');
    hseis2=findobj(hmaster,'tag','seis2');
    hi=findobj(hseis1,'type','image');
    seis1=get(hi,'cdata');
    hi=findobj(hseis2,'type','image');
    seis2=get(hi,'cdata');
    t=get(hi,'ydata');
    hspec=findobj(hmaster,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isempty(hspecwin))
        %make the spectral window if it does not already exist
        pos=get(hmaster,'position');
        wid=pos(3)*.5;ht=pos(4)*.5;
        x0=pos(1)+pos(3)-wid;y0=pos(2);
        hspecwin=figure('position',[x0,y0,wid,ht],'closerequestfcn','seisplotdecon(''closespec'');','userdata',hmaster);
        set(hspecwin,'name','Spectral display window')
        
        whitefig;
        x0=.1;y0=.1;awid=.7;aht=.8;
        subplot('position',[x0,y0,awid,aht]);
        sep=.01;
        ht=.05;wid=.075;
        ynow=y0+aht-ht;
        xnow=x0+awid+sep;
        uicontrol(gcf,'style','text','string','tmin:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        ntimes=10;
        tinc=round(10*(t(end)-t(1))/ntimes)/10;
        %times=[fliplr(0:-tinc:t(1)) tinc:tinc:t(end)-tinc];
        times=t(1):tinc:t(end)-tinc;
        %times=t(1):tinc:t(end)-tinc;
        stimes=num2strcell(times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmin',...
            'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''spectra'');','userdata',times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','text','string','tmax:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        times=t(end):-tinc:tinc;
        stimes=num2strcell(times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmax',...
            'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''spectra'');','userdata',times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','text','string','db range:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        db=-20:-20:-160;
        idb=near(db,-100);
        dbs=num2strcell(db);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','popupmenu','string',dbs,'units','normalized','tag','db','value',idb,...
            'position',[xnow,ynow,wid,ht],'callback','seisplotdecon(''spectra'');','userdata',db);
        set(hspec,'userdata',hspecwin);
    else
        figure(hspecwin);
    end
    htmin=findobj(gcf,'tag','tmin');
    times=get(htmin,'userdata');
    it=get(htmin,'value');
    tmin=times(it);
    htmax=findobj(gcf,'tag','tmax');
    times=get(htmax,'userdata');
    it=get(htmax,'value');
    tmax=times(it);
    if(tmin>=tmax)
        return;
    end
    ind=near(t,tmin,tmax);
    hdb=findobj(gcf,'tag','db');
    db=get(hdb,'userdata');
    dbmin=db(get(hdb,'value'));
    pct=10;
    if(length(ind)<10)
        return;
    end
    [S1,f]=fftrl(seis1(ind,:),t(ind),pct);
    S2=fftrl(seis2(ind,:),t(ind),pct);
    A1=mean(abs(S1),2);
    A2=mean(abs(S2),2);
    hh=plot(f,todb(A1),f,todb(A2));
    set(hh,'linewidth',2)
    xlabel('Frequency (Hz)')
    ylabel('decibels');
    ylim([dbmin 0])
    grid on
    legend('Input','Decon+filter'); 
    title(['Average ampltude spectra, tmin=' time2str(tmin) ', tmax=' time2str(tmax)]);
elseif(strcmp(action,'closespec'))
    hfig=gcf;
    hdaddy=get(hfig,'userdata');
    hspec=findobj(hdaddy,'tag','spectra');
    set(hspec,'userdata',[]);
    delete(hfig);
    if(isgraphics(hdaddy))
        figure(hdaddy);
    end
elseif(strcmp(action,'select'))
    hfig=gcf;
    hdelete=findobj(gcf,'tag','delete');%this has the previous selection
    iprev=get(hdelete,'userdata');
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');%the new selection
    hseis2=findobj(hfig,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    set(hi,'cdata',results.data{iresult});
    hop=findobj(hfig,'tag','oplen');
    set(hop,'string',num2str(results.top{iresult}));
    hstab=findobj(hfig,'tag','stab');
    set(hstab,'string',num2str(results.stab{iresult}));
    httop=findobj(hfig,'tag','ttop');
    set(httop,'ydata',ones(1,2)*results.ttop{iresult});
    htbot=findobj(hfig,'tag','tbot');
    set(htbot,'ydata',ones(1,2)*results.tbot{iresult});
    hfmin=findobj(hfig,'tag','fmin');
    set(hfmin,'string',num2str(results.fmins{iresult}));
    hdfmin=findobj(hfig,'tag','dfmin');
    set(hdfmin,'string',num2str(results.dfmins{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    hdfmax=findobj(hfig,'tag','dfmax');
    set(hdfmax,'string',num2str(results.dfmaxs{iresult}));
    hphase=findobj(hfig,'tag','phase');
    set(hphase,'value',results.phases{iresult}+1);
    hteflag=findobj(hfig,'tag','te');
    set(hteflag,'value',results.teflag{iresult});
    set(hdelete,'userdata',iresult);
    %load up decon button. This is needed so that a filter gets applied to the right result
    hdbut=findobj(gcf,'tag','deconbutton');
    set(hdbut,'userdata',{results.datanf{iresult},results.ttop{iresult},results.tbot{iresult},...
        results.top{iresult},results.stab{iresult}});
    %Check for an existing graphical window from the previous selection
    if(results.iclips{iprev}==1)%will only be true if the previous selection had a graphical window
       hclip2=findobj(gcf,'tag','clip2');
       udat=get(hclip2,'userdata');
       hprevax=udat{6};
       hprevclim=udat{7};
       if(isgraphics(hprevclim))
           lims=climslider('getlims',hprevclim);
           close(hprevclim);
       else
           lims=get(hprevax,'clim');
       end
       results.clims{iprev}=lims;
       udat{7}=[];
       set(hclip2,'userdata',udat);
    end
    %update clipping
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(results.data{iresult}); %#ok<ASGLU>
    iclip=results.iclips{iresult};
    hclip2=findobj(gcf,'tag','clip2');
    set(hclip2,'string',clipstr','value',results.iclips{iresult},'userdata',{clips,am,sigma,amax,amin,hseis2});
    seisplotdecon('clip2');
    if(iclip==1)
        hclipfig=gcf;
        climslider('setlims',hclipfig,results.clims{iresult});
    end
    %see if spectra window is open
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        seisplotdecon('spectra');
    end
    set(hresults,'userdata',results);
elseif(strcmp(action,'delete'))
    hfig=gcf;
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    if(length(results.names)==1)
        msgbox('You cannot delete the only result!');
        return;
    end
    iresult=get(hresults,'value');
    fn=fieldnames(results);
    for k=1:length(fn)
        results.(fn{k})(iresult)=[];
    end
    iresult=iresult-1;
    if(iresult<1); iresult=1; end
    set(hresults,'string',results.names,'value',iresult,'userdata',results);
    seisplotdecon('select');
elseif(strcmp(action,'setgate'))
    if(isempty(DECONGATE_TOP))
        return
    end
    ttop=DECONGATE_TOP;
    tbot=DECONGATE_BOT;
    %set the design gate
    hseis1=findobj(gcf,'tag','seis1');
    htop=findobj(hseis1,'tag','ttop');
    set(htop,'ydata',ttop*ones(1,2));
    hbot=findobj(hseis1,'tag','tbot');
    set(hbot,'ydata',tbot*ones(1,2));
elseif(strcmp(action,'close'))
    hspec=findobj(gcf,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    if(isgraphics(hspecwin))
        delete(hspecwin);
    end
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
    hclip=findobj(gcf,'tag','clip1');
    ud=get(hclip,'userdata');
    if(length(ud)>6)
        if(isgraphics(ud{7}))
            close(ud{7});
        end
    end
    hclip=findobj(gcf,'tag','clip2');
    ud=get(hclip,'userdata');
    if(length(ud)>6)
        if(isgraphics(ud{7}))
            close(ud{7});
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
    msg={['The axes at left (the input axes) shows the input sesimic and the axes at right ',...
        '(decon axes) shows the result of the application of spiking (Wiener) decon. To the right of the ',...
        'decon axes are controls for the deconvolution and the post-decon filter. Each unique ',...
        'decon/filter application is considered a "result". The tool remembers your results and ',...
        'any number of results can be computed. Above the decon axes is a popup menu used to ',...
        'select a result for viewing. Each new computation adds another entry to this menu. ',...
        'The horizontal red lines in the imput axes denote the decon design window which is the time ',...
        'zone over which the decon operator will be designed. This window is the same for all traces ',...
        'and the operator, once designed, is applied to the entire trace. Thus each trace gets a ',...
        'unique decon operator designed in this window. Each time a deconvolution is run, the design ',...
        'window is "published" meaning its start and end times are placed where other tools can pick them ',...
        'up. So, if you have several deconvolution tools running, you can transfer the design window ',...
        'from one to the other by pushing the button "Use published gate" in the receiving window. ',...
        'Just to the right of each axes '...
        'are clipping controls for the displays. Smaller clip numbers mean greater clipping. ',...
        'The deconvolution parameters and the filter parameters each have a short description that will appear ',...
        'if you hover the pointer over the parameter name. Note that all "time" values must be ',...
        'specified in seconds, not milliseconds. After you have run a deconvolution, you can apply a ',...
        'different filter without re-running the decon. Just change the filter parameters and click ',...
        '"Apply Filter". The filter is always applied to the (unfiltered) deconvolution result being displayed. ',...
        'The "Show spectra" button allows comparison of spectra before and after ',...
        'deconvolution. Spectra are averages taken over the application window.']};
    hinfo=showinfo(msg,'Instructions for Spiking (Wiener) Decon');
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

function show2dspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
dx=abs(x(2)-x(1));
dt=abs(t(2)-t(1));
fmax=.5/(t(2)-t(1));
haxe=get(hi,'parent');
hresults=findobj(gcf,'tag','results');
idata=get(hresults,'value');
dnames=get(hresults,'string');
if(haxe==hseis2)
    dname=dnames{idata};
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
seisplotfk(seis,t,x,dname,fmax,dx,dt,0);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on')
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dnames{idata});
end
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
set(hfig,'userdata',{-999.25, hmasterfig});
enhancebutton(hfig,[.95,.920,.05,.025])
end

function showtvspectrum(~,~)
global NEWFIGVIS
hmasterfig=gcf;
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
%hi=findobj(hseis2,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hresults=findobj(gcf,'tag','results');
    idata=get(hresults,'value');
    dnames=get(hresults,'string');
    dname=dnames{idata};
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
seisplottvs(seis,t,x,dname,nan,nan);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    if(haxe==hseis2)
        set(hppt,'userdata',dnames{idata});
    else
        set(hppt,'userdata',dname);
    end
end
set(hfig,'visible','on');
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
set(hfig,'userdata',{-999.25, hmasterfig});
enhancebutton(hfig,[.95,.920,.05,.025])
end

function showfxamp(~,~)
global NEWFIGVIS
hmasterfig=gcf;
hseis2=findobj(hmasterfig,'tag','seis2');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
hresults=findobj(gcf,'tag','results');
    idata=get(hresults,'value');
    dnames=get(hresults,'string');
if(haxe==hseis2)
    dname=dnames{idata};
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
seisplotfx(seis,t,x,dname);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    set(hppt,'userdata',dnames{idata});
end
set(hfig,'visible','on');
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
set(hfig,'userdata',{-999.25, hmasterfig});
enhancebutton(hfig,[.95,.920,.05,.025])
end

function showfxphase(~,~)
global NEWFIGVIS
hmasterfig=gcf;
hseis2=findobj(hmasterfig,'tag','seis2');
hi=findobj(gca,'type','image');
seis=get(hi,'cdata');
x=get(hi,'xdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');
if(haxe==hseis2)
    hresults=findobj(gcf,'tag','results');
    idata=get(hresults,'value');
    dnames=get(hresults,'string');
    dname=dnames{idata};
else
    dname=haxe.Title.String;
end
NEWFIGVIS='off'; %#ok<NASGU>
seisplotfx(seis,t,x,dname,nan,nan,nan,nan,1);
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
hbrighten=findobj(hmasterfig,'tag','brighten');
hfigs=get(hbrighten,'userdata');
set(hbrighten,'userdata',[hfigs hfig]);
%determine if this is from enhance
hs=findobj(hmasterfig,'tag','fromenhance');
if(~isempty(hs))
    henhance=get(hs,'userdata');
    %the only purpose of this is to store the enhance figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromenhance','userdata',henhance);
    set(hfig,'tag','fromenhance');
    hppt=addpptbutton([.95,.95,.025,.025]);
    if(haxe==hseis2)
        set(hppt,'userdata',dnames{idata});
    else
        set(hppt,'userdata',dname);
    end
end
set(hfig,'visible','on');
%register the new figure with parent
udat=get(hmasterfig,'userdata');
if(udat{1}==-999.25)
    udat{1}=hfig;
else
    udat{1}=[udat{1} hfig];
end
set(hmasterfig,'userdata',udat);
set(hfig,'userdata',{-999.25, hmasterfig});
enhancebutton(hfig,[.95,.920,.05,.025])
end

function showtraces(~,~)
hthisfig=gcf;
fromenhance=false;
if(strcmp(get(gcf,'tag'),'fromenhance'))
    fromenhance=true;
end
hseis1=findobj(hthisfig,'tag','seis1');
%get the data
hi=findobj(gca,'type','image');
x=get(hi,'xdata');
t=get(hi,'ydata');
seis=get(hi,'cdata');

dname=get(hthisfig,'name');

ind=strfind(dname,' for ');
dname2=dname(ind(1)+5:end);

%get current point
pt=get(gca,'currentpoint');
ixnow=near(x,pt(1,1));

%determine pixels per second
un=get(gca,'units');
set(gca,'units','pixels');
pos=get(gca,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(gca,'units',un);

iuse=ixnow(1)-0:ixnow(1)+0;
% iuse=ixnow;
pos=get(hthisfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);

if(hseis1==gca)
    nametrace=[dname2 ' no decon'];
else
    nametrace=[dname2 ' after decon']; 
end

seisplottraces(double(seis(:,iuse)),t,x(iuse),nametrace,pixpersec);
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance)
    seisplottraces('addpptbutton');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
    set(hfig,'tag','fromenhance');
end

%determine if PI3D or PI2D called this decon tool
udat=get(hthisfig,'userdata');
if(length(udat)==2)
    if(isgraphics(udat{2}))
        windowentry=true;%mean it was called by PI3D or PI2D (don't care which)
        hpifig=udat{2};
    end
end

if(windowentry)
    %Make entry in windows list and set closerequestfcn
    winname='Trace Inspector';
    hwin=findobj(hpifig,'tag','windows');
    
    currentwindows=get(hwin,'string');
    if(~iscell(currentwindows))
        currentwindows={currentwindows};
    end
    %see if its already listed
    addwin=true;
    for k=1:length(currentwindows)
        if(strcmp(winname,currentwindows{k}))
            addwin=false;
        end
    end
    if(addwin)
        currentfigs=get(hwin,'userdata');
        
        nwin=length(currentwindows);
        if(nwin==1)
            if(strcmp(currentwindows{1},'None'))
                currentwindows{1}=winname;
                currentfigs(1)=hfig;
                nwin=0;
            else
                currentwindows{2}=winname;
                currentfigs(2)=hfig;
            end
        else
            currentwindows{nwin+1}=winname;
            currentfigs(nwin+1)=hfig;
        end
        set(hwin,'string',currentwindows,'value',nwin+1,'userdata',currentfigs)
    end
    udat=get(hfig,'userdata');
    if(isempty(udat))
        udat={-999.25 hpifig};%-999.25 is just a dummy placeholder
    elseif(length(udat)==1)
        %this is the case with only a single owner and no subwindows. Should be rare
        udat={udat hpifig};
    elseif(length(udat)==2)
        %here there is one owner already and we add a second.
        udat{2}=[udat{2} hpifig];
    end
    crf=get(hfig,'closerequestfcn');
    if(~isempty(crf))
        if(crf(end)~=';')
            crf=[crf ';'];
        end
    end
    % both PI3D and PI2D may be effectively owners of the same window. This is a problem. We want both
    % to be able to remove the window from the windows list, but only the last one should delete the
    % tool. So, the userdata of the Trace Inspector Window is a two element cell array where the first
    % element contains the array of windows spawned by the TIW and the second is the owner of the TIW
    % normally a single window either PI3D or PI2D. However, in this case it may be two entries if both
    % PI3D and PI2D have claimed the TIW. In that case, only the last entry will delete the tool. This
    % requires additional 9intelligence in the 'closewindow' action of both PI3D and PI2D.
    ind=strfind(crf,';');
    if(length(ind)>2)
        return;%this means there are already two owners. Don't want more
    end
    set(hfig,'closerequestfcn',[crf 'PI2D(''closewindow'')'],'userdata',udat);
    % if(fromenhance)
    %     %the only purpose of this is to store the enhance figure handle
    %     uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
    %         'tag','fromenhance','userdata',henhance);
    % end
end
enhancebutton(hfig,[.8,.920,.05,.025]);
end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
%the title string will be stored as userdata
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

ind=find(data~=0);
sigma=std(data(ind));
am=mean(data(ind));
amin=min(data(ind));
amax=max(data(ind));
nsigma=ceil((amax-amin)/sigma);%number of sigmas that span the data

%clips=linspace(nsigma,1,nclips)';
clips=[20 15 10 9 8 7 6 5 4 3 2 1 .75 .5 .25 .1]';
if(nsigma<clips(1))
    %ind= clips<nsigma;
    %clips=[nsigma;clips(ind)];
    clips=linspace(nsigma,.1,length(clips));
else
    n=floor(log10(nsigma/clips(1))/log10(2));
    newclips=zeros(n,1);
    newclips(1)=nsigma;
    for k=n:-1:2
        newclips(k)=2^(n+1-k)*clips(1);
    end
    clips=[newclips;clips];
end

ind=find(clips>=1);
clips(ind)=round(clips(ind));
ind=find(clips<1);
clips(ind)=round(clips(ind)*10)/10;


clipstr=cell(size(clips));
nclips=length(clips);
clipstr{1}='graphical';
for k=2:nclips
    clipstr{k}=['clip= ' num2str(sigfig(clips(k),3))];
end
iclip=near(clips,3);
iclip=iclip(1);
clip=clips(iclip);

end