function datar=seisplot_fdomtslice(slices,t,x,y,dname,cmap)
% seisplot_fdomtslice: Interactactive dominant freqeuncy computation on time slices
%
% datar=seisplot_fdomtslice(slices,t,x,y,dname,cmap)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% volume is displayed in the left-hand-side and the corresponding dominant frequency volume is shown
% the the right-hand side. Initial fdom parameters come either from internal defaults or global
% variables. Controls are provided to explore both volumes and to compute new fdom volumes with
% different parameters.
%
% slices ... 3D seismic matrix of time slices, should be short in the first dimension (time)
% t ... first dimension (time) coordinate vector for slices
% x ... second dimension (xline) coordinate vector for slices
% y ... third dimension (inline) coordinate vector for slices
% dname ... text string nameing the slices matrix.
%   *********** default = 'Input data' **************
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the input seismic axes
%           data{2} ... handle of the fdom axes
% These return data are provided to simplify plotting additional lines and text in either axes.
% 
% NOTE: The key parameters for the dominant frequency computation are twin, tinc, fmax, and tfmax
% and the starting values for these can be controlled by defining the global variables below. These
% globals have names that are all caps. The default value applies when the corresponding global is
% either undefined or empty.
% FDOM_TWIN ... half-width of the Gaussian windows (standard deviation) in seconds
%  ************ default = 0.01 seconds ************
% FDOM_TINC ... increment between adjacent Gaussians
%  ************ default = 2*dt seconds (dt is the time sample size of the data) ***********
% FDOM_FMAX ... maximum signal frequency in the dataset. specified at the reference time  (in Hertz)
%  ************ default 0.25/dt Hz which is 1/2 of Nyquist *************
% FDOM_TFMAX ... reference time at which FDOM_FMAX is specified (in seconds)
% ************* default mean(t) seconds ***************
%
% 
% G.F. Margrave, Devon, 2018
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
global FDOM_TWIN FDOM_TINC FDOM_FMAX FDOM_TFMAX
global NEWFIGVIS WaitBarContinue XCFIG YCFIG BIGFIG_WIDTH BIGFIG_HEIGHT  %#ok<NUSED>
if(~ischar(slices))
    action='init';
else
    action=slices;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(nargin<4)
        error('at least 4 inputs are required');
    end
    if(nargin<5)
        dname='Input data';
    end
    if(nargin<6)
        cmap='seisclrs';
    end
    
%     x2=x1;
%     t2=t1;
    dt=t(2)-t(1);
    fnyq=.5/dt;
    if(isempty(FDOM_FMAX))
        fmax=round(.25*fnyq);
    else
        fmax=FDOM_FMAX;
    end
    if(isempty(FDOM_TFMAX))
        tfmax=mean(t);
    else
        tfmax=FDOM_TFMAX;
    end
    if(isempty(FDOM_TWIN))
        twin=0.01;
    else
        twin=FDOM_TWIN;
    end
    if(isempty(FDOM_TINC))
        tinc=2*dt;
    else
        tinc=FDOM_TINC;
    end

    
    if(length(t)~=size(slices,1))
        error('time coordinate vector does not match time slices matrix');
    end
    if(length(x)~=size(slices,2))
        error('xline coordinate vector does not match time slices matrix');
    end
    if(length(y)~=size(slices,3))
        error('inline coordinate vector does not match time slices matrix');
    end
    [nt,nx,ny]=size(slices); %#ok<ASGLU>
    
    if(iscell(dname))
        dname=dname{1};
    end

    xwid=.35;
    yht=.8;
    xsep=.1;
    xnot=.05;
    ynot=.1;
    

%     if(~isempty(NEWFIGVIS))
%         figure('visible',NEWFIGVIS);
%     else
%         figure
%     end
    if(~isempty(XCFIG))
        if(isempty(BIGFIG_WIDTH))
            figwid=1900;
            fight=900;
        else
            figwid=BIGFIG_WIDTH;
            fight=BIGFIG_HEIGHT;
        end
        figx=XCFIG-.5*figwid;
        figy=YCFIG-.5*fight;
        figure('position',[figx,figy,figwid,fight]);
    else
        figure;
    end
    hax1=subplot('position',[xnot ynot xwid yht]);

    inot=near(t,t(round(nt/2)));
    inot=inot(1);
    seis1=squeeze(slices(inot,:,:))';
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis1);
    clim=[am-clip*sigma am+clip*sigma];
        
    hi=imagesc(x,y,seis1,clim);colormap(seisclrs);
    hcm=uicontextmenu;
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d); 
    set(hi,'uicontextmenu',hcm);
    brighten(.5);
    grid
    ht=title({dname,['time= ' time2str(t(inot))]});
    ht.Interpreter='none';
    xlabel('crossline')
    ylabel('inline')
    

    wid=.055;ht=.05;sep=.005;
    xnow=xnot+xwid+sep;
    %make a clip control
    ynow=ynot+yht-ht;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_fdomtslice(''clip1'')','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax1,[]},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    ht=.5*ht;
    ynow=ynow-sep;
    ilive=seis1~=0;
    uicontrol(gcf,'style','radiobutton','string','Auto adjust clip','tag','autoclip1','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
        'tooltipstring','clip level auto adjusted with each time slice')
     
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnow,ynow+2.5*ht,.5*wid,ht],'callback','seisplot_fdomtslice(''info'');',...
        'backgroundcolor','y');
    
    
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','brighten','tag','brighten','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_fdomtslice(''brighten'')',...
        'tooltipstring','push once or multiple times to brighten the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','darken','tag','darken','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_fdomtslice(''brighten'')',...
        'tooltipstring','push once or multiple times to darken the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','lvl 0','tag','brightness','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','image brightness (both images)','userdata',0);
    
    set(hax1,'tag','seis1');
    
    %time location thermometer
    xnow=xnow+.25*wid;
    widtherm=.75*wid;
    httherm=4*xsep;
    ytherm=ynow-ht-httherm;
    htherm=uithermometer(gcf,[xnow,ytherm,widtherm,httherm],'Time slice',t,30,'seisplot_fdomtslice(''jump'');');
    set(htherm,'tag','thermt');
    
    %prev and next buttons
    ynow=ytherm-5*sep;
    %prev and next buttons
    wid=.055;ht=.05;sep=.005;
    xnow=xnot+xwid+sep;
    uicontrol(gcf,'style','pushbutton','string','Next lesser time','tag','prev','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_fdomtslice(''step'');',...
        'tooltipstring','Step to lesser time');
    ynow=ynow-.5*ht;
    uicontrol(gcf,'style','pushbutton','string','Next deeper time','tag','next','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_fdomtslice(''step'');',...
        'tooltipstring','Step to greater time','userdata',{slices,t,x,y,dname,inot});
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    xlabel('line coordinate')
    
    
    %make a clip control

    xnow=xnot+2*xwid+xsep+sep;
    ht=.05;
    ynow=ynot+yht-ht;
    %wid=.045;sep=.005;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_fdomtslice(''clip2'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax2,[]},'tooltipstring',...%the values here in userdata are placeholders. See 'computefdom' for the real thing
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    ht=.5*ht;
    ynow=ynow-sep;
    %ynow=ynow-ht;
    uicontrol(gcf,'style','radiobutton','string','Auto adjust clip','tag','autoclip2','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
        'tooltipstring','clip level auto adjusted with each time slice')
    %controls to choose the dominant frequency display section 
    ynow=ynow-4*ht-sep;
    hbg=uibuttongroup('position',[xnow,ynow,1.5*wid,4*ht],'title','Display choice','tag','choices',...
        'selectionchangedfcn','seisplot_fdomtslice(''choice'');');
    ww=1;
    hh=.333;
    uicontrol(hbg,'style','radiobutton','string','Dom. Freq.','units','normalized','tag','freq',...
        'position',[0,2*hh,ww,hh],'value',1,'tooltipstring','Display dominant frequency');
    uicontrol(hbg,'style','radiobutton','string','Bandwidth','units','normalized','tag','bw',...
        'position',[0,hh,ww,hh],'value',0,'tooltipstring','Display bandwidth about dominant frequency');
    uicontrol(hbg,'style','radiobutton','string','Amp at Fdom','units','normalized','tag','amp',...
        'position',[0,0,ww,hh],'value',0,'tooltipstring','Display amplitude at dominant frequency');
    
    %fdom parameters
    ht=.025;
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Fdom parameters:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'tooltipstring','Change these values and then click "Compute Fdom"');
    ynow=ynow-ht-sep;
    wid=wid*.5;
    uicontrol(gcf,'style','text','string','Twin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Gaussian window half-width in seconds');
    uicontrol(gcf,'style','edit','string',num2str(twin),'units','normalized','tag','twin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds corresponding to a few samples');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Tinc:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Increment between consequtive windows in seconds');
    uicontrol(gcf,'style','edit','string',num2str(tinc),'units','normalized','tag','tinc',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in seconds smaller than Twin');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Maximum frequency of interest at time Tfmax');
    uicontrol(gcf,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Tfmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Reference time at which Fmax applies');
    uicontrol(gcf,'style','edit','string',num2str(tfmax),'units','normalized','tag','tfmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Compute Fdom','units','normalized',...
        'position',[xnow,ynow,3*wid,ht],'callback','seisplot_fdomtslice(''computefdom'');',...
        'tooltipstring','Compute Fdom with current parameters','tag','fdombutton');
    
    %colormap controls
    ht=.025;
    ynow=ynow-1.5*ht;
    wid=3*wid;
    uicontrol(gcf,'style','text','string','Colormap:','tag','colomaplabel',...
        'units','normalized','position',[xnow ynow wid ht]);
    ynow=ynow-ht;
    uicontrol(gcf,'style','radiobutton','string','Show colorbars','tag','colorbars',...
        'units','normalized','position',[xnow ynow wid ht],'value',0,...
        'callback','seisplot_fdomtslice(''colorbars'');');
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
    ynow=ynow-ht;
    uicontrol(gcf,'style','popupmenu','string',colormaps,'tag','colormap',...
        'units','normalized','position',[xnow ynow wid ht],'callback',...
        'seisplot_fdomtslice(''colormap'');','value',icolor);
    ynow=ynow-2*ht-5*sep;
    hbg=uibuttongroup('position',[xnow,ynow,wid,3*ht],'title','Colormap goes to','tag','cmapgt');
    uicontrol(hbg,'style','radiobutton','string','left','tag','left','units','normalized',...
        'position',[0 2/3 1 1/3],'value',0);
    uicontrol(hbg,'style','radiobutton','string','right','tag','right','units','normalized',...
        'position',[0 1/3 1 1/3],'value',1);
    uicontrol(hbg,'style','radiobutton','string','both','tag','both','units','normalized',...
        'position',[0 0 1 1/3],'value',0);
    
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(gcf,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplot_fdomtslice(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(gcf,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplot_fdomtslice(''equalzoom'');');
    
    %results popup
    wida=.065;
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid2=pos(3)-wida-.25*xsep;
    ht=3*ht;
    fs=12;
    uicontrol(gcf,'style','popupmenu','string','...','units','normalized','tag','results',...
        'position',[xnow,ynow,wid2,ht],'callback','seisplot_fdomtslice(''select'');','fontsize',fs,...
        'fontweight','bold');
    
    %bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.2,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
%     whitefig;
    
    set(hax2,'tag','seis2');
    seisplot_fdomtslice('computefdom');
%     if(iscell(dname2))
%         dn2=dname2{1};
%     else
%         dn2=dname2;
%     end
    set(gcf,'name',['Fdom for ' dname ' at time= ' time2str(t(inot))],...
        'closerequestfcn','seisplot_fdomtslice(''close'');','menubar','none','toolbar',...
        'figure','numbertitle','off');
    colormap(cmap)
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
    end
elseif(strcmp(action,'choice'))
    hchoice=findobj(gcf,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    hresults=findobj(gcf,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    switch choice
        case 'freq'
            i4=1;
            clipdat=results.clipdat1{iresult};
        case 'bw'
            i4=3;
            clipdat=results.clipdat3{iresult};
        case 'amp'
            i4=2;
            clipdat=results.clipdat2{iresult};
    end
    clips=clipdat{1};
    clipstr=clipdat{2};
    clip=clipdat{3};
    iclip=clipdat{4};
    sigma=clipdat{5};
    am=clipdat{6};
    amax=clipdat{7};
    amin=clipdat{8};
    hseis2=findobj(gcf,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    clim=[am-clip*sigma am+clip*sigma];
    set(hseis2,'clim',clim);
    hclip2=findobj(gcf,'tag','clip2');
    %update graphical clip window
    uc=get(hclip2,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=gcf;
            idat=seis2~=0;
            [N,xn]=hist(seis2(idat),100);
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    tmp=get(hclip2,'userdata');
    if(length(tmp)>6)
        if(isgraphics(tmp{7}))
            close(tmp{7});
        end
    end
    set(hclip2,'userdata',{clips,am,sigma,amax,amin,hseis2,[]},'string',clipstr,'value',iclip);
    seisplot_fdomtslice('clip2');
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
        %clim=[amin amax];
        %clim=[0 amax];
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
            hfig=tmp;
        else
            hfig=figure('position',[x0,y0,fwid,fht],'menubar','none','toolbar','none',...
            'numbertitle','off','name','Colorbar limits chooser','tag','climchooser');
            ud=get(hmasterfig,'userdata');
            if(~iscell(ud))
                ud={hfig ud};
            else
                if(ud{1}==-999.25)
                    ud{1}=hfig;
                else
                    ud{1}=[ud{1} hfig];
                end
            end
            set(hmasterfig,'userdata',ud);
        end
%         ud=get(hmasterfig,'userdata');
%         if(~iscell(ud))
%             ud=[ud hfig];
%         else
%             ud{1}=[ud{1} hfig];
%         end
%        set(hmasterfig,'userdata',ud);
        udat{7}=hfig;
        set(hclip,'userdata',udat);
        WinOnTop(hfig,true);
        climslider(hax,hfig,[0 0 1 1],N,xn);
    else
        if(isgraphics(udat{7}))
            close(udat{7});
        end
        clip=clips(iclip);
        clim=[am-clip*sigma,am+clip*sigma];
        set(hax,'clim',clim);
    end
    
elseif(strcmp(action,'autoclip1'))
    hfig=gcf;
    if(strcmp(get(hfig,'name'),'Colorbar limits chooser'))
        hfig=get(hfig,'userdata');
    end
    hauto=findobj(hfig,'tag','autoclip1');
    val=get(hauto,'value');
    if(val==0)
        return;
    end
    hseis1=findobj(hfig,'tag','seis1');
    hi=findobj(hseis1,'type','image');
    seis1=hi.CData;
    hclip1=findobj(hfig,'tag','clip1');
    udat=get(hclip1,'userdata');
    ilive=get(hauto,'userdata');
    sigma=std(seis1(ilive));
    am=mean(seis1(ilive));
    udat{2}=am;
    oldsigma=udat{3};
    udat{3}=sigma;
    if(get(hclip1,'value')==1)
        %in graphical
        cl=get(hseis1,'clim');
        cl=cl*sigma/oldsigma;
        if(isgraphics(udat{7}))
            h1=findobj(udat{7},'tag','clim1');
            hax=get(h1,'parent');
            yl=get(hax,'ylim');
            set(h1,'xdata',cl(1)*ones(1,2),'ydata',yl);
            h2=findobj(udat{7},'tag','clim2');
            set(h2,'xdata',cl(2)*ones(1,2),'ydata',yl);
        end
        set(hseis1,'clim',cl);
    end
    
    set(hclip1,'userdata',udat);
    seisplot_fdomtslice('clip1');
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
        %clim=[amin amax];
        %clim=[0 amax];
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
            return;
        else
            hfig=figure('position',[x0,y0,fwid,fht],'menubar','none','toolbar','none',...
                'numbertitle','off','name','Colorbar limits chooser');
            ud=get(hmasterfig,'userdata');
            if(~iscell(ud))
                ud={hfig ud};
            else
                if(ud{1}==-999.25)
                    ud{1}=hfig;
                else
                    ud{1}=[ud{1} hfig];
                end
            end
            set(hmasterfig,'userdata',ud);
        end
%         ud=get(hmasterfig,'userdata');
%         if(~iscell(ud))
%             ud=[ud hfig];
%         else
%             ud{1}=[ud{1} hfig];
%         end
        
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
        %clim=[max([am-clip*sigma,0]),am+clip*sigma];
        clim=[am-clip*sigma,am+clip*sigma];
        %clim=[amin am+clip*sigma];
        set(hax,'clim',clim);
        hresult=findobj(hmasterfig,'tag','results');
        results=get(hresult,'userdata');
        if(~isempty(results))
            iresult=get(hresult,'value');
            results.iclips{iresult}=iclip;
            set(hresult,'userdata',results)
        end
    end
elseif(strcmp(action,'autoclip2'))
    hfig=gcf;
    if(strcmp(get(hfig,'name'),'Colorbar limits chooser'))
        hfig=get(hfig,'userdata');
    end
    hauto=findobj(hfig,'tag','autoclip2');
    val=get(hauto,'value');
    if(val==0)
        return;
    end
    hseis2=findobj(hfig,'tag','seis2');
    hi=findobj(hseis2,'type','image');
    seis2=hi.CData;
    hclip2=findobj(hfig,'tag','clip2');
    udat=get(hclip2,'userdata');
    ilive=get(hauto,'userdata');
    sigma=std(seis2(ilive));
    am=mean(seis2(ilive));
    udat{2}=am;
    oldsigma=udat{3};
    udat{3}=sigma;
    if(get(hclip2,'value')==1)
        %in graphical
        cl=get(hseis2,'clim');
        cl=cl*sigma/oldsigma;
        if(isgraphics(udat{7}))
            h1=findobj(udat{7},'tag','clim1');
            hax=get(h1,'parent');
            yl=get(hax,'ylim');
            set(h1,'xdata',cl(1)*ones(1,2),'ydata',yl);
            h2=findobj(udat{7},'tag','clim2');
            set(h2,'xdata',cl(2)*ones(1,2),'ydata',yl);
        end
        set(hseis2,'clim',cl);
    end
    
    set(hclip2,'userdata',udat);
    seisplot_fdomtslice('clip2');    
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
elseif(strcmp(action,'step'))
    hbut=gcbo;
    step='d';
    if(strcmp(get(hbut,'tag'),'prev'))
        step='u';
    end
    %step the seismic
    hseis1=findobj(gcf,'tag','seis1');
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    inot=udat{6};
    if(step=='u')
        inot=max([1,inot-1]);
    else
        inot=min([length(t),inot+1]);
    end
    udat{6}=inot;
    set(hnext,'userdata',udat);
    tnot=t(inot);
    ht=hseis1.Title.String;
    ht{2}=['time= ' time2str(tnot)];
    hseis1.Title.String=ht;
    seis1=squeeze(slices(inot,:,:))';
    hi=findobj(hseis1,'type','image');
    hi.CData=seis1;
    %update graphical clip window
    hclip1=findobj(gcf,'tag','clip1');
    uc=get(hclip1,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=gcf;
            idat=seis1~=0;
            [N,xn]=hist(seis1(idat),100);
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    seisplot_fdomtslice('autoclip1');
    %step the fdom
    %determine the display choice
    hchoice=findobj(gcf,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    switch choice
        case 'freq'
            i4=1;
        case 'bw'
            i4=3;
        case 'amp'
            i4=2;
    end
    hresults=findobj(gcf,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hseis2=findobj(gcf,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update graphical clip window
    hclip2=findobj(gcf,'tag','clip2');
    uc=get(hclip2,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=gcf;
            idat=seis2~=0;
            [N,xn]=hist(seis2(idat),100);
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    %update thermometer
    hthermt=findobj(gcf,'tag','thermt');
    uithermometer('set',hthermt,tnot);
    seisplot_fdomtslice('autoclip2');
elseif(strcmp(action,'jump'))
    hfig=gcf;
    if(strcmp(get(hfig,'tag'),'climchooser'))
        hmasterfig=get(hfig,'userdata');
    else
        hmasterfig=hfig;
    end
    hbut=gcbo;
    tnot=get(hbut,'userdata');
    %step the seismic
    hseis1=findobj(hmasterfig,'tag','seis1');
    hnext=findobj(hmasterfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    dt=abs(t(2)-t(1));
    inot=round((tnot-t(1))/dt)+1;
    udat{6}=inot;
    set(hnext,'userdata',udat);
    ht=hseis1.Title.String;
    ht{2}=['time= ' time2str(tnot)];
    hseis1.Title.String=ht;
    seis1=squeeze(slices(inot,:,:))';
    hi=findobj(hseis1,'type','image');
    hi.CData=seis1;
    %update graphical clip window
    hclip1=findobj(hmasterfig,'tag','clip1');
    uc=get(hclip1,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=hmasterfig;
            idat=seis1~=0;
            [N,xn]=hist(seis1(idat),100);
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    seisplot_fdomtslice('autoclip1');
    %step the fdom
    %determine the display choice
    hchoice=findobj(hmasterfig,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    switch choice
        case 'freq'
            i4=1;
        case 'bw'
            i4=3;
        case 'amp'
            i4=2;
    end
    hresults=findobj(hmasterfig,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hseis2=findobj(hmasterfig,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    hi2=findobj(hseis2,'type','image');
    hi2.CData=seis2;
    %update graphical clip window
    hclip2=findobj(hmasterfig,'tag','clip2');
    uc=get(hclip2,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=hmasterfig;
            idat=seis2~=0;
            [N,xn]=hist(seis2(idat),100);
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    seisplot_fdomtslice('autoclip2');
elseif(strcmp(action,'computefdom'))
    %plan: apply the fdom parameters and display the results
    hfig=gcf;
    hseis2=findobj(hfig,'tag','seis2');
    hnext=findobj(hfig,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    x=udat{3};
    y=udat{4};
    %dname=udat{5};
    inot=udat{6};
    tmax=max(t);
    tmin=min(t);
    tlen=tmax-tmin;
    dt=t(2)-t(1);
    fnyq=.5/dt;
    
    %get the window size
    hw=findobj(gcf,'tag','twin');
    val=get(hw,'string');
    twin=str2double(val);
    if(isnan(twin))
        msgbox('Twin is not recognized as a number','Oh oh ...');
        return;
    end
    if(twin<0 || twin>.25*tlen)
        msgbox('twin is unreasonable, must be positive and less than (Tmax-Tmin)/4');
        return;
    end
    %get the window increment
    hw=findobj(gcf,'tag','tinc');
    val=get(hw,'string');
    tinc=str2double(val);
    if(isnan(tinc))
        msgbox('Tinc is not recognized as a number','Oh oh ...');
        return;
    end
    if(tinc<0 || tinc>twin)
        msgbox('tinc is unreasonable, must be positive and less than Twin');
        return;
    end
    %get fmax
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
    %get tfmax
    hobj=findobj(gcf,'tag','tfmax');
    val=get(hobj,'string');
    tfmax=str2double(val);
    if(isnan(tfmax))
        msgbox('tfmax is not recognized as a number','Oh oh ...');
        return;
    end
    if(tfmax<t(1) || tfmax>t(end))
        msgbox('tfmax must be greater than t(1) and less than t(end)','Oh oh ...');
        return;
    end
    
    %compute fdom
    t0=clock;
    ievery=1;
    nt=length(t);
    ny=length(y);
    nx=length(x);
    fdom=zeros(nt,nx,ny,3);%In the 4th dim, 1 is fd, 2 is afd, 3 is bwfd
    if(isempty(XCFIG))
       posw=[400 100];
    else
       posw=[XCFIG-200,YCFIG-50,400,100];
    end
    hbar=WaitBar(0,ny,'Fdom computation','Computing dominant frequency',posw);
    for k=1:ny %loop over inlines
        s2d=squeeze(slices(:,:,k));
        if(sum(abs(s2d(:)))>0) %avoid all zeros s2d
            [fd,afd,bwfd]=tv_afdom(s2d,t,twin,tinc,[fmax tfmax],1,2,1);
            %[amp,phs,tsd,f2d]=tv_afdom(s2d,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,-1); %#ok<ASGLU>
            %Accumulate results
            fdom(:,:,k,1)=fd;
            fdom(:,:,k,2)=afd;
            fdom(:,:,k,3)=bwfd;
            if(rem(k,ievery)==0)
                time_used=etime(clock,t0);
                time_per_line=time_used/k;
                timeleft=(ny-k-1)*time_per_line/60;
                timeleft=round(100*timeleft)/100;
                WaitBar(k,hbar,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            if(~WaitBarContinue)
                break;
            end
        end
    end
    delete(hbar);
    set(hfig,'currentaxes',hseis2)
    %get the current display choice
    hchoice=findobj(gcf,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    switch choice
        case 'freq'
            i4=1;
        case 'bw'
            i4=3;
        case 'amp'
            i4=2;
    end
    seis2=squeeze(fdom(inot,:,:,i4))';
    %choose 10 time slices
    nr=min([10 nt]);
    irt=randi(nt,nr);
    
    %calculate 3 different clipdats
    for j=1:3
        A=fdom(irt,:,:,j);
        [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(A(:));
        if(j==1)
            %frequency
            clipdat1={clips,clipstr,clip,iclip,sigma,am,amax,amin};
        elseif(j==2)
            %amp
            clipdat2={clips,clipstr,clip,iclip,sigma,am,amax,amin};
        elseif(j==3)
            %bandwidth
            clipdat3={clips,clipstr,clip,iclip,sigma,am,amax,amin};
        end
        if(j==i4)
            clim=[am-clip*sigma am+clip*sigma];
            hclip2=findobj(hfig,'tag','clip2');
            %delete any graphical clipdat
            tmp=get(hclip2,'userdata');
            if(length(tmp)>6)
                if(isgraphics(tmp{7}))
                    close(tmp{7});
                end
            end
            set(hclip2,'userdata',{clips,am,sigma,amax,amin,hseis2,[]},'string',clipstr,'value',iclip);
        end
    end
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    hi=imagesc(x,y,seis2,clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d); 
    set(hi,'uicontextmenu',hcm);
    xlabel('crossline');ylabel('inline');
    name=['Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ...
        ', Fmax= ', num2str(fmax) ', Tfmax= ', num2str(tfmax)];
    set(hseis2,'tag','seis2','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.data={fdom};
        results.twins={twin};
        results.tincs={tinc};
        results.fmaxs={fmax};
        results.tfmaxs={tfmax};
        results.clipdat1={clipdat1};
        results.clipdat2={clipdat2};
        results.clipdat3={clipdat3};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.data{nresults}=fdom;
        results.twins{nresults}=twin;
        results.tincs{nresults}=tinc;
        results.fmaxs{nresults}=fmax;
        results.tfmaxs{nresults}=tfmax;
        results.clipdat1{nresults}=clipdat1;
        results.clipdat2{nresults}=clipdat2;
        results.clipdat3{nresults}=clipdat3;
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hcompute=findobj(hfig,'tag','fdombutton');
    set(hcompute,'userdata',nresults);%the current result number stored here
elseif(strcmp(action,'select'))
    hfig=gcf;
    
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hcompute=findobj(hfig,'tag','fdombutton');
    set(hcompute,'userdata',iresult);
    hseis2=findobj(hfig,'tag','seis2');
    hop=findobj(hfig,'tag','twin');
    set(hop,'string',num2str(results.twins{iresult}));
    hstab=findobj(hfig,'tag','tinc');
    set(hstab,'string',num2str(results.tincs{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    htfmax=findobj(hfig,'tag','tfmax');
    set(htfmax,'string',num2str(results.tfmaxs{iresult}));
    %get the proper time slice
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %determine the display choice
    hchoice=findobj(gcf,'tag','choices');
    hselected=get(hchoice,'selectedobject');
    choice=get(hselected,'tag');
    switch choice
        case 'freq'
            i4=1;
            clipdat=results.clipdat1{iresult};
        case 'bw'
            i4=3;
            clipdat=results.clipdat3{iresult};
        case 'amp'
            i4=2;
            clipdat=results.clipdat2{iresult};
    end
    seis2=squeeze(results.data{iresult}(inot,:,:,i4))';
    %update clipping
    clips=clipdat{1};
    clipstr=clipdat{2};
    clip=clipdat{3};
    iclip=clipdat{4};
    sigma=clipdat{5};
    am=clipdat{6};
    amax=clipdat{7};
    amin=clipdat{8};
    clim=[am-clip*sigma am+clip*sigma];
    
    hi=findobj(hseis2,'type','image');
    hi.CData=seis2;
    
    hclip2=findobj(gcf,'tag','clip2');
    %update graphical clip window
    hgfig=[];
    uc=get(hclip2,'userdata');
    if(length(uc)>6)
        if(isgraphics(uc{7}))
            hfig=gcf;
            hgfig=uc{7};
            figure(hgfig);
            idat=seis2~=0;
            [N,xn]=hist(seis2(idat),100);
            climslider('refresh',uc{7},N,xn);
            figure(hfig);
        end
    end
    iclipnow=get(hclip2,'value');
    if(iclipnow==1)
        iclip=iclipnow;
    else
        set(hseis2,'clim',clim);
    end
    set(hclip2,'string',clipstr','value',iclip,'userdata',{clips,am,sigma,amax,amin,hseis2,hgfig});
    seisplot_fdomtslice('clip2');
elseif(strcmp(action,'colormap'))
    hcmap=gcbo;
    cmaps=get(hcmap,'string');
    icmap=get(hcmap,'value');
    hcmp=findobj(gcf,'tag','cmapgt');
    switch hcmp.SelectedObject.Tag
        case 'left'
            hax1=findobj(gcf,'tag','seis1');
            colormap(hax1,cmaps{icmap});
        case 'right'
            hax2=findobj(gcf,'tag','seis2');
            colormap(hax2,cmaps{icmap});
        case 'both'
            hax1=findobj(gcf,'tag','seis1');
            hax2=findobj(gcf,'tag','seis2');
            colormap(hax1,cmaps{icmap});
            colormap(hax2,cmaps{icmap});
    end
elseif(strcmp(action,'colorbars'))
    hcbar=gcbo;
    hax1=findobj(gcf,'tag','seis1');
    hax2=findobj(gcf,'tag','seis2');
    val=get(hcbar,'value');
    if(val==1)
        axes(hax1);
        colorbar
        axes(hax2)
        colorbar
    else
        axes(hax1);
        colorbar off
        axes(hax2)
        colorbar off
    end
elseif(strcmp(action,'close'))
    hfig=gcf;
    hspec=findobj(hfig,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    delete(hspecwin);
    hi=findobj(hfig,'tag','info');
    hinfo=get(hi,'userdata');
    if(isgraphics(hinfo))
        delete(hinfo);
    end
    hclip=findobj(hfig,'tag','clip1');
    ud=get(hclip,'userdata');
    if(isgraphics(ud{7}))
        close(ud{7});
    end
    hclip=findobj(hfig,'tag','clip2');
    ud=get(hclip,'userdata');
    if(isgraphics(ud{7}))
        close(ud{7});
    end
    crf=get(gcf,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(gcf);
    end
elseif(strcmp(action,'info'))
    hi=gcbo;
    msg={['The axes at left (the seismic axes) shows the input sesimic and the axes at right ',...
        '(Fdom axes) shows any of three dominant frequency attributes. Both axes are showing the ',...
        'same time slice and controls to change the time are just to the right of the seismic axes. ',...
        'There are two buttons labelled "Next lesser time" and "Next deeper time" that step one time sample ',...
        'in either direction. Above these buttons is a tall rectangle labeled "Time slice" that ',...
        'enables a quick jump to any of 30 positions within the set of time slices. Hover the mouse over ',...
        'one of the tiny buttons and you will see the time for that button. Pressing the button ',...
        'gets you there. Within this rectangle at the bottom are buttons to step up or down ',...
        'through the 30 jump points.'],[],...
        ['To the right of the Fdom axes are controls to choose the Fdom attribute to display and ',...
        'to change the Fdom computation.  The three Fdom attributes are (1) "Dom. Freq." in which ',...
        ' the ampltude is the numerical value of the dominant frequency in Hz, (2) "Bandwidth" in ',...
        'which the amplitude is the numerical value of the bandwidth in Hz and centered at the ',...
        'dominant frequency, and (3) "Amp at Fdom" where the amplitude is the value of the amplitude ',...
        'spectrum at the dominant frequency. The third attribute is closely related to a spectral ',...
        'decomposition.'],[],['If you change one of the four Fdom parameters, you can then push ',...
        '"Compute Fdom" to compute a new Fdom result. The previous result remains in memory and ',...
        'can be returned to by simply using the popup menu above the Fdom axes. You can have any ',...
        'number of results in memory at the same time. The most important parameters are Twin, which ',...
        'is the halfwidth of the Gaussian time window that "localizes" the computation, and "Tinc", ',...
        'which is the separation between adjacent window centers. Making these smaller causes the ',...
        'computation to be more local but also reduces the resolution of the frequency spectrum which ',...
        'makes the Fdom values less distinct. '],[],...
        ['The colormap tool is easy to figure out and can assign one ',...
        'of a list of pre-built colormaps to either axis. The colormaps that do not have a central ',...
        'tend to work best to display dominant frequency. This is because Fdom is always positive ',...
        'and does not have zero crossings. The best colormaps for this are seisclrs, blueblack, '...
        'greenblack, jet, parula, copper, bone, gray, and winter.'],[],...
        ['The clipping controls have a strong effect on what you see. If you choose a numeric ',...
        'clipping level, x, then the colorbar stretches from -x*sigma to +x*sigma centered at the data ',...
        'mean value. Here x is the clip number and sigma is the standard deviation of the data. ',...
        'For more control, choose "graphical" instead of a numerical value and a small window will ',...
        'appear showing an amplitude histogram and two red lines. The colorbar stretchs between ',...
        'these lines. You can click and drag these lines as desired. ']};
    hinfo=showinfo(msg,'Dominant Frequency on time slices');
    ud=get(hi,'userdata');
    if(isgraphics(ud))
        delete(ud);
    end
    set(hi,'userdata',hinfo);
end
end

function spec2d(~,~)
global NEWFIGVIS
hmasterfig=gcf;
pos=get(hmasterfig,'position');
hseis2=findobj(gcf,'tag','seis2');
hi=gco;
seis=get(hi,'cdata');
x=get(hi,'xdata');
y=get(hi,'ydata');
dx=abs(x(2)-x(1));
dy=abs(y(2)-y(1));
kymax=.5/(y(2)-y(1));
haxe=get(hi,'parent');
ydir=get(haxe,'ydir');
hresults=findobj(gcf,'tag','results');
idata=get(hresults,'value');
dnames=get(hresults,'string');
if(haxe==hseis2)
    dname=dnames{idata};
else
    dname=haxe.Title.String;
    if(iscell(dname))
        dname=dname{1};
    end
end
NEWFIGVIS='off'; %#ok<NASGU>
datar=seisplotfk(seis,y,x,dname,kymax,dx,dy,2);
datar{1}.XLabel.String=hseis2.XLabel.String;
datar{1}.YLabel.String=hseis2.YLabel.String;
datar{1}.YDir=ydir;
NEWFIGVIS='on';
hfig=gcf;
customizetoolbar(hfig);
set(hfig,'position',pos,'visible','on');
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

clips=round(clips*10)/10;

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