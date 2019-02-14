function datar=specd_viewer(seis,seissd,t,x,tsd,fsd,dname,cmap)
% specd_viewer: provides interactive viewing of a spectral decomp dataset
%
% datar=specd_viewer(seis,seissd,t,x,tsd,fsd,dname,cmap)
%
% A new figure is created and divided into three axes (side-by-side). The first axes shows the
% seismic gather on which spectral decomp was performed, the second shows the spectral decomp one
% frequency at a time with controls to step through the frequencies, and the third axis shows the
% spectral decomp at a single x location as a function of frequency.
%
% seis ... 2D seismic matrix that spectral decomp was done on
% seissd ... 3D seismic matrix that resulted from spectral decomp. Can be either amplitude or phase.
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
% tsd ... time coordinate vector for seissd
% fsd ... frequency coordinate vector for seissd
% NOTE: let nt=length(t), nx=length(x), ntsd=length(tsd), nfsd=length(fsd) then seis is a 2D matrix
%   of dimension nt-by-nx while seissd is 3D of dimension ntsd-by-nx-by-nfsd. Generally ntsd will be
%   less than nt.
% dname ... text string nameing the first seismic matrix. Enter [] or '' for no name.
% cmap ... starting colormap
% ******** default 'seisclrs' **********
%
% datar ... Return data which is a length 3 cell array containing
%           datar{1} ... handle of the first seismic axes
%           datar{2} ... handle of the second spectral decomp axis
%           datar{3} ... handle of the third spectral decomp axis
% These return data are provided to simplify plotting additional lines and
% text.
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
global NEWFIGVIS
if(~ischar(seis))
    action='init';
else
    action=seis;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match first seismic matrix');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match first seismic matrix');
    end
    if(length(tsd)~=size(seissd,1))
        error('time coordinate vector tsd does not match spectral decomp matrix');
    end
    if(length(x)~=size(seissd,2))
        error('space coordinate vector does not match spectral decomp matrix');
    end
    if(length(fsd)~=size(seissd,3))
        error('frequency coordinate vector does not match spectral decomp matrix');
    end
    
    if(nargin<7)
        dname=[];
    end
    if(nargin<8)
        cmap='seisclrs';
    end
    
    if(iscell(dname))
        error('dname must be a simp[le string')
    end
    
    %determine a few things about the spectral decomp
    nfsd=length(fsd);
    mnfsd=zeros(1,nfsd);
    maxfsd=mnfsd;
    minfsd=mnfsd;
    sfsd=mnfsd;
    %test for amp or phase
    ind=find(seissd(:,:,round(nfsd/2))<0, 1);
    if(isempty(ind))
        amp=true;
    else
        amp=false;
    end
    for k=1:nfsd
        tmp=seissd(:,:,k);
        mnfsd(k)=mean(tmp(:));
        maxfsd(k)=max(tmp(:));
        minfsd(k)=mean(tmp(:));
        sfsd(k)=std(tmp(:));
    end

    xwid=.35;
    xwid2=.35;
    xwid3=.1;
    yht=.8;
    xsep=.05;
    xnot=.5*(1-xwid-xwid2-xwid3-1.5*xsep);
    ynot=.1;
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    hax1=subplot('position',[xnot ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis);
    clim=[am-clip*sigma am+clip*sigma];
        
    imagesc(x,t,seis,clim);
    %brighten(.5);
    grid
    title(dname,'interpreter','none')
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

    xnow=xnot+.8*xwid;
    wid=.055;ht=.05;
    ynow=ynot+yht;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
        'position',[xnow,ynow+.5*ht,.8*wid,ht],'callback','specd_viewer(''clip1'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax1},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnot,ynow+ht,.5*wid,.5*ht],'callback','specd_viewer(''info'');',...
        'backgroundcolor','y');
    
    %colormap controls
    xnoww=xnot+xwid+xsep;
    uicontrol(gcf,'style','text','string','Colormap:','tag','colomaplabel',...
        'units','normalized','position',[xnoww ynow+.9*ht wid .5*ht],'horizontalalignment','right',...
        'backgroundcolor',.9999*ones(1,3));
    if(exist('parula','file')==2)
        colormaps={'seisclrs','redblue','redblue2','redblue3','blueblack','bluebrown','greenblack',...
            'greenblue','jet','parula','copper','bone','gray','winter'};
    else
        colormaps={'seisclrs','redblue','redblue2','redblue3','blueblack','bluebrown','greenblack',...
            'greenblue','jet','copper','bone','gray','winter'};
    end
    icolor=0;
    for k=1:length(colormaps)
        if(strcmp(colormaps{k},cmap))
            icolor=k;
        end
    end
    if(icolor==0)
        nk=length(colormaps);
        colormaps{nk+1}=cmap;
        icolor=nk+1;
    end
    xnoww=xnoww+wid;
    uicontrol(gcf,'style','popupmenu','string',colormaps,'tag','colormap',...
        'units','normalized','position',[xnoww ynow+.5*ht wid ht],'callback',...
        'specd_viewer(''colormap'');','value',icolor);
    xnoww=xnoww+1.1*wid;
    uicontrol(gcf,'style','radiobutton','string','Apply to all axes','units','normalized',...
        'position',[xnoww ynow+.9*ht 2*wid .75*ht],'tag','applytoall',...
        'backgroundcolor',.9999*ones(1,3));
    
    %the hide seismic button
    xnoww=xnot+wid;
    uicontrol(gcf,'style','pushbutton','string','Hide seismic','tag','hideshow','units','normalized',...
        'position',[xnoww,ynow+ht,wid,.5*ht],'callback','specd_viewer(''hideshow'');','userdata','hide');
    %the toggle button
    xnoww=xnoww+1.1*wid;
    uicontrol(gcf,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnoww,ynow+ht,wid,.5*ht],'callback','specd_viewer(''toggle'');','visible','off');
    
%     ht=.5*ht;
%     ynow=ynow-sep;
%     uicontrol(gcf,'style','pushbutton','string','brighten','tag','brighten','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','specd_viewer(''brighten'')',...
%         'tooltipstring','push once or multiple times to brighten the images');
%     ynow=ynow-ht-sep;
%     uicontrol(gcf,'style','pushbutton','string','darken','tag','darken','units','normalized',...
%         'position',[xnow,ynow,wid,ht],'callback','specd_viewer(''brighten'')',...
%         'tooltipstring','push once or multiple times to darken the images');
%     ynow=ynow-ht-sep;
%     uicontrol(gcf,'style','text','string','lvl 0','tag','brightness','units','normalized',...
%         'position',[xnow,ynow,wid,ht],...
%         'tooltipstring','image brightness (both images)','userdata',0);
    
    set(hax1,'tag','seis');
    
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid2 yht]);
%     [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seissd);
    if(amp)
        clip=max(clips);
    else
        clip=1;
    end
    iclip=near(clips,clip);
    am=mean(mnfsd(:));
    sigma=mean(sfsd(:));
    clim=[am-clip*sigma am+clip*sigma];
    ifsd=round(nfsd/2);
    imagesc(x,tsd,seissd(:,:,ifsd),clim);
    grid
    if(amp)
        title(['specD amplitude, frequency= ' num2str(fsd(ifsd)) ' Hz'],'interpreter','none')
    else
        title(['specD phase, frequency= ' num2str(fsd(ifsd)) ' Hz'],'interpreter','none')
    end
    set(hax2,'tag','seissd');
    %draw line indicating gather position
    tmin=min(t);
    tmax=max(t);
    klr='r';
    xm=mean(x);
    ix=near(x,xm);
    xm=x(ix(1));
    lw=1;
    line([xm xm],[tmin tmax],'color',klr,'linestyle','--','buttondownfcn','specd_viewer(''dragline'');','tag','1','linewidth',lw);
    
    if(max(tsd)<10)
        ylabel('time (s)')
    elseif(max(tsd)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('(depth (ft)')
    end
    if(max(x)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    
    %gather axis
    df=fsd(2)-fsd(1);
    hax3=subplot('position',[xnot+xwid+xwid2+2*xsep ynot xwid3 yht]);
    imagesc(fsd,tsd,squeeze(seissd(:,ix(1),:)),clim);
    colormap(cmap)
    xlim([fsd(1)-5*df fsd(end)+5*df])
    xlabel('frequency (Hz)')
    ylabel('time (sec)')
    brighten(.5);
    set(hax3,'tag','sdgather');
    %draw line indicating frequency position
    tmin=min(t);
    tmax=max(t);
    %klrs=get(hax1,'colororder');
    klr='r';
    lw=1;
    line([fsd(ifsd) fsd(ifsd)],[tmin tmax],'color',klr,'linestyle','--','buttondownfcn','specd_viewer(''dragline'');','tag','2','linewidth',lw);
    
    title(['loc= ' num2str(x(ix(1)))])
    grid
    
    %make a clip control

    xnow=xnot+2*xwid+xsep;
    ht=.05;
    ynow=ynot+yht+.5*ht;
    %wid=.045;sep=.005;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
        'position',[xnow,ynow,.8*wid,ht],'callback','specd_viewer(''clip2'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,[hax2,hax3],x,t,tsd,fsd,seissd,seis},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    
    %frequency stepping controls
    xnow=xnow+.1*wid;
    ynow=ynow-.5*ht;
    df=fsd(2)-fsd(1);
    uicontrol(gcf,'style','pushbutton','string','<','tag','stepd','units','normalized',...
        'position',[xnow,ynow,.2*wid,.5*ht],'callback','specd_viewer(''step'');',...
        'tooltipstring',['step down ' num2str(df) ' Hz']);
    xnow=xnow+.22*wid;
    uicontrol(gcf,'style','pushbutton','string','>','tag','stepu','units','normalized',...
        'position',[xnow,ynow,.2*wid,.5*ht],'callback','specd_viewer(''step'');',...
        'tooltipstring',['step up ' num2str(df) ' Hz']);
    %browse spectra button
    xnow=xnow-.22*wid;
    ynow=ynow-.5*(ht+xsep);
    uicontrol(gcf,'style','pushbutton','string','Browse spectra','tag','browse','units','normalized',...
        'position',[xnow,ynow,.8*wid,.5*ht],'callback','specd_viewer(''browse'');',...
        'tooltipstring','click to view spectra at individual locations')
    %fmax control
%     ynow=ynow-.5*(ht+xsep);
    uicontrol(gcf,'style','text','string','Max freq:','units','normalized',...
        'position',[xnow,ynow,.75*wid,.5*ht],'tooltipstring','Maximum frequency in  Hz to display');
    ynow=ynow-.5*ht;
    uicontrol(gcf,'style','edit','string',num2str(fsd(end)),'tag','fmax','units','normalized',...
        'position',[xnow,ynow,.5*wid,.5*ht],'callback','specd_viewer(''fmax'');',...
        'tooltipstring',['enter a value between ' num2str(fsd(1)) ' and ' num2str(fsd(end))]);
%     ynow=ynow-.5*ht;
%     uicontrol(gcf,'style','pushbutton','string','Ave. Amp. Spectra','tag','aveamp','units','normalized',...
%         'position',[xnow,ynow,wid,.5*ht],'callback','specd_viewer(''aveamp'');','tooltipstring',...
%         'Compare the average amplitude spectra');
    
    %zoom buttons
%     wid=.1;
%     pos=get(hax,'position');
%     xnow=pos(1)+.5*pos(3)-.5*wid;
%     ynow=.97;
%     uicontrol(gcf,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
%         'position',[xnow ynow wid .5*ht],'tag','1like2','callback','specd_viewer(''equalzoom'');');
%     
%     pos=get(hax,'position');
%     xnow=pos(1)+.5*pos(3)-.5*wid;
%     uicontrol(gcf,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
%         'position',[xnow ynow wid .5*ht],'tag','2like1','callback','specd_viewer(''equalzoom'');');

    
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.6,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
    
   
%     if(iscell(dname))
%         dn1=dname{1};
%     else
%         dn1=dname;
%     end
%     if(iscell(dname))
%         dn2=dname{1};
%     else
%         dn2=dname;
%     end
    set(gcf,'name',['Spectral decomp for ' dname],'closerequestfcn','specd_viewer(''close'');',...
        'userdata',-999.25);%userdata here is just a placeholder to cause plotimage3D to do the right thing
    if(nargout>0)
        datar=cell(1,3);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=hax3;
    end
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    msg=['The axes at left (the seismic axes) shows the ordinary sesimic, the middle axes (the specd axes) shows the spectral ',...
        'decomp for a single frequency and the rightmost axes (the frequency axes) shows the spectral decomp at ',...
        'a single location. The vertical dashed red line in the specd axes indicates the ',...
        'location being displayed in the frequency axes. Similarly, the red dashed line in the ',...
        'frequency axes indicates the frequency being highlighted in the specd axes. Either red line ',...
        'can be changed by simply clicking a dragging it. At far left above the seismic axes is a ',...
        'button labelled "Hide seismic". Clicking this removes the seismic axes from the display ',...
        'allows the specd axes to fill the window. This action also displays a new button labelled ',...
        '"Toggle" which allows the display to be switched back and forth bwtween seismic and specd. ',...
        'When both seismic and specd are shown, there are two clipping controls, the left one being for the ',...
        'seismic and the right one being for the specd. Feel free to adjust these. Smaller clip ',...
        'numbers mean greater clipping. The word "none" means there is no clipping.'];
    hinfo=msgbox(msg,'Instructions for spectral decomp tool');
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
elseif(strcmp(action,'colormap'))
    hcmap=gcbo;
    cmaps=get(hcmap,'string');
    icmap=get(hcmap,'value');
    cm=eval(cmaps{icmap});
    if(strcmp(cmaps{icmap},'blueblack')||strcmp(cmaps{icmap},'greenblack')||strcmp(cmaps{icmap},...
            'copper')||strcmp(cmaps{icmap},'bone')||strcmp(cmaps{icmap},'gray')||...
            strcmp(cmaps{icmap},'winter')||strcmp(cmaps{icmap},'bluebrown')||...
            strcmp(cmaps{icmap},'greenblue'))
        cm=flipud(cm);
    end
    hseissd=findobj(gcf,'tag','seissd');
    hgather=findobj(gcf,'tag','sdgather');
    happlytoall=findobj(gcf,'tag','applytoall');
    flag=get(happlytoall,'value');
    colormap(hseissd,cm);
    colormap(hgather,cm);
    if(flag==1)
        hseis=findobj(gcf,'tag','seis');
        colormap(hseis,cm);
    end
    %brighten(.5);
elseif(strcmp(action,'fmax'))
    hfmax=findobj(gcf,'tag','fmax');
    fmax=str2double(get(hfmax,'string'));
    hgather=findobj(gcf,'tag','sdgather');
    hspec=findobj(gcf,'tag','spectra');
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    fsd=udat{10};
    if(isnan(fmax)||fmax<=fsd(1)||fmax>fsd(end))
        fmax=fsd(end);
        set(hfmax,'string',num2str(fmax))
    end
    if(~isempty(hgather))
        axes(hgather);
        xlim([fsd(1) fmax])
    end
    if(~isempty(hspec))
        axes(hspec);
        xlim([fsd(1) fmax])
    end
elseif(strcmp(action,'clip1'))
    hclip=findobj(gcf,'tag','clip1');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
    amax=udat{4};
    amin=udat{5};
    sigma=udat{3};
    hax=udat{6}(1);
    if(iclip==1)
        clim=[amin amax];
    else
        clip=clips(iclip);
        clim=[am-clip*sigma,am+clip*sigma];
    end
    set(hax,'clim',clim);
elseif(strcmp(action,'clip2'))
    hclip=findobj(gcf,'tag','clip2');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
    %amax=udat{4};
    %amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        %clim=[amin amax];
        clip=max(clips);
    else
        clip=clips(iclip-1);
    end
    clim=[am-clip*sigma,am+clip*sigma];
    set(hax,'clim',clim);
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
    hseis=findobj(gcf,'tag','seis');
    hseissd=findobj(gcf,'tag','seissd');
    tag=get(hbut,'tag');
    switch tag
        case '1like2'
            xl=get(hseissd,'xlim');
            yl=get(hseissd,'ylim');
            set(hseis,'xlim',xl,'ylim',yl);
            
        case '2like1'
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            set(hseissd,'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'dragline'))
    hnow=gcbo;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    haxes=udat{6};
    
    h1=findobj(haxes(1),'tag','1');
%     xx=get(h1,'xdata');
%     x1=xx(1);

    h2=findobj(haxes(2),'tag','2');
%     xx=get(h2,'xdata');
%     f2=xx(2);
    
    
    hi=findobj(haxes(1),'type','image');
    x=get(hi,'xdata');
    xmin=x(1);xmax=x(end);
    
    hi=findobj(haxes(2),'type','image');
    f=get(hi,'xdata');
    fmin=f(1);fmax=f(end);
    
    DRAGLINE_SHOWPOSN='on';
    DRAGLINE_CALLBACK='';
    DRAGLINE_MOTIONCALLBACK='';
    if(hnow==h1)
        %clicked on x1
        dx=abs(x(2)-x(1));
        n=.01*length(x);
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[xmin+n*dx xmax-n*dx];
        DRAGLINE_MOTIONCALLBACK='specd_viewer(''changeloc'');';
    elseif(hnow==h2)
        %clicked on f2
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[fmin fmax];
        DRAGLINE_MOTIONCALLBACK='specd_viewer(''changefreq'');';
    end
    
    dragline('click')
elseif(strcmp(action,'changeloc'))
    hobj=gco;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    x=udat{7};
    %fsd=udat{10};
    haxes=udat{6};
    seissd=udat{11};
    if(strcmp(get(hobj,'type'),'line'))
        xx=get(hobj,'xdata');
        xnow=xx(1);
        ix=near(x,xnow);
        hi=findobj(haxes(2),'type','image');
        set(hi,'cdata',squeeze(seissd(:,ix(1),:)));
        ht=get(haxes(2),'title');
        xnow=x(ix);
        ht.String=['loc= ' num2str(xnow)];
    end
    
elseif(strcmp(action,'changefreq'))
    hobj=gco;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    %x=udat{7};
    fsd=udat{10};
    haxes=udat{6};
    seissd=udat{11};
    if(~strcmp(get(hobj,'type'),'line'))
       hobj=findobj(haxes(2),'tag','2'); 
    end
    xx=get(hobj,'xdata');
    fnow=xx(1);
    ix=near(fsd,fnow);
    fnow=fsd(ix(1));
    hi=findobj(haxes(1),'type','image');
    set(hi,'cdata',squeeze(seissd(:,:,ix(1))));
    
    ht=get(haxes(1),'title');
    str=get(ht,'string');
    ind=strfind(str,'=');
    set(ht,'string',[str(1:ind+1) num2str(fnow) ' Hz'])
elseif(strcmp(action,'step'))
    hstep=gcbo;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    %x=udat{7};
    fsd=udat{10};
    df=fsd(2)-fsd(1);
    haxes=udat{6};
    hline=findobj(haxes(2),'tag','2');
    ff=get(hline,'xdata');
    fnow=round(ff(1));
    if(strcmp(get(hstep,'tag'),'stepd'))
        fnow=fnow-df;
    else
        fnow=fnow+df;
    end
    set(hline,'xdata',[fnow fnow]);
    specd_viewer('changefreq');
    
elseif(strcmp(action,'close'))
    haveamp=findobj(gcf,'tag','aveamp');
    hspec=get(haveamp,'userdata');
    if(isgraphics(hspec))
        delete(hspec);
    end
    delete(gcf);
elseif(strcmp(action,'hideshow'))
    hbut=gcbo;
    option=get(hbut,'userdata');
    hclip1=findobj(gcf,'tag','clip1');
    udat1=get(hclip1,'userdata');
    hax1=udat1{6};
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax2=udat2{6}(1);
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    htoggle=findobj(gcf,'tag','toggle');
    
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
            set(hbut,'string','Show seismic','userdata','show')
            set(htoggle,'visible','on');
        case 'show'
            udat=get(htoggle,'userdata');
            pos1=udat{1};
            pos2=udat{2};
            set(hax1,'visible','on','position',pos1);
            set([hi1 hclip1],'visible','on');
            set(hax2,'visible','on','position',pos2);
            set(htoggle','visible','off')
            set(hbut,'string','Hide seismic','userdata','hide');
            set([hi2 hclip2],'visible','on');
    end
elseif(strcmp(action,'toggle'))
    hclip1=findobj(gcf,'tag','clip1');
    udat1=get(hclip1,'userdata');
    hax1=udat1{6};
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax2=udat2{6}(1);
    hi1=findobj(hax1,'type','image');
    hi2=findobj(hax2,'type','image');
    
    option=get(hax1,'visible');
    switch option
        case 'off'
            %ok, turning on seismic
            set([hax1 hclip1 hi1],'visible','on');
            set([hax2 hclip2 hi2],'visible','off');
            
        case 'on'
            %ok, turning off seismic
            set([hax1 hclip1 hi1],'visible','off');
            set([hax2 hclip2 hi2],'visible','on');
    end
elseif(strcmp(action,'browse'))
    hbrowse=gcbo;
    mode=get(hbrowse,'string');
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax1=findobj(gcf,'tag','seis');
    hax2=udat2{6}(1);
    switch mode
        case 'Browse spectra'
            set(hbrowse,'string','Stop browse');
            
            %determine if specD is full or half
            pos=get(hax2,'position');
            if(pos(3)>.4)
                %full
                bdy=.05;
                fact=1;
                hback=axes('position',[pos(1)-fact*bdy,pos(2)+.75*pos(4)-bdy, .2*pos(3)+fact*bdy, .25*pos(4)+bdy],...
                    'tag','back');
                axes('position',[pos(1),pos(2)+.75*pos(4), .2*pos(3), .25*pos(4)],...
                    'tag','spectra');
            else
                %half
                pos1=get(hax1,'position');
                bdy=.05;
                fact=.75;
                hback=axes('position',[pos1(1)+.6*pos1(3)-fact*bdy,pos1(2)+.25*pos1(4)-bdy, .4*pos1(3)+fact*bdy,...
                    .35*pos1(4)+bdy],'tag','back');
                axes('position',[pos1(1)+.6*pos1(3),pos1(2)+.25*pos1(4), .4*pos1(3),...
                    .35*pos1(4)],'tag','spectra');
            end
            set(hback,'xtick',[],'ytick',[],'xcolor',[1 1 1],'ycolor',[1 1 1]);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','specd_viewer(''specpt'');');
        case 'Stop browse'
            set(hbrowse,'string','Browse spectra');
            hback=findobj(gcf,'tag','back');
            delete(hback);
            haxspec=findobj(gcf,'tag','spectra');
            delete(haxspec);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','');
            udat=get(hbrowse,'userdata');
            if(~isempty(udat))
                delete(udat{1});
            end
            set(hbrowse,'userdata',[]);
    end
elseif(strcmp(action,'specpt'))
    kols=get(gca,'colororder');
    mkrs={'.','o','x','+','*','s','d','v','^','<','>','p','h'};
    nk=size(kols,1);
    nm=length(mkrs);
    hbrowse=findobj(gcf,'tag','browse');
    udatb=get(hbrowse,'userdata');
    if(isempty(udatb))
       nlines=1;
    else
       nlines=length(udatb{1})+1; 
    end
    ik=nlines;
    if(ik>nk)
        ik=nlines-nk;
        if(ik>nk)
            ik=nlines-2*nk;
        end
    end
    im=nlines;
    if(im>nm)
        im=nlines-nm;
        if(im>nm)
            im=nlines-2*nm;
        end
    end
    hseissd=gca;
    pt=get(hseissd,'currentpoint');
    hm=line(pt(1,1),pt(1,2),'linestyle','none','marker',mkrs{im},'color',kols(ik,:),'markersize',10,'linewidth',1);
    
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    x=udat{7};
    tsd=udat{9};
    fsd=udat{10};
    seissd=udat{11};
    %haxes=udat{6};
    it=near(tsd,pt(1,2));
    ix=near(x,pt(1,1));
    spec=squeeze(seissd(it,ix,:));
    haxspec=findobj(gcf,'tag','spectra');
    axes(haxspec)
    hs=line(fsd,spec,'linestyle','-','marker',mkrs{im},'color',kols(ik,:));
    
    if(isempty(udatb))
        udatb={hm,hs};
        xlabel('Frequency');ylabel('Amplitude')
    else
        udatb={[udatb{1} hm],[udatb{2} hs]};
    end
    set(hbrowse,'userdata',udatb);
    
    
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

%clips=linspace(nsigma,1,nclips)';
clips=[20 15 10 8 6 4 3 2 1 .5 .25 .1 .075 .05 .025 .01 .005 .001 .0001]';
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
clip=clips(iclip);

end