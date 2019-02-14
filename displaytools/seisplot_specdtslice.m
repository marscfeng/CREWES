function datar=seisplot_specdtslice(slices,t,x,y,dname,cmap)
% seisplot_specdtslice: Interactive spectral decomp on time slices
%
% datar=seisplot_specdtslice(slices,t,x,y,dname,cmap)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The input seismic
% volume is displayed in the left-hand-side and the corresponding spectral decomp volume is shown
% the the right-hand side. Initial SpecD parameters come either from internal defaults or global
% variables. Controls are provided to explore both volumes and to compute new SpecD volumes with
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
%           data{2} ... handle of the specd axes
% These return data are provided to simplify plotting additional lines and text in either axes.
% 
% NOTE: The key parameters for the spectral decomp computation are twin, tinc, fmin, fmax, and delf
% and the starting values for these can be controlled by defining the global variables below. These
% globals have names that are all caps. The default value applies when the corresponding global is
% either undefined or empty.
% SPECD_TWIN ... half-width of the Gaussian windows (standard deviation) in seconds
%  ************ default = 0.01 seconds ************
% SPECD_TINC ... increment between adjacent Gaussians
%  ************ default = 2*dt seconds (dt is the time sample size of the data) ***********
% SPECD_FMIN ... minimum frequency in the SpecD volume.  (in Hertz)
%  ************ default 5 Hz *************
% SPECD_FMAX ... maximum signal frequency in the dataset. (in Hertz)
%  ************ default 0.25/dt Hz which is 1/2 of Nyquist *************
% SPECD_DELF ... increment between frequencies in Hertz
% ************* default 5 Hz ***************
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
global SPECD_TWIN SPECD_TINC SPECD_FMIN SPECD_FMAX SPECD_DELF
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
    if(isempty(SPECD_FMAX))
        fmax=round(.25*fnyq);
    else
        fmax=SPECD_FMAX;
    end
    if(isempty(SPECD_FMIN))
        fmin=5;
    else
        fmin=SPECD_FMIN;
    end
    if(isempty(SPECD_DELF))
        delf=5;
    else
        delf=SPECD_DELF;
    end
    if(isempty(SPECD_TWIN))
        twin=0.01;
    else
        twin=SPECD_TWIN;
    end
    if(isempty(SPECD_TINC))
        tinc=2*dt;
    else
        tinc=SPECD_TINC;
    end


    
    %seis2=filter_stack(seis1,t1,fmin,fmax,'method','filtf');
    %dname2=[dname1 ' filtered, fmin=' num2str(fmin) ', fmax=' num2str(fmax)];
    %seis2=seis1;
    
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
%         vis=NEWFIGVIS;
%     else
%         vis='on';
%     end
    vis='on';
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
        figure('position',[figx,figy,figwid,fight],'visible',vis);
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
    %make a clip control
    xnow=xnot+xwid+sep;
    ynow=ynot+yht-ht;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''clip1'')','value',iclip,...
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
        'position',[xnow,ynow+2.5*ht,.5*wid,ht],'callback','seisplot_specdtslice(''info'');',...
        'backgroundcolor','y');
    
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','brighten','tag','brighten','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''brighten'')',...
        'tooltipstring','push once or multiple times to brighten the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','darken','tag','darken','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''brighten'')',...
        'tooltipstring','push once or multiple times to darken the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','lvl 0','tag','brightness','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','image brightness (both images)','userdata',0);
    
    set(hax1,'tag','seis1');
    
    %time location thermometer
    xnow=xnow+.25*wid-sep;
    widtherm=.75*wid;
    httherm=4*xsep;
    ytherm=ynow-ht-httherm;
    htherm=uithermometer(gcf,[xnow,ytherm,widtherm,httherm],'Time slice',t,30,'seisplot_specdtslice(''jump'');');
    set(htherm,'tag','thermt');
    
    %prev and next buttons
    wid=.055;ht=.05;sep=.005;
    xnow=xnot+xwid+.1*wid;
    ynow=ytherm-5*sep;
    uicontrol(gcf,'style','pushbutton','string','Next time','tag','next','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_specdtslice(''step'');',...
        'tooltipstring','Step to greater time','userdata',{slices,t,x,y,dname,inot});
    ynow=ynow-.5*ht;
    uicontrol(gcf,'style','pushbutton','string','Previous time','tag','prev','units','normalized',...
        'position',[xnow ynow wid .5*ht],'callback','seisplot_specdtslice(''step'');',...
        'tooltipstring','Step to lesser time');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    xlabel('line coordinate')
    
    
    %make a clip control

    xnow=xnot+2*xwid+xsep+sep;
    ht=.05;
    ynow=ynot+yht-ht;
    %wid=.045;sep=.005;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''clip2'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax2,[]},'tooltipstring',...%the values here in userdata are placeholders. See 'computespecd' for the real thing
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
     
    ht=.5*ht;
    ynow=ynow-sep;
    %ynow=ynow-ht;
    uicontrol(gcf,'style','radiobutton','string','Auto adjust clip','tag','autoclip2','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'value',0,'userdata',ilive,...
        'tooltipstring','clip level auto adjusted with each time slice')
    %specd parameters
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','SpecD parameters:','units','normalized',...
        'position',[xnow,ynow,1.5*wid,ht],'tooltipstring','Change these values and then click "Compute SpecD"');
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
    uicontrol(gcf,'style','text','string','Fmin:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Minimum frequency of interest');
    uicontrol(gcf,'style','edit','string',num2str(fmin),'units','normalized','tag','fmin',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Fmax:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Maximum frequency of interest');
    uicontrol(gcf,'style','edit','string',num2str(fmax),'units','normalized','tag','fmax',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','delF:','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Frequency increment');
    uicontrol(gcf,'style','edit','string',num2str(delf),'units','normalized','tag','delf',...
        'position',[xnow+wid+sep,ynow,wid,ht],'tooltipstring','Enter a value in Hertz');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Compute SpecD','units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'callback','seisplot_specdtslice(''computespecd'');',...
        'tooltipstring','Compute SpecD with current parameters','tag','specdbutton');
    
    %colormap controls
    ht=.025;
    ynow=ynow-1.5*ht;
    wid=2*wid;
    uicontrol(gcf,'style','text','string','Colormap:','tag','colormaplabel',...
        'units','normalized','position',[xnow ynow 1.2*wid ht]);
    ynow=ynow-ht;
    uicontrol(gcf,'style','radiobutton','string','Show colorbars','tag','colorbars',...
        'units','normalized','position',[xnow ynow 1.2*wid ht],'value',0,...
        'callback','seisplot_specdtslice(''colorbars'');');
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
        'units','normalized','position',[xnow ynow 1.2*wid ht],'callback',...
        'seisplot_specdtslice(''colormap'');','value',icolor);
    ynow=ynow-2*ht-5*sep;
    hbg=uibuttongroup('position',[xnow,ynow,1.2*wid,3*ht],'title','Colormap goes to','tag','cmapgt');
    uicontrol(hbg,'style','radiobutton','string','left','tag','left','units','normalized',...
        'position',[0 2/3 1 1/3],'value',0);
    uicontrol(hbg,'style','radiobutton','string','right','tag','right','units','normalized',...
        'position',[0 1/3 1 1/3],'value',1);
    uicontrol(hbg,'style','radiobutton','string','both','tag','both','units','normalized',...
        'position',[0 0 1 1/3],'value',0);
    
    %spectra
    ynow=ynow-2*ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Browse spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''browse'');',...
        'tooltipstring','Start browsing spectra at specific points','tag','browse',...
        'userdata',{[],[],'Point Set New'});
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Save spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''savespec'');',...
        'tooltipstring','Save the current set of points for recall later','tag','savespec',...
        'visible','off');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','popupmenu','string','Point Set New','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''choosespec'');',...
        'tooltipstring','Choose the set of points to work with','tag','choosespec',...
        'userdata',{[]},'visible','off');
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(gcf,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplot_specdtslice(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(gcf,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplot_specdtslice(''equalzoom'');');
    
    %results popup
    wida=.065;
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid2=pos(3)-wida-.25*xsep;
    ht=3*ht;
    fs=12;
    uicontrol(gcf,'style','popupmenu','string','...','units','normalized','tag','results',...
        'position',[xnow,ynow,wid2,ht],'callback','seisplot_specdtslice(''select'');','fontsize',fs,...
        'fontweight','bold');
    
    %make frequency stepping controls
    ht=.025;wid=.055;
    xnow=xnot+2*xwid+1.4*wid+xsep;
    %ynow=ynot+yht+ht;
    ynow=ytherm-5*sep;
    uicontrol(gcf,'style','pushbutton','string','Next frequency','tag','nextf','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''stepf'');',...
        'tooltipstring','step the the next higher frequency');
    ynow=ynow-ht;
    uicontrol(gcf,'style','pushbutton','string','Prev frequency','tag','prevf','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplot_specdtslice(''stepf'');',...
        'tooltipstring','step the the next lower frequency');
    xnow=pos(1)+wid2+.25*xsep;
   
    ff=fmin:delf:fmax;
    nf=length(ff);
    fnow=ff(round(nf/2));
    ynow=ynot+yht+.5*ht;
    uicontrol(gcf,'style','text','string',['Fnow= ' num2str(fnow) 'Hz'],'tag','fnow','units','normalized',...
        'position',[xnow,ynow+.5*ht,wida,ht],'tooltipstring','This is the displayed frequency',...
        'userdata',round(nf/2),'fontsize',12,'fontweight','bold','backgroundcolor',.99*ones(1,3));
    
    %bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.2,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
%     whitefig;
    
    set(hax2,'tag','seis2');
    seisplot_specdtslice('computespecd');
%     if(iscell(dname2))
%         dn2=dname2{1};
%     else
%         dn2=dname2;
%     end
    set(gcf,'name',['Spectral decomp for ' dname ' at time= ' time2str(t(inot))],...
        'closerequestfcn','seisplot_specdtslice(''close'');','menubar','none','toolbar',...
        'figure','numbertitle','off');
    colormap(cmap)
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
        ud=get(hmasterfig,'userdata');
        if(~iscell(ud))
            ud=[ud hfig];
        else
            ud{1}=[ud{1} hfig];
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
    seisplot_specdtslice('clip1');    
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
    seisplot_specdtslice('autoclip1');
    %step the specd
    hresults=findobj(gcf,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hfnow=findobj(gcf,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    hseis2=findobj(gcf,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
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
    hthermt=findobj(gcf,'tag','thermt');
    uithermometer('set',hthermt,tnot);
    seisplot_specdtslice('autoclip2');
    seisplot_specdtslice('updatespectra');
elseif(strcmp(action,'jump'))
    hbut=gcbo;
    tnot=get(hbut,'userdata');
    %step the seismic
    hseis1=findobj(gcf,'tag','seis1');
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    slices=udat{1};
    t=udat{2};
    dt=abs(t(2)-t(1));
    inot=round((tnot-t(1))/dt)+1;
%     if(step=='u')
%         inot=max([1,inot-1]);
%     else
%         inot=min([length(t),inot+1]);
%     end
    udat{6}=inot;
    set(hnext,'userdata',udat);
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
    seisplot_specdtslice('autoclip1');
    %step the specd
    hresults=findobj(gcf,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    hfnow=findobj(gcf,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    hseis2=findobj(gcf,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
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
    seisplot_specdtslice('autoclip2');
    seisplot_specdtslice('updatespectra');
elseif(strcmp(action,'stepf'))
    hbut=gcbo;
    if(strcmp(get(hbut,'tag'),'nextf'))
        step='u';
    else
        step='d';
    end
    %get current time
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %get results
    hresults=findobj(gcf,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    %determine current and new frequency
    fout=results.fouts{iresult};
    hfnow=findobj(gcf,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    if(step=='u')
        ifnow=min([length(fout),ifnow+1]);
    else
        ifnow=max([1,ifnow-1]);
    end
    %update display
    set(hfnow,'string',['Fnow= ' num2str(fout(ifnow)) 'Hz'],'userdata',ifnow);
    hseis2=findobj(gcf,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot(1),:,:,ifnow(1)))';
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
    seisplot_specdtslice('autoclip2');
    hthermf=results.thermfs{iresult};
    uithermometer('set',hthermf,fout(ifnow));
elseif(strcmp(action,'jumpf'))
    hbut=gcbo;
    fnow=get(hbut,'userdata');%frequency we are jumping to
    %get current time
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %get results
    hresults=findobj(gcf,'tag','results');
    iresult=get(hresults,'value');
    results=get(hresults,'userdata');
    %determine current frequency
    fout=results.fouts{iresult};
    hfnow=findobj(gcf,'tag','fnow');
    ifnow=near(fout,fnow);
    %update display
    set(hfnow,'string',['Fnow= ' num2str(fout(ifnow(1))) 'Hz'],'userdata',ifnow(1));
    hseis2=findobj(gcf,'tag','seis2');
    seis2=squeeze(results.data{iresult}(inot(1),:,:,ifnow(1)))';
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
    seisplot_specdtslice('autoclip2');
elseif(strcmp(action,'computespecd'))
    %plan: apply the specd parameters and display the results for the mean frequency
    hfig=gcf;
    hseis2=findobj(hfig,'tag','seis2');
    hseis1=findobj(hfig,'tag','seis1');
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
    %get fmin
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
    if(fmax<=fmin)
        msgbox('Fmax must be greater than Fmin','Oh oh ...');
        return;
    end
    %get delf
    hobj=findobj(gcf,'tag','delf');
    val=get(hobj,'string');
    delf=str2double(val);
    if(isnan(delf))
        msgbox('delF is not recognized as a number','Oh oh ...');
        return;
    end
    if(delf<0 )%|| length(fmin:delf:fmax)==0)
        msgbox('dFmin must be greater than 0','Oh oh ...');
        return;
    end
    fout=fmin:delf:fmax;
    if( isempty(fout))
        msgbox('Fmin:delF:Fmax is empty','Oh oh ...');
        return;
    end

    
    %compute specd
    t0=clock;
    ievery=1;
    nt=length(t);
    ny=length(y);
    nx=length(x);
    nf=length(fout);
    phaseflag=3;
    specd=zeros(nt,nx,ny,nf);
    if(isempty(XCFIG))
       posw=[400 100];
    else
       posw=[XCFIG-200,YCFIG-50,400,100];
    end
    hbar=WaitBar(0,ny,'SpecD computation','Computing spectral decomp',posw);
    for k=1:ny %loop over inlines
        s2d=squeeze(slices(:,:,k));
        if(sum(abs(s2d(:)))>0) %avoid all zero s2d
            [amp,phs,tsd,f2d]=specdecomp(s2d,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,-1); %#ok<ASGLU>
            %Accumulate results
            for j=1:nf
                specd(:,:,k,j)=amp(:,:,j);
            end
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
    
    fnot=fout(round(nf/2));
    ifnot=near(fout,fnot);
    hfnow=findobj(hfig,'tag','fnow');
    set(hfnow,'string',['Fnow= ' num2str(fnot) 'Hz'],'userdata',ifnot)
    
    seis2=squeeze(specd(inot,:,:,ifnot))';
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis2);
    clipdat={clips,clipstr,clip,iclip,sigma,am,amax,amin};
    clim=[am-clip*sigma am+clip*sigma];
    
    hclip2=findobj(hfig,'tag','clip2');
    set(hclip2,'userdata',{clips,am,sigma,amax,amin,hseis2,[]},'string',clipstr,'value',iclip);
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    fs=get(hseis1,'fontsize');
    hi=imagesc(x,y,seis2,clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','2D Spectrum','callback',@spec2d); 
    set(hi,'uicontextmenu',hcm);
    xlabel('crossline');ylabel('inline');
    name=['Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ',Fmin= ', num2str(fmin) ...
        ', Fmax= ', num2str(fmax) ', delF= ', num2str(delf)];
    set(hseis2,'tag','seis2','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc,'fontsize',fs);
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    %build frequency thermometer
    hthermt=findobj(hfig,'tag','thermt');
    posth=get(hthermt,'position');
    posth(1)=.935;
    htherm=uithermometer(gcf,posth,'Frequency',fout,30,'seisplot_specdtslice(''jumpf'');');
    set(htherm,'tag','thermf');
    
    if(isempty(results))
        nresults=1;
        results.names={name};
        results.data={specd};
        results.twins={twin};
        results.tincs={tinc};
        results.fmins={fmin};
        results.fmaxs={fmax};
        results.delfs={delf};
        results.fouts={fout};
        results.clipdats={clipdat};
        results.thermfs={htherm};
    else
        iresult=get(hresults,'value');
        nresults=length(results.names)+1;
        results.names{nresults}=name;
        results.data{nresults}=specd;
        results.twins{nresults}=twin;
        results.tincs{nresults}=tinc;
        results.fmins{nresults}=fmin;
        results.fmaxs{nresults}=fmax;
        results.fouts{nresults}=fout;
        results.delfs{nresults}=delf;
        results.clipdats{nresults}=clipdat;
        results.thermfs{nresults}=htherm;
        set(results.thermfs{iresult},'visible','off');
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hcompute=findobj(hfig,'tag','specdbutton');
    set(hcompute,'userdata',nresults);%the current result number stored here
elseif(strcmp(action,'select'))
    hfig=gcf;
    %     %get current time and frequency
    %     hnext=findobj(gcf,'tag','next');
    %     udat=get(hnext,'userdata');
    %     inot=udat{6};
    %     hfnow=findobj(gcf,'tag','fnow');
    %     ifnow=get(hfnow,'userdata');
    
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hcompute=findobj(hfig,'tag','specdbutton');
    iresultold=get(hcompute,'userdata');
    set(hcompute,'userdata',iresult);
    hseis2=findobj(hfig,'tag','seis2');
    %     hi=findobj(hseis2,'type','image');
    %     seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    %     set(hi,'cdata',seis2);
    hop=findobj(hfig,'tag','twin');
    set(hop,'string',num2str(results.twins{iresult}));
    hstab=findobj(hfig,'tag','tinc');
    set(hstab,'string',num2str(results.tincs{iresult}));
    hfmin=findobj(hfig,'tag','fmin');
    set(hfmin,'string',num2str(results.fmins{iresult}));
    hfmax=findobj(hfig,'tag','fmax');
    set(hfmax,'string',num2str(results.fmaxs{iresult}));
    hdfmax=findobj(hfig,'tag','delf');
    set(hdfmax,'string',num2str(results.delfs{iresult}));
    %get the proper time/frequency slice
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    inot=udat{6};
    %     fout=results.fouts{iresult};
    hfnow=findobj(gcf,'tag','fnow');
    ifnow=get(hfnow,'userdata');
    seis2=squeeze(results.data{iresult}(inot,:,:,ifnow))';
    %update clipping
    clipdat=results.clipdats{iresult};
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
    
    %show the proper thermometer
    set(results.thermfs{iresultold},'visible','off');
    set(results.thermfs{iresult},'visible','on');
    %set themometer to current frequency
    uithermometer('set',results.thermfs{iresult},results.fouts{iresult}(ifnow));
    
    hclip2=findobj(gcf,'tag','clip2');
    set(hclip2,'string',clipstr','value',iclip,'userdata',{clips,am,sigma,amax,amin,hseis2});
    set(hseis2,'clim',clim);
    seisplot_specdtslice('clip2');
    seisplot_specdtslice('updatespectra');
    %     %see if spectra window is open
    %     hspec=findobj(hfig,'tag','spectra');
    %     hspecwin=get(hspec,'userdata');
    %     if(isgraphics(hspecwin))
    %         seisplot_specdtslice('spectra');
    %     end
elseif(strcmp(action,'browse'))
    hbrowse=gcbo;
    mode=get(hbrowse,'string');
    hclip2=findobj(gcf,'tag','clip2');
    udat2=get(hclip2,'userdata');
    hax1=findobj(gcf,'tag','seis1');
    hax2=udat2{6}(1);
    hsavespec=findobj(gcf,'tag','savespec');
    hchoose=findobj(gcf,'tag','choosespec');
    switch mode
        case 'Browse spectra'
            set(hbrowse,'string','Stop browse','tooltipstring','Click to close spectral window and stop browsing');
            set([hsavespec hchoose],'visible','on');
            %determine if specD is full or half
            pos=get(hax2,'position');
            if(pos(3)>.4)
                %full
%                 bdy=.05;
%                 fact=1;
%                 hback=axes('position',[pos(1)-fact*bdy,pos(2)+.75*pos(4)-bdy, .2*pos(3)+fact*bdy, .25*pos(4)+bdy],...
%                     'tag','back');
%                 axes('position',[pos(1),pos(2)+.75*pos(4), .2*pos(3), .25*pos(4)],...
%                     'tag','spectra');
            else
                %half
                pos1=get(hax1,'position');
                set(hax1,'visible','off')
                haxspec=axes('position',pos1,'tag','spectra');
            end
            %set(hback,'xtick',[],'ytick',[],'xcolor',[1 1 1],'ycolor',[1 1 1]);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','seisplot_specdtslice(''specpt'');');
            %display current set
            iset=get(hchoose,'value');
            setnames=get(hchoose,'string');
            if(iscell(setnames))
                thisname=setnames{iset};
            else
                thisname=setnames;
            end
            pointsets=get(hchoose,'userdata');
            seti=pointsets{iset};
            if(isempty(seti))
               return;
            end
            hm=zeros(size(seti));
            hs=hm;
            haxspecd=findobj(gcf,'tag','seis2');
            axes(haxspecd);
            for k=1:length(seti)
                hm(k)=line(seti{k}.x,seti{k}.y,'linestyle','none','marker',seti{k}.marker,...
                    'color',seti{k}.color,'markersize',seti{k}.msize,'linewidth',2);
            end
            axes(haxspec);
            hnext=findobj(gcf,'tag','next');
            udat=get(hnext,'userdata');
            x=udat{3};
            y=udat{4};
            inot=udat{6};%current time
            hresult=findobj(gcf,'tag','results');
            results=get(hresult,'userdata');
            iresult=get(hresult,'value');
            for k=1:length(hs)
                iy=near(y,seti{k}.y);
                ix=near(x,seti{k}.x);
                spec=squeeze(results.data{iresult}(inot,ix,iy,:));
                hs(k)=line(results.fouts{iresult},spec,'linestyle','-','marker',seti{k}.marker,...
                    'color',seti{k}.color,'buttondownfcn','seisplot_specdtslice(''idspect'');');
            end
            set(hbrowse,'userdata',{hm hs thisname});
        case 'Stop browse'
            set(hbrowse,'string','Browse spectra','tooltipstring','Start browsing spectra at specific points');
            set([hsavespec hchoose],'visible','off');
%             hback=findobj(gcf,'tag','back');
%             delete(hback);
            haxspec=findobj(gcf,'tag','spectra');
            delete(haxspec);
            hi=findobj(hax2,'type','image');
            set(hi,'buttondownfcn','');
            set(hax1,'visible','on')
            udat=get(hbrowse,'userdata');
            if(~isempty(udat))
                delete(udat{1});
            end
            udat{1}=[];
            udat{2}=[];
            set(hbrowse,'userdata',udat);
    end
elseif(strcmp(action,'specpt'))
    kols=get(gca,'colororder');
    mkrs={'.','o','x','+','*','s','d','v','^','<','>','p','h'};
    nk=size(kols,1);
    nm=length(mkrs);
    hbrowse=findobj(gcf,'tag','browse');
    udatb=get(hbrowse,'userdata');
    if(isempty(udatb{1}))
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
    hm=line(pt(1,1),pt(1,2),'linestyle','none','marker',mkrs{im},'color',kols(ik,:),'markersize',10,'linewidth',2);
    
%     hclip2=findobj(gcf,'tag','clip2');
%     udat=get(hclip2,'userdata');
%     x=udat{7};
%     tsd=udat{9};
%     fsd=udat{10};
%     seissd=udat{11};
    %haxes=udat{6};
    %get the x and y coordinates
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    x=udat{3};
    y=udat{4};
    inot=udat{6};%current time
    hresult=findobj(gcf,'tag','results');
    results=get(hresult,'userdata');
    iresult=get(hresult,'value');
    iy=near(y,pt(1,2));
    ix=near(x,pt(1,1));
    spec=squeeze(results.data{iresult}(inot,ix,iy,:));
    haxspec=findobj(gcf,'tag','spectra');
    axes(haxspec)
    hs=line(results.fouts{iresult},spec,'linestyle','-','marker',mkrs{im},'color',kols(ik,:));
    set(hs,'buttondownfcn','seisplot_specdtslice(''idspect'');');
    if(isempty(udatb))
        udatb{1}=hm;
        udatb{2}=hs;
        xlabel('Frequency');ylabel('Amplitude')
    else
        udatb{1}=[udatb{1} hm];
        udatb{2}=[udatb{2} hs];
    end
    set(hbrowse,'userdata',udatb);    
elseif(strcmp(action,'updatespectra'))
    haxspec=findobj(gcf,'tag','spectra');
    if(isempty(haxspec))
        return;
    end
    hnext=findobj(gcf,'tag','next');
    ud=get(hnext,'userdata');
    inot=ud{6};%index of current time 
    x=ud{3};
    y=ud{4};
    hbrowse=findobj(gcf,'tag','browse');
    hresult=findobj(gcf,'tag','results');
    iresult=get(hresult,'value');
    results=get(hresult,'userdata');
    udat=get(hbrowse,'userdata');
    hm=udat{1};%handles of the markers in the specd axes
    hs=udat{2};%handles of the spectral curves in the spectra axes
    for k=1:length(hm)
        xp=get(hm(k),'xdata');
        yp=get(hm(k),'ydata');
        ix=near(x,xp);
        iy=near(y,yp);
        set(hs(k),'ydata',squeeze(results.data{iresult}(inot,ix,iy,:)));
    end
elseif(strcmp(action,'idspect'))
    hthisspec=gco;
    hbrowse=findobj(gcf,'tag','browse');
    udat=get(hbrowse,'userdata');
    hm=udat{1};%handles of the markers in the specd axes
    hs=udat{2};%handles of the spectral curves in the spectra axes
    im=find(hthisspec==hs);
    if(isempty(im))
        return;
    end
    msize=get(hm(im),'markersize');
    set(hm(im),'markersize',2*msize);
    uiwait(gcf,1);
    set(hm(im),'markersize',msize);
elseif(strcmp(action,'savespec'))
    haxspec=findobj(gcf,'tag','spectra');
    if(isempty(haxspec))
        return;
    end
    hchoose=findobj(gcf,'tag','choosespec');
    setnames=get(hchoose,'string');
    if(~iscell(setnames))
        setnames={setnames};
    end
    iset=get(hchoose,'value');
    a=askthingsle('questions',{'Name the point set'},'answers',{setnames{iset}});
    if(isempty(a))
        return;
    end
    %check for no name change
    newname=a{1};
    iset=length(setnames)+1;
    for k=1:length(setnames)
       if(strcmp(a{1},setnames{k}))
          iset=k;
          newname=setnames{k};
       end
    end
    setnames{iset}=newname;
    hbrowse=findobj(gcf,'tag','browse');
    udat=get(hbrowse,'userdata');
    hm=udat{1};%handles of the markers in the specd axes
    udat{3}=newname;
    set(hbrowse,'userdata',udat);
    thisset=cell(size(hm));
    for k=1:length(hm)
       pset.x=get(hm(k),'xdata');
       pset.y=get(hm(k),'ydata');
       pset.color=get(hm(k),'color');
       pset.msize=get(hm(k),'markersize');
       pset.marker=get(hm(k),'marker');
       thisset{k}=pset;
    end
    pointsets=get(hchoose,'userdata');
    pointsets{iset}=thisset;
    set(hchoose,'string',setnames,'value',iset,'userdata',pointsets);
elseif(strcmp(action,'choosespec'))
    haxspec=findobj(gcf,'tag','spectra');
    if(isempty(haxspec))
        return;
    end
    hchoose=findobj(gcf,'tag','choosespec');
    setnames=get(hchoose,'string');
    if(~iscell(setnames))
        setnames={setnames};
    end
    iset=get(hchoose,'value');
    pointsets=get(hchoose,'userdata');
    hbrowse=findobj(gcf,'tag','browse');
    udatb=get(hbrowse,'userdata');
    %if current setname is same as choose spec then the set has simply been updated and we return
    thisname=udatb{3};
    if(strcmp(setnames{iset},thisname))
        return;
    end
    %determine which set is presently open
    for k=1:length(setnames)
       if(strcmp(thisname,setnames{k}))
           kset=k;
       end
    end
    %see if current set has changed and save if so
    hm=udatb{1};
    hs=udatb{2};
    if(~strcmp(thisname,'Point Set New'))
        setk=pointsets{kset};
        if(length(hm)>length(setk))%
            setknew=cell(size(hm));
            setknew(1:length(setk))=setk;
            for k=length(setk)+1:length(hm)
                pset.x=get(hm(k),'xdata');
                pset.y=get(hm(k),'ydata');
                pset.color=get(hm(k),'color');
                pset.msize=get(hm(k),'markersize');
                pset.marker=get(hm(k),'marker');
                setknew{k}=pset;
            end
            pointsets{kset}=setknew;
            set(hchoose,'userdata',pointsets);
        end
    end
    %delete current set
    delete(hm);
    delete(hs);
    %display new set
    seti=pointsets{iset};
    hm=zeros(size(seti));
    hs=hm;
    haxspecd=findobj(gcf,'tag','seis2');
    axes(haxspecd);
    for k=1:length(seti)
        hm(k)=line(seti{k}.x,seti{k}.y,'linestyle','none','marker',seti{k}.marker,...
            'color',seti{k}.color,'markersize',seti{k}.msize,'linewidth',2);
    end
    axes(haxspec);
    hnext=findobj(gcf,'tag','next');
    udat=get(hnext,'userdata');
    x=udat{3};
    y=udat{4};
    inot=udat{6};%current time
    hresult=findobj(gcf,'tag','results');
    results=get(hresult,'userdata');
    iresult=get(hresult,'value');
    for k=1:length(hs)
        iy=near(y,seti{k}.y);
        ix=near(x,seti{k}.x);
        spec=squeeze(results.data{iresult}(inot,ix,iy,:));
        hs(k)=line(results.fouts{iresult},spec,'linestyle','-','marker',seti{k}.marker,...
            'color',seti{k}.color,'buttondownfcn','seisplot_specdtslice(''idspect'');');
    end
    udatb={hm hs setnames{iset}};
    set(hbrowse,'userdata',udatb)

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
    hspec=findobj(gcf,'tag','spectra');
    hspecwin=get(hspec,'userdata');
    delete(hspecwin);
    hi=findobj(gcf,'tag','info');
    hinfo=get(hi,'userdata');
    if(isgraphics(hinfo))
        delete(hinfo);
    end
    hclip=findobj(gcf,'tag','clip1');
    ud=get(hclip,'userdata');
    if(isgraphics(ud{7}))
        close(ud{7});
    end
    hclip=findobj(gcf,'tag','clip2');
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
    hi=gcbo;
    msg={['The axes at left (the seismic axes) shows the input sesimic and the axes at right ',...
        '(specd axes) shows the spectral decomp for a single frequency. Both axes are showing the ',...
        'same time and controls to change the time are just to the right of the seismic axes. ',...
        'There are two buttons labelled "Next time" and "Previous time" that step one time sample ',...
        'in either direction. Below these buttons is a tall rectangle labeled "Time slice" that ',...
        'enables a quick jump to any of 30 positions within the set of time slices. Hover the mouse over ',...
        'one of the tiny buttons and you will see the time for that button. Pressing the button ',...
        'gets you there. '],[],...
        ['Similarly controls to change the frequency are to the right of the specd axes. There are ',...
        'both large buttons to step a single sample and a "Frequency" rectangle with 30 jump points. ',...
        'Below the clip popup are the parameters of the Spectral decomposition. You can change any of ',...
        'these parameters and then create a new decomposition by pushing the "Compute SpecD" button. ',...
        'Any number of deconpositions can be computed and they are alll retained in memory ',...
        'until you close the window. The popup menu above the specd axes is used to choose the ',...
        'specd result that is displayed. '],[],['The colormap tool is easy to figure out and can assign one ',...
        'of a list of pre-built colormaps to either axis.'],[],...
        ['The "Browse spectra" button enables you to view the frequency spectrum of any point. ',...
        'Clicking this button causes a new axes to appear on top of the seismic axes. You then ',...
        'click on any point in the SpecD image to see the spectrum associated with tha point. ',...
        'Any number of points can be clicked and their spectra are all drawn in the spectral axes. ',...
        'Clicking on a spectral curve allows easy identification of its corresponding point. '],[],...
        ['The clipping controls have a strong effect on what you see. If you choose a numeric ',...
        'clipping level then the colorbar stretches from -x*sigma to +x*sigma centered at the data ',...
        'mean value. Here x is the clip number and sigma is the standard deviation of the data. ',...
        'For more control, choose "graphical" instead of a numerical value and a small window will ',...
        'appear showing an amplitude histogram and two red lines. The colorbar stretchs between ',...
        'these lines. You can click and drag these lines as desired. ']};
    hinfo=showinfo(msg,'Spectral Decomp on time slices');
    ud=get(hi,'userdata');
    if(isgraphics(ud))
        delete(ud);
    end
    set(hi,'userdata',hinfo);
    set(hi,'userdata',{msg,hinfo});
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
kymax=.5/dy;
haxe=get(hi,'parent');
ydir=haxe.YDir;
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