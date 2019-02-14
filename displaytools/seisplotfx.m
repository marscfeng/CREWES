function datar=seisplotfx(seis,t,x,dname,t1s,twins,fmax,xname,flag)
% SEISPLOTFX: plots a seismic gather and its f-x spectrum in time windows
%
% datar=seisplotfx(seis,t,x,dname,t1s,twins,fmax,xname,flag)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The seismic gather is
% plotted as an image in the left-hand-side and its temporal amplitude spectra in different time
% windows are plotted in the right-hand-side. Controls are provided to adjust the clipping and to
% brighten or darken the image plots.
%
% seis ... input seismic matrix
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% x ... space coordinate vector for seis
% dname ... text string giving a name for the dataset that will annotate
%       the plots. Enter nan for the default.
% ************ default dname =[] ************
% t1s ... vector of 3 window start times. Enter nan for the default.
% ********** default = [t(1) t(1)+twin t(2)+2*twin] where twin=(t(end)-t(1))/3 *********
% twins ... vector of 3 window lengths. Enter nan for the default.
% ********** default = [twin twin twin] *************
% fmax ... maximum frequency to include on the frequency axis. Enter nan for the default.
% ************ default = .25/(t(2)-t(1)) which is half-Nyquist ***********
% xname ... name of the x coordinate. nan gets the default
% ************ default = 'x coordinate' **********
% flag ... either 0 or 1. 0 means amplitude spectra and 1 means phase
% ************ default flag = 0 ************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the seismic axes
%           data{2} ... handle of the spectral axes
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
global SANE_TIMEWINDOWS
global FMAX
global NEWFIGVIS
global FXNAME
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
    
    if(nargin<4)
        dname=[];
    end
    
    if(nargin<5)
        t1s=nan;
    end
    if(isnan(t1s))
        if(~isempty(SANE_TIMEWINDOWS))
            t1s=SANE_TIMEWINDOWS(:,1);
        else
            twin=(t(end)-t(1))/3;
            t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
        end
    end
    if(nargin<6)
        twins=nan;
    end
    if(isnan(twins))
        if(~isempty(SANE_TIMEWINDOWS))
            t2s=SANE_TIMEWINDOWS(:,2);
            twins=t2s-t1s;
        else
            twin=(t(end)-t(1))/3;
            twins=twin*ones(1,3);
        end
    end
    
    if(length(t1s)~=3 || length(twins)~=3)
        error('t1s and twins must be length 3');
    end
    fnyq=.5/(t(2)-t(1));
    if(nargin<7)
        fmax=nan;
    end
    
    if(isnan(fmax))
        if(isempty(FMAX))
            fmax=.5*fnyq;
        else
            fmax=FMAX;
        end
    end
    
    
    if(fmax>fnyq)
        fmax=fnyq;
    end
    
    if(nargin < 8)
        xname=nan;
    end
    if(isnan(xname))
        xname='x coordinate';
    end
    if(nargin<9)
        flag=0;
    end
    
    rflucstring={'50','40','30','20','10','5','2','1','0'};
    irfluc=5;
    
    xwid=.35;
    yht=.8;
    xsep=.1;
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
        
    imagesc(x,t,seis,clim);colormap(seisclrs);
%     brighten(.5);
    grid
    if(length(dname)<30)
        htitle=title(dname ,'interpreter','none');
        htFontSize=16;
    elseif(length(dname)<50)
        htitle=title(dname ,'interpreter','none');
        htFontSize=14;
    else
        N=length(dname);
        N2=round(N/2);
        htitle=title({dname(1:N2),dname(N2+1:end)} ,'interpreter','none');
        htFontSize=12;
    end
    
    %draw window start times
    xmin=min(x);
    xmax=max(x);
    klrs=get(hax1,'colororder');
    lw=1;
    line([xmin xmax],[t1s(1) t1s(1)],'color',klrs(2,:),'linestyle','--','buttondownfcn','seisplotfx(''dragline'');','tag','1','linewidth',lw);
    line([xmin xmax],[t1s(1)+twins(1) t1s(1)+twins(1)],'color',klrs(2,:),'linestyle',':','buttondownfcn','seisplotfx(''dragline'');','tag','1b','linewidth',lw);
    line([xmin xmax],[t1s(2) t1s(2)],'color',klrs(3,:),'linestyle','--','buttondownfcn','seisplotfx(''dragline'');','tag','2','linewidth',lw);
    line([xmin xmax],[t1s(2)+twins(2) t1s(2)+twins(2)],'color',klrs(3,:),'linestyle',':','buttondownfcn','seisplotfx(''dragline'');','tag','2b','linewidth',lw);
    line([xmin xmax],[t1s(3) t1s(3)],'color',klrs(4,:),'linestyle','--','buttondownfcn','seisplotfx(''dragline'');','tag','3','linewidth',lw);
    line([xmin xmax],[t1s(3)+twins(3) t1s(3)+twins(3)],'color',klrs(4,:),'linestyle',':','buttondownfcn','seisplotfx(''dragline'');','tag','3b','linewidth',lw);
    
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
    
    %make a button to reset time windows to the global values
    xnow=xnot+xwid;
    wid=.055;ht=.05;sep=.005;
    ynow=ynot+yht+sep;
    uicontrol(gcf,'style','pushbutton','string','Reset windows to globals','units','normalized',...
        'position',[xnow,ynow,1.5*wid,.5*ht],'callback','seisplotfx(''resetwindows'')','tag','resetwin',...
        'tooltipstring','Resets windows to the most recent published values');
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+ht,.5*wid,.5*ht],'callback','seisplotfx(''info'');',...
        'backgroundcolor','y');
    %make a clip control
    ynow=ynot+yht-ht;
    hclip=uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clipxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''clipxt'');','value',iclip,...
        'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped');
    
    ht=.5*ht;
    ynow=ynow-sep;
    uicontrol(gcf,'style','pushbutton','string','brighten','tag','brightenxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''brightenxt'');',...
        'tooltipstring','push once or multiple times to brighten the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','darken','tag','darkenxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''brightenxt'');',...
        'tooltipstring','push once or multiple times to darken the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','lvl 0','tag','brightnessxt','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','image brightness (both images)','userdata',0);
    
    set(hax1,'tag','seis');
    pos=[xnot+xwid+xsep ynot xwid yht];
    set(hclip,'userdata',{clips,am,sigma,amax,amin,hax1,t1s,twins,fnyq,dname,xname,flag,pos,x})
%     hback=axes('position',pos,'color',.5*ones(1,3));
    hax2=axes('position',pos,'xtick',[],'ytick',[],'xcolor',.999*ones(1,3),'ycolor',.999*ones(1,3)); 
    t2s=t1s+twins;
    if(flag==0)
        cm=get(gcf,'colormap');
    end
    rfluc=str2double(rflucstring{irfluc});
    [hfigs,phs,fphs,amp,famp]=fxanalysis(seis,t,t1s,t2s,fnyq,'',x,xname,nan,flag,hax2,rfluc); %#ok<ASGLU>
    if(flag==0)
        result={flag,amp,famp,t1s,t2s,rfluc,fmax};
    else
        result={flag,phs,fphs,t1s,t2s,rfluc,fmax};
    end
    fxname=FXNAME;
    if(flag==0)
        set(gcf,'colormap',cm);
%         hax=findobj(gcf,'tag','spec1');
% %         set(hax,'ylim',[0 fmax])
%         cl=get(hax,'clim');
%         set(hax,'clim',.5*[-cl(2) cl(2)]);
%         hax=findobj(gcf,'tag','spec2');
% %         set(hax,'ylim',[0 fmax])
%         cl=get(hax,'clim');
%         set(hax,'clim',.5*[-cl(2) cl(2)]);
%         hax=findobj(gcf,'tag','spec3');
% %         set(hax,'ylim',[0 fmax])
%         cl=get(hax,'clim');
%         set(hax,'clim',.5*[-cl(2) cl(2)]);
% %     else
% %         hax=findobj(gcf,'tag','spec1');
% %         set(hax,'ylim',[0 fmax])
% %         hax=findobj(gcf,'tag','spec2');
% %         set(hax,'ylim',[0 fmax])
% %         hax=findobj(gcf,'tag','spec3');
% %         set(hax,'ylim',[0 fmax])
    end
    htxt=zeros(1,3);
    htxt(1)=findobj(gcf,'tag','z1');
    set(htxt(1),'backgroundcolor',klrs(2,:),'fontweight','bold');
    htxt(2)=findobj(gcf,'tag','z2');
    set(htxt(2),'backgroundcolor',klrs(3,:),'fontweight','bold');
    htxt(3)=findobj(gcf,'tag','z3');
    set(htxt(3),'backgroundcolor',klrs(4,:),'fontweight','bold','foregroundcolor',[1 1 1]);
%     set(hax2,'xtick',[],'ytick',[],'xcolor',.9*ones(1,3),'ycolor',.9*ones(1,3));
    
    %make 3 zoom buttons
    ynudge=0;
    xnow=xnot+2*xwid+xsep+.01;
    ynow=ynot+.17*yht+ynudge;
    wid=.075;ht=.025;
    uicontrol(gcf,'style','pushbutton','string','zoom 1&2 like 3','units','normalized','tag','z12',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''zoom'');');
    ynow=ynow+.33*yht;
    uicontrol(gcf,'style','pushbutton','string','zoom 1&3 like 2','units','normalized','tag','z13',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''zoom'');');
    ynow=ynow+.33*yht;
    uicontrol(gcf,'style','pushbutton','string','zoom 2&3 like 1','units','normalized','tag','z23',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''zoom'');');
    
    %make a clip control

    xnow=xnot+2*xwid+xsep+.01;
    ht=.025;
    ynow=ynot+yht-.75*ht;
%     nudge=.25*ht;
    uicontrol(gcf,'style','text','string','PctRand:','units','normalized',...
        'position',[xnow,ynow,.5*wid,.75*ht],'tooltipstring',...
        'Amount of random fluctuation in window size as a percent','horizontalalignment','right');
    
    uicontrol(gcf,'style','popupmenu','string',rflucstring,'units','normalized','position',...
        [xnow+.5*wid,ynow,.5*wid,ht],'tag','rfluc','value',irfluc);
    ynow=ynow-ht;
    uicontrol(gcf,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,.5*wid,.75*ht],'tooltipstring','The maximum frequency to show',...
        'horizontalalignment','right');
    uicontrol(gcf,'style','edit','string',num2str(round(fmax)),'units','normalized','tag','fmax',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a value in Hz.',...
        'callback','seisplotfx(''changefmax'');','userdata',fnyq);
    if(flag==0)
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','radiobutton','string','show ave amp','units','normalized','tag','showave',...
            'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''showave'');','value',1);
    end
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','recompute','tag','recompute','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotfx(''recompute'');',...
        'tooltipstring','recompute the spectra','backgroundcolor','y');

%results popup
    haxspec1=findobj(gcf,'tag','spec1');
    pos=get(haxspec1,'position');
    xnow=pos(1);
    ynow=pos(2)+pos(4)+ht;
    wid=pos(3);
    fs=12;
    uicontrol(gcf,'style','popupmenu','string',{fxname},'units','normalized','tag','results',...
        'position',[xnow,ynow,wid,2*ht],'callback','seisplotfx(''select'');','fontsize',fs,...
        'fontweight','bold','value',1)
    
    seisplotfx('newresult',result);
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.6,1); %enlarge the fonts in the figure
    set(htxt,'fontweight','bold')
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    htitle.FontSize=htFontSize;
    whitefig;
    
    if(flag==0)
        if(~iscell(dname))
            dname2=dname;
        else
            dname2=[dname{1} ' ' dname{2}];
        end
        set(gcf,'name',['F-X amplitude analysis for ' dname2],'closerequestfcn','seisplotfx(''close'');',...
            'userdata',-999.25);%userdata here is just a placeholder to cause plotimage3D to do the right thing
    else
        if(~iscell(dname))
            dname2=dname;
        else
            dname2=[dname{1} ' ' dname{2}];
        end
        set(gcf,'name',['F-X phase analysis for ' dname2],'closerequestfcn','seisplotfx(''close'');',...
            'userdata',-999.25);%userdata here is just a placeholder to cause plotimage3D to do the right thing
    end
    if(nargout>0)
        hfxax1=findobj(gcf,'tag','spec1');
        hfxax2=findobj(gcf,'tag','spec2');
        hfxax3=findobj(gcf,'tag','spec3');
        datar={hax1,hfxax1,hfxax2,hfxax3};
    end
    seisplotfx('clipxt');
    seisplotfx('changefmax');
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    msg={['The spectral windows are indicated by the colored horizontal lines on the seismic. ',...
        'The red lines define the window for the upper f-x spectum, the orange lines define ',...
        'the middle window, and the purple lines the lower spectral window. For each spectral window, the dashed ',...
        'line is the top and the dotted line is the bottom. Click (left button) on any of these ',...
        'lines and drag them to new positions. If you wish to move the window but retain its size ',...
        'then right-click on either the top or bottom and drag. After adjusting the lines, push "recompute" to recalculate ',...
        'the spectra. When you adjust the windows, the window positions are saved (for the ',...
        'current MATLAB session) so that the next invocation of this tool will start with the ',...
        'newly defined windows. The button "reset windows to globals" matters only if you have ',...
        'several of these tools running at once. If you adjust the windows in tool#1 and then ',...
        'wish tool#2 to grab these same windows, then push this button in tool#2 and then push ',...
        '"recompute". The presence of signal is indicated by spatial continuity of the spectra, ',...
        'either amplitude or phase.  The amplitude spectra can seem easier to interpret but they ',...
        'only show signal where the spectral strength is strong. Examining the phase spectra as ',...
        'well alllows a judgement of whether the band of spectral whitening corresponds to the ',...
        'signal band. If the phase spectra show coherence at frequencies where the spectrum is not ',...
        'whitened, then such signal is wasted.']};
    hinfo=showinfo(msg,'Instructions for f-x spectra tool');
    udat=get(hthisfig,'userdata');
    if(iscell(udat))
        if(isgraphics(udat{1}))
            delete(udat{1});
        end
        udat{1}=hinfo;
    else
        if(isgraphics(udat))
            delete(udat);
        end
        udat=hinfo;
    end
    set(hthisfig,'userdata',udat);
elseif(strcmp(action,'showave'))
    val=get(gco,'value');
    vis='on';
    if(~val); vis='off'; end
    
    ha=findobj(gcf,'tag','Aamp1');
    hk=get(ha,'children');
    set(ha,'visible',vis);
    for k=1:length(hk)
        set(hk(k),'visible',vis);
    end
    
    ha=findobj(gcf,'tag','Aamp2');
    hk=get(ha,'children');
    set(ha,'visible',vis);
    for k=1:length(hk)
        set(hk(k),'visible',vis);
    end
    
    ha=findobj(gcf,'tag','Aamp3');
    hk=get(ha,'children');
    set(ha,'visible',vis);
    for k=1:length(hk)
        set(hk(k),'visible',vis);
    end
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
    %adjust the spectral axes
    for k=1:3
        hax=findobj(gcf,'tag',['spec' int2str(k)]);
        htxt=findobj(gcf,'tag',['z' int2str(k)]);
        udat=get(htxt,'userdata');
        amean=udat(1);
        amax=udat(2);
        sigma=udat(3);
        flag=udat(4);
        if(flag==0)
            if(iclip~=1)
                set(hax,'clim',[-.5*sigma clip*sigma+amean]);
            else
                set(hax,'clim',[-.5*sigma amax]);
            end
        else
            if(iclip~=1)
                c1=max([amean-clip*sigma -1]);
                c2=min([clip*sigma+amean 1]);
                set(hax,'clim',[c1 c2]);
            else
                set(hax,'clim',[-amax amax]);
            end
        end
    end

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

elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{6};
%     t1s=udat{7};
    twins=udat{8};
    twin=.25*min(twins);
    
    h1=findobj(haxe,'tag','1');
    yy=get(h1,'ydata');
    t1=yy(1);
    h1b=findobj(haxe,'tag','1b');
    yy=get(h1b,'ydata');
    t1b=yy(1);
    h2=findobj(haxe,'tag','2');
    yy=get(h2,'ydata');
    t2=yy(2);
    h2b=findobj(haxe,'tag','2b');
    yy=get(h2b,'ydata');
    t2b=yy(2);
    h3=findobj(haxe,'tag','3');
    yy=get(h3,'ydata');
    t3=yy(1);
    h3b=findobj(haxe,'tag','3b');
    yy=get(h3b,'ydata');
    t3b=yy(1);
    
    hi=findobj(haxe,'type','image');
    t=get(hi,'ydata');
    tmin=t(1);tmax=t(end);
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on t1
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin t1b];
        DRAGLINE_PAIRED=h1b;
    elseif(hnow==h2)
        %clicked on t2
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin t2b];
        DRAGLINE_PAIRED=h2b;
    elseif(hnow==h3)
        %clicked on t3
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[tmin t3b];
        DRAGLINE_PAIRED=h3b;
    elseif(hnow==h1b)
        %clicked on t1b
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t1 tmax-twin];
        DRAGLINE_PAIRED=h1;
    elseif(hnow==h2b)
        %clicked on t2b
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t2 tmax-twin];
        DRAGLINE_PAIRED=h2;
    elseif(hnow==h3b)
        %clicked on t3b
        DRAGLINE_MOTION='yonly';
        DRAGLINE_YLIMS=[t3 tmax-twin];
        DRAGLINE_PAIRED=h3;
    end
    
    dragline('click')
    
elseif(strcmp(action,'resetwindows'))
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    haxe=udat{6};
    
    tglobal=SANE_TIMEWINDOWS;
    t1s=tglobal(:,1);
    t2s=tglobal(:,2);
    
    h1=findobj(haxe,'tag','1');
    set(h1,'ydata',[t1s(1) t1s(1)]);
    h1b=findobj(haxe,'tag','1b');
    set(h1b,'ydata',[t2s(1) t2s(1)]);
    h2=findobj(haxe,'tag','2');
    set(h2,'ydata',[t1s(2) t1s(2)]);
    h2b=findobj(haxe,'tag','2b');
    set(h2b,'ydata',[t2s(2) t2s(2)]);
    h3=findobj(haxe,'tag','3');
    set(h3,'ydata',[t1s(3) t1s(3)]);
    h3b=findobj(haxe,'tag','3b');
    set(h3b,'ydata',[t2s(3) t2s(3)]);
    
elseif(strcmp(action,'changefmax'))
    hfmax=findobj(gcf,'tag','fmax');
    tmp=get(hfmax,'string');
    fmax=str2double(tmp);
    fnyq=get(hfmax,'userdata');
    if(isnan(fmax))
        fmax=fnyq;
        set(hfmax,'string',num2str(fmax));
    end
    if(fmax<0 || fmax>fnyq)
        fmax=fnyq;
        set(hfmax,'string',num2str(fmax));
    end
    hax=findobj(gcf,'tag','spec1');
    set(hax,'ylim',[0 fmax]);
    hax=findobj(gcf,'tag','spec2');
    set(hax,'ylim',[0 fmax]);
    hax=findobj(gcf,'tag','spec3');
    set(hax,'ylim',[0 fmax]);
    
    hax=findobj(gcf,'tag','Aamp1');
    if(~isempty(hax))
        set(hax,'xlim',[0 fmax]);
    end
        hax=findobj(gcf,'tag','Aamp2');
    if(~isempty(hax))
        set(hax,'xlim',[0 fmax]);
    end
    hax=findobj(gcf,'tag','Aamp3');
    if(~isempty(hax))
        set(hax,'xlim',[0 fmax]);
    end
    
    FMAX=fmax;
    
    hresults=findobj(gcf,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    results.fmaxs{iresult}=fmax;
    set(hresults,'userdata',results);
    
elseif(strcmp(action,'recompute'))
    hclipxt=findobj(gcf,'tag','clipxt');
    udat=get(hclipxt,'userdata');
    hax1=udat{6};
    t1s=udat{7};
    twins=udat{8};
    fnyq=udat{9};
    %dname=udat{10};
    xname=udat{11};
    flag=udat{12};
    pos=udat{13};
    x=udat{14};
    
    hfmax=findobj(gcf,'tag','fmax');
    val=get(hfmax,'string');
    fmax=str2double(val);
    
    hrand=findobj(gcf,'tag','rfluc');
    flucs=get(hrand,'string');
    ifluc=get(hrand,'value');
    rfluc=str2double(flucs{ifluc});
%     if(isnan(fmax)||fmax<0||fmax>fnyq)
%         msgbox('Invalid value for fmax, correct and try again');
%         return;
%     end
    
    %for some unknown reason, when a recompute occurs, the fontsize changes (gets smaller) in all
    %of the fx axes. So, the fix is to grab the previous fontsizes and then reset them after
    haxes=findobj(gcf,'type','axes');
    fs=zeros(size(haxes));
    fw=cell(size(haxes));
    tags=cell(size(haxes));
    for k=1:length(haxes)
        fs(k)=get(haxes(k),'fontsize');
        fw{k}=get(haxes(k),'fontweight');
        tags{k}=get(haxes(k),'tag');
    end
    if(flag==0)
        hax3=findobj(gcf,'tag','spec3');
    else
        hax3=findobj(gcf,'tag','spec3');
    end
    htxt=get(hax3,'userdata');
    fstxt=zeros(size(htxt));
    fwtxt=cell(size(htxt));
    for k=1:length(htxt)
        fstxt(k)=get(htxt(k),'fontsize');
        fwtxt{k}=get(htxt(k),'fontweight');
    end
    
    h1=findobj(hax1,'tag','1');
    yy=get(h1,'ydata');
    t1s(1)=yy(1);
    h1b=findobj(hax1,'tag','1b');
    yy=get(h1b,'ydata');
    twins(1)=yy(1)-t1s(1);
    
    h2=findobj(hax1,'tag','2');
    yy=get(h2,'ydata');
    t1s(2)=yy(1);
    h2b=findobj(hax1,'tag','2b');
    yy=get(h2b,'ydata');
    twins(2)=yy(1) -t1s(2);
    
    h3=findobj(hax1,'tag','3');
    yy=get(h3,'ydata');
    t1s(3)=yy(1);
    h3b=findobj(hax1,'tag','3b');
    yy=get(h3b,'ydata');
    twins(3)=yy(1)-t1s(3);
    
    udat{7}=t1s;
    udat{8}=twins;
    set(hclipxt,'userdata',udat);
    
    hi=findobj(hax1,'type','image');
    seis=get(hi,'cdata');
    t=get(hi,'ydata');
    
    hax2=subplot('position',pos);
    t2s=t1s+twins;
    %delete the window text labels so that fxanalysis can make new ones
    for k=1:3
        htxt=findobj(gcf,'tag',['z' int2str(k)]);
        if(isgraphics(htxt))
            delete(htxt);
        end
    end
    
    SANE_TIMEWINDOWS=[t1s(:) t2s(:)];
    
%     if(flag==0)
%         cm=get(gcf,'colormap');
%     end
    cm=get(gcf,'colormap');
    [hfigs,phs,fphs,amp,famp]=fxanalysis(seis,t,t1s,t2s,fnyq,'',x,xname,nan,flag,hax2,rfluc); %#ok<ASGLU>
    set(gcf,'colormap',cm);
    if(flag==0)
        result={flag,amp,famp,t1s,t2s,rfluc,fmax};
    else
        result={flag,phs,fphs,t1s,t2s,rfluc,fmax};
    end
    %update results menu
    hresults=findobj(gcf,'tag','results');
    names=get(hresults,'string');
    nresults=length(names);
    names{nresults+1}=FXNAME;
    set(hresults,'string',names,'value',nresults+1);
    seisplotfx('newresult',result);
     
    if(flag==0)
       
        hax=findobj(gcf,'tag','spec1');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec2');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec3');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','Aamp1');
        hl=findobj(hax,'type','line');
        set(hl,'linewidth',4*get(hl,'linewidth'));
        hax=findobj(gcf,'tag','Aamp2');
        hl=findobj(hax,'type','line');
        set(hl,'linewidth',4*get(hl,'linewidth'));
        hax=findobj(gcf,'tag','Aamp3');
        hl=findobj(hax,'type','line');
        set(hl,'linewidth',4*get(hl,'linewidth'));
    end
    if(flag==1)
        hax=findobj(gcf,'tag','spec1');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec2');
        set(hax,'ylim',[0 fmax]);
        hax=findobj(gcf,'tag','spec3');
        set(hax,'ylim',[0 fmax]);
    end
    klrs=get(hax1,'colororder');
    h=findobj(gcf,'tag','z1');
    set(h,'backgroundcolor',klrs(2,:),'fontweight','bold');
    h=findobj(gcf,'tag','z2');
    set(h,'backgroundcolor',klrs(3,:),'fontweight','bold');
    h=findobj(gcf,'tag','z3');
    set(h,'backgroundcolor',klrs(4,:),'fontweight','bold','foregroundcolor',[1 1 1]);
    haxes=findobj(gcf,'type','axes');
    hax3=findobj(gcf,'tag','spec3');
%     if(flag==0)
%         hax3=findobj(gcf,'tag','spec3');
%     else
%         hax3=findobj(gcf,'tag','spec3');
%     end
    htxt=get(hax3,'userdata');
    for k=1:length(haxes)
        thistag=get(haxes(k),'tag');
        for kk=1:length(tags)
            if(strcmp(thistag,tags{kk}))
                set(haxes(k),'fontsize',fs(kk));
                set(haxes(k),'fontweight',fw{kk});
                break
            end
        end
        tmp=strfind(thistag,'Aamp');
        if(~isempty(tmp)) %#ok<STREMP>
           set(haxes(k),'xlim',[0 fmax]); 
        end
    end
    for k=1:length(htxt)
       set(htxt(k),'fontsize',fstxt(k),'fontweight',fwtxt{k}) 
    end
    
    seisplotfx('clipxt');
elseif(strcmp(action,'newresult'))
    result=t;%second argument
    %result{1}=flag ... 0 for amp 1 for phase
    %result{2}=fxspec ... cell array of 3 fx spectra
    %result{3}=fs ... cell array of 3 frequency coord vectors
    %result{4}=t1s ... ord array of window start times
    %result{5}=t2s ... ord array of window end times
    %result{6}=rfluc ... value of rfluc
    hresults=findobj(gcf,'tag','results');
    results=get(hresults,'userdata');
    nresults=get(hresults,'value');
%     if(isempty(results))
%         nresults=1;
%     else
%         nresults=length(results)+1;
%     end
    results.flags{nresults}=result{1};
    results.fxspecs{nresults}=result{2};
    results.fss{nresults}=result{3};
    results.t1ss{nresults}=result{4};
    results.t2ss{nresults}=result{5};
    results.rflucs{nresults}=result{6};
    results.fmaxs{nresults}=result{7};
    
    set(hresults,'userdata',results)

elseif(strcmp(action,'select'))
    hfig=gcf;
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    %loop over spectra
    flag=results.flags{iresult};
    fmax=results.fmaxs{iresult};
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(fmax));
    hseis=findobj(hfig,'tag','seis');
    for k=1:length(results.fxspecs{iresult})
        fxspec=results.fxspecs{iresult}{k};
        f=results.fss{iresult}{k};
        t1s=results.t1ss{iresult};
        t2s=results.t2ss{iresult};
        rfluc=results.rflucs{iresult};
        %update spectra
        hax=findobj(hfig,'tag',['spec' int2str(k)]);
        hi=findobj(hax,'type','image');
        set(hi,'ydata',f,'cdata',fxspec);
        set(hax,'ylim',[0 fmax]);
        %update average amplitude
        if(flag==0)
            aveamp=sum(fxspec,2);
            haxa=findobj(hfig,'tag',['Aamp', int2str(k)]);
            hl=findobj(haxa,'type','line');
            set(hl,'xdata',f,'ydata',todb(aveamp));
        end
        %update time label
        htxt=findobj(hfig,'tag',['z' int2str(k)]);
        set(htxt,'string',[time2str(t1s(k)) ' to ' time2str(t2s(k)) ' sec']);
        %update amplitude info
        amean=mean(fxspec(:));
        amax=max(fxspec(:));
        sigma=std(fxspec(:));
        set(htxt,'userdata',[amean amax sigma flag]);
        %update line positions
        hlinea=findobj(hseis,'tag',int2str(k));
        hlineb=findobj(hseis,'tag',[int2str(k) 'b']);
        set(hlinea,'ydata',[t1s(k) t1s(k)]);
        set(hlineb,'ydata',[t2s(k) t2s(k)]);
        %update rfluc
        hrfluc=findobj(gcf,'tag','rfluc');
        rflucstring=get(hrfluc,'string');
        for j=1:length(rflucstring)
           if(str2double(rflucstring{j})==rfluc)
              set(hrfluc,'value',j); 
           end
        end
    end
    %seisplotfx('changefmax');
elseif(strcmp(action,'info'))
    msg=['Spectral analysis windows are shown on the seismic section with red being the shallow window, ',...
        'yellow the intermediate window, and purple the deepest window. For each window, the top is shown as a dashed line ',...
        'and the bottom as a dotted line. You can click and drag the window boundaries to new positions. With the left mouse button, click on either the ',...
        'top or bottom of a window and drag it to a new position. (The bottom cannot be dragged ',...
        'past the top and vice versa.) With the right mouse button, click and drag either the ',...
        'window top or bottom and they will move together keeping the window width constant. ',...
        'After adjusting the window, click recompute to see the spectra. Avoid very narrow ',...
        'gates. Windows may overlap.'];
    pos=get(gcf,'position');
    msgbox(msg,'TVS gate adjustment instructions');
    pos2=get(gcf,'position');
    xc=pos(1)+.5*pos(3);
    yc=pos(2)+.5*pos(4);
    x1=xc-.5*pos2(3);
    y1=yc-.5*pos2(4);
    set(gcf,'position',[x1 y1 pos2(3:4)]);
elseif(strcmp(action,'zoom'))
    hbut=gcbo;
    tag=get(hbut,'tag');
    switch tag
        case 'z12'
            haxnow=findobj(gcf,'tag','spec3');
            yl=get(haxnow,'ylim');
            xl=get(haxnow,'xlim');
            haxa=findobj(gcf,'tag','spec1');
            haxb=findobj(gcf,'tag','spec2');
            set([haxa haxb],'xlim',xl,'ylim',yl);
            
        case 'z13'
            haxnow=findobj(gcf,'tag','spec2');
            yl=get(haxnow,'ylim');
            xl=get(haxnow,'xlim');
            haxa=findobj(gcf,'tag','spec1');
            haxb=findobj(gcf,'tag','spec3');
            set([haxa haxb],'xlim',xl,'ylim',yl);
            
        case 'z23'
            haxnow=findobj(gcf,'tag','spec1');
            yl=get(haxnow,'ylim');
            xl=get(haxnow,'xlim');
            haxa=findobj(gcf,'tag','spec2');
            haxb=findobj(gcf,'tag','spec3');
            set([haxa haxb],'xlim',xl,'ylim',yl);
    end
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
clip=clips(iclip(1));

end