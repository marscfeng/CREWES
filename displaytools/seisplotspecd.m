function datar=seisplotspecd(seis,t,x,dname,cmap)
% seisplotspecd: provides interactive spectral decomp of a 2D seismic section
%
% datar=seisplotspecd(seis,t,x,dname,cmap)
%
% A new figure is created and divided into three axes (side-by-side). The first axes shows the
% seismic gather on which spectral decomp was performed, the second shows the spectral decomp one
% frequency at a time with controls to step through the frequencies, and the third axis shows the
% spectral decomp at a single x location as a function of frequency.
%
% seis ... 2D seismic matrix that spectral decomp was done on
% t ... time coordinate vector for seis
% x ... space coordinate vector for seis
% dname ... text string nameing the first seismic matrix. Enter [] or '' for no name.
% ******** default = '' ************
% cmap ... starting colormap
% ******** default 'seisclrs' **********
%
% datar ... Return data which is a length 3 cell array containing
%           datar{1} ... handle of the first seismic axes
%           datar{2} ... handle of the first spectral decomp axis (section)
%           datar{3} ... handle of the second spectral decomp axis (gather)
% These return data are provided to simplify plotting additional lines and text.
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
global NEWFIGVIS
global SPECD_TWIN SPECD_TINC SPECD_FMIN SPECD_FMAX SPECD_DELF
global HMFIG
if(~ischar(seis))
    action='init';
else
    action=seis;
end

HMFIG=gcf;%debugging tool

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    
    
    if(length(t)~=size(seis,1))
        error('time coordinate vector does not match first seismic matrix');
    end
    if(length(x)~=size(seis,2))
        error('space coordinate vector does not match first seismic matrix');
    end
    
    if(nargin<4)
        dname=[];
    end
    if(nargin<5)
        cmap='seisclrs';
    end
    
    if(iscell(dname))
        error('dname must be a simple string not a cell')
    end
    
    %establish initial parameter defaults
    dt=t(2)-t(1);
    fnyq=.5/dt;
    if(isempty(SPECD_FMAX))
        fmax=round(.5*fnyq);
    else
        fmax=SPECD_FMAX;
    end
    fmax2=.5*fmax;%display fmax
    if(isempty(SPECD_FMIN))
        fmin=5;
    else
        fmin=SPECD_FMIN;
    end
    if(isempty(SPECD_DELF))
        delf=2;
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
    
    %do initial spectral decomp
    %do the spectral decomp
    phaseflag=3;
    tmin=t(1);tmax=t(end);
    [seissd,phs,tsd,fsd]=specdecomp(seis,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,1); %#ok<ASGLU>
    name=['Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ',Fmin= ', num2str(fmin) ...
        ', Fmax= ', num2str(fmax) ', delF= ', num2str(delf),', agc=0'];
    
    
    %determine a few things about the spectral decomp
    nfsd=length(fsd);
    mnfsd=zeros(1,nfsd);
    maxfsd=mnfsd;
    minfsd=mnfsd;
    sfsd=mnfsd;
%     %test for amp or phase
    amp=true;
%     ind=find(seissd(:,:,round(nfsd/2))<0, 1);
%     if(isempty(ind))
%         amp=true;
%     else
%         amp=false;
%     end
    for k=1:nfsd
        tmp=seissd(:,:,k);
        mnfsd(k)=mean(tmp(:));
        maxfsd(k)=max(tmp(:));
        minfsd(k)=mean(tmp(:));
        sfsd(k)=std(tmp(:));
    end

    %establish window geometry
    xwid=.4;
    xwid2=.4;
    xwid3=.1;
    yht=.8;
    xsep=.05;
    
    ynot=.1;
    xshrink=.8;
    xwid=xshrink*xwid;
    xwid2=xshrink*xwid2;
    xwid3=xshrink*xwid3;
    xwid4=.1;
    xnot=.75*(1-xwid-xwid2-xwid3-xwid4-1.5*xsep);
    
    
    
    if(~isempty(NEWFIGVIS))
        figure('visible',NEWFIGVIS);
    else
        figure
    end
    set(gcf,'menubar','none','toolbar','figure','numbertitle','off');
    hax1=subplot('position',[xnot ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis);
    clim=[am-clip*sigma am+clip*sigma];
        
    hi=imagesc(x,t,seis,clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    
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
        xlabel('distance')
    else
        xlabel('distance')
    end
    
    %make a clip control
    xnow=xnot+.8*xwid;
    wid=.055;ht=.05;
    ynow=ynot+yht;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
        'position',[xnow,ynow+.5*ht,.8*wid,ht],'callback','seisplotspecd(''clip1'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,hax1},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    %make a help button
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[xnot,ynow+ht,.5*wid,.5*ht],'callback','seisplotspecd(''info'');',...
        'backgroundcolor','y');
    
    %the hide seismic button
    xnoww=xnot+wid;
    uicontrol(gcf,'style','pushbutton','string','Hide seismic','tag','hideshow','units','normalized',...
        'position',[xnoww,ynow+ht,wid,.5*ht],'callback','seisplotspecd(''hideshow'');','userdata','hide');
    %the toggle button
    xnoww=xnoww+1.1*wid;
    uicontrol(gcf,'style','pushbutton','string','Toggle','tag','toggle','units','normalized',...
        'position',[xnoww,ynow+ht,wid,.5*ht],'callback','seisplotspecd(''toggle'');','visible','off');
    
    %aec controls
    nudge=.5*xsep;
    wid2=.04;
    uicontrol(gcf,'style','pushbutton','string','Apply AGC:','tag','appagc','units','normalized','position',...
        [xnot-wid2-nudge,ynow-.5*ht,wid2,.5*ht],'callback','seisplotspecd(''agc'');',...
        'tooltipstring','Push to apply Automatic gain correction','userdata',0);
    %the userdata of the above is the operator length of the actually applied agc
    uicontrol(gcf,'style','edit','string','0','tag','agc','units','normalized','position',...
        [xnot-wid2-nudge,ynow-ht,wid2,.5*ht],'tooltipstring','Define an operator length in seconds (0 means no AGC)',...
        'userdata',{seis,t},'callback','seisplotspecd(''agc'');');
    
    set(hax1,'tag','seis');
    
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid2 yht]);
%     [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seissd);
    if(amp)
        clip=6;
    else
        clip=1; %#ok<UNRCH>
    end
    iclip=near(clips,clip);
    am=mean(mnfsd(:));
    sigma=mean(sfsd(:));
    clim=[-.5*sigma am+clip*sigma];
    ifsd=near(fsd,fmax2/2);
    ifsd=ifsd(1);
    hi=imagesc(x,tsd,seissd(:,:,ifsd),clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    grid
%     if(amp)
%         title(['specD amplitude, frequency= ' num2str(fsd(ifsd)) ' Hz'],'interpreter','none')
%     else
%         title(['specD phase, frequency= ' num2str(fsd(ifsd)) ' Hz'],'interpreter','none')
%     end
    set(hax2,'tag','seissd','nextplot','add');
    %draw line indicating gather position
    tmin=min(t);
    tmax=max(t);
    klr='r';
    xm=mean(x);
    ix=near(x,xm);
    xm=x(ix(1));
    lw=1;
    line([xm xm],[tmin tmax],[1 1],'color',klr,'linestyle','--','buttondownfcn',...
        'seisplotspecd(''dragline'');','tag','1','linewidth',lw);
    
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
    hi=imagesc(fsd,tsd,squeeze(seissd(:,ix(1),:)),clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    colormap(cmap)
    xlim([fsd(1)-df fmax2+df])
    xlabel('frequency (Hz)')
    ylabel('time (sec)')
    brighten(.5);
    set(hax3,'tag','sdgather','nextplot','add');
    %draw line indicating frequency position
    tmin=min(t);
    tmax=max(t);
    %klrs=get(hax1,'colororder');
    klr='r';
    lw=1;
    line([fsd(ifsd) fsd(ifsd)],[tmin tmax],[1 1],'color',klr,'linestyle','--',...
        'buttondownfcn','seisplotspecd(''dragline'');','tag','2','linewidth',lw);
    
    title(['freq= ' num2str(fsd(ifsd)) ' Hz'])
    grid
    
    
    %make a clip control

    xnow=xnot+xwid+xwid2+xwid3+2*xsep+.1*wid;
    ht=.025;
    ynow=ynot+yht+ht;
    %wid=.045;sep=.005;
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
        'position',[xnow,ynow,.8*wid,2*ht],'callback','seisplotspecd(''clip2'');','value',iclip,...
        'userdata',{clips,am,sigma,amax,amin,[hax2,hax3],x,t,fsd,seissd,seis},'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    
    %frequency stepping controls
%     xnow=xnow+.1*wid;
    ynow=ynow-1*ht;
    df=fsd(2)-fsd(1);
    uicontrol(gcf,'style','text','string','Step frequencies:','units','normalized',...
        'position',[xnow,ynow,wid,ht]);
    xnow=xnow+wid;
    uicontrol(gcf,'style','pushbutton','string','<','tag','stepd','units','normalized',...
        'position',[xnow,ynow,.2*wid,ht],'callback','seisplotspecd(''step'');',...
        'tooltipstring',['step down ' num2str(df) ' Hz']);
    xnow=xnow+.22*wid;
    uicontrol(gcf,'style','pushbutton','string','>','tag','stepu','units','normalized',...
        'position',[xnow,ynow,.2*wid,ht],'callback','seisplotspecd(''step'');',...
        'tooltipstring',['step up ' num2str(df) ' Hz']);
    %browse spectra button
%     xnow=xnow-.22*wid;
%     ynow=ynow-(ht+xsep);
%     uicontrol(gcf,'style','pushbutton','string','Browse spectra','tag','browse','units','normalized',...
%         'position',[xnow,ynow,.8*wid,ht],'callback','seisplotspecd(''browse'');',...
%         'tooltipstring','click to view spectra at individual locations')
    %fmax control
    ynow=ynow-.5*(ht+xsep);
    xnow=xnot+xwid+xwid2+xwid3+2*xsep+.1*wid;
    uicontrol(gcf,'style','text','string','Max display freq:','units','normalized',...
        'position',[xnow,ynow,1*wid,ht],'tooltipstring','Maximum frequency in  Hz to display');
%     ynow=ynow-.5*ht;
    uicontrol(gcf,'style','edit','string',num2str(fmax2),'tag','fmaxdisp','units','normalized',...
        'position',[xnow+1*wid,ynow,.5*wid,ht],'callback','seisplotspecd(''fmax'');',...
        'tooltipstring',['enter a value between ' num2str(fsd(1)) ' and ' num2str(fsd(end))]);
    
    %specd parameters
    sep=.005; 
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','SpecD parameters:','units','normalized',...
        'position',[xnow,ynow,1.25*wid,ht],'tooltipstring','Change these values and then click "Compute SpecD"');
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
        'position',[xnow,ynow,2*wid,ht],'callback','seisplotspecd(''computespecd'');',...
        'tooltipstring','Compute SpecD with current parameters','tag','specdbutton','backgroundcolor','y');
    
    %colormap controls
    ht=.025;
    ynow=ynow-1.5*ht;
    wid=2.5*wid;
    uicontrol(gcf,'style','text','string','Colormap:','tag','colormaplabel',...
        'units','normalized','position',[xnow ynow wid ht]);
    ynow=ynow-ht;
    uicontrol(gcf,'style','radiobutton','string','Show colorbars','tag','colorbars',...
        'units','normalized','position',[xnow ynow wid ht],'value',0,...
        'callback','seisplotspecd(''colormap'');');
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
        'seisplotspecd(''colormap'');','value',icolor);
    ynow=ynow-2*ht-5*sep;
    hbg=uibuttongroup('position',[xnow,ynow,wid,3*ht],'title','Colormap goes to','tag','cmapgt');
    uicontrol(hbg,'style','radiobutton','string','Seismic','tag','left','units','normalized',...
        'position',[0 2/3 1 1/3],'value',0);
    uicontrol(hbg,'style','radiobutton','string','Specd','tag','right','units','normalized',...
        'position',[0 1/3 1 1/3],'value',1);
    uicontrol(hbg,'style','radiobutton','string','both','tag','both','units','normalized',...
        'position',[0 0 1 1/3],'value',0);
    
    %spectra
    ynow=ynow-2*ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Browse spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotspecd(''browse'');',...
        'tooltipstring','Start browsing spectra at specific points','tag','browse',...
        'userdata',{[],[],'Point Set New'});
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','Save spectra','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotspecd(''savespec'');',...
        'tooltipstring','Save the current set of points for recall later','tag','savespec',...
        'visible','off');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','popupmenu','string','Point Set New','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplotspecd(''choosespec'');',...
        'tooltipstring','Choose the set of point to work with','tag','choosespec',...
        'userdata',{[]},'visible','off');
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.98;
    uicontrol(gcf,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid ht],'tag','1like2','callback','seisplotspecd(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(gcf,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid ht],'tag','2like1','callback','seisplotspecd(''equalzoom'');');
    
    %results popup
    xnow=pos(1);
    ynow=pos(2)+pos(4)-ht;
    wid2=pos(3);
    ht=3*ht;
    fs=12;
    uicontrol(gcf,'style','popupmenu','string','...','units','normalized','tag','results',...
        'position',[xnow,ynow,wid2,ht],'callback','seisplotspecd(''select'');','fontsize',fs,...
        'fontweight','bold');
    
    %delete button
    wid=.1;
    ht=ht/3;
    xnow=xnow+wid2-wid;
    ynow=ynow+ht+sep;
    
    %userdata of the delete button is the number of the current selection
    uicontrol(gcf,'style','pushbutton','string','Delete this result','units','normalized',...
        'tag','delete','position',[xnow,ynow+1.75*ht,wid,ht],'callback','seisplotspecd(''delete'');',...
        'tooltipstring','Delete this result (no undo)','userdata',1);
    
    %save result
    clipdat={clips,clipstr,clip,iclip,sigma,am,amax,amin,clim};
    seisplotspecd('newresult',{name,seissd,twin,tinc,fmin,fmax,delf,fsd,clipdat});
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.6,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
    
   

    set(gcf,'name',['Spectral decomp for ' dname],'closerequestfcn','seisplotspecd(''close'');',...
        'userdata',-999.25);%userdata here is just a placeholder to cause plotimage3D to do the right thing
    if(nargout>0)
        datar=cell(1,3);
        datar{1}=hax1;
        datar{2}=hax2;
        datar{3}=hax3;
    end
    
elseif(strcmp(action,'info'))
    hthisfig=gcf;
    msg={['The axes at left (the seismic axes) shows the ordinary sesimic, the middle axes (the specd axes) shows the spectral ',...
        'decomp for a single frequency (section view) and the rightmost axes (the frequency axes) shows the spectral decomp at ',...
        'a single location (gather view). The vertical dashed red line in the specd axes indicates the ',...
        'location being displayed in the frequency axes. Similarly, the red dashed line in the ',...
        'frequency axes indicates the frequency being highlighted in the specd axes. Either red line ',...
        'can be changed by simply clicking a dragging it. At far left above the seismic axes is a ',...
        'button labelled "Hide seismic". Clicking this removes the seismic axes from the display ',...
        'allows the specd axes to fill the window. This action also displays a new button labelled ',...
        '"Toggle" which allows the display to be switched back and forth bwtween seismic and specd. ',...
        'When both seismic and specd are shown, there are two clipping controls, the left one being for the ',...
        'seismic and the right one being for the specd. Feel free to adjust these. Smaller clip ',...
        'numbers mean greater clipping. Selecting "graphical" for clipping opens a small window ',...
        'to allow interactive adjustment of the clipping controls. This window shows a histogram ',...
        'of the amplitudes in the current view along with two red vertical lines. The colobar extends ',...
        'from one line to the other and amplitudes not between these lines are clipped. '],...
        [],...
        ['On the far right are shown the parameters of the current spectral decomp. Changing any of ',...
        'values and pressing "Compute SpecD" creates a new spectral decomp. This tool retains any ',...
        'number of spectral decomps in memory unless they are expolicitly deleted. Above the section ',...
        'spectral decomp display is qa popup menu displaying the name of the current spectral view. ',...
        'Clicking on this menu allows any of the current spectral decomps to be displayed. '],...
        [],...
        ['The "Browse spectra" button allows inteactive examination of the spectra at any point in ',...
        'the section view. Clicking this button opens a new axes to display spectra. Next click on ',...
        'any point in the spectral decomp section view and the spectrum at that location will be ',...
        'displayed. Clicking the same button (now labelled "Stop browse" closes the spectral browsing '...
        'window.']};
    hinfo=showinfo(msg,'Instructions for spectral decomp tool');
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
    seisplotspecd('select');
elseif(strcmp(action,'colormap'))
    hcmap=findobj(gcf,'tag','colormap');
    cmaps=get(hcmap,'string');
    icmap=get(hcmap,'value');
    cm=eval(cmaps{icmap});
    if(strcmp(cmaps{icmap},'blueblack')||strcmp(cmaps{icmap},'greenblack')||strcmp(cmaps{icmap},...
            'copper')||strcmp(cmaps{icmap},'bone')||strcmp(cmaps{icmap},'gray')||...
            strcmp(cmaps{icmap},'winter')||strcmp(cmaps{icmap},'bluebrown')||...
            strcmp(cmaps{icmap},'greenblue'))
        cm=flipud(cm);
    end
    hseis=findobj(gcf,'tag','seis');
    hseissd=findobj(gcf,'tag','seissd');
    hgather=findobj(gcf,'tag','sdgather');
    hleft=findobj(gcf,'tag','left');
    ileft=get(hleft,'value');
    hright=findobj(gcf,'tag','right');
    iright=get(hright,'value');
    hboth=findobj(gcf,'tag','both');
    iboth=get(hboth,'value');
    hbars=findobj(gcf,'tag','colorbars');
    ibars=get(hbars,'value');
    
    %flag=get(happlytoall,'value');
    if(ileft || iboth)
        colormap(hseis,cm);
        if(ibars)
            colorbar2(hseis);
            set(hseissd,'yticklabel','');
            ylabel(hseissd,'');
        else
            colorbar2(hseis,'off');
%             ytl=get(hseis,'yticklabel');
            set(hseissd,'yticklabelmode','auto');
            ylabel(hseissd,'time (s)');
        end
    end
    if(iright || iboth)
        colormap(hseissd,cm);
        colormap(hgather,cm);
        if(ibars)
            colorbar2(hseissd);
            set(hgather,'yticklabel','');
            ylabel(hgather,'');
        else
            colorbar2(hseissd,'off');
%             ytl=get(hseis,'yticklabel');
            set(hgather,'yticklabelmode','auto');
            ylabel(hgather,'time (s)');
        end
    end
    %brighten(.5);
elseif(strcmp(action,'fmax'))
    hfmax=findobj(gcf,'tag','fmaxdisp');
    fmax=str2double(get(hfmax,'string'));
    hgather=findobj(gcf,'tag','sdgather');
    hspec=findobj(gcf,'tag','spectra');
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    fsd=udat{9};
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
    hmasterfig=gcf;
    hz12=findobj(hmasterfig,'tag','1like2');
    hclip=findobj(hmasterfig,'tag','clip1');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
%     amax=udat{4};
%     amin=udat{5};
    sigma=udat{3};
    hax=udat{6}(1);
    if(iclip==1)
        %doing graphical
        tmp=get(hz12,'userdata');
        posf=get(hmasterfig,'position');
        posc=get(hclip,'position');
        fwid=300;fht=150;
        x0=posf(1)+(posc(1)+posc(3))*posf(3);
        y0=posf(2)+(posc(2)-posc(4))*posf(4);
        hi=findobj(hax,'type','image');
        data=hi.CData;
        ind= data~=0;
        [N,xn]=hist(data(ind),100);
        %         tmp=[];
        %         if(length(udat)>6)
        %             tmp=udat{7};
        %         end
        if(isgraphics(tmp))
            %means a graphical window already exists
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
            ud{1}=[ud{1} hfig];
        end
        set(hmasterfig,'userdata',ud);
        %         udat{7}=hfig;
        set(hz12,'userdata',hfig);
        set(hclip,'userdata',udat);
        WinOnTop(hfig,true);
        climslider(hax,hfig,[0 0 1 1],N,xn);
    else
        hfig=get(hz12,'userdata');
        if(isgraphics(hfig))
            delete(hfig);
            set(hz12,'userdata',[]);
        end
        clip=clips(iclip);
        clim=[am-clip*sigma,am+clip*sigma];
        set(hax,'clim',clim);
    end
    
    
elseif(strcmp(action,'clip2'))
    hmasterfig=gcf;
    hz21=findobj(hmasterfig,'tag','2like1');
    hresults=findobj(hmasterfig,'tag','results');
    hclip=findobj(hmasterfig,'tag','clip2');
    udat=get(hclip,'userdata');
    iclip=get(hclip,'value');    
    clips=udat{1};
    am=udat{2};
    %amax=udat{4};
    %amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        %doing graphical
        tmp=get(hz21,'userdata');
        posf=get(hmasterfig,'position');
        posc=get(hclip,'position');
        fwid=300;fht=150;
        x0=posf(1)+(posc(1)+posc(3))*posf(3);
        y0=posf(2)+(posc(2)-posc(4))*posf(4);
        pos=figpos_ur([x0 y0 fwid fht]);
        hi=findobj(hax,'type','image');
        data=hi.CData;
        ind= data~=0;
        [N,xn]=hist(data(ind),100);
        if(isgraphics(tmp))
            %means a graphical window already exists
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
        set(hz21,'userdata',hfig);
        set(hclip,'userdata',udat);
        WinOnTop(hfig,true);
        climslider(hax,hfig,[0 0 1 1],N,xn);
        clim=get(gca,'clim');
    else
        hfig=get(hz21,'userdata');
        if(isgraphics(hfig))
            delete(hfig);
            set(hz21,'userdata',hfig)
        end
        clip=clips(iclip);
        clim=[-.5*sigma,am+clip*sigma];
        set(hax,'clim',clim);
    end
    
    results=get(hresults,'userdata');
    if(~isempty(results))
        iresult=get(hresults,'value');
        clipdat=results.clipdats{iresult};
        clipdat{4}=iclip;
        clipdat{9}=clim;
        results.clipdats{iresult}=clipdat;
        set(hresults,'userdata',results);
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
        DRAGLINE_MOTIONCALLBACK='seisplotspecd(''changeloc'');';
    elseif(hnow==h2)
        %clicked on f2
        DRAGLINE_MOTION='xonly';
        DRAGLINE_XLIMS=[fmin fmax];
        DRAGLINE_MOTIONCALLBACK='seisplotspecd(''changefreq'');';
    end
    
    dragline('click')
elseif(strcmp(action,'changeloc'))
    hobj=gco;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    x=udat{7};
    %fsd=udat{10};
    haxes=udat{6};
    seissd=udat{10};
    if(strcmp(get(hobj,'type'),'line'))
        xx=get(hobj,'xdata');
        xnow=xx(1);
        ix=near(x,xnow);
        hi=findobj(haxes(2),'type','image');
        set(hi,'cdata',squeeze(seissd(:,ix(1),:)));
%         ht=get(haxes(2),'title');
%         xnow=x(ix);
%         ht.String=['loc= ' num2str(xnow)];
    end
    
elseif(strcmp(action,'changefreq'))
    hobj=gco;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    %x=udat{7};
    fsd=udat{9};
    haxes=udat{6};
    seissd=udat{10};
    if(~strcmp(get(hobj,'type'),'line'))
       hobj=findobj(haxes(2),'tag','2'); 
    end
    xx=get(hobj,'xdata');
    fnow=xx(1);
    ix=near(fsd,fnow);
    fnow=fsd(ix(1));
    hi=findobj(haxes(1),'type','image');
    set(hi,'cdata',squeeze(seissd(:,:,ix(1))));
    
    ht=get(haxes(2),'title');
%     str=get(ht,'string');
%     ind=strfind(str,'=');
    set(ht,'string',['freq= ' num2str(fnow) ' Hz'])
elseif(strcmp(action,'step'))
    hstep=gcbo;
    hclip2=findobj(gcf,'tag','clip2');
    udat=get(hclip2,'userdata');
    %x=udat{7};
    fsd=udat{9};
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
    seisplotspecd('changefreq');
    
elseif(strcmp(action,'close'))
    haveamp=findobj(gcf,'tag','aveamp');
    hspec=get(haveamp,'userdata');
    if(isgraphics(hspec))
        delete(hspec);
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
    %this last bit avoids deleting the tool figure if there is another close function to be called
    %(usually PI2D or PI3D)
    crf=get(gcf,'closerequestfcn');
    ind=strfind(crf,';');
    if(ind(1)==length(crf))
        delete(gcf);
    end       
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
            colorbar2(hax1,'off');
            set(hax2,'yticklabelmode','auto');ylabel(hax2(1),'time (s)');
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
elseif(strcmp(action,'computespecd'))
    %plan: apply the specd parameters and display the results for the mean frequency
    hfig=gcf;
    hseis=findobj(hfig,'tag','seis');
    hseis2=findobj(hfig,'tag','seissd');
    hgather=findobj(hfig,'tag','sdgather');
    hclip2=findobj(hfig,'tag','clip2');
    udat=get(hclip2,'userdata');
%     seis=udat{11};
    %after implementation of agc, we get seis from 'cdata' of the image
    hi=findobj(hseis,'type','image');
    seis=get(hi,'cdata');
    t=udat{8};
    x=udat{7};
    %dname=udat{5};
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

    %do the spectral decomp
    phaseflag=3;
    tmin=t(1);tmax=t(end);
    [seissd,phs,tsd,fsd]=specdecomp(seis,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,1); %#ok<ASGLU>
    %tsd and t are the same because of the input after phaseflag
    
    %determine gather location and frequency to show
    h1=findobj(hseis2,'tag','1');
    h2=findobj(hgather,'tag','2');
    tmp=get(h1,'xdata');
    xgath=tmp(1);
    tmp=get(h2,'xdata');
    fshow=tmp(1);
    tmp=near(x,xgath);
    igath=tmp(1);
    if(~between(fsd(1),fsd(end),fshow))
        fshow=.5*(fsd(1)+fsd(end));
    end
    tmp=near(fsd,fshow);
    ifshow=tmp(1);

    set(hfig,'currentaxes',hseis2)
    
    %Check for an existing graphical window from the previous selection
    hz21=findobj(gcf,'tag','2like1');
    hprevwin=get(hz21,'userdata');
    if(~isempty(hprevwin))%will only be true if the previous selection had a graphical window
        hresult=findobj(hfig,'tag','results');
        results=get(hresult,'userdata');
        iresult=get(hresult,'value');
        %        udat=get(hclip2,'userdata');
        if(isgraphics(hprevwin))
            clim=climslider('getlims',hprevwin);
            delete(hprevwin);
        else
            clim=get(hgather,'clim');
        end
        set(hz21,'userdata',[]);
        results.clipdats{iresult}{9}=clim;
        set(hresult,'userdata',results);
        %        set(hclip2,'userdata',udat);
    end
    
%     fnot=fout(round(nf/2));
%     ifnot=near(fout,fnot);
%     hfnow=findobj(hfig,'tag','fnow');
%     set(hfnow,'string',['Fnow= ' num2str(fnot) 'Hz'],'userdata',ifnot)
    
    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seissd); %#ok<ASGLU>
    clip=6;
    iclip=near(clips,clip);
    clip=clips(iclip);
    clim=[-.5*sigma am+clip*sigma];
    clipdat={clips,clipstr,clip,iclip,sigma,am,amax,amin,clim};    
    hclip2=findobj(hfig,'tag','clip2');
    set(hclip2,'userdata',{clips,am,sigma,amax,amin,[hseis2 hgather],x,t,fsd,seissd,seis},...
        'string',clipstr,'value',iclip);
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    set(hseis2,'nextplot','add');
    hi=findobj(hseis2,'type','image');
    delete(hi);
    hi=imagesc(x,t,seissd(:,:,ifshow),clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    xlabel('crossline');ylabel('inline');
    happagc=findobj(gcf,'tag','appagc');
    oplen=get(happagc,'userdata');
    name=['Twin= ' time2str(twin) ', Tinc= ' time2str(tinc) ',Fmin= ', num2str(fmin) ...
        ', Fmax= ', num2str(fmax) ', delF= ', num2str(delf),', agc=' num2str(oplen)];
    set(hseis2,'tag','seissd','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    
    set(hfig,'currentaxes',hgather)
    xdir=get(hgather,'xdir');
    ydir=get(hgather,'ydir');
    xg=get(hgather,'xgrid');
    yg=get(hgather,'ygrid');
    ga=get(hgather,'gridalpha');
    gc=get(hgather,'gridcolor');
    set(hgather,'nextplot','add');
    hi=findobj(hgather,'type','image');
    delete(hi);
    hi=imagesc(fsd,t,squeeze(seissd(:,igath,:)),clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    xlabel('crossline');ylabel('inline');

    set(hgather,'tag','sdgather','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    
    %save result
    seisplotspecd('newresult',{name,seissd,twin,tinc,fmin,fmax,delf,fsd,clipdat});
    
elseif(strcmp(action,'newresult'))
    hfig=gcf;
    hdelete=findobj(gcf,'tag','delete');
    result=t;%second argument
    %result is a cell array with the following contents: 
    %   name, specd, twin, tinc, fmin, fmax, delf, fout, clipdat
    
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    if(isempty(results))
        nresults=1;
        results.names={result{1}};
        results.data={result{2}};
        results.twins={result{3}};
        results.tincs={result{4}};
        results.fmins={result{5}};
        results.fmaxs={result{6}};
        results.delfs={result{7}};
        results.fsds={result{8}};
        results.clipdats={result{9}};
    else
        nresults=length(results.names)+1;
        results.names{nresults}=result{1};
        results.data{nresults}=result{2};
        results.twins{nresults}=result{3};
        results.tincs{nresults}=result{4};
        results.fmins{nresults}=result{5};
        results.fmaxs{nresults}=result{6};
        results.delfs{nresults}=result{7};
        results.fsds{nresults}=result{8};
        results.clipdats{nresults}=result{9};
    end
    set(hresults,'string',results.names,'value',nresults,'userdata',results)
    hcompute=findobj(hfig,'tag','specdbutton');
    set(hcompute,'userdata',nresults);%the current result number stored here
    set(hdelete,'userdata',nresults);
    
elseif(strcmp(action,'select'))
    hfig=gcf;
    hdelete=findobj(gcf,'tag','delete');%this has the previous selection
    iprev=get(hdelete,'userdata');
    hresults=findobj(hfig,'tag','results');
    results=get(hresults,'userdata');
    iresult=get(hresults,'value');
    hcompute=findobj(hfig,'tag','specdbutton');
%     iresultold=get(hcompute,'userdata');
    set(hcompute,'userdata',iresult);
    hseis2=findobj(hfig,'tag','seissd');
    hgather=findobj(hfig,'tag','sdgather');
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
    
    %determine gather location and frequency to show
    hclip2=findobj(hfig,'tag','clip2');
    udat=get(hclip2,'userdata');
    seis=udat{11};
    t=udat{8};
    x=udat{7};
    fsd=results.fsds{iresult};
    h1=findobj(hseis2,'tag','1');
    h2=findobj(hgather,'tag','2');
    tmp=get(h1,'xdata');
    xgath=tmp(1);
    tmp=get(h2,'xdata');
    fshow=tmp(1);
    tmp=near(x,xgath);
    igath=tmp(1);
    if(~between(fsd(1),fsd(end),fshow))
        fshow=.5*(fsd(1)+fsd(end));
    end
    tmp=near(fsd,fshow);
    ifshow=tmp(1);
    seissd=results.data{iresult};
    %Check for an existing graphical window from the previous selection
    hz21=findobj(gcf,'tag','2like1');
    hprevwin=get(hz21,'userdata');
    if(~isempty(hprevwin))%will only be true if the previous selection had a graphical window
       prevclipdat=results.clipdats{iprev};
%        udat=get(hclip2,'userdata');
       if(isgraphics(hprevwin))
           clim=climslider('getlims',hprevwin);
           delete(hprevwin);
       else
           clim=get(hgather,'clim');
       end
       set(hz21,'userdata',[]);
       prevclipdat{9}=clim;
       results.clipdats{iprev}=prevclipdat;
%        set(hclip2,'userdata',udat);
    end
    %update clipping
    clipdat=results.clipdats{iresult};
    clips=clipdat{1};
    clipstr=clipdat{2};
%     clip=clipdat{3};
%     if(length(clip)==1)
%         clip=[-clip clip];
%     end
    iclip=clipdat{4};
    sigma=clipdat{5};
    am=clipdat{6};
    amax=clipdat{7};
    amin=clipdat{8};
    clim=clipdat{9};
    set(hclip2,'userdata',{clips,am,sigma,amax,amin,[hseis2 hgather],x,t,fsd,seissd,seis},...
        'string',clipstr,'value',iclip);
    
    %update images
    set(hfig,'currentaxes',hseis2)
    xdir=get(hseis2,'xdir');
    ydir=get(hseis2,'ydir');
    xg=get(hseis2,'xgrid');
    yg=get(hseis2,'ygrid');
    ga=get(hseis2,'gridalpha');
    gc=get(hseis2,'gridcolor');
    hi=findobj(hseis2,'type','image');
    delete(hi);%delete previous image
    hi=imagesc(x,t,seissd(:,:,ifshow),clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    if(strcmp(get(hseis2,'yticklabelmode'),'manual'))
        xlabel('distance');
    else
        xlabel('distance');ylabel('time (s)');
    end
    set(hseis2,'tag','seissd','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    
    set(hfig,'currentaxes',hgather)
    xdir=get(hgather,'xdir');
    ydir=get(hgather,'ydir');
    xg=get(hgather,'xgrid');
    yg=get(hgather,'ygrid');
    ga=get(hgather,'gridalpha');
    gc=get(hgather,'gridcolor');
    hi=findobj(hgather,'type','image');
    delete(hi);%delete previous
    hi=imagesc(fsd,t,squeeze(seissd(:,igath,:)),clim);
    hcm=uicontextmenu;
    uimenu(hcm,'label','Trace Inspector','callback',@showtraces); 
    set(hi,'uicontextmenu',hcm);
    if(strcmp(get(hgather,'yticklabelmode'),'manual'))
        xlabel('frequency (Hz)');
    else
        xlabel('frequency (Hz)');ylabel('time (s)');
    end
    set(hgather,'tag','sdgather','xdir',xdir,'ydir',ydir,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
    seisplotspecd('clip2');
    seisplotspecd('updatespectra');
    set(hresults,'userdata',results);
    set(hdelete,'userdata',iresult);
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
            set(hi,'buttondownfcn','seisplotspecd(''specpt'');');
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
    t=udat{8};
    hresult=findobj(gcf,'tag','results');
    results=get(hresult,'userdata');
    iresult=get(hresult,'value');
    seissd=results.data{iresult};
    fsd=results.fsds{iresult};
    %haxes=udat{6};
    it=near(t,pt(1,2));
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
elseif(strcmp(action,'agc'))
    hagc=findobj(gcf,'tag','agc');
    hseis=findobj(gcf,'tag','seis');
    udat=get(hagc,'userdata');
    seis=udat{1};
    t=udat{2};
    tmp=get(hagc,'string');
    oplen=str2double(tmp);
    if(isnan(oplen)||oplen<0||oplen>t(end))
        set(hagc,'string','0');
        msgbox(['Bad value for operator length. enter a value between 0 and ' num2str(t(end))]);
        return;
    end
    hi=findobj(hseis,'type','image');
    happagc=findobj(gcf,'tag','appagc');
    if(oplen==0)
        seis2=seis;
    else
        seis2=aec(seis,t(2)-t(1),oplen);
    end
    set(hi,'cdata',seis2);
    set(happagc,'userdata',oplen);
    hclip1=findobj(gcf,'tag','clip1');
    udat=get(hclip1,'userdata');
    udat{2}=mean(seis2(:));
    udat{3}=std(seis2(:));
    udat{4}=max(seis2(:));
    udat{5}=min(seis2(:));
    set(hclip1,'userdata',udat);
    seisplotfdom('clip1');    
    
end

end

function showtraces(~,~)
hmasterfig=gcf;
fromenhance=false;
if(strcmp(get(gcf,'tag'),'fromenhance'))
    fromenhance=true;
end
hseis=findobj(gcf,'tag','seis');
hseissd=findobj(gcf,'tag','seissd');
hgather=findobj(gcf,'tag','sdgather');
name=hseis.Title.String;

hi=gco;
seis=get(hi,'cdata');
t=get(hi,'ydata');
haxe=get(hi,'parent');

if(haxe==hseis)
    x=get(hi,'xdata');
    dname=name;
    %get current point
    pt=get(haxe,'currentpoint');
    ixnow=near(x,pt(1,1));
    xnow=x(ixnow(1));
    dname2=dname;
    mode=1;
elseif(haxe==hseissd)
    x=get(hi,'xdata');
    dname=[name '_SPECD'];
    %get current point
    pt=get(haxe,'currentpoint');
    ixnow=near(x,pt(1,1));
    xnow=x(ixnow(1));
    %get frequency from gather
    hline=findobj(hgather,'tag','2');
    tmp=get(hline,'xdata');
    fnow=tmp(1);
    dname2=[dname ' @f=' num2str(fnow)];
    mode=2;
else
    f=get(hi,'xdata');
    dname=[name '_SPECD_gather'];
    %get current point
    pt=get(haxe,'currentpoint');
    ifnow=near(f,pt(1,1));
    fnow=f(ifnow(1));
    %get xnow from specd
    hline=findobj(hseissd,'tag','1');
    tmp=get(hline,'xdata');
    xnow=tmp(1);
    dname2=[dname ' @x=' num2str(xnow)];
    mode=3;
end

%determine pixels per second
un=get(haxe,'units');
set(gca,'units','pixels');
pos=get(haxe,'position');
pixpersec=pos(4)/(t(end)-t(1));
set(haxe,'units',un);


pos=get(hmasterfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
switch mode
    case 1
        iuse=ixnow(1);
        seisplottraces(double(seis(:,iuse)),t,xnow,dname2,pixpersec);
    case 2
        iuse=ixnow(1);
        seisplottraces(double(seis(:,iuse)),t,xnow,dname2,pixpersec);
    case 3
        iuse=ifnow(1);
        seisplottraces(double(seis(:,iuse)),t,fnow,dname2,pixpersec);
end
hfig=gcf;
customizetoolbar(hfig);
if(fromenhance)
    seisplottraces('addpptbutton');
    set(gcf,'tag','fromenhance');
    pos2=get(hfig,'position');
    pos2(1)=xc-.5*pos2(3);
    pos2(2)=yc-.5*pos2(4);
    set(hfig,'position',pos2,'visible','on');
end

% hbrighten=findobj(hmasterfig,'tag','brighten');
% hfigs=get(hbrighten,'userdata');
% set(hbrighten,'userdata',[hfigs hfig]);

%determine is PI3D or PI2D called this decon tool
udat=get(hmasterfig,'userdata');
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
clipstr{1}='graphical';
for k=2:nclips
    clipstr{k}=['clip= ' num2str(sigfig(clips(k),3))];
end
iclip=near(clips,3);
clip=clips(iclip);

end