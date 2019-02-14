function datar=seisplottvs1(seis,t,dname,t1s,twins,fmax)
% seisplottvs1: plots a seismic trace and its frequency spectrum in time windows
%
% datar=seisplottvs1(seis,t,dname,t1s,twins,fmax)
%
% This is a single trace version of seisplottvs. A new figure is created and divided into two axes
% (side-by-side). The seismic trace is plotted in the left-hand-side and its amplitude
% spectra in different time windows are plotted in the right-hand-side. Controls are provided to
% adjust the clipping and to brighten or darken the image plots.
%
% seis ... input seismic trace
% t ... time coordinate vector for seis. This is the row coordinate of seis. 
% dname ... text string giving a name for the dataset that will annotate
%       the plots.
% ************ default dname =[] ************
% t1s ... vector of 3 window start times (nan gets default)
% ********** default = [t(1) t(1)+twin t(2)+2*twin] where twin=(t(end)-t(1))/3 *********
% twins ... vector of 3 window lengths (nan gets default)
% ********** default = [twin twin twin] *************
% fmax ... maximum frequency to include on the frequency axis.
% ************ default = .5/(t(2)-t(1)) which is Nyquist ***********
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
global FMAX DBLIM
global NEWFIGVIS

if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    [nrows,ncols]=size(seis);
    if((nrows-1)*(ncols-1)>0)
        error('seisplottvs1 accepts only a single trace');
    end
    
    seis=seis(:);
    
    if(length(t)~=length(seis))
        error('time coordinate vector does not match seismic');
    end
    
    if(nargin<3)
        dname=[];
    end
    if(nargin<4)
        t1s=nan;
    end
    if(nargin<5)
        twins=nan;
    end
    if(nargin<6)
        fmax=nan;
    end
    
    if(any(isnan(t1s)) && any(isnan(twins)))
        if(~isempty(SANE_TIMEWINDOWS))
            t1s=SANE_TIMEWINDOWS(:,1);
            t2s=SANE_TIMEWINDOWS(:,2);
            twins=t2s-t1s;
        else
            twin=(t(end)-t(1))/3;
            t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
            twins=twin*ones(1,3);
        end
    end
    
    if(any(isnan(t1s)))
        twin=(t(end)-t(1))/3;
        t1s=[t(1)+.05*twin t(1)+twin t(1)+1.95*twin];
    end
    if(any(isnan(twins)))
        twin=(t(end)-t(1))/3;
        twins=twin*ones(1,3);
    end
    
    if(length(t1s)~=3 || length(twins)~=3)
        error('t1s and twins must be length 3');
    end
    
    fnyq=.5/(t(2)-t(1));
    
    if(isnan(fmax))
        if(isempty(FMAX))
            fmax=fnyq;
        else
            fmax=FMAX;
        end
    end
    
    if(fmax>fnyq)
        fmax=fnyq;
    end
    
    xwid1=.2;
    xwid2=.45;
    yht=.75;
    xsep=.1;
    xnot=.1;
    ynot=.1;
    

    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hax1=subplot('position',[xnot ynot xwid1 yht]);
        
    plot(seis,t);flipy
%     brighten(.5);
    grid
    ht=title(dname ,'interpreter','none');
    if(length(dname)>80)
        ht.FontSize=15;
    end
    
    %draw window start times
    xl=get(gca,'xlim');
    klrs=get(hax1,'colororder');
    lw=1;
    line(xl,[t1s(1) t1s(1)],'color',klrs(2,:),'linestyle','--','buttondownfcn','seisplottvs1(''dragline'');','tag','1','linewidth',lw);
    line(xl,[t1s(1)+twins(1) t1s(1)+twins(1)],'color',klrs(2,:),'linestyle',':','buttondownfcn','seisplottvs1(''dragline'');','tag','1b','linewidth',lw);
    line(xl,[t1s(2) t1s(2)],'color',klrs(3,:),'linestyle','--','buttondownfcn','seisplottvs1(''dragline'');','tag','2','linewidth',lw);
    line(xl,[t1s(2)+twins(2) t1s(2)+twins(2)],'color',klrs(3,:),'linestyle',':','buttondownfcn','seisplottvs1(''dragline'');','tag','2b','linewidth',lw);
    line(xl,[t1s(3) t1s(3)],'color',klrs(4,:),'linestyle','--','buttondownfcn','seisplottvs1(''dragline'');','tag','3','linewidth',lw);
    line(xl,[t1s(3)+twins(3) t1s(3)+twins(3)],'color',klrs(4,:),'linestyle',':','buttondownfcn','seisplottvs1(''dragline'');','tag','3b','linewidth',lw);
    
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    ylabel('time (s)');
    xlabel('amplitude');
    
    %make a button to reset time windows to the global values
    xnow=xnot+xwid1;
    wid=.1;ht=.06;sep=.005;
    ynow=ynot+yht+sep;
    uicontrol(gcf,'style','pushbutton','string','Reset windows to globals','units','normalized',...
        'position',[xnow,ynow,1.5*wid,.5*ht],'callback','seisplottvs1(''resetwindows'')','tag','resetwin',...
        'tooltipstring','Resets windows to the most recent published values');
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+ht,.5*wid,.5*ht],'callback','seisplottvs1(''info'');',...
        'backgroundcolor','y');
    %make a hidden control for storage
    ynow=ynot+yht-ht;
    uicontrol(gcf,'style','text','string','','tag','store','units','normalized',...
        'position',[xnow,ynow,wid,ht],'visible','off',...
        'userdata',{seis,t,hax1,t1s,twins,fmax,dname});
    
%     ynow=ynow-ht-sep;
%     uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','seisplottvs1(''info'');',...
%         'tooltipstring','Click for gate adjustment instructions','userdata',0);
    
    set(hax1,'tag','seis');
    
    hax2=subplot('position',[xnot+xwid1+xsep ynot xwid2 yht]);
    set(hax2,'tag','tvs');
    
    
    xnow=xnot+xwid1+xwid2+xsep;
    ht=.025;
    ynow=ynot+yht-ht;
    uicontrol(gcf,'style','pushbutton','string','recompute','tag','recompute','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs1(''recompute'');',...
        'tooltipstring','recompute the spectra');
    ynow=ynow-ht;
    uicontrol(gcf,'style','pushbutton','string','separate spectra','tag','separate','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottvs1(''separate'');',...
        'tooltipstring','separate the spectra for easier viewing','userdata',0);
     ynow=ynow-ht;
    uicontrol(gcf,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tooltipstring','The maximum frequency to show');
    uicontrol(gcf,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a value in Hz.',...
        'callback','seisplottvs1(''setlims'');','userdata',fnyq);
    ynow=ynow-ht;
    uicontrol(gcf,'style','text','string','db limit:','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tooltipstring','The minimum decibel level to show');
    
    
    bigfig; %enlarge the figure to get more pixels
    pos=get(gcf,'position');
    newwid=pos(3)*.6;
    xshrink=pos(3)-newwid;
    set(gcf,'position',[pos(1)+.5*xshrink pos(2) newwid pos(4)]);
    seisplottvs1('recompute');
    yl=get(gca,'ylim');
    dblimmin=yl(1);
    if(~isempty(DBLIM))
        dblim=DBLIM;
    else
        dblim=dblimmin;
    end
    xlim([0 fmax])
    ylim([dblim 0])
%     bigfont(gcf,1.2,1); %enlarge the fonts in the figure
%     boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
    uicontrol(gcf,'style','edit','string',num2str(dblim),'units','normalized','tag','dblim',...
        'position',[xnow+.5*wid,ynow,.5*wid,ht],'tooltipstring','Enter a negative number',...
        'callback','seisplottvs1(''setlims'');','userdata',dblimmin);
    
    
    set(gcf,'name',['TVS analysis for ' dname],'userdata',-999.25);%userdata here is just a placeholder to cause plotimage3D to do the right thing
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
        msg=['The spectral windows are indicated by the colored horizontal lines on the trace. ',...
        'The colors of the spectra match the colors of the corresponding lines except for the ',...
        'blue spectrum which is always the total trace. For each spectral window, the dashed ',...
        'line is the top and the dotted line is the bottom. Click (left button) on any of these ',...
        'lines and drag them to new positions. If you wish to move the window but retain its size ',...
        'then right-click on either the top or bottom and drag. After adjusting the lines, push "recompute" to recalculate ',...
        'the spectra. When you adjust the windows, the window positions are saved (for the ',...
        'current MATLAB session) so that the next invocation of this tool will start with the ',...
        'newly defined windows. The button "reset windows to globals" matters only if you have ',...
        'several of these tools running at once. If you adjust the windows in tool#1 and then ',...
        'wish tool#2 to grab these same windows, then push this button in tool#2 and then push ',...
        '"recompute". The "separate spectra" button simply shifts the spectra apart (vertically) ',...
        'for better viewing. Only when the spectra are combined (not shifted) are they in true ',...
        'relative amplitude to one another. If the legend on the spectra is in the way, you can drag it to a new position.'];
    hinfo=msgbox(msg,'Instructions for Time-variant spectra tool');
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

elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclipxt=findobj(gcf,'tag','store');
    udat=get(hclipxt,'userdata');
    haxe=udat{3};
%     t1s=udat{4};
    twins=udat{5};
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
   
    
%     hi=findobj(haxe,'type','image');
    t=get(haxe,'ylim');
    tmin=t(1);tmax=t(2);
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
    hclipxt=findobj(gcf,'tag','store');
    udat=get(hclipxt,'userdata');
    haxe=udat{3};
    
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
    
elseif(strcmp(action,'setlims'))
    hfmax=findobj(gcf,'tag','fmax');
    hdblim=findobj(gcf,'tag','dblim');
    tmp=get(hfmax,'string');
    fmax=str2double(tmp);
    fnyq=get(hfmax,'userdata');
    if(isnan(fmax) || fmax>fnyq || fmax<0)
        fmax=fnyq;
        set(hfmax,'string',num2str(fmax));
    end
    tmp=get(hdblim,'string');
    dblim=str2double(tmp);
    if(isnan(dblim))
        dblim=get(hdblim,'userdata');
        set(hdblim,'string',num2str(dblim));
    end
    if(dblim>0)
        dblim=-dblim;
        set(hdblim,'string',num2str(dblim));
    end
    htvs=findobj(gcf,'tag','tvs');
    axes(htvs);
    xlim([0 fmax]);
    ylim([dblim 0]);
    
    FMAX=fmax;
    DBLIM=dblim;
    
elseif(strcmp(action,'recompute'))
    hclipxt=findobj(gcf,'tag','store');
    udat=get(hclipxt,'userdata');
    hax1=udat{3};
    t1s=udat{4};
    twins=udat{5};
    dname=udat{7};
    dbflag=1;
    %fmax
    hfmax=findobj(gcf,'tag','fmax');
    fmax=str2double(get(hfmax,'string'));
    %dblim
    hdblim=findobj(gcf,'tag','dblim');
    dblim=str2double(get(hdblim,'string'));
    
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
    
    
    udat{4}=t1s;
    udat{5}=twins;
    set(hclipxt,'userdata',udat);
    
    t2s=t1s+twins;
    
    SANE_TIMEWINDOWS=[t1s(:) t2s(:)];
    
    seis=udat{1};
    t=udat{2};
    
    hax2=findobj(gcf,'tag','tvs');
    tpad=2*max(twins);
    tvdbspec(t,seis,t1s,twins,tpad,dname,hax2,dbflag);
    set(hax2,'tag','tvs');
    boldlines(hax2,4,2);
    bigfont(hax2,1.08,1);
    xlim([0 fmax])
    if(isnan(dblim))
        dblim=-100;
    end
    ylim([dblim 0])
    
    hsep=findobj(gcf,'tag','separate');
    set(hsep,'string','separate spectra','userdata',0)
    
elseif(strcmp(action,'separate'))
    hsep=gcbo;
    sep=get(hsep,'userdata');
    if(sep==0)
        %we are separating
        hax2=findobj(gcf,'tag','tvs');
        yl=get(hax2,'ylim');
        sep=round(abs(diff(yl))/10);
        hl=findobj(hax2,'type','line');
        yl=get(hl(1),'ydata');
        set(hl(1),'ydata',yl-3*sep);
        yl=get(hl(2),'ydata');
        set(hl(2),'ydata',yl-2*sep);
        yl=get(hl(3),'ydata');
        set(hl(3),'ydata',yl-sep);
        set(hsep,'userdata',sep);
        set(hsep,'string','combine spectra')
    else
        %we are un-separating
        hax2=findobj(gcf,'tag','tvs');
        hl=findobj(hax2,'type','line');
        yl=get(hl(1),'ydata');
        set(hl(1),'ydata',yl+3*sep);
        yl=get(hl(2),'ydata');
        set(hl(2),'ydata',yl+2*sep);
        yl=get(hl(3),'ydata');
        set(hl(3),'ydata',yl+sep);
        set(hsep,'userdata',0);
        set(hsep,'string','separate spectra')
    end
    
    
end
end