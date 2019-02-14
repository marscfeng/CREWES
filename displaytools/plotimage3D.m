function plotimage3D(seis,t,xline,iline,dname,cmap,gridx,gridy)
% PLOTIMAGE3D: provides interactive ability to browse and study a 3D seismic volume
%
% plotimage3D(seis,t,xline,iline,dname,cmap,gridx,gridy)
%
% Seismic data stored in a 3D matrix are presented in a way that facilites easy viewing. Data can be
% viewed as either inline (iline) or crossline (xline) vertical sections or as time slices. The 3D
% matrix must be organized with time as the first dimension, xline as the second dimension, and
% iline as the third dimension. The views presented are always 2D panels from the 3D volume and are
% presented as images (i.e. not wiggle traces). Controls are provided to adjust cliping and to step
% through the volume sequentially. Additionally, when more than one plotimage3D window is active,
% then they can be grouped (linked) and browsed simultaneously. Changing the view in any window of a
% group causes all members of the group to show the same view.  Other functionality includes: easy
% copying of any view to the Windows clipboard (for pasting into PowerPoint), adjusting the display
% clip level, changing the colormap, saving views of interest for easy return, easy cursor location
% in data coordinates, flipping inline and crossline axes direction. Extended analysis functions are
% available through right-clicking on a displayed image. For cross sections, the available options
% are f-k spectrum, time-variant f sprectrum, and f-x analysis sections.
%
% seis ... 3D seismic matrix. Should be a regular grid with dimension 1
%       (row) as time, dimension 2 (column) as xline, and dimension 3 as
%       iline.
% t ... time coordinate vector for seis. Must has the same length as
%       size(seis,1)
% xline ... crossline coordinate or x coordinate. Must have length equal to
%       size(seis,2). Can be a cell array in which case xline{1} is the crossline coordinate and
%       xline{2} is the crossline geographic coordinate (cdp). They must be same sized vectors.
% iline ... inline coordinate or y coordinate. Must have length equal to
%       size(seis,3). Can be a cell array in which case iline{1} is the crossline coordinate and
%       iline{2} is the crossline geographic coordinate (cdp). They must be same sized vectors.
% dataname ... string giving a name for the dataset
% ************ default = '' ***********
% cmap ... initial colormap. This is a text string and should be one of
%     colormaps={'seisclrs','parula','jet','hsv','copper','autumn','bone'...
%         'gray','cool','winter','spring','alpine','summer','hot'};
% ************ default = 'seisclrs' ***********
% gridx ... physical distance between crosslines
% ************ default abs(xline(2)-xline(1)) **********
% gridy ... physical distance between inlines
% ************ default abs(iline(2)-iline(1)) **********
% NOTE: gridx and gridy are only important if you intend to examine 2D spectra of inline, crossline,
% or timeslice views or do wavenumber filtering (all actions accessed by right-clicking in image
% views). The default values will not give physically correct wavenumbers for these processes.
% 
% NOTE2: Missing traces should be filled with zeros (not nan's). The presence of nan's in the data
% volume will cause the program to fail. 
%
% NOTE3: This function is designed to work with the specific size window that it creates by default.
% If you resize this window significantly, then the axes labels (coordinates) may become incorrect.
% There is currently no workaround for this.
%
% NOTE4: When reading into memory using readsegy, a 3D survey will be stored as a 2D matrix in trace
% sequential mode (i.e. one trace after another). You must move these traces into a 3D matrix in
% order to use plotimage3D. Unless the 3D survey has a perfectly square spatial aperture, this will
% generally involve padding with zero traces. You can use 'make3dvol' for this purpose. Here is an
% axample:
%
% Let path and fname be strings whose concatenation points to the input dataset
% [seis,dt,segfmt,texthdrfmt,byteorder,texthdr,binhdr,exthdr,traceheaders] =readsegy([path fname]);
% 
% t=dt*(0:size(seis,1)-1)'; %time coordinate vector
% ilineall=double(traceheaders.InlineNum); %get inline numbers from trace headers
% xlineall=double(traceheaders.XlineNum); %get xline numbers from trace headers
% cdpx=double(traceheaders.CdpX); %get cdpx from trace headers
% cdpy=double(traceheaders.CdpY); %get cdpy from trace headers
%
% [seis3D,xline,iline,xcdp,ycdp,kxline]=make3Dvol(seis,xlineall,ilineall,cdpx,cdpy);
%
% plotimage3D(seis3D,t,xline,iline,'My 3D dataset');
%
% This example expects the inline and crossline numbers and the inline and crossline cdp values to
% be stored in the SEGY trace headers in the standard places. It will fail if this is not the case
% with your data.
%
% G.F. Margrave, Devon Energy, 2016-2017
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

%USER DATA information
%
% control ... tagstring ... userdata
% hbasemap ... 'basemap' ... {seis, t, xline, iline, dname, [smean sdev smin smax], gridx, gridy}
% hinline ... 'inlinebox' ... ykol (yellow color user to indicate which mode is active)
% htslice ... 'tslicebox' ... dt (time sample rate)
% hb1 ... 'inlinemode' ... [hb2 hb3 hinline hxline htslice] (handles of various controls)
% hampapply ... 'ampapply' ... [hmax hmin hmaxlbl hminlbl] (handles of manual clipping controls)
% hlocate ... 'locate' ... a flag used by locate mechanism
% hinlinebutton ... 'inlinemode' ... 5 handles
% htslicebutton ... 'tslicemode' ... not used
% hxlinebutton ... 'xlinemode' ... not used
% hpreviousbutton ... 'previous' ... info for context menu and other uses cell array
%               {seismic_section, xcoord, ycoord, mode, 3rdcoord, dname, dx, dy} See updateview
% hnextbutton ... 'next' ... not used
% hincrementbutton ... 'increment' ... notused
% htmin ... 'tmin' ... time increment for tmin and tmax 
% htmax ... 'tmax' ... not used
% 
% To find any of these handles, just use h=findobj(gcf,'tag','tagstring')
% 
% 
global PLOTIMAGE3DFIGS PLOTIMAGE3DDATASIZE PLOTIMAGE3DDIFFDIAL PLOTIMAGE3DINFODIAL PLOTIMAGE3DMASTER PLOTIMAGE3DTHISFIG;
% Description of globals
% PLOTIMAGE3DFIGS ... Ordinary array of Figure handles of the grouped figures. The first figure is
%           considered the master figure.
% PLOTIMAGE3DDATASIZE ... ordinary array containing size numbers for each grouped dataset. The first
%           3 are the dataset sizes in t,x, and y. The second 3 are shifts for each of the 3
%           dimensions needed to align with the master figure.
% PLOTIMAGE3DDIFFDIAL ... handle to the difference dialog.
% PLOTIMAGE3DINFODIAL ... handle to the information dialog
% PLOTIMAGE3DMASTER ... handle of the master figure in the group
% PLOTIMAGE3DTHISFIG ... set by SANE when it controls the plotimage3D figure and we are doing a grouping operation
%

%installing an analysis tool
%these are accessed via right clicking on a displayed image plot
% 1) Go to the internal function updateview (in this file)
% 2) There are 3 possible views (modes): 'inline', 'xline', 'tslice'. For each view you can set the
%       right-click action via a context menu entry. There is a switch statment with a case for
%       each type of view.
% 3) Decide which of the views (can be all) that you wish your tool to be active on. Then, inside
%       the case statement for that view, locate the line hcm=uicontextmenu; Below that line are a
%       series of uimenu statements, one for each tool that appears on a right click. Duplicate one
%       of the existing lines and modify it for your tool. The last entry in the uimenu call is the
%       callback that executes when the menu is selected.
% 4) Choose a unique name for your function callback and then write the correspondiong internal
%       function. For example, the 2D spectra callback is @show2dspectrum and corresponding to this
%       there is the internal function function show2dspectrum(~,~) in this file. The data that you
%       want to operate on are found in the userdata for hprevious. See the first few lines of
%       show2dspectrum to see how to get this data.
% 5) Most of the present tools pass data to one of the seisplotXXXX utilities (see the displaytools
%       folder). A good development plan is to create the new seisplotXXXX tool separately by
%       copying and modifying one of the existing tools. Then, once the tool is ready, the function
%       mentioned in part 4) merely has to pass data to the new seisplotXXX tool.
if(ischar(seis))
    action=seis;
else
    action='init';
end

if(strcmp(action,'init'))
    
    PLOTIMAGE3DDIFFDIAL=[];
    geooption=false;
    xcdp=false;
    ycdp=false;
    geooption=true;%this is true if the option to switch to geographic coordinates exists
    if(iscell(xline))
        xcdp=xline{2};
        xline=xline{1};
    end
    if(iscell(iline))
        ycdp=iline{2};
        iline=iline{1};
    end
    
    if(nargin<5)
        dname='';
    end
    if(nargin<6)
        cmap='seisclrs';
    end
    if(nargin<7)
        gridx=abs(xline(2)-xline(1));
    end
    if(nargin<8)
        gridy=abs(iline(2)-iline(1));
    end
    if(~isa(seis,'single'))
        seiss=single(seis);
        clear seis;
    else
        seiss=seis;
        clear seis;
    end
    [nt,nx,ny]=size(seiss);
    
    if(length(t)~=nt)
        error('t is the wrong size')
    end
    if(length(xline)~=nx)
        error('xline is wrong size');
    end
    if(length(iline)~=ny)
        error('iline is wrong size');
    end
    if(gridx==1 && length(xcdp)==1)
        if(~xcdp)
            geooption=false;
        end
    end
    if(~xcdp)
       xcdp=gridx*(0:length(xline)-1);
    end
    if(~ycdp)
        ycdp=gridy*(0:length(iline)-1)';
    end
    xline=xline(:)';%row vector
    iline=iline(:);%column vector
    xx=xline(ones(size(iline)),:);
    yy=iline(:,ones(size(xline)));
    
    figure
    set(gcf,'menubar','none','toolbar','figure');
    bigfig
    pos=get(gcf,'position');
    %get plotting statistics
    %first determine where the zero traces are
    set(gcf,'name',['plotimage3D ... ' dname]);
    map=squeeze(sum(abs(seiss(:,:,:)),1))';
    %ideadtr=find(map==0);
    ilivetr=find(map~=0);
    %map(ixlive,iylive)=1;
    xlive=xx(ilivetr);
    ylive=yy(ilivetr);
    %determine max min mean and std by examining 10 inlines and 10 xlines
    n1=min([10 length(xline)]);
    n2=min([10 length(iline)]);
    idel=round(length(xline)/n1);
    ix1=10:idel:length(xline);
    idel=round(length(iline)/n2);
    iy1=10:idel:length(iline);
    amax1=zeros(1,length(ix1));
    amin1=amax1;
    std1=amax1;
    amean1=amax1;
    ns1=amax1;
    for k=1:length(ix1)
       tmp=squeeze(seiss(:,ix1(k),:));
       ilive=find(tmp~=0);
       if(~isempty(ilive))
           ns1(k)=length(ilive);
           amax1(k)=max(tmp(ilive));
           amin1(k)=min(tmp(ilive));
           std1(k)=std(tmp(ilive));
           amean1(k)=mean(tmp(ilive));
       end
    end
    amax2=zeros(1,length(iy1));
    amin2=amax2;
    std2=amax2;
    amean2=amax2;
    ns2=amax2;
    for k=1:length(iy1)
       tmp=squeeze(seiss(:,:,iy1(k)));
       ilive=find(tmp~=0);
       if(~isempty(ilive))
           ns2(k)=length(ilive);
           amax2(k)=max(tmp(ilive));
           amin2(k)=min(tmp(ilive));
           std2(k)=std(tmp(ilive));
           amean2(k)=mean(tmp(ilive));
       end
    end
    smean=sum([amean1.*ns1 amean2.*ns2])/sum([ns1 ns2]);
    sdev=sqrt(sum([std1.^2.*ns1 std2.^2.*ns2])/sum([ns1 ns2]));
    smax=max([amax1 amax2]);
    smin=min([amin1 amin2]);
%     ilive=find(seiss);%live samples (really just the nonzero samples)
%     smean=mean(seiss(ilive));
%     sdev=std(seiss(ilive));
%     smax=max(seiss(ilive));
%     smin=min(seiss(ilive));

    %info button
    uicontrol(gcf,'style','pushbutton','string','Info','units','normalized','tag','info',...
        'position',[0,.975,.025,.025],'callback','plotimage3D(''pi3dinfo'');','backgroundcolor','y');
    
    %make the basemap axes
    xnot=.05;ynot=.1;
    width=.15;ht=.2;
    ynow=1-ynot-ht;
    xnow=xnot;
    hbmap=axes('position',[xnow,ynow,width,ht],'tag','basemap');
    set(gcf,'nextplot','add');
    hh=plot(xlive(:),ylive(:),'r.','markersize',.1);flipy;
    set(gcf,'nextplot','new');
    set(hbmap,'tag','basemap');
    set(hh,'color',[.5 .5 .5]);
    set(hbmap,'yaxislocation','right');
    xlabel('crossline');ylabel('inline');
    title('basemap')
    xmin=min(xline);
    ymin=min(iline);
    xmax=max(xline);
    ymax=max(iline);
    xlim([xmin xmax]);
    ylim([ymin ymax]);
    set(hbmap,'userdata',{seiss, t, xline, iline, dname, [smean sdev smin smax], gridx, gridy, xcdp, ycdp, ilivetr})
    
    %make the geographic coordinates option
    if(geooption)
        geoviz='on';
    else
        geoviz='off';
    end
    
    ht2=.03;
    wid2=.1;
    uicontrol(gcf,'style','radiobutton','string','geographic coords','units','normalized','tag','geo',...
        'position',[xnow,ynow+ht+ht2,wid2,ht2;],'callback','plotimage3D(''geooption'');',...
        'tooltipstring','switch to geographic coordinates for seismic display','visible',geoviz,...
        'value',0,'userdata',{xline iline xcdp ycdp});
    uicontrol(gcf,'style','radiobutton','string','local origin','units','normalized','tag','locor',...
        'position',[xnow+wid2,ynow+ht+ht2,wid2,ht2;],'callback','plotimage3D(''locor'');',...
        'tooltipstring','use local coordinates, i.e. (0,0) origin','visible','off',...
        'value',1);
    
    %mode buttons
    sep=.05;
    ht=.03;
    width=.05;
    ynow=ynow-sep-ht;
    ykol=[1 1 .5];
    fs=10;
    if(pos(3)<1500)
        fs=7;
    end
    if(pos(3)<900)
        fs=6;
    end

%     hb1=uicontrol(gcf,'style','pushbutton','string','Inline','tag','inlinemode',...
%         'units','normalized','position',[xnow ynow width ht],'callback',...
%         'plotimage3D(''inlinemode'')','backgroundcolor',ykol,'fontsize',fs);
%     sep=.01;
%     xnow=xnow+width+sep;
%     hb2=uicontrol(gcf,'style','pushbutton','string','Xline','tag','xlinemode',...
%         'units','normalized','position',[xnow ynow width ht],'callback',...
%         'plotimage3D(''xlinemode'')','fontsize',fs);
%     xnow=xnow+width+sep;
%     hb3=uicontrol(gcf,'style','pushbutton','string','Tslice','tag','tslicemode',...
%         'units','normalized','position',[xnow ynow width ht],'callback',...
%         'plotimage3D(''tslicemode'')','fontsize',fs);
    hb1=uicontrol(gcf,'style','text','string','Inline','tag','inlinemode',...
        'units','normalized','position',[xnow ynow-.6*ht width ht],...
        'backgroundcolor',ykol,'fontsize',fs);
    sep=.01;
    xnow=xnow+width+sep;
    hb2=uicontrol(gcf,'style','text','string','Xline','tag','xlinemode',...
        'units','normalized','position',[xnow ynow-.6*ht width ht],'fontsize',fs);
    xnow=xnow+width+sep;
    hb3=uicontrol(gcf,'style','text','string','Tslice','tag','tslicemode',...
        'units','normalized','position',[xnow ynow-.6*ht width ht],'fontsize',fs);
    
    
    xnow=xnot;
    ynow=ynow-sep-ht;
    inot=round(length(iline)/2);%first inline to display
    hinline=uicontrol(gcf,'style','edit','string',int2str(iline(inot)),'tag','inlinebox',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''inline'')','backgroundcolor',ykol,'fontsize',fs,...
        'userdata',ykol,'tooltipstring',...
        ['inline number to view (min=' int2str(min(iline)) ', max=' int2str(max(iline)) ')']);
    sep=.01;
    xnow=xnow+width+sep;
    hxline=uicontrol(gcf,'style','edit','string','all','tag','xlinebox',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''xline'')','fontsize',fs,'tooltipstring',...
        ['xline number to view (min=' int2str(min(xline)) ', max=' int2str(max(xline)) ')']);
    xnow=xnow+width+sep;
    htslice=uicontrol(gcf,'style','edit','string','all','tag','tslicebox',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''tslice'')','fontsize',fs,'userdata',t(2)-t(1),...
        'tooltipstring',...
        ['timeslice to view (min=' num2str(min(t)) ', max=' num2str(max(t)) ')']);
    
    set(hb1,'userdata',[hb2 hb3 hinline hxline htslice]);
    
    %prev, next and increment
    xnow=xnot;
    ynow=ynow-sep-ht;
    uicontrol(gcf,'style','pushbutton','string','previous','tag','previous',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''previous'')','fontsize',fs,'tooltipstring',...
        'increment the view to the previous inline/xline/tslice');
    sep=.01;
    xnow=xnow+width+sep;
    uicontrol(gcf,'style','pushbutton','string','next','tag','next',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''next'')','fontsize',fs,'tooltipstring',...
        'increment the view to the next inline/xline/tslice');
    xnow=xnow+width+sep;
    w2=width/2-.5*sep;
    nudge=.25*ht;
    uicontrol(gcf,'style','text','string','incr:','units','normalized',...
        'position',[xnow,ynow-nudge,w2,ht],'fontsize',fs,...
        'tooltipstring','increment for prev and next');
    xnow=xnow+w2;
    uicontrol(gcf,'style','edit','string','10','tag','increment',...
        'units','normalized','position',[xnow ynow w2+sep ht],'callback',...
        'plotimage3D(''increment'')','fontsize',fs,...
        'tooltipstring','specify increment in samples');
    
    %tmin and tmax
    xnow=xnot;
    ynow=ynow-sep-ht;
    tmin=min(t);
    tmax=max(t);
    tinc=.1;
    tminvalues=tmin:tinc:tmax-tinc;
    tminlabels=num2strcell(tminvalues,-1);
    width2=.5*width;
    uicontrol(gcf,'style','text','string','Tmin:','tag','tminlabel',...
        'units','normalized','position',[xnow ynow-nudge width2 ht],'fontsize',fs,...
        'tooltipstring','Choose minimum display time.');
    sep=.01;
    xnow=xnow+width2;
    uicontrol(gcf,'style','popupmenu','string',tminlabels,'tag','tmin',...
        'units','normalized','position',[xnow ynow width2 ht],'callback',...
        'plotimage3D(''tmin_tmax'')','fontsize',fs,'value',1,'userdata',tinc);
    xnow=xnow+sep+width2;
    tmin=min(t);
    tmax=max(t);
    tmaxvalues=tmin+tinc:tinc:tmax;
    tmaxlabels=num2strcell(tmaxvalues,-1);
    uicontrol(gcf,'style','text','string','Tmax:','tag','tmaxlabel',...
        'units','normalized','position',[xnow ynow-nudge width2 ht],'fontsize',fs,...
        'tooltipstring','Choose maximum display time.');
    sep=.01;
    xnow=xnow+width2;
    uicontrol(gcf,'style','popupmenu','string',tmaxlabels,'tag','tmax',...
        'units','normalized','position',[xnow ynow width2 ht],'callback',...
        'plotimage3D(''tmin_tmax'')','fontsize',fs,'value',length(tmaxlabels));
    
    %clip control
    xnow=xnot;
    ynow=ynow-3*sep-ht;
    uicontrol(gcf,'style','text','string','Clip level:','tag','cliplabel',...
        'units','normalized','position',[xnow ynow-nudge width ht],'fontsize',fs,...
        'tooltipstring','Choose clipping level, smaller means more clipping.');
    sep=.01;
    xnow=xnow+width;
    cliplevels={'manual','30','20','15','10','8','7','6','5','4','3','2','1','.5','.25','.1','.05'};
    iclip=10;%starting clip level
    uicontrol(gcf,'style','popupmenu','string',cliplevels,'tag','cliplevel',...
        'units','normalized','position',[xnow ynow .75*width ht],'callback',...
        'plotimage3D(''clip'')','fontsize',fs,'value',iclip,...
        'tooltipstring','Value is the number of standard deviations from the mean at which clipping occurs.');
    
    %manual amplitude controls
    xnow=xnow+.5*width+2*sep;
    ynow=ynow+.75*ht;
    vis='off';
    hmaxlbl=uicontrol(gcf,'style','text','string','max:','tag','maxamplbl',...
        'units','normalized','position',[xnow,ynow-nudge,.5*width',ht],...
        'fontsize',fs,'visible',vis,'tooltipstring',...
        'Enter the maximum amplitude to be displayed without clipping.');
    xnow=xnow+.5*width;
    hmax=uicontrol(gcf,'style','edit','string',num2str(smean+str2double(cliplevels{iclip})*sdev),'tag','maxamp',...
        'units','normalized','position',[xnow ynow width ht],'fontsize',...
        fs,'visible',vis,...
        'tooltipstring','Walue shown is the current clipping maximum.');
    xnow=xnow-.5*width;
    ynow=ynow-ht;
    hminlbl=uicontrol(gcf,'style','text','string','min:','tag','minamplbl',...
        'units','normalized','position',[xnow,ynow-nudge,.5*width',ht],...
        'fontsize',fs,'visible',vis,'tooltipstring',...
        'Enter the minimum amplitude to be displayed without clipping.');
    xnow=xnow+.5*width;
    hmin=uicontrol(gcf,'style','edit','string',num2str(smean-str2double(cliplevels{iclip})*sdev),'tag','minamp',...
        'units','normalized','position',[xnow ynow width ht],'fontsize',...
        fs,'visible',vis,...
        'tooltipstring','Value shown is the current clipping minimum.');
    ynow=ynow-ht;
    uicontrol(gcf,'style','pushbutton','string','apply','tag','ampapply',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''manualclipping'')','fontsize',fs,'visible',vis,...
        'tooltipstring','Push to apply manual clipping.',...
        'userdata',[hmax hmin hmaxlbl hminlbl]);
    
    %colormap control
    xnow=xnot;
    ynow=ynow-1.25*ht;
    uicontrol(gcf,'style','text','string','Colormap:','tag','colomaplabel',...
        'units','normalized','position',[xnow ynow-.5*nudge width ht],'fontsize',fs);
    sep=.01;
    xnow=xnow+width;
    if(exist('parula','file')==2)
        colormaps={'seisclrs','redblue','redblue2','redblue3','blueblack','bluebrown','greenblack',...
            'greenblue','jet','parula','copper','bone','gray','winter'};
        icolor=2;%starting colormap
    else
        colormaps={'seisclrs','redblue','redblue2','redblue3','blueblack','bluebrown','greenblack',...
            'greenblue','jet','copper','bone','gray','winter'};
        icolor=2;%starting colormap
    end
    for k=1:length(colormaps)
        if(strcmp(colormaps{k},cmap))
            icolor=k;
        end
    end
    uicontrol(gcf,'style','popupmenu','string',colormaps,'tag','colormap',...
        'units','normalized','position',[xnow ynow width ht],'callback',...
        'plotimage3D(''colormap'')','fontsize',fs,'value',icolor);
    
    %grid lines
    xnow=xnow+width+.5*sep;
    uicontrol(gcf,'style','text','string','Grid lines boldness:','tag','grid',...
        'units','normalized','position',[xnow,ynow-.5*nudge,1.5*width,ht],'fontsize',fs,...
        'tooltipstring','turn coordinate grid on or off');
    %ynow=ynow-ht;
    xnow2=xnow+1.5*width;
    gridoptions={'off','.1','.2','.3','.4','.5','.6','.7','.8','.9','1'};
    uicontrol(gcf,'style','popupmenu','string',gridoptions,'tooltipstring',...
        'larger number means darker grid lines','units','normalized',...
        'position',[xnow2,ynow,.5*width,ht],'callback','plotimage3D(''grid'')',...
        'value',1,'fontsize',fs,'tag','gridoptions');
    %grid color
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Grid color:','tag','grid',...
        'units','normalized','position',[xnow,ynow-.5*nudge,.75*width,ht],'fontsize',fs,...
        'tooltipstring','Choose grid color');
    gridcolors={'black','white','red','dark red','blue','green','dark green','cyan','magenta','yellow','dark yellow'};
    xnow2=xnow2-.75*width;
    uicontrol(gcf,'style','popupmenu','string',gridcolors,'tooltipstring',...
        'Choose the grid color','units','normalized',...
        'position',[xnow2,ynow,width,ht],'callback','plotimage3D(''grid'')',...
        'value',1,'fontsize',fs,'tag','gridcolors','userdata',{'k','w','r',[.5 0 0],'b','g',[0 .5 0],'c','m','y',[.8 .8 0]});
    
    %brightness
    xnow=xnot;
    %ynow=ynow-ht;
    uicontrol(gcf,'style','text','string','Brightness:','tag','brightnesslabel',...
        'units','normalized','position',[xnow ynow-.5*nudge width ht],'fontsize',fs);
    sep=.01;
    xnow=xnow+width;
    brightnesses={'0.8','0.7','0.6','0.5','0.4','0.3','0.2','0.1','0','-0.1','-0.2','-0.3','-0.4','-0.5','-0.6','-0.7','-0.8'};
    uicontrol(gcf,'style','popupmenu','string',brightnesses,'tag','brighten',...
        'units','normalized','position',[xnow ynow .6*width ht],'callback',...
        'plotimage3D(''colormap'')','fontsize',fs,'value',9);
    %flip colormap
    xnow=xnot;
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','Flip Colormap:','tag','flipcolormaplabel',...
        'units','normalized','position',[xnow ynow 1.5*width ht],'fontsize',fs);
    xnow=xnow+1.5*width;
    uicontrol(gcf,'style','radiobutton','tag','flipcolormap','value',0,...
        'units','normalized','position',[xnow ynow+.9*nudge .3*width ht],'callback','plotimage3D(''colormap'')');
    %copy to clipboard
    xnow=xnot;
    ynow=ynow-ht;
    if(isunix)
        msg='To TIFF file without controls';
        msg2='Save current view to a TIFF file without controls';
    else
        msg='To Clipboard without controls';
        msg2='Copy current view to the WINDOWS clipboard without control panel';
    end
    uicontrol(gcf,'style','pushbutton','string',msg,'tag','clipboardalt',...
        'units','normalized','position',[xnow,ynow,2*width ht],'callback',...
        'plotimage3D(''clipboardalt'')','fontsize',fs,'tooltipstring',msg2);
    if(isunix)
        msg='To TIFF file with controls';
        msg2='Save current view to a TIFF file with controls';
    else
        msg='To Clipboard with controls';
        msg2='Copy current view to the WINDOWS clipboard with control panel';
    end
    uicontrol(gcf,'style','pushbutton','string',msg,'tag','clipboard',...
        'units','normalized','position',[xnow+2*width,ynow,2*width ht],'callback',...
        'plotimage3D(''clipboard'')','fontsize',fs,'tooltipstring',msg2);
    
    
    %add to group
    ynow=ynow-ht-.5*sep;
    uicontrol(gcf,'style','pushbutton','string','Add to Group','units',...
        'normalized','position',[xnow,ynow,1.3*width,ht],'callback',...
        'plotimage3D(''group'')','fontsize',fs,'tooltipstring',...
        'Include in group of linked plotimage3D figures','tag','group');
    %remove from group
    xnow=xnow+1.3*width;
    uicontrol(gcf,'style','pushbutton','string','Remove from Group','units',...
        'normalized','position',[xnow,ynow,1.3*width,ht],'callback',...
        'plotimage3D(''ungroup'')','fontsize',fs,'tooltipstring',...
        'Remove from group of linked plotimage3D figures','tag','ungroup');
    
    %group info
    xnow=xnot;
    ynow=ynow-ht-.5*sep;
    uicontrol(gcf,'style','pushbutton','string','Group info','units',...
        'normalized','position',[xnow,ynow,1.3*width,ht],'callback',...
        'plotimage3D(''groupinfo'');','fontsize',fs,'tooltipstring',...
        'Show group datasets and time shifts','tag','groupinfo');
    %clear group
    xnow=xnow+1.3*width;
    uicontrol(gcf,'style','pushbutton','string','Clear Group','units',...
        'normalized','position',[xnow,ynow,1.3*width,ht],'callback',...
        'plotimage3D(''cleargroup'')','fontsize',fs,'tooltipstring',...
        'Clear the group of linked figures to start a new group',...
        'tag','cleargroup');
    %group zoom
    xnow=xnow+1.3*width;
    uicontrol(gcf,'style','pushbutton','string','Group zoom','units',...
        'normalized','position',[xnow,ynow,1.3*width,ht],'callback',...
        'plotimage3D(''groupzoom'')','fontsize',fs,'tooltipstring',...
        'Zoom one member of a group and then push this to zoom all members',...
        'tag','cleargroup');
    
    %save views
    xnow=xnot;
    ynow=ynow-ht-.5*sep;
    uicontrol(gcf,'style','pushbutton','string','Save view','units',...
        'normalized','position',[xnow,ynow,width,ht],'callback',...
        'plotimage3D(''saveview'')','fontsize',fs,'tooltipstring',...
        'Save this view for easy return','tag','saveview');
    %forget views
    xnow=xnow+width;
    uicontrol(gcf,'style','pushbutton','string','Forget view','units',...
        'normalized','position',[xnow,ynow,width,ht],'callback',...
        'plotimage3D(''forgetview'')','fontsize',fs,'tooltipstring',...
        'Remove from list of saved views','tag','forgetview');
    %restore views
    xnow=xnow+width;
    uicontrol(gcf,'style','popupmenu','string',{'Saved views'},'units',...
        'normalized','position',[xnow,ynow,1.5*width,ht],'callback',...
        'plotimage3D(''restoreview'')','fontsize',fs,'tooltipstring',...
        'Remove from list of saved views','tag','savedviews');
    
    %cursor locate button
    xnow=xnot;
    ynow=ynow-ht-.5*sep;
    uicontrol(gcf,'style','pushbutton','string','cursor locate on','units',...
        'normalized','position',[xnow ynow 1.2*width ht],'tag','locate',...
        'fontsize',fs,'tooltipstring','Turn on location information at cursor',...
        'callback','plotimage3D(''locate'')','userdata',[]);
    %flipx button
    xnow=xnow+1.2*width;
    uicontrol(gcf,'style','pushbutton','string','flip xline','units',...
        'normalized','position',[xnow ynow width ht],'tag','locate',...
        'fontsize',fs,'tooltipstring','Reverse the x axis',...
        'callback','plotimage3D(''flipx'')','userdata',1,'tag','flipx');
    %userdata, 1 for normal -1 for reversed. This refers to the seismic
    %axis which uses the image convention for axis direction. For images, 
    %xdir normal increases to the right while ydir normal increases down.
    %For normal plots, xdir is the same but ydir increases up.
    %flipy button
    xnow=xnow+width;
    uicontrol(gcf,'style','pushbutton','string','flip inline','units',...
        'normalized','position',[xnow ynow width ht],'tag','locate',...
        'fontsize',fs,'tooltipstring','Reverse the y axis',...
        'callback','plotimage3D(''flipy'')','userdata',1,'tag','flipy');
    ynow=ynow-ht-.5*sep;
    xnow=xnot;
    uicontrol(gcf,'style','text','string','Associated figures:','units','normalized',...
        'position',[xnow,ynow-.5*nudge,1.5*width,ht],'fontsize',fs);
    xnow=xnow+1.5*width;
    uicontrol(gcf,'style','popupmenu','string',{'None'},'tag','windows',...
        'units','normalized','position',[xnow ynow 2*width ht],'fontsize',fs,...
        'callback','plotimage3D(''show_window'')');
    xnow=xnow+2*width;
    uicontrol(gcf,'style','pushbutton','string','Close all','tag','closeall','units','normalized',...
        'position',[xnow, ynow, .5*width, ht],'callback','plotimage3D(''closeall'');',...
        'tooltipstring','close all associated figure windows');%user data will be used by dialog
    %userdata of this popup is a vector of windows handles
    
    set(gcf,'closerequestfcn','plotimage3D(''close'');');
    
    %make the seismic axes and show the first inline
    xnow=xnot+3*sep+5*width;
    width=.6;
    ht=.8;
    ynow=ynot;
    %hseismic=axes('position',[xnow,ynow,width,ht],'tag','seismic');
    axes('position',[xnow,ynow,width,ht],'tag','seismic');
    updateview;
    
elseif(strcmp(action,'inline'))
    %hfigs=getfigs;
    hthisfig=gcf;
    hinlinemode=findobj(hthisfig,'tag','inlinemode');
    udat=get(hinlinemode,'userdata');
    hxlinemode=udat(1);
    htslicemode=udat(2);
    hinline=udat(3);
    hxline=udat(4);
    htslice=udat(5);
    kol_off=.94*ones(1,3);
    kol_on=get(hinline,'userdata');
    tmp=get(hinline,'string');
    iline_chosen=str2double(tmp);
    if(isnan(iline_chosen))
        msgbox('You must enter an integer number to chose an inline',...
            'Ooops!');
        return;
    end
    hbmap=findobj(hthisfig,'tag','basemap');
    udat=get(hbmap,'userdata');
    iline=udat{4};
    imin=min(iline);imax=max(iline);
    if(iline_chosen<imin || iline_chosen>imax)
        msgbox(['Invalid inline number, must be between ' int2str(imin) ...
            ' and ' int2str(imax)],'Ooops!');
        return;
    end
    set(hinlinemode,'backgroundcolor',kol_on);
    set(hinline,'backgroundcolor',kol_on);
    set(hxlinemode,'backgroundcolor',kol_off);
    set(hxline,'backgroundcolor',kol_off,'string','all');
    set(htslicemode,'backgroundcolor',kol_off);
    set(htslice,'backgroundcolor',kol_off,'string','all');
    updateview;
    
elseif(strcmp(action,'xline'))
    %hfigs=getfigs;
    hthisfig=gcf;
    hinlinemode=findobj(hthisfig,'tag','inlinemode');
    udat=get(hinlinemode,'userdata');
    hxlinemode=udat(1);
    htslicemode=udat(2);
    hinline=udat(3);
    hxline=udat(4);
    htslice=udat(5);
    kol_off=.94*ones(1,3);
    kol_on=get(hinline,'userdata');
    tmp=get(hxline,'string');
    xline_chosen=str2double(tmp);
    if(isnan(xline_chosen))
        msgbox('You must enter an integer number to chose an xline',...
            'Ooops!');
        return;
    end
    hbmap=findobj(hthisfig,'tag','basemap');
    udat=get(hbmap,'userdata');
    xline=udat{3};
    xlmin=min(xline);xlmax=max(xline);
    if(xline_chosen<xlmin || xline_chosen>xlmax)
        msgbox(['Invalid xline number, must be between ' int2str(xlmin) ...
            ' and ' int2str(xlmax)],'Ooops!');
        return;
    end
    set(hinlinemode,'backgroundcolor',kol_off);
    set(hinline,'backgroundcolor',kol_off,'string','all');
    set(hxlinemode,'backgroundcolor',kol_on);
    set(hxline,'backgroundcolor',kol_on);
    set(htslicemode,'backgroundcolor',kol_off);
    set(htslice,'backgroundcolor',kol_off,'string','all');
    updateview;
    
elseif(strcmp(action,'tslice'))
    %hfigs=getfigs;
    hthisfig=gcf;
    hinlinemode=findobj(hthisfig,'tag','inlinemode');
    udat=get(hinlinemode,'userdata');
    hxlinemode=udat(1);
    htslicemode=udat(2);
    hinline=udat(3);
    hxline=udat(4);
    htslice=udat(5);
    kol_off=.94*ones(1,3);
    kol_on=get(hinline,'userdata');
    tmp=get(htslice,'string');
    tslice_chosen=str2double(tmp);
    if(isnan(tslice_chosen))
        msgbox('You must enter a valid time to chose a tslice',...
            'Ooops!');
        return;
    end
    hbmap=findobj(hthisfig,'tag','basemap');
    udat=get(hbmap,'userdata');
    t=udat{2};
    tmin=min(t);tmax=max(t);
    %check for milliseconds
    if(tslice_chosen>tmax)
        if(round(tslice_chosen)==tslice_chosen)
            tslice_chosen=tslice_chosen/1000;
            set(htslice,'string',num2str(tslice_chosen));
        end
    end
    if(tslice_chosen<tmin || tslice_chosen>tmax)
        msgbox(['Invalid time, must be between ' num2str(tmin) ...
            ' and ' num2str(tmax)],'Ooops!');
        return;
    end
    %make sure the time requested is one that we have
    it=near(t,tslice_chosen);
    tslice_chosen=t(it(1));
    set(htslice,'string',num2str(tslice_chosen));
    set(hinlinemode,'backgroundcolor',kol_off);
    set(hinline,'backgroundcolor',kol_off,'string','all');
    set(hxlinemode,'backgroundcolor',kol_off);
    set(hxline,'backgroundcolor',kol_off,'string','all');
    set(htslicemode,'backgroundcolor',kol_on);
    set(htslice,'backgroundcolor',kol_on);
    updateview;
    
elseif(strcmp(action,'geooption')||strcmp(action,'locor'))
    hthisfig=gcf;
    mode=determinemode;
    hlocor=findobj(hthisfig,'tag','locor');
    locor=get(hlocor,'value');
    hgeo=findobj(hthisfig,'tag','geo');
    togeo=get(hgeo,'value');%if 1, then we are moving from lines to cdps, 0 is the other way
    udat=get(hgeo,'userdata');
    xline=udat{1};
    iline=udat{2};
    if(locor)
        tmp=udat{3};
        x0=min(tmp);
        xcdp=tmp-x0;
        tmp=udat{4}(:);
        y0=min(tmp);
        ycdp=tmp-y0;
    else
        xcdp=udat{3};
        ycdp=udat{4}(:);
    end
    hbmap=findobj(hthisfig,'tag','basemap');
    ubdat=get(hbmap,'userdata');
    ilivetr=ubdat{11};
    hseismic=findobj(hthisfig,'tag','seismic');
    hcb=findobj(hthisfig,'type','colorbar');
    hk=get(hbmap,'children');
    if(strcmp(get(hk(1),'tag'),'currenttext'))
        ht=hk(1);%the text
    else
        ht=hk(2);
    end
    if(strcmp(get(hk(2),'tag'),'currentline'))
        hl=hk(2);%the line
    else
        hl=hk(1);
    end
    hd=hk(3);%the basemap line drawing
    if(strcmp(action,'locor'))
        %must adjusr userdata for coordinate origin change
        if(locor)
            %we are changing to local orgin
            udat=get(hl,'userdata');
            if(udat(1)==1)
                udat(2)=udat(2)-y0;
            elseif(udat(1)==2)
                udat(2)=udat(2)-x0;
            end
            set(hl,'userdata',udat);
        else
            %we are changing from local orgin
            udat=get(hl,'userdata');
            if(udat(1)==1)
                udat(2)=udat(2)+min(ycdp);
            elseif(udat(1)==2)
                udat(2)=udat(2)+min(xcdp);
            end
            set(hl,'userdata',udat);
            
        end
    end
    if(togeo==1)
        %we are converting from line coords to geographic
        if(sum(xcdp)==0)
            msgbox('CDP coordinates are all zero');
            set(hgeo,'value',0);
            return;
        end
        set(hlocor,'visible','on')
        %handle basemap
        udatline=get(hl,'userdata');
        xx=xcdp(ones(length(ycdp),1),:);
        yy=ycdp(:,ones(length(xcdp),1));
        set(hd,'xdata',xx(ilivetr),'ydata',yy(ilivetr));
        switch mode
            case 'inline'
                if(strcmp(action,'geooption'))
                    ynow=yline2cdp(udatline(2));
                else
                    ynow=udatline(2);
                end
                set(hl,'xdata',xcdp,'ydata',ynow*ones(size(xcdp)),'userdata',[udatline(1) ynow]);
                nmid=round(length(xcdp)/2);
                set(ht,'position',[xcdp(nmid) ynow 0]);
            case 'xline'
                if(strcmp(action,'geooption'))
                    xnow=xline2cdp(udatline(2));
                else
                    xnow=udatline(2);
                end
                set(hl,'xdata',xnow*ones(size(ycdp)),'ydata',ycdp,'userdata',[udatline(1) xnow]);
                nmid=round(length(ycdp)/2);
                set(ht,'position',[xnow ycdp(nmid) 0]);
            case 'tslice'
                xx=[xcdp(1) xcdp(end) xcdp(end) xcdp(1) xcdp(1)];
                yy=[ycdp(1) ycdp(1) ycdp(end) ycdp(end) ycdp(1)];
                set(hl,'xdata',xx,'ydata',yy);
                xx=(xcdp(1)+xcdp(end))*.5;
                yy=(ycdp(1)+ycdp(end))*.5;
                set(ht,'position',[xx yy 0]);
        end
        axes(hbmap);
        xlabel('x coordinate');ylabel('y coordinate')
        axis equal
        set(hbmap,'xlim',[min(xcdp) max(xcdp)],'ylim',[min(ycdp) max(ycdp)])
        
        %now set the main display
        axes(hseismic)
        hi=findobj(hseismic,'type','image');
        pos=get(hseismic,'position');
        posc=get(hcb,'position');
        switch mode
            case 'inline'
                set(hi,'xdata',xcdp);
                xlabel('x coordinate');
                xlim([min(xcdp) max(xcdp)]);
                set(hseismic,'position',pos);
                set(hcb,'position',posc);
                hhor=findobj(hseismic,'tag','hor');
                for k=1:length(hhor)
                   set(hhor(k),'xdata',xcdp) 
                end
            case 'xline'
                set(hi,'xdata',ycdp);
                xlabel('y coordinate');
                xlim([min(ycdp) max(ycdp)]);
                set(hseismic,'position',pos);
                set(hcb,'position',posc);
                hhor=findobj(hseismic,'tag','hor');
                for k=1:length(hhor)
                   set(hhor(k),'xdata',ycdp) 
                end
            case 'tslice'
                set(hi,'xdata',xcdp,'ydata',ycdp);
                axis equal
                set(gca,'xlim',[min(xcdp) max(xcdp)],'ylim',[min(ycdp) max(ycdp)]);
                xlabel('x coordinate');
                ylabel('y coordinate');
        end
                
    else
        %we are converting from  geographic to line coords
        set(hlocor,'visible','off')
        %handle basemap
        udatline=get(hl,'userdata');
        xx=xline(ones(length(iline),1),:);
        yy=iline(:,ones(length(xline),1));
        set(hd,'xdata',xx(ilivetr),'ydata',yy(ilivetr));
        switch mode
            case 'inline'
                ynow=ycdp2line(udatline(2));
                set(hl,'xdata',xline,'ydata',ynow*ones(size(xline)),'userdata',[udatline(1) ynow]);
                nmid=round(length(xline)/2);
                set(ht,'position',[xline(nmid) ynow 0]);
            case 'xline'
                xnow=xcdp2line(udatline(2));
                set(hl,'xdata',xnow*ones(size(iline)),'ydata',iline,'userdata',[udatline(1) xnow]);
                nmid=round(length(iline)/2);
                set(ht,'position',[xnow iline(nmid) 0]);
            case 'tslice'
                xx=[xline(1) xline(end) xline(end) xline(1) xline(1)];
                yy=[iline(1) iline(1) iline(end) iline(end) iline(1)];
                set(hl,'xdata',xx,'ydata',yy);
                xx=(xline(1)+xline(end))*.5;
                yy=(iline(1)+iline(end))*.5;
                set(ht,'position',[xx yy 0]);
        end
        axes(hbmap);
        xlabel('crossline');ylabel('inline')
        axis normal
        set(hbmap,'xlim',[min(xline) max(xline)],'ylim',[min(iline) max(iline)])
        
        %now set the main display
        axes(hseismic)
        hi=findobj(hseismic,'type','image');
        pos=get(hseismic,'position');
        posc=get(hcb,'position');
        switch mode
            case 'inline'
                set(hi,'xdata',xline);
                xlabel('xline number');
                xlim([min(xline) max(xline)]);
                set(hseismic,'position',pos);
                set(hcb,'position',posc);
                hhor=findobj(hseismic,'tag','hor');
                for k=1:length(hhor)
                   set(hhor(k),'xdata',xline) 
                end
            case 'xline'
                set(hi,'xdata',iline);
                xlabel('inline number');
                xlim([min(iline) max(iline)]);
                set(hseismic,'position',pos);
                set(hcb,'position',posc);
                hhor=findobj(hseismic,'tag','hor');
                for k=1:length(hhor)
                   set(hhor(k),'xdata',iline) 
                end
            case 'tslice'
                set(hi,'xdata',xline,'ydata',iline);
                axis normal
                set(gca,'xlim',[min(xline) max(xline)],'ylim',[min(iline) max(iline)]);
                ylabel('inline number');
                xlabel('xline number');
        end
    end
    
    
elseif(strcmp(action,'previous'))
    hincr=findobj(gcf,'tag','increment');
    tmp=get(hincr,'string');
    inc=str2double(tmp);
    mode=determinemode;
    hseis=findobj(gcf,'tag','seismic');
    switch mode
        case 'inline'
            hinline=findobj(gcf,'tag','inlinebox');
            tmp=get(hinline,'string');
            inlinenow=str2double(tmp);
            inlinenext=inlinenow-inc;
            set(hinline,'string',int2str(inlinenext));
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            updateview;
            set(hseis,'xlim',xl,'ylim',yl);
            
        case 'xline'
            hxline=findobj(gcf,'tag','xlinebox');
            tmp=get(hxline,'string');
            xlinenow=str2double(tmp);
            xlinenext=xlinenow-inc;
            set(hxline,'string',int2str(xlinenext));
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            updateview;
            set(hseis,'xlim',xl,'ylim',yl);
            
        case 'tslice'
            htslice=findobj(gcf,'tag','tslicebox');
            dt=get(htslice,'userdata');
            inc=inc*dt;
            tmp=get(htslice,'string');
            tslicenow=str2double(tmp);
            tslicenext=tslicenow-inc;
            
            set(htslice,'string',num2str(tslicenext));
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            updateview;
            set(hseis,'xlim',xl,'ylim',yl);
    end
    
elseif(strcmp(action,'next'))
    hincr=findobj(gcf,'tag','increment');
    tmp=get(hincr,'string');
    inc=str2double(tmp);
    mode=determinemode;
    hseis=findobj(gcf,'tag','seismic');
    switch mode
        case 'inline'
            hinline=findobj(gcf,'tag','inlinebox');
            tmp=get(hinline,'string');
            inlinenow=str2double(tmp);
            inlinenext=inlinenow+inc;
            set(hinline,'string',int2str(inlinenext));
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            updateview;
            set(hseis,'xlim',xl,'ylim',yl);
        case 'xline'
            hxline=findobj(gcf,'tag','xlinebox');
            tmp=get(hxline,'string');
            xlinenow=str2double(tmp);
            xlinenext=xlinenow+inc;
            set(hxline,'string',int2str(xlinenext));
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            updateview;
            set(hseis,'xlim',xl,'ylim',yl);
            
        case 'tslice'
            htslice=findobj(gcf,'tag','tslicebox');
            dt=get(htslice,'userdata');
            inc=inc*dt;
            tmp=get(htslice,'string');
            tslicenow=str2double(tmp);
            tslicenext=tslicenow+inc;
            set(htslice,'string',num2str(tslicenext));
            xl=get(hseis,'xlim');
            yl=get(hseis,'ylim');
            updateview;
            set(hseis,'xlim',xl,'ylim',yl);
            
    end
    
elseif(strcmp(action,'clip'))
    hfigs=getfigs;
    hthisfig=gcf;
    clipnow=getclip;
    hampapply=findobj(hthisfig,'tag','ampapply');
    hampcontrols=get(hampapply,'userdata');
    if(length(clipnow)>1) %if manual clipping, then clipnow is two numbers
        %activate manual clipping
        set([hampapply hampcontrols],'visible','on');
        return;
    else
        set([hampapply hampcontrols],'visible','off');
    end
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    %get the dat amp values
    hbmap=findobj(hthisfig,'tag','basemap');
    udat=get(hbmap,'userdata');
    amp=udat{6};
    %update the values in the invisible max and min edit fields
    set(hampcontrols(1),'string',num2str(amp(1)+clipnow*amp(2)));%maximum
    set(hampcontrols(2),'string',num2str(amp(1)-clipnow*amp(2)));%minimum
    %get the seismic axes and update its clim property
    hseismic=findobj(hthisfig,'tag','seismic');
    clim=[amp(1)-clipnow*amp(2), amp(1)+clipnow*amp(2)];
    set(hseismic,'clim',clim);
    %process the other figs
    hclip=findobj(hthisfig,'tag','cliplevel');
    iclip=get(hclip,'value');
    for k=1:length(hotherfigs)
        hbmap=findobj(hotherfigs(k),'tag','basemap');
        udat=get(hbmap,'userdata');
        amp=udat{6};
        hampapply=findobj(hotherfigs(k),'tag','ampapply');
        hampcontrols=get(hampapply,'userdata');
        set(hampcontrols(1),'string',num2str(amp(1)+clipnow*amp(2)));%maximum
        set(hampcontrols(2),'string',num2str(amp(1)-clipnow*amp(2)));%minimum
        hcliplevel=findobj(hotherfigs(k),'tag','cliplevel');
        set(hcliplevel,'value',iclip);
        hseismic=findobj(hotherfigs(k),'tag','seismic');
        clim=[amp(1)-clipnow*amp(2), amp(1)+clipnow*amp(2)];
        set(hseismic,'clim',clim);
    end
    
elseif(strcmp(action,'manualclipping'))
    %hfigs=getfigs;
    hthisfig=gcf;
%     ind=hfigs~=hthisfig;
%     hotherfigs=hfigs(ind);
    clim=getclip;
    if(length(clim)~=2)
        error('logic failure');
    end
    hseismic=findobj(hthisfig,'tag','seismic');
    set(hseismic,'clim',clim);
    
elseif(strcmp(action,'colormap'))
    hfigs=getfigs;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    cmapnow=getcolormap;
    colormap(cmapnow);
    hcolormap=findobj(hthisfig,'tag','colormap');
    icolor=get(hcolormap,'value');
    cmap=get(hthisfig,'colormap');
    hbrighten=findobj(hthisfig,'tag','brighten');
    ibright=get(hbrighten,'value');
    hflip=findobj(hthisfig,'tag','flipcolormap');
    flip=get(hflip,'value');
    for k=1:length(hotherfigs)
        hcolormap=findobj(hotherfigs(k),'tag','colormap');
        set(hcolormap,'value',icolor);
        set(hotherfigs(k),'colormap',cmap);
        hbrighten=findobj(hotherfigs(k),'tag','brighten');
        set(hbrighten,'value',ibright)
        hflip=findobj(hotherfigs(k),'tag','flipcolormap');
        set(hflip,'value',flip);
    end
    
elseif(strcmp(action,'clipboard')||strcmp(action,'clipboardalt'))
    if(strcmp(action,'clipboardalt'))
        hidecontrols;
    end
    %determine if PPTX or not
    str=get(gcbo,'string');
    pptx=false;
    if(~isempty(strfind(str,'PPT'))) %#ok<STREMP>
        pptx=true;
    end
    if(~pptx)
        if(isunix)
            print -dtiff
            adon='tiff file in current directory';
        else
            fh=gcf;
            fh.Renderer='opengl';
            hgexport(fh,'-clipboard');
            adon='Windows clipboard';
        end
%         msg=['Figure has been sent to ' adon];
%         msgbox(msg,'Good news!');
    else

        hseis=findobj(gcf,'tag','seismic');
        ht=get(hseis,'title');
        titlestring=get(ht,'string');
        sane('makepptslide',titlestring)
%         slideNum = exportToPPTX('addslide','Layout','Title and Footer');
%         exportToPPTX('addtext',titlestring,'Position','Title');
%         %fprintf('Added slide %d\n',slideNum);
%         exportToPPTX('addpicture',gcf,'position',[0 1.5 13.333 5.5]);
    end
    if(strcmp(action,'clipboardalt'))
        restorecontrols;
    end
elseif(strcmp(action,'grid'))
    hthisfig=gcf;
    hfigs=getfigs;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hgridopt=findobj(hthisfig,'tag','gridoptions');
    hgridcolor=findobj(hthisfig,'tag','gridcolors');
    hseismic=findobj(hthisfig,'tag','seismic');
    axes(hseismic);
    opt=get(hgridopt,'value');
    gridoptions=get(hgridopt,'string');
    iklr=get(hgridcolor,'value');
    klrs=get(hgridcolor,'userdata');
    klr=klrs{iklr};
    if(opt==1)
        grid off;
    else
        alpha=str2double(gridoptions{opt});
        grid on;
        set(hseismic,'gridalpha',alpha,'gridcolor',klr); 
    end
    %handle other figs
    for k=1:length(hotherfigs)
        hgridopt=findobj(hotherfigs(k),'tag','gridoptions');
        hgridcolor=findobj(hotherfigs(k),'tag','gridcolors');
        hseismic=findobj(hotherfigs(k),'tag','seismic');
        axes(hseismic); %#ok<LAXES>
        set(hgridopt,'value',opt);
        set(hgridcolor','value',iklr);
        if(opt==1)
            grid off;
        else
            alpha=str2double(gridoptions{opt});
            grid on;
            set(hseismic,'gridalpha',alpha,'gridcolor',klr);
        end
    end
    
elseif(strcmp(action,'group')||strcmp(action,'groupex'))
    %'groupex' is initiated by SANE to cause grouping.  
    if(~isempty(PLOTIMAGE3DDIFFDIAL))
        delete(PLOTIMAGE3DDIFFDIAL);
        PLOTIMAGE3DDIFFDIAL=[];
    end
    PLOTIMAGE3DMASTER=[];
    if(strcmp(action,'group'))
        hthisfig=gcf;
    else
        hthisfig=PLOTIMAGE3DTHISFIG;
    end
    hbmap=findobj(hthisfig,'tag','basemap');
    udat=get(hbmap,'userdata');
    if(~isempty(PLOTIMAGE3DFIGS))
        %check data size for compatibility
%         tmp=PLOTIMAGE3DDATASIZE;
%         if(length(udat{2})~=tmp(1)||length(udat{3})~=tmp(2)||length(udat{4})~=tmp(3))
%             msgbox('Cannot include this figure in group because data size is not compatible',...
%                 'Ooops!');
%             return;
%         end
        PLOTIMAGE3DDATASIZE=[PLOTIMAGE3DDATASIZE; [length(udat{2}) length(udat{3}) length(udat{4}) 0 0 0]];
    else
        %the first three numbers are nt nx and ny (dataset sizes) 
        %and the second three are dt dx and dy (units of seconds and line numbers) that give shifts
        %to match the master figure (first figure). Usually the master Figure will have zero shifts
        %unless the original master was removed from group. The basic rule relating time slice on
        %dataset k with that on dataset j is tk+dtk = tj+dtj (all values in seconds) and therefore
        %tj=tk+dtk-dtj.  If datasets do not have the same sample rate then this might not work out
        %to an exact sample.
        PLOTIMAGE3DDATASIZE=[length(udat{2}) length(udat{3}) length(udat{4}) 0 0 0];
    end
    ind=find(hthisfig==PLOTIMAGE3DFIGS,1);%see if we have already included it
    if(isempty(ind))
        if(~isempty(PLOTIMAGE3DFIGS))
            %equalize the displays
            hgroupfig=PLOTIMAGE3DFIGS(end);%previously the last member of the group
            
            h=findobj(hgroupfig,'tag','tmin');
            tmins=str2double(get(h,'string'));
            ival=get(h,'value');
            tmin=tmins(ival);
            h=findobj(hthisfig,'tag','tmin');
            tmins=str2double(get(h,'string'));
            ival=near(tmins,tmin);
            set(h,'value',ival);
            
            h=findobj(hgroupfig,'tag','tmax');
            tmaxs=str2double(get(h,'string'));
            ival=get(h,'value');
            tmax=tmaxs(ival);
            h=findobj(hthisfig,'tag','tmax');
            tmaxs=str2double(get(h,'string'));
            ival=near(tmaxs,tmax);
            set(h,'value',ival);
            
            h=findobj(hgroupfig,'tag','cliplevel');
            val=get(h,'value');
            h=findobj(hthisfig,'tag','cliplevel');
            set(h,'value',val);
            
            h=findobj(hgroupfig,'tag','colormap');
            val=get(h,'value');
            h=findobj(hthisfig,'tag','colormap');
            set(h,'value',val);
            
            h=findobj(hgroupfig,'tag','gridoptions');
            val=get(h,'value');
            h=findobj(hthisfig,'tag','gridoptions');
            set(h,'value',val);
            
            h=findobj(hgroupfig,'tag','brighten');
            val=get(h,'value');
            h=findobj(hthisfig,'tag','brighten');
            set(h,'value',val);
            
            h=findobj(hgroupfig,'tag','gridcolors');
            val=get(h,'value');
            h=findobj(hthisfig,'tag','gridcolors');
            set(h,'value',val);
            
            h=findobj(hgroupfig,'tag','flipcolormap');
            val=get(h,'value');
            h=findobj(hthisfig,'tag','flipcolormap');
            set(h,'value',val);
        end
        
        PLOTIMAGE3DFIGS=[PLOTIMAGE3DFIGS hthisfig];
        
        %send message to SANE
        if(issane)%issane is an internal function
            sane('pi3d:group',sanedata);%sanedata is an internal function
        end
        
        thisname=get(hthisfig,'name');
        msgbox([thisname ' added to group of linked figures'],'Done');
    end
    
elseif(strcmp(action,'ungroup')||strcmp(action,'ungroupex'))
    %'ungroupex' is initiated by SANE to cause ungrouping. 
    if(~isempty(PLOTIMAGE3DDIFFDIAL))
        delete(PLOTIMAGE3DDIFFDIAL);
        PLOTIMAGE3DDIFFDIAL=[];
    end
    if(strcmp(action,'ungroup'))
        hthisfig=gcf;
    else
        hthisfig=PLOTIMAGE3DTHISFIG;
    end
    ind=find(hthisfig==PLOTIMAGE3DFIGS,1);
    if(~isempty(ind))
        PLOTIMAGE3DFIGS(ind)=[];
        PLOTIMAGE3DDATASIZE(ind,:)=[];

        %send message to SANE
        if(issane)%issane is an internal function
            sane('pi3d:group',sanedata);%sanedata is an internal function
        end
        
        thisname=get(hthisfig,'name');
        msgbox([thisname ' removed from group of linked figures'],'Done');
    end
%     if(isempty(PLOTIMAGE3DFIGS))
%         PLOTIMAGE3DDATASIZE=[];
%     end
elseif(strcmp(action,'cleargroup'))
    if(~isempty(PLOTIMAGE3DDIFFDIAL))
        delete(PLOTIMAGE3DDIFFDIAL);
        PLOTIMAGE3DDIFFDIAL=[];
    end
    if(~isgraphics(PLOTIMAGE3DINFODIAL))
        delete(PLOTIMAGE3DINFODIAL)
    end
    PLOTIMAGE3DFIGS=[];
    PLOTIMAGE3DDATASIZE=[];
    PLOTIMAGE3DINFODIAL=[];
    
    %send message to SANE
    if(issane)%issane is an internal function
        sane('pi3d:group',sanedata);%sanedata is an internal function
    end
    
    msgbox(' Existing group cleared, start a new one! ','Done');
    
elseif(strcmp(action,'groupinfo'))
    if(isempty(PLOTIMAGE3DFIGS))
       msgbox('You have not yet created a group (or the group is empty) so there is nothing to show');
       return
    end
    hfigs=PLOTIMAGE3DFIGS;%get the grouped plotseis3D figures
    if(~isgraphics(PLOTIMAGE3DINFODIAL))
        delete(PLOTIMAGE3DINFODIAL)
    end
    hthisfig=gcf;
    tabledata=cell(length(hfigs),2);
    %get the time shifts
    figdata=PLOTIMAGE3DDATASIZE;
    %load up the tabledata
    for k=1:length(hfigs)
        hprevious=findobj(hfigs(k),'tag','previous');
        udat=get(hprevious,'userdata');
        name=strrep(udat{6},'plotimage3D ... ','');
        tabledata{k,1}=name;%names
        tabledata{k,2}=figdata(k,4);%time shifts
        %time shift rule tj+dtj=tk+dtk
    end

    %create a dialog
    pos=get(hthisfig,'position');
    width=pos(3)*.5;
    ht=pos(4)*.25;
    xnow=pos(1)+.5*(pos(3)-width);
    ynow=pos(2)+.5*(pos(4)-ht);
    hdial=figure('position',[xnow,ynow,width,ht]);
    pos=get(hdial,'position');
    width=.8;ht=.6;
    xnow=.1;ynow=.2;
    uitable(gcf,'units','normalized','position',[xnow,ynow,width,ht],'data',tabledata,...
        'columneditable',[false true],'columnname',{'Dataset name','Time shift (seconds)'},...
        'columnwidth',{pos(3)*width*.7,pos(3)*width*.2},'tag','table');
    
    %dismiss button
    xnow=.05;
    ynow=.1;
    width=.2;
    ht=.1;
    uicontrol(hdial,'style','pushbutton','string','Apply&Dismiss','tag','dismiss','units','normalized',...
        'position',[xnow,ynow,width,ht],'callback','plotimage3D(''dismissinfo'');',...
        'backgroundcolor','y','tooltipstring','Click to apply changes and dismiss this dialog',...
        'userdata',hthisfig);

    PLOTIMAGE3DINFODIAL=hdial;
    set(hdial,'closerequestfcn','plotimage3D(''dismissinfo'')','name','Plotimage3D Group Info');
elseif(strcmp(action,'groupzoom'))
    hfigs=getfigs;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hseis=findobj(hthisfig,'tag','seismic');
    xl=get(hseis,'xlim');
    yl=get(hseis,'ylim');
    set(hseis,'xlim',xl,'ylim',yl)
    for k=1:length(hotherfigs)
        hseis=findobj(hotherfigs(k),'tag','seismic');
        set(hseis,'xlim',xl,'ylim',yl);
    end
elseif(strcmp(action,'dismissinfo'))
    hdial=gcf;
    hfigs=getfigs;
    currentdata=PLOTIMAGE3DDATASIZE;
    htable=findobj(hdial,'tag','table');
    tabledata=get(htable,'data');
    newshifts=zeros(size(tabledata,1),1);
    for k=1:length(newshifts)
       newshifts(k)=tabledata{k,2};
    end
    currentshifts=currentdata(:,4);
    for k=1:length(newshifts)
        if(newshifts(k)~=currentshifts(k))
            %update view
            figure(hfigs(k))
            view=currentview;
            hbmap=findobj(gcf,'tag','basemap');
            udat=get(hbmap,'userdata');
            t=udat{2};
            dt=abs(t(2)-t(1));
            newshifts(k)=dt*round(newshifts(k)/dt);%round to nearest sample
            PLOTIMAGE3DDATASIZE(k,4)=newshifts(k);
%             if(strcmp(view{4},'tslice'))
%                 htslice=findobj(gcf,'tag','tslicebox');
%                 txt=get(htslice,'string');
%                 tnow=str2double(txt);
%                 
%                 tnow=tnow-currentshifts(k)+newshifts(k);
%                 set(htslice,'string',num2str(tnow));
%             end
            setview(view);
        end
    end
    delete(hdial);
    PLOTIMAGE3DINFODIAL=[];
    
elseif(strcmp(action,'saveview'))
    hfigs=getfigs;
    view=currentview;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hsavedviews=findobj(hthisfig,'tag','savedviews');
    viewlist=get(hsavedviews,'string');
    nviews=length(viewlist);
    switch view{4}
        case 'inline'
            viewlist{nviews+1}=[view{4} ': ' view{1}];
        case 'xline'
            viewlist{nviews+1}=[view{4} ': ' view{2}];
        case 'tslice'
            viewlist{nviews+1}=[view{4} ': ' view{3}];
    end
    %viewlist{nviews+1}=[view{4} ' inline: ' view{1} ' xline: ' view{2} ' tslice: ' view{3}];
    set(hsavedviews,'string',viewlist,'value',nviews+1);
    udat=get(hsavedviews,'userdata');
    nviews=length(udat);
    udat{nviews+1}=view;
    set(hsavedviews,'userdata',udat);
    %process the view menus of the other figs
    for k=1:length(hotherfigs)
        hsavedviews=findobj(hotherfigs(k),'tag','savedviews');
        viewlist=get(hsavedviews,'string');
        nviews=length(viewlist);
        switch view{4}
            case 'inline'
                viewlist{nviews+1}=[view{4} ': ' view{1}];
            case 'xline'
                viewlist{nviews+1}=[view{4} ': ' view{2}];
            case 'tslice'
                viewlist{nviews+1}=[view{4} ': ' view{3}];
        end
        %viewlist{nviews+1}=[view{4} ' inline: ' view{1} ' xline: ' view{2} ' tslice: ' view{3}];
        set(hsavedviews,'string',viewlist,'value',nviews+1);
        udat=get(hsavedviews,'userdata');
        nviews=length(udat);
        udat{nviews+1}=view;
        set(hsavedviews,'userdata',udat);
    end
    
elseif(strcmp(action,'forgetview'))
    hfigs=getfigs;
    view=currentview;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hsavedviews=findobj(hthisfig,'tag','savedviews');
    viewlist=get(hsavedviews,'userdata');
    %search for the current view among the saved views
    nviews=length(viewlist);
    iview=[];
    for k=1:nviews
        if(strcmp(view{1},viewlist{k}{1}))
            if(strcmp(view{2},viewlist{k}{2}))
                if(strcmp(view{3},viewlist{k}{3}))
                    if(strcmp(view{4},viewlist{k}{4}))
                        iview=k;
                    end
                end
            end
        end
    end
    if(isempty(iview))
%         msgbox('Current view is not in the saved list','Ooops!');
        return
    end
    viewlist(iview)=[];
    set(hsavedviews,'userdata',viewlist);
    viewnames=get(hsavedviews,'string');
    viewnames(iview+1)=[];
    set(hsavedviews,'string',viewnames,'value',1);
    %process other figs
    for k=1:length(hotherfigs)
        hsavedviews=findobj(hotherfigs(k),'tag','savedviews');
        viewlist=get(hsavedviews,'userdata');
        %search for the current view among the saved views
        nviews=length(viewlist);
        iview=[];
        for kk=1:nviews
            if(strcmp(view{1},viewlist{kk}{1}))
                if(strcmp(view{2},viewlist{kk}{2}))
                    if(strcmp(view{3},viewlist{kk}{3}))
                        if(strcmp(view{4},viewlist{kk}{4}))
                            iview=kk;
                        end
                    end
                end
            end
        end
        if(isempty(iview))
            %         msgbox('Current view is not in the saved list','Ooops!');
            return
        end
        viewlist(iview)=[];
        set(hsavedviews,'userdata',viewlist);
        viewnames=get(hsavedviews,'string');
        viewnames(iview+1)=[];
        set(hsavedviews,'string',viewnames,'value',1);
    end
    
elseif(strcmp(action,'restoreview'))
    hsavedviews=findobj(gcf,'tag','savedviews');
    views=get(hsavedviews,'userdata');
    desiredview=get(hsavedviews,'value')-1;
    if(desiredview>0)
        setview(views{desiredview});
    end
    
elseif(strcmp(action,'locate')||strcmp(action,'stoplocate'))
    hfigs=getfigs;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hlocate=findobj(gcf,'tag','locate');
    if(strcmp(action,'locate'))
        flag=1;
    else
        flag=0;
    end
    if(flag==1) %turn it on
        set(hlocate,'string','cursor locate off','callback','plotimage3D(''stoplocate'')');
        set(gcf,'windowbuttondownfcn','plotimage3D(''postlocation'')');
    else
        set(hlocate,'string','cursor locate on','callback','plotimage3D(''locate'')');
        set(gcf,'windowbuttondownfcn','');
        clearlocations;
    end
    
    %process other figs
    for k=1:length(hotherfigs)
        hlocate=findobj(hotherfigs(k),'tag','locate');
        if(flag==1) %turn it on
            set(hlocate,'string','cursor locate off','callback','plotimage3D(''stoplocate'')');
            set(hotherfigs(k),'windowbuttondownfcn','plotimage3D(''postlocation'')');
        else
            set(hlocate,'string','cursor locate on','callback','plotimage3D(''locate'')');
            set(hotherfigs(k),'windowbuttondownfcn','');
            clearlocations;
        end
    end
elseif(strcmp(action,'postlocation'))
    hlocate=findobj(gcf,'tag','locate');
    hfigs=getfigs;
    hthisfig=gcf;
    hseismic=findobj(hthisfig,'tag','seismic');
    existinglocations=get(hlocate,'userdata');
    currentpoint=get(hseismic,'currentpoint');
    xl=get(hseismic,'xlim');
    yl=get(hseismic,'ylim');
    if(currentpoint(1,1)<xl(1) || currentpoint(1,1)>xl(2))
        return;
    end
    if(currentpoint(1,2)<yl(1) || currentpoint(1,2)>yl(2))
        return;
    end
    % existinglocations are stored in a cell array, one entry per point. Each point is represented
    % by a two element vector of handles. The first is the handle to the line with the point marker
    % and the second is the text. check existing locations. If we have a match, then this is a
    % deletion
    if(isempty(currentpoint))
        return;
    end
    npts=length(existinglocations);
    badpoints=zeros(size(existinglocations));
    %small=10^12*eps;
    hclicked=gco;
    for k=1:npts
        thispoint=existinglocations{k};
        if(isempty(thispoint))
            badpoints(k)=1;
        else
            if(~isgraphics(thispoint(1)))
                badpoints(k)=1;
            else
%                 xpt=get(thispoint(1),'xdata');
%                 ypt=get(thispoint(1),'ydata');
%                 test=abs(currentpoint(1,1)-xpt)+abs(currentpoint(1,2)-ypt);
%                 if(test<small)
                if(hclicked==thispoint(1))
                    delete(thispoint);
                    return;
                end
            end
        end
    end
    ind=find(badpoints==1);
    if(~isempty(ind))
        existinglocations(ind)=[];
    end
    mode=determinemode;
    %use the gridcolor as the color
    kol=get(hseismic,'gridcolor');
    fs=9;mksize=6;
    if(strcmp(mode,'tslice'))
        newpoint(2)=text(currentpoint(1,1),currentpoint(1,2),...
            ['(' int2str(currentpoint(1,1)) ',' int2str(currentpoint(1,2)) ')'],...
            'fontsize',fs','color',kol);
    else
        newpoint(2)=text(currentpoint(1,1),currentpoint(1,2),...
            ['(' int2str(currentpoint(1,1)) ',' num2str(round(1000*currentpoint(1,2))/1000) ')'],...
            'fontsize',fs','color',kol);
    end
    newpoint(1)=line(currentpoint(1,1),currentpoint(1,2),'linestyle','none',...
        'marker','*','markersize',mksize,'color',kol);
    existinglocations{npts+1}=newpoint;
    set(hlocate,'userdata',existinglocations);
    
    %post the point in other figs
    ind= hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    for k=1:length(hotherfigs)
        figure(hotherfigs(k));
        hseismic=findobj(hotherfigs(k),'tag','seismic');
        hlocate=findobj(hotherfigs(k),'tag','locate');
        existinglocations=get(hlocate,'userdata');
        set(hotherfigs(k),'currentaxes',hseismic);
        if(strcmp(mode,'tslice'))
            newpoint(2)=text(currentpoint(1,1),currentpoint(1,2),...
                ['(' int2str(currentpoint(1,1)) ',' int2str(currentpoint(1,2)) ')'],...
                'fontsize',fs','color',kol);
        else
            newpoint(2)=text(currentpoint(1,1),currentpoint(1,2),...
                ['(' int2str(currentpoint(1,1)) ',' num2str(round(1000*currentpoint(1,2))/1000) ')'],...
                'fontsize',fs','color',kol);
        end
        newpoint(1)=line(currentpoint(1,1),currentpoint(1,2),'linestyle','none',...
            'marker','*','markersize',mksize,'color',kol);
        existinglocations{npts+1}=newpoint;
        set(hlocate,'userdata',existinglocations);
    end
    
    
elseif(strcmp(action,'flipx'))
    hfigs=getfigs;
    hthisfig=gcf;
    hflipx=findobj(hthisfig,'tag','flipx');
    dirflag=get(hflipx,'userdata');
    if(dirflag==1)
        set(hflipx,'userdata',-1);
    else
        set(hflipx,'userdata',1);
    end
    setaxesdir;
    
    %now handle other figs in group
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    for k=1:length(hotherfigs)
        figure(hotherfigs(k));
        hflipx=findobj(hotherfigs(k),'tag','flipx');
        if(dirflag==1)
            set(hflipx,'userdata',-1);
        else
            set(hflipx,'userdata',1);
        end
        setaxesdir;
    end
elseif(strcmp(action,'flipy'))
    hfigs=getfigs;
    hthisfig=gcf;
    hflipy=findobj(hthisfig,'tag','flipy');
    dirflag=get(hflipy,'userdata');
    if(dirflag==1)
        set(hflipy,'userdata',-1);
    else
        set(hflipy,'userdata',1);
    end
    setaxesdir;
    
    %now handle other figs in group
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    for k=1:length(hotherfigs)
        figure(hotherfigs(k));
        hflipy=findobj(hotherfigs(k),'tag','flipy');
        if(dirflag==1)
            set(hflipy,'userdata',-1);
        else
            set(hflipy,'userdata',1);
        end
        setaxesdir;
    end
    
elseif(strcmp(action,'increment'))
    hfigs=getfigs;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hinc=findobj(hthisfig,'tag','increment');
    val=get(hinc,'string');
    for k=1:length(hotherfigs)
       hinc=findobj(hotherfigs(k),'tag','increment');
       set(hinc,'string',val);
    end
    
elseif(strcmp(action,'tmin_tmax'))
    hfigs=getfigs;
    hthisfig=gcf;
    ind=hfigs~=hthisfig;
    hotherfigs=hfigs(ind);
    hobj=gcbo;
    htmin=findobj(gcf,'tag','tmin');
    htmax=findobj(gcf,'tag','tmax');
    tinc=get(htmin,'userdata');
    if(hobj==htmin)
        %tmin is changed
        tmin=get_tmin;%current tmin
        tmax=get_tmax;%current tmax
        tmaxlbl=get(htmax,'string');%current tmax labels
        Tmax=str2double(tmaxlbl{end});%largest possible tmax
        tmaxs=tmin+tinc:tinc:Tmax;%new tmax vector
        imax=near(tmaxs,tmax);
        tmaxlbl=num2strcell(tmaxs,-1);%new tmax labels
        set(htmax,'string',tmaxlbl,'value',imax);%reset tmax
        %process other figs
        for k=1:length(hotherfigs)
           htmin=findobj(hotherfigs(k),'tag','tmin');
           tmins=str2double(get(htmin,'string'));
           imin=near(tmins,tmin);
           set(htmin,'value',imin)
           htmax=findobj(hotherfigs(k),'tag','tmax');
           set(htmax,'string',tmaxlbl,'value',imax);%reset tmax
        end
    else
        %tmax is changed
        tmin=get_tmin;%current tmin
        tmax=get_tmax;%current tmax
        tminlbl=get(htmin,'string');%current tminx labels
        Tmin=str2double(tminlbl{1});%smallest possible tmin
        tmins=Tmin:tinc:tmax-tinc;%new tmin vector
        imin=near(tmins,tmin);
        tminlbl=num2strcell(tmins,-1);%new tmax labels
        set(htmin,'string',tminlbl,'value',imin);%reset tmax
        %process other figs
        for k=1:length(hotherfigs)
           htmax=findobj(hotherfigs(k),'tag','tmax');
           tmaxs=str2double(get(htmax,'string'));
           imax=near(tmaxs,tmax);
           set(htmax,'value',imax)
           htmin=findobj(hotherfigs(k),'tag','tmin');
           set(htmin,'string',tminlbl,'value',imin);%reset tmin
        end
    end
    updateview;
elseif(strcmp(action,'dismissdifference'))
    if(~isempty(PLOTIMAGE3DDIFFDIAL))
        PLOTIMAGE3DDIFFDIAL=[];
    end
    delete(gcf);
    
elseif(strcmp(action,'close'))
    if(nargin<2)
        button=questdlg('Are you sure you want to close this PLOTIMAGE3D dataset?','Just to be sure...');
    else
        %this mechanism is invoked by SANE to close without asking
        button=t;%the second input
    end
    if(strcmp(button,'Yes'))
        hthisfig=gcf;
        hwin=findobj(hthisfig,'tag','windows');
        hfigs=get(hwin,'userdata');
        %hfigs is an array of figure windows than have been spawned by pi3d. Each one may also have
        %spawned windows. The userdata of each hfigs entry indicates this. If the userdata is not a
        %cell array, then it is a single entry which has the handle of the pi3D window and this has
        %already been deleted. If the userdata is a cell array, then udat{1} is an array of handles
        %of windows spawned hy the hfigs entry. This will need to be deleted if we are clsing this
        %up. udat{2} will then be the deleted pi3D window.
        for k=1:length(hfigs)
            if(isgraphics(hfigs(k)))
                udat=get(hfigs(k),'userdata');
                if(iscell(udat))
                    hauxfigs=udat{1};
                    for kk=1:length(hauxfigs)
                        if(isgraphics(hauxfigs(kk)))
                            delete(hauxfigs(kk));
                            
                        end
                    end
                end
                delete(hfigs(k))
            end
        end
        delete(hthisfig);
    end
elseif(strcmp(action,'closesane'))%called from SANE
    hsane=gcbf;
    if(strcmp(get(hsane,'tag'),'sane'))
        hbut=gcbo;
        hpan=get(get(hbut,'parent'),'parent');
        idat=get(hpan,'userdata');%the is the number of the dataset whose window is being closed
        hfile=findobj(hsane,'tag','file');
        %hmsg=findobj(hsane,'tag','message');
        proj=get(hfile,'userdata');
        hthisfig=proj.pifigures{idat};
    else
        hthisfig=hsane;
    end
    hwin=findobj(hthisfig,'tag','windows');
    hfigs=get(hwin,'userdata');
    %hfigs is an array of figure windows than have been spawned by pi3d. Each one may also have
    %spawned windows. The userdata of each hfigs entry indicates this. If the userdata is not a
    %cell array, then it is a single entry which has the handle of the pi3D window and this has
    %already been deleted. If the userdata is a cell array, then udat{1} is an array of handles
    %of windows spawned hy the hfigs entry. This will need to be deleted if we are clsing this
    %up.
    for k=1:length(hfigs)
        if(isgraphics(hfigs(k)))
            udat=get(hfigs(k),'userdata');
                if(iscell(udat))
                    hauxfigs=udat{1};
                    for kk=1:length(hauxfigs)
                        if(isgraphics(hauxfigs(kk)))
                            delete(hauxfigs(kk));
                            
                        end
                    end
                end
            delete(hfigs(k))
        end
    end
    delete(hthisfig);
elseif(strcmp(action,'datanamechange'))
    %called by SANE to change the data name, arg2 (t) will be the Figure handle, and arg3 (x) will be
    %the new dataname
    hfig=t;
    dname=xline;
    hbmap=findobj(hfig,'tag','basemap');
    udat=get(hbmap,'userdata');
    oldname=udat{5};
    udat{5}=dname;
    set(hfig,'name',['plotimage3D ... ' dname]);
    hseismic=findobj(hfig,'tag','seismic');
    ht=get(hseismic,'title');
    ht.String=strrep(ht.String,oldname,dname);
    set(hbmap,'userdata',udat);
    hprevious=findobj(hfig,'tag','previous');
    udat=get(hprevious,'userdata');
    udat{6}=dname;
    set(hprevious,'userdata',udat)
elseif(strcmp(action,'closewindow'))
    %called to close a PI3D tool window
    hwin=gcf;%should be the tool window
    hthisfig=get(hwin,'userdata');%the PI3D window and possibly subwindows of hwin
    hotherwin=[];
    if(iscell(hthisfig))
        hotherwin=hthisfig{1};%subwindows
        hthisfig=hthisfig{2};%pi3dwindow
    end
    if(~isgraphics(hthisfig))
        delete(hwin);
        return
    end
    %test for difference dialog
    if(~isempty(PLOTIMAGE3DDIFFDIAL))
        if(hwin==PLOTIMAGE3DDIFFDIAL)
            PLOTIMAGE3DDIFFDIAL=[];
        end
    end
    %**** from here to **** may be unused
%     hwinlist=findobj(hthisfig,'tag','windows');
%     winfigs=get(hwinlist,'userdata');
%     winnames=get(hwinlist,'string');
%     ival=get(hwinlist,'value');
%     nwins=length(winfigs);
%     if(nwins==0)
%         return;%happens if string is 'None'
%     end
%     iwin=find(hwin==winfigs, 1);
%     if(isempty(iwin))
%         return;%not sure why this might happen
%     end
%     winnames(iwin)=[];
%     winfigs(iwin)=[];
%     if(ival==iwin)
%         ival=min([length(winfigs) ival+1]);
%     elseif(ival>iwin)
%         ival=ival-1; 
%     end
%     if(isempty(winfigs))
%         winnames{1}='None';
%         ival=1;
%     end
%     set(hwinlist,'string',winnames,'value',ival,'userdata',winfigs);
    %****
%     ud=get(hwin,'userdata');
%     if(iscell(ud))
%        for kk=1:length(ud)
%           hh=ud{kk};
%           for jj=1:length(hh)
%              if(isgraphics(hh(jj)))
%                  delete(hh(jj));
%              end
%           end
%        end
%     end
    if(isgraphics(hwin))
        delete(hwin)
    end
    if(~isempty(hotherwin))
        for k=1:length(hotherwin)
            if(isgraphics(hotherwin(k)))
                delete(hotherwin(k));
            end
        end
    end
elseif(strcmp(action,'show_window'))
    hwin=gcbo;
    hfigs=get(hwin,'userdata');
    iwin=get(hwin,'value');
    if(isgraphics(hfigs(iwin)))
        figure(hfigs(iwin));
    else
        nwin=length(hfigs);
        fignames=get(hwin,'string');
        fignames(iwin)=[];
        hfigs(iwin)=[];
        nwin=nwin-1;
        if(iwin>nwin)
            iwin=nwin;
        end
        if(isempty(hfigs))
            fignames{1}='None';
            iwin=1;
        end
        set(hwin,'string',fignames,'value',iwin,'userdata',hfigs);
    end
elseif(strcmp(action,'closeall')||strcmp(action,'closeall2'))
    hwin=findobj(gcf,'tag','windows');
    if(strcmp(action,'closeall'))
        hthiswin=get(hwin,'parent');
        fname=get(hthiswin,'name');
        dname=strrep(fname,'plotimage3D ... ','');
        %confirm the deletion
        pos=get(hthiswin,'position');
        xc=pos(1)+.5*pos(3);yc=pos(2)+.5*pos(4);%center of calling window
        wid=400;ht=200;
        xnow=xc-.5*wid;ynow=yc-.5*wid;
        yesnoinit('plotimage3D(''closeall2'');',['Do you want to close all associated Figures for ' dname ' ??']);
        return;
    else
        choice=yesnofini;
    end
        
    
    switch choice
        case 0
            return;
        case -1
            return;
        case 1
            hfigs=get(hwin,'userdata');%these are our Figures to close
            for k=1:length(hfigs)
                if(isgraphics(hfigs(k)))
                    udat=get(hfigs(k),'userdata');
                    if(iscell(udat))
                        hauxfigs=udat{1};
                        for kk=1:length(hauxfigs)
                            if(isgraphics(hauxfigs(kk)))
                                delete(hauxfigs(kk));
                                
                            end
                        end
                    end
                    delete(hfigs(k))
                end
            end
            set(hwin,'string','None','value',1)
    end
    
elseif(strcmp(action,'buttons2ppt'))
    %this is called by SANE when the 'Start PPT' button is pushed and also when new pi3D windows are
    %opened and PPT is active
    hpifig=t; %this is just the second input when calling
    yellow='y';
    if(isunix)
        hbut=findobj(hpifig,'tag','clipboardalt');
        str=get(hbut,'string');
        str=strrep(str,'TIFF file','PPT');
        str2='Copy current view to the current PPT without controls';
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',yellow);
        hbut=findobj(hpifig,'tag','clipboard');
        str=get(hbut,'string');
        str=strrep(str,'TIFF file','PPT');
        str2='Copy current view to the current PPT with controls';
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',yellow);
    else
        hbut=findobj(hpifig,'tag','clipboardalt');
        str=get(hbut,'string');
        str=strrep(str,'Clipboard','PPT');
        str2=get(hbut,'tooltipstring');
        str2=strrep(str2,'WINDOWS clipboard','current PPT');
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',yellow);
        hbut=findobj(hpifig,'tag','clipboard');
        str=get(hbut,'string');
        str=strrep(str,'Clipboard','PPT');
        str2=get(hbut,'tooltipstring');
        str2=strrep(str2,'WINDOWS clipboard','current PPT');
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',yellow);
    end
elseif(strcmp(action,'buttons2clipboard'))
    %this is called by SANE when 'Close PPT' is pushed.
    hpifig=t; %this is just the second input when calling
    if(~isgraphics(hpifig))
        return;%this can happen if the pifig has been destroyed.
    end
    gray=.94*ones(1,3);
    if(isunix)
        hbut=findobj(hpifig,'tag','clipboardalt');
        str=get(hbut,'string');
        str=strrep(str,'PPT','TIFF file');
        str2='Save current view to a TIFF file without controls';
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',gray);
        hbut=findobj(hpifig,'tag','clipboard');
        str=get(hbut,'string');
        str=strrep(str,'TIFF file','PPT');
        str2='Save current view to a TIFF file with controls';
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',gray);
    else
        hbut=findobj(hpifig,'tag','clipboardalt');
        str=get(hbut,'string');
        str=strrep(str,'PPT','Clipboard');
        str2=get(hbut,'tooltipstring');
        str2=strrep(str2,'current PPT','WINDOWS clipboard');
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',gray);
        hbut=findobj(hpifig,'tag','clipboard');
        str=get(hbut,'string');
        str=strrep(str,'PPT','Clipboard');
        str2=get(hbut,'tooltipstring');
        str2=strrep(str2,'current PPT','WINDOWS clipboard');
        set(hbut,'string',str,'tooltipstring',str2,'backgroundcolor',gray);
    end
elseif(strcmp(action,'importhorizons'))
    hpi3D=gcf;
    %this is called by SANE to import horizons that have been loded into SANE
    horstruct=t;%second argument
    %make the horizons button
    hhor=uicontrol(hpi3D,'style','pushbutton','string','Horizons','tag','horizons','units','normalized',...
        'position',[.25,.925,.05,.025],'callback','plotimage3D(''horedit'');');
    uicontrol(hpi3D,'style','radiobutton','string','Horizon legend','tag','horlegend','units','normalized',...
        'position',[.25,.895,.05,.025],'callback','plotimage3D(''showhors'');','value',0);
    set(hhor,'userdata',horstruct);
    plotimage3D('showhors');
elseif(strcmp(action,'showhors'))
    hhor=findobj(gcf,'tag','horizons');
    if(isempty(hhor))
        return;
    end
    hlocor=findobj(gcf,'tag','locor');
    locor=get(hlocor,'value');
    horstruct=get(hhor,'userdata');
    hseismic=findobj(gcf,'tag','seismic');
    axes(hseismic);
    hbmap=findobj(gcf,'tag','basemap');
    udat=get(hbmap,'userdata');
    x=udat{3};
    y=udat{4};
    view=currentview;
    mode=view{4};
    if(locor)
        tmp=udat{9};
        xcdp=tmp-min(tmp);
        tmp=udat{10}(:);
        ycdp=tmp-min(tmp);
    else
        xcdp=udat{9};
        ycdp=udat{10}(:);
    end
    %get the geooption flag
    hgeo=findobj(gcf,'tag','geo');
    geoflag=get(hgeo,'value');
    %get the legend flag
    hlegend=findobj(gcf,'tag','horlegend');
    legendflag=get(hlegend,'value');
    switch mode
        case 'inline'
            ilinenum=str2double(view{1});
            nhors=length(horstruct.names);
            klrs=get(gca,'colororder');
            for k=1:nhors
                if(isgraphics(horstruct.handles(k)))
                   delete(horstruct.handles(k));
                   horstruct.handles(k)=-1;
                end
                if(horstruct.showflags(k)==1)
                    hor=squeeze(horstruct.horizons(k,:,:));%x is row coordinate, y is column
                    ihor=near(y,ilinenum);
                    thor=hor(:,ihor(1));
                    klr=horstruct.colors{k};
                    if(isempty(klr))
                        klr=klrs(cycle(k,size(klrs,1)),:);
                    end
                    if(geoflag==0)
                        horstruct.handles(k)=line(x,thor,'color',klr,'linewidth',horstruct.linewidths(k),'tag','hor');
                    else
                        horstruct.handles(k)=line(xcdp,thor,'color',klr,'linewidth',horstruct.linewidths(k),'tag','hor');
                    end
                end
            end
            if(legendflag)
                names=cell(1,sum(horstruct.showflags));
                iname=0;
                for k=1:nhors
                    if(horstruct.showflags(k)==1)
                        iname=iname+1;
                        names{iname}=horstruct.names{k};
                    end
                end
                hl=legend(names);
                set(hl,'fontsize',.75*get(hl,'fontsize'),'fontweight','bold');
            else
                legend off
            end
            
        case 'xline'
            xlinenum=str2double(view{2});
            nhors=length(horstruct.names);
            klrs=get(gca,'colororder');
            for k=1:nhors
                if(isgraphics(horstruct.handles(k)))
                   delete(horstruct.handles(k));
                   horstruct.handles(k)=-1;
                end
                if(horstruct.showflags(k)==1)
                    hor=squeeze(horstruct.horizons(k,:,:));%x is row coordinate, y is column
                    ihor=near(x,xlinenum);
                    thor=hor(ihor(1),:);
                    klr=horstruct.colors{k};
                    if(isempty(klr))
                        klr=klrs(cycle(k,size(klrs,1)),:);
                    end
                    if(geoflag==0)
                        horstruct.handles(k)=line(y,thor,'color',klr,'linewidth',horstruct.linewidths(k),'tag','hor');
                    else
                        horstruct.handles(k)=line(ycdp,thor,'color',klr,'linewidth',horstruct.linewidths(k),'tag','hor');
                    end
                end
            end
            if(legendflag)
                names=cell(1,sum(horstruct.showflags));
                iname=0;
                for k=1:nhors
                    if(horstruct.showflags(k)==1)
                        iname=iname+1;
                        names{iname}=horstruct.names{k};
                    end
                end
                hl=legend(names);
                set(hl,'fontsize',.75*get(hl,'fontsize'),'fontweight','bold');
            else
                legend off
            end
        case 'tslice'
            nhors=length(horstruct.names);
            for k=1:nhors
                if(isgraphics(horstruct.handles(k)))
                   delete(horstruct.handles(k));
                   horstruct.handles(k)=-1;
                end
            end
            
    end
    set(hhor,'userdata',horstruct);
    return
    
elseif(strcmp(action,'horedit'))
    horstruct=get(gcbo,'userdata');
    hbmap=findobj(gcf,'tag','basemap');
    udat=get(hbmap,'userdata');
    x=udat{3};
    y=udat{4};
    transfer='plotimage3D(''horedit2'');';
    horizonviewer(horstruct,x,y,transfer);
elseif(strcmp(action,'horedit2'))
    state=horizonviewer('getstate');
    pi3dfig=get(gcf,'userdata');
    if(strcmp(state,'cancel'))
        delete(gcf);
        figure(pi3dfig);
        return;
    end
    horstruct=horizonviewer('getresult');
    delete(gcf);
    figure(pi3dfig);
    hhor=findobj('tag','horizons');
    set(hhor,'userdata',horstruct);
    plotimage3D('showhors');
elseif(strcmp(action,'pi3dinfo'))
    hpi3d=gcf;
    hwin=findobj(hpi3d,'tag','windows');
    msg={['plotimage3D (aka PI3D) is a tool to facilitate exploration and analysis of a 3D seismic dataset. ',...
        'In the upper left is a basemap showing the location of non-zero data while the large image ',...
        'display shows a view of the 3D seismic volume. PI3D can show 3 possible views: inline, ',...
        'crossline (aka xline) and time slice (aka Tslice). Of course, the Tslice view is also a depth ',...
        'slice if the volume is in depth. Just below the basemap are the basic controls for navigation ',...
        'through the 3D volume. Initially you are viewing the middle inline and the inline controls are ',...
        'yellow with the inline number displayed. To display a different inline you can either type its ',...
        'number in the box or click the "previous" or "next" buttons. These buttons step to a lower ',...
        '(previous) or higher (next) number by the increment in the box labelled "incr". This increment ',...
        'is always expressed in samples so in section view (inline or xline) it is the number of lines ',...
        'to step while in Tslice view it is the number of time samples. To switch from inline view to ',...
        'xline view you simply double-click the word "all" in the xline box and type the xline number ',...
        'you wish to see. You jump to Tslice view by a similar process and can type the time slice ',...
        'number in either seconds or milliseconds (a value greater than 10 is assumed to be in ',...
        'milliseconds). '],...
        [],['Below the navigation controls are a collection of controls to manipulate the display. ',...
        'The "Clip level" determines the extent of the colorbar in standard deviations. PI3D measures ',...
        'data mean, called dm, and standard deviation, ds, (for the entire volume) and the colorbar ',...
        'extends from dm-c*ds to dm+c*ds where "c" is the clip level. This means that the smaller the ',...
        'clip level, the greater the clipping. The large dynamic range of seismic amplitudes means ',...
        'some degree of clipping is almost always desired. Clip levels in the range 2-6 are normal. ',...
        'The next 5 controls allow the selection of the colormap, the choice of gridlines, and the ',...
        'image brightness. There are currently 14 colormaps, with seisclrs (aka seimic colors) being ',...
        'the default. New colormaps are possible but must be bullt by hand. '],...
        [],['The buttons initially labelled "To Clipboard without controls" and "To Clipboard with controls" ',...
        'cause the current view to be copied to the Windows clipboard with or without the controls ',...
        'to the left of the image. If you are using PI3D from SANE, then these buttons may also be ',...
        'colored yellow and labelled "To PPT" instead of "To Clipboard". In this case, the image is ',...
        'copied to the current SANE PowerPoint buffer. '],...
        [],['Next are a series of grouping controls. A set of PI3D windows may be grouped such that ',...
        'they all show the same view. Changing the view on any one window will cause all to change. ',...
        'This is generally useful if all of the datasets in the view have the same geometry. There are ',...
        'also grouping controls on the SANE main window which accomplish the same function. ',...
        'Beneath the grouping controls are controls to save any given view. This simply allows ',...
        'a quick return to a saved view.'],...
        [],['Pressing the cursor locate button will turn the mouse pointer into a location device. ',...
        'After pushing this button, then a click inside the image will cause the point to be labelled ',...
        'with its coordinates on all windows in a group. The "Associated figures" popup contains a ',...
        'List of all of the data analysis windows that have been spawned by this PI3D window. ',...
        'Choosing any window from this list will cause it to appear.'],...
        [],['Finally, from any view, data analysis tools are accessed by right-clicking (i.e. press the right mouse ',...
        'button) on the current seismic display (anywhere). This causes a menu to appear giving ',...
        'the available data anlysis tools. The available tools are different for section view versus ',...
        'time slice view. Any number of tool windows can be open at a time and the open windows are ',...
        'listed in the "Associated figures" popup menu in the PI3D window. ',...
        'Each tool window has its own info button.']};
    hinfo=msgbox(msg,'Information for plotimage3D');
%     pos=get(hinfo,'position');
%     set(hinfo,'position',[pos(1:2) 2*pos(3) pos(4)]);
    udat=get(hwin,'userdata');
    udat=[udat hinfo];
    set(hwin,'userdata',udat);
end
end

function mode=determinemode
hthisfig=gcf;
hinlinemode=findobj(hthisfig,'tag','inlinemode');
udat=get(hinlinemode,'userdata');
% hxlinemode=udat(1);
% htslicemode=udat(2);
hinline=udat(3);
hxline=udat(4);
htslice=udat(5);
%determine mode
ykol=get(hinline,'userdata');%this is a flag to indicate mode
kol=get(hinline,'backgroundcolor');
if(kol==ykol)
    mode='inline';
end
kol=get(hxline,'backgroundcolor');
if(kol==ykol)
    mode='xline';
end
kol=get(htslice,'backgroundcolor');
if(kol==ykol)
    mode='tslice';
end
end

function updateview
global PLOTIMAGE3DMASTER PLOTIMAGE3DDIFFDIAL

if(~isempty(PLOTIMAGE3DDIFFDIAL))
    delete(PLOTIMAGE3DDIFFDIAL);
    PLOTIMAGE3DDIFFDIAL=[];
end

hfigs=getfigs;%get the grouped plotseis3D figures
hthisfig=gcf;
ind=hfigs~=hthisfig;
hotherfigs=hfigs(ind);%other figures in this group
hlocor=findobj(hthisfig,'tag','locor');
locor=get(hlocor,'value');
%first deal with the main figure
hinlinemode=findobj(hthisfig,'tag','inlinemode');
udat=get(hinlinemode,'userdata');
%
hinline=udat(3);
hxline=udat(4);
htslice=udat(5);
%determine mode
mode=determinemode;
%get the data
hbmap=findobj(hthisfig,'tag','basemap');
udat=get(hbmap,'userdata');
seiss=udat{1};
t=udat{2};
dt=abs(t(2)-t(1));
xline=udat{3};
iline=udat{4};
dname=udat{5};
dname=strrep(dname,'plotimage3D ... ','');
amp=udat{6};
hseismic=findobj(hthisfig,'tag','seismic');
%get limits of current view to impose again if just updating
xl=get(hseismic,'xlim');
yl=get(hseismic,'ylim');
tmin=get_tmin;
tmax=get_tmax;
gridx=udat{7};
gridy=udat{8};
if(locor)
    tmp=udat{9};
    xcdp=tmp-min(tmp);
    tmp=udat{10}(:);
    ycdp=tmp-min(tmp);
else
    xcdp=udat{9};
    ycdp=udat{10}(:);
end

if(ycdp(1)<ycdp(end))
    hflipy=findobj(hthisfig,'tag','flipy');
    set(hflipy,'userdata',0);
end
%get the geooption flag
hgeo=findobj(hthisfig,'tag','geo');
geoflag=get(hgeo,'value');
timeshift=gettimeshift;
switch mode
    case 'inline'
        t=t+timeshift;
        tmp=get(hinline,'string');
        iline_next=str2double(tmp);
        tmp=get(hxline,'string');
        if(strcmp(tmp,'all'))
            ixline=1:length(xline);
        else
            ind=strfind(tmp,':');
            ix1=str2double(tmp(1:ind-1));
            ix2=str2double(tmp(ind+1:end));
            ixline=ix1:ix2;
        end
        tmp=get(htslice,'string');
        if(strcmp(tmp,'all'))
            %it=1:length(t);
            it=near(t,tmin,tmax);
        else
            ind=strfind(tmp,':');
            it1=str2double(tmp(1:ind-1));
            it2=str2double(tmp(ind+1:end));
            it=it1:it2;
        end
        axes(hseismic)
        %find the image if it exists
        hi=findobj(gca,'type','image');
        inot=near(iline,iline_next);
        if(~isempty(hi))
            tag=get(hi,'tag');
            if(~strcmp(tag,'inline'))
                delete(hi);%this happens if we have switched modes
                hi=[];
            end
        end
        if(isempty(hi))
            %make a new image
            %xx=1:length(xline);
            clipnow=getclip;
            if(length(clipnow)==1)
                clim=[amp(1)-clipnow*amp(2) amp(1)+clipnow*amp(2)];
            else
                clim=clipnow;
            end
            clearlocations;
            set(gcf,'nextplot','add');
            if(geoflag==0)
                hi=imagesc(xline,t(it),squeeze(seiss(it,ixline,inot(1))),clim);
            else
                hi=imagesc(xcdp,t(it),squeeze(seiss(it,ixline,inot(1))),clim);
            end
            set(gcf,'nextplot','new');
            %create a context menu
            hcm=uicontextmenu;
            uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
            uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
            uimenu(hcm,'label','f-x phase','callback',@showfxphase);
            uimenu(hcm,'label','f-x amp','callback',@showfxamp);
            uimenu(hcm,'label','Spectral decomp','callback',@spdcmp);
            uimenu(hcm,'label','Dominant frequency','callback',@dominentfreq);
            if(isdeployed)
                uimenu(hcm,'label','Time-variant relative phase','callback',@showtvphase,'enable','off');
            else
                uimenu(hcm,'label','Time-variant relative phase','callback',@showtvphase,'enable','on');
            end
            uimenu(hcm,'label','Amplitude histogram','callback',@amphist)
            uimenu(hcm,'label','SVD separation','callback',@showsvdsep);
            uimenu(hcm,'label','Difference plot','callback',@difference);
            uimenu(hcm,'label','Bandpass filter','callback',@filter);
            uimenu(hcm,'label','Spiking decon','callback',@deconvolution);
            uimenu(hcm,'label','Gabor decon','callback',@gabdec);
            set(hi,'uicontextmenu',hcm);
            %save the contextmenudata
            hprevious=findobj(gcf,'tag','previous');
            dname=get(gcf,'name');
            dname=strrep(dname,'plotimage3D ... ','');
            
            if(geoflag==0)
                set(hprevious,'userdata',{squeeze(seiss(it,ixline,inot(1))),xline,t(it),'inline',iline(inot(1)),dname,gridx,dt,xcdp});
                xlabel('xline number');
            else
                set(hprevious,'userdata',{squeeze(seiss(it,ixline,inot(1))),xcdp,t(it),'inline',iline(inot(1)),dname,gridx,dt,xline});
                xlabel('x coordinate');
            end
            
            colorbar;
            set(hi,'tag','inline');
            %flipx;
            cmapnow=getcolormap;
            colormap(cmapnow);
            
            ylabel('time (s)');
            ht=title([dname ' inline ' int2str(iline(inot))]);
            ht.Interpreter='none';
%             xt=get(hseismic,'xtick');
%             set(hseismic,'xticklabel',vector2textcell(xline(xt)));
            set(hseismic,'tag','seismic');
            setaxesdir;
            bigfont(hseismic,1.5,1);
            plotimage3D('grid');
        else
            %update the existing image
            set(hi,'cdata',squeeze(seiss(it,ixline,inot(1))),'ydata',t(it),'tag','inline');
            ylim([t(it(1)) t(it(end))])
            ht=title([dname ' inline ' int2str(iline(inot))]);
            ht.Interpreter='none';
            clipnow=getclip;
            if(length(clipnow)==1)
                clim=[amp(1)-clipnow*amp(2) amp(1)+clipnow*amp(2)];
            else
                clim=clipnow;
            end
            yl=[tmin tmax];
            set(hseismic,'tag','seismic','clim',clim,'xlim',xl,'ylim',yl);
            %save the contextmenudata
            hprevious=findobj(gcf,'tag','previous');
            dname=get(gcf,'name');
            if(geoflag==0)
                set(hprevious,'userdata',{squeeze(seiss(it,ixline,inot(1))),xline,t(it),'inline',iline(inot(1)),dname,gridx,dt,xcdp});
                xlabel('xline number');
            else
                set(hprevious,'userdata',{squeeze(seiss(it,ixline,inot(1))),xcdp,t(it),'inline',iline(inot(1)),dname,gridx,dt,xline});
                xlabel('x coordinate');
            end
            %set(hprevious,'userdata',{squeeze(seiss(it,ixline,inot(1))),xline,t(it),'inline',iline(inot(1)),dname,gridx,dt});
        end
        %update the basemap
        axes(hbmap)
        hl=findobj(hbmap,'tag','currentline');
        ht=findobj(hbmap,'tag','currenttext');
        if(~isempty(hl)); delete(hl); end
        if(~isempty(ht)); delete(ht); end
        if(geoflag==0)
            hnow=line(xline,iline(inot)*ones(size(xline)),'color','r');
            set(hnow,'userdata',[1 iline(inot)]);
            nmid=round(length(xline)/2);
            text(xline(nmid),iline(inot),['inline ' int2str(iline(inot))],...
                'horizontalalignment','center','tag','currenttext');
        else
            ynow=yline2cdp(iline(inot));
            hnow=line(xcdp,ynow*ones(size(xline)),'color','r');
            set(hnow,'userdata',[1 ynow])
            nmid=round(length(xcdp)/2);
            text(xcdp(nmid),ynow,['inline ' int2str(iline(inot))],...
                'horizontalalignment','center','tag','currenttext');
        end
        set(hnow,'tag','currentline');
        set(hbmap,'tag','basemap');
        
    case 'xline'
        t=t+timeshift;
        tmp=get(hxline,'string');
        xline_next=str2double(tmp);
        tmp=get(hinline,'string');
        if(strcmp(tmp,'all'))
            iiline=1:length(iline);
        else
            ind=strfind(tmp,':');
            il1=str2double(tmp(1:ind-1));
            il2=str2double(tmp(ind+1:end));
            iiline=il1:il2;
        end
        tmp=get(htslice,'string');
        if(strcmp(tmp,'all'))
            %it=1:length(t);
            it=near(t,tmin,tmax);
        else
            ind=strfind(tmp,':');
            it1=str2double(tmp(1:ind-1));
            it2=str2double(tmp(ind+1:end));
            it=it1:it2;
        end
        axes(hseismic)
        %find the image if it exists
        hi=findobj(gca,'type','image');
        inot=near(xline,xline_next);
        if(~isempty(hi))
            tag=get(hi,'tag');
            if(~strcmp(tag,'xline'))
                delete(hi);%this happens if we have switched modes
                hi=[];
            end
        end
        if(isempty(hi))
            %make a new image
            %xx=1:length(iline);
            clipnow=getclip;
            if(length(clipnow)==1)
                clim=[amp(1)-clipnow*amp(2) amp(1)+clipnow*amp(2)];
            else
                clim=clipnow;
            end
            clearlocations;
            set(gcf,'nextplot','add');
            if(geoflag==0)
                hi=imagesc(iline,t(it),squeeze(seiss(it,inot(1),iiline)),clim);
            else
                hi=imagesc(ycdp,t(it),squeeze(seiss(it,inot(1),iiline)),clim);
            end
            set(gcf,'nextplot','new');
            %create a context menu
            hcm=uicontextmenu;
            uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
            uimenu(hcm,'label','Time-variant spectra','callback',@showtvspectrum);
            uimenu(hcm,'label','f-x phase','callback',@showfxphase);
            uimenu(hcm,'label','f-x amp','callback',@showfxamp);
            uimenu(hcm,'label','Spectral decomp','callback',@spdcmp);
            uimenu(hcm,'label','Dominant frequency','callback',@dominentfreq);
            if(isdeployed)
                uimenu(hcm,'label','Time-variant relative phase','callback',@showtvphase,'enable','off');
            else
                uimenu(hcm,'label','Time-variant relative phase','callback',@showtvphase,'enable','on');
            end
            uimenu(hcm,'label','Amplitude histogram','callback',@amphist)
            uimenu(hcm,'label','SVD separation','callback',@showsvdsep);
            uimenu(hcm,'label','Difference plot','callback',@difference);
            uimenu(hcm,'label','Bandpass filter','callback',@filter);
            uimenu(hcm,'label','Spiking decon','callback',@deconvolution);
            uimenu(hcm,'label','Gabor decon','callback',@gabdec);
            set(hi,'uicontextmenu',hcm);
            %save the contextmenudata
            hprevious=findobj(gcf,'tag','previous');
            dname=get(gcf,'name');
            dname=strrep(dname,'plotimage3D ... ','');
            if(geoflag==0)
                set(hprevious,'userdata',{squeeze(seiss(it,inot(1),iiline)),iline,t(it),'xline',xline(inot(1)),dname,gridy,dt,ycdp});
                xlabel('inline number');
            else
                set(hprevious,'userdata',{squeeze(seiss(it,inot(1),iiline)),iline,t(it),'xline',xline(inot(1)),dname,gridy,dt,iline});
                xlabel('y coordinate');
            end
            
            colorbar;
            set(hi,'tag','xline');
            %flipx;
            cmapnow=getcolormap;
            colormap(cmapnow);
            ylabel('time (s)');
            ht=title([dname ' xline ' int2str(xline(inot))]);
            ht.Interpreter='none';
%             xt=get(hseismic,'xtick');
%             set(hseismic,'xticklabel',vector2textcell(iline(xt)));
            set(hseismic,'tag','seismic');
            setaxesdir;            
            bigfont(hseismic,1.5,1);
            plotimage3D('grid');
        else
            %update the existing image, either clip or time range has changed
            set(hi,'cdata',squeeze(seiss(it,inot(1),iiline)),'ydata',t(it),'tag','xline');
            ylim([t(it(1)) t(it(end))])
            ht=title([dname ' xline ' int2str(xline(inot))]);
            ht.Interpreter='none';
            clipnow=getclip;
            if(length(clipnow)==1)
                clim=[amp(1)-clipnow*amp(2) amp(1)+clipnow*amp(2)];
            else
                clim=clipnow;
            end
            yl=[tmin tmax];
            set(hseismic,'tag','seismic','clim',clim,'xlim',xl,'ylim',yl);
            %save the contextmenudata
            hprevious=findobj(gcf,'tag','previous');
            dname=get(gcf,'name');
            if(geoflag==0)
                set(hprevious,'userdata',{squeeze(seiss(it,inot(1),iiline)),iline,t(it),'xline',xline(inot(1)),dname,gridy,dt,ycdp});
            else
                set(hprevious,'userdata',{squeeze(seiss(it,inot(1),iiline)),iline,t(it),'xline',xline(inot(1)),dname,gridy,dt,iline});
            end
                
        end
        %update the basemap
        axes(hbmap)
        hl=findobj(hbmap,'tag','currentline');
        ht=findobj(hbmap,'tag','currenttext');
        if(~isempty(hl)); delete(hl); end
        if(~isempty(ht)); delete(ht); end
        if(geoflag==0)
            hnow=line(xline(inot)*ones(size(iline)),iline,'color','r');
            set(hnow,'userdata',[2 xline(inot)])
            nmid=round(length(iline)/2);
            text(xline(inot),iline(nmid),['xline ' int2str(xline(inot))],...
                'horizontalalignment','center','tag','currenttext');
        else
            xnow=xline2cdp(xline(inot));
            hnow=line(xnow*ones(size(iline)),ycdp,'color','r');
            set(hnow,'userdata',[2 xnow]);
            nmid=round(length(ycdp)/2);
            text(xnow,ycdp(nmid),['xline ' int2str(xline(inot))],...
                'horizontalalignment','center','tag','currenttext');
        end
        
        
        set(hnow,'tag','currentline');
        set(hbmap,'tag','basemap');
        
        
    case 'tslice'
        t=t+timeshift;
        tmp=get(htslice,'string');
        tslice_next=str2double(tmp);
        tmp=get(hxline,'string');
        if(strcmp(tmp,'all'))
            ixline=1:length(xline);
        else
            ind=strfind(tmp,':');
            ix1=str2double(tmp(1:ind-1));
            ix2=str2double(tmp(ind+1:end));
            ixline=ix1:ix2;
        end
        tmp=get(hinline,'string');
        if(strcmp(tmp,'all'))
            iiline=1:length(iline);
        else
            ind=strfind(tmp,':');
            il1=str2double(tmp(1:ind-1));
            il2=str2double(tmp(ind+1:end));
            iiline=il1:il2;
        end
        axes(hseismic)
        %find the image if it exists
        hi=findobj(gca,'type','image');
        inot=near(t,tslice_next);
        if(~isempty(hi))
            tag=get(hi,'tag');
            if(~strcmp(tag,'tslice'))
                delete(hi);%this happens if we have switched modes
                hi=[];
            end
        end
        if(isempty(hi))
            %make a new image
            %xx=1:length(xline);
            %yy=1:length(iline);
            clipnow=getclip;
            if(length(clipnow)==1)
                clim=[amp(1)-clipnow*amp(2) amp(1)+clipnow*amp(2)];
            else
                clim=clipnow;
            end
            clearlocations;
            set(gcf,'nextplot','add');
            if(geoflag==0)
                hi=imagesc(xline,iline,squeeze(seiss(inot(1),ixline,iiline))',clim);
            else
                hi=imagesc(xcdp,ycdp,squeeze(seiss(inot(1),ixline,iiline))',clim);
            end
            if(ycdp(1)<ycdp(end))
                hflipy=findobj(hthisfig,'tag','flipy');
                set(hflipy,'userdata',0);
            end
            set(gcf,'nextplot','new');
            %create a context menu
            hcm=uicontextmenu;
            uimenu(hcm,'label','Spectrum (2D)','callback',@show2dspectrum);
            uimenu(hcm,'label','SVD separation','callback',@showsvdsep);
            uimenu(hcm,'label','Footprint analysis','callback',@footprint);
            uimenu(hcm,'label','Spectral decomp','callback',@specdtslice);
            uimenu(hcm,'label','Dominant frequency','callback',@fdomtslice);
            uimenu(hcm,'label','Surface plot','callback',@showsurf);
            uimenu(hcm,'label','Difference plots (Requires a Group)','callback',@difference);
            uimenu(hcm,'label','Amplitude histogram','callback',@amphist)
            
            set(hi,'uicontextmenu',hcm);
            %save the contextmenudata
            hprevious=findobj(gcf,'tag','previous');
            dname=get(gcf,'name');
            dname=strrep(dname,'plotimage3D ... ','');
            if(geoflag==0)
                set(hprevious,'userdata',{squeeze(seiss(inot(1),ixline,iiline))',xline,iline,'tslice',t(inot(1)),dname,gridx,gridy,xcdp,ycdp});
                xlabel('xline number');
                ylabel('inline number');
                axis normal
                xlim([min(xline) max(xline)]);ylim([min(iline) max(iline)]);
            else
                set(hprevious,'userdata',{squeeze(seiss(inot(1),ixline,iiline))',xcdp,ycdp,'tslice',t(inot(1)),dname,gridx,gridy,xline,iline});
                xlabel('x coordinate');
                ylabel('y coordinate');
                axis equal
                xlim([min(xcdp) max(xcdp)]);ylim([min(ycdp) max(ycdp)]);
            end
            
            colorbar;
            set(hi,'tag','tslice');
            %flipx;
            cmapnow=getcolormap;
            colormap(cmapnow);
            ht=title([dname ' timeslice ' num2str(t(inot))]);
            ht.Interpreter='none';
%             xt=get(hseismic,'xtick');
%             set(hseismic,'xticklabel',vector2textcell(xline(xt)));
%             yt=get(hseismic,'ytick');
%             set(hseismic,'yticklabel',vector2textcell(iline(yt)));
            set(hseismic,'tag','seismic');
            setaxesdir;            
            bigfont(hseismic,1.5,1);
            plotimage3D('grid');
        else
            %update the existing image
            set(hi,'cdata',squeeze(seiss(inot(1),ixline,iiline))','tag','tslice');
            if(ycdp(1)<ycdp(end))
                hflipy=findobj(hthisfig,'tag','flipy');
                set(hflipy,'userdata',0);
            end
            ht=title([dname ' timeslice ' num2str(t(inot))]);
            ht.Interpreter='none';
            clipnow=getclip;
            if(length(clipnow)==1)
                clim=[amp(1)-clipnow*amp(2) amp(1)+clipnow*amp(2)];
            else
                clim=clipnow;
            end
            set(hseismic,'tag','seismic','clim',clim,'xlim',xl,'ylim',yl);
            %save the contextmenudata
            hprevious=findobj(gcf,'tag','previous');
            dname=get(gcf,'name');
            dname=strrep(dname,'plotimage3D ... ','');
            if(geoflag==0)
                set(hprevious,'userdata',{squeeze(seiss(inot(1),ixline,iiline))',xline,iline,'tslice',t(inot(1)),dname,gridx,gridy,xcdp,ycdp});
                xlabel('xline number');ylabel('inline number');
                axis normal
                xlim([min(xline) max(xline)]);ylim([min(iline) max(iline)]);
            else
                set(hprevious,'userdata',{squeeze(seiss(inot(1),ixline,iiline))',xcdp,ycdp,'tslice',t(inot(1)),dname,gridx,gridy,xline,iline});
                xlabel('x coordinate');ylabel('y coordinate');
                axis equal
                xlim([min(xcdp) max(xcdp)]);ylim([min(ycdp) max(ycdp)]);
            end
        end
        %update the basemap
        axes(hbmap)
        hl=findobj(hbmap,'tag','currentline');
        ht=findobj(hbmap,'tag','currenttext');
        if(~isempty(hl)); delete(hl); end
        if(~isempty(ht)); delete(ht); end
        if(geoflag==0)
            xx=[xline(1) xline(end) xline(end) xline(1) xline(1)];
            yy=[iline(1) iline(1) iline(end) iline(end) iline(1)];
            hnow=line(xx,yy,'color','r');
            xx=(xline(1)+xline(end))*.5;
            yy=(iline(1)+iline(end))*.5;
            text(xx,yy,['tslice ' num2str(t(inot))],...
                'horizontalalignment','center','tag','currenttext');
        else
            xx=[xcdp(1) xcdp(end) xcdp(end) xcdp(1) xcdp(1)];
            yy=[ycdp(1) ycdp(1) ycdp(end) ycdp(end) ycdp(1)];
            hnow=line(xx,yy,'color','r');
            xx=(xcdp(1)+xcdp(end))*.5;
            yy=(ycdp(1)+ycdp(end))*.5;
            text(xx,yy,['tslice ' num2str(t(inot))],...
                'horizontalalignment','center','tag','currenttext');
        end
        
        set(hnow,'tag','currentline','userdata',[3,t(inot)]);%the first entry in udat is a flag, 1=inline, 2=xline, 3=timeslice
        set(hbmap,'tag','basemap');
        
        
end

%update horizons
plotimage3D('showhors');

%now deal with the otherfigs
if(~isempty(hotherfigs))
    %this stuff with PLOTIMAGE3DMASTER is so that only one figure in the
    %group updates the others. Without this, they update each other
    %endlessly. So, the figure in which the click occurs calls the other
    %but the others just updatethemselves and do not call the others.
    xdir=get(hseismic,'xdir');
    ydir=get(hseismic,'ydir');
    xl=get(hseismic,'xlim');
    yl=get(hseismic,'ylim');
    if(isempty(PLOTIMAGE3DMASTER))
        PLOTIMAGE3DMASTER=1;
        view=currentview;
        for k=1:length(hotherfigs)
            figure(hotherfigs(k));
            hseismic=findobj(hotherfigs(k),'tag','seismic');
            setview(view);
            set(hseismic,'xdir',xdir,'ydir',ydir,'xlim',xl,'ylim',yl);
            PLOTIMAGE3DMASTER=PLOTIMAGE3DMASTER+1;%this seems useless but it makes the editor think PLOTIMAGE3DMASTER is in use
        end
        PLOTIMAGE3DMASTER=[];
    end
%     PLOTIMAGE3DMASTER=1;
%     view=currentview;
%     for k=1:length(hotherfigs)
%         figure(hotherfigs(k));
%         setview(view);
%         hseismic=findobj(hotherfigs(k),'tag','seismic');
%         set(hseismic,'xdir',xdir,'ydir',ydir);
%         PLOTIMAGE3DMASTER=PLOTIMAGE3DMASTER+1;%this seems useless but it makes the editor think PLOTIMAGE3DMASTER is in use
%     end
%     PLOTIMAGE3DMASTER=[];
end

end

function xc=xline2cdp(xl)
hlocor=findobj(gcf,'tag','locor');
locor=get(hlocor,'value');
hgeo=findobj(gcf,'tag','geo');
udat=get(hgeo,'userdata');
xline=udat{1};
if(locor)
    tmp=udat{3};
    xcdp=tmp-min(tmp);
else
    xcdp=udat{3};
end
ind=near(xline,xl);
xc=xcdp(ind(1));
end
function xl=xcdp2line(xc)
hlocor=findobj(gcf,'tag','locor');
locor=get(hlocor,'value');
hgeo=findobj(gcf,'tag','geo');
udat=get(hgeo,'userdata');
xline=udat{1};
if(locor)
    tmp=udat{3};
    xcdp=tmp-min(tmp);
else
    xcdp=udat{3};
end
ind=near(xcdp,xc);
xl=xline(ind(1));
end
function yc=yline2cdp(yl)
hlocor=findobj(gcf,'tag','locor');
locor=get(hlocor,'value');
hgeo=findobj(gcf,'tag','geo');
udat=get(hgeo,'userdata');
iline=udat{2};
if(locor)
    tmp=udat{4};
    ycdp=tmp-min(tmp);
else
    ycdp=udat{4};
end
ind=near(iline,yl);
yc=ycdp(ind(1));
end
function yl=ycdp2line(yc)
hlocor=findobj(gcf,'tag','locor');
locor=get(hlocor,'value');
hgeo=findobj(gcf,'tag','geo');
udat=get(hgeo,'userdata');
iline=udat{2};
if(locor)
    tmp=udat{4};
    ycdp=tmp-min(tmp);
else
    ycdp=udat{4};
end
ind=near(ycdp,yc);
yl=iline(ind(1));
end

function hfigs=getfigs
%check to see if current figure is the dismiss dialog
name=get(gcf,'name');
ind=strfind(name,'Group Info');
if(~isempty(ind)) %#ok<STREMP>
    hbutt=findobj(gcf,'tag','dismiss');
    hthisfig=get(hbutt,'userdata');
else
    hthisfig=gcf;
end
global PLOTIMAGE3DFIGS
%PLOTIMAGE3DFIGS is an ordinary array of figure handles
if(isempty(PLOTIMAGE3DFIGS))
    hfigs=hthisfig;
    return;
else
    ind=isgraphics(PLOTIMAGE3DFIGS);
    PLOTIMAGE3DFIGS=PLOTIMAGE3DFIGS(ind);
    if(isempty(PLOTIMAGE3DFIGS))
        hfigs=hthisfig;
        return;
    end
    ind=find(hthisfig==PLOTIMAGE3DFIGS, 1);
    if(isempty(ind))
        hfigs=hthisfig;
    else
        hfigs=PLOTIMAGE3DFIGS;
    end
    return;
end
end

function timeshift=gettimeshift
hfigs=getfigs;
hthisfig=gcf;
global PLOTIMAGE3DDATASIZE
if(~isempty(PLOTIMAGE3DDATASIZE))
    ind= hthisfig==hfigs;
    figdata=PLOTIMAGE3DDATASIZE;
    if(length(figdata)>3)
        timeshift=figdata(ind,4);
    else
        timeshift=0;
    end
else
    timeshift=0;
end
end

function clipnow=getclip
%hfigs=getfigs;
hthisfig=gcf;
%ind=hfigs~=hthisfig;
%hotherfigs=hfigs(ind);
hclip=findobj(hthisfig,'tag','cliplevel');
cliplevels=get(hclip,'string');
iclip=get(hclip,'value');
if(strcmp(cliplevels{iclip},'manual'))
    hampapply=findobj(hthisfig,'tag','ampapply');
    hampcontrols=get(hampapply,'userdata');
    ampmax=str2double(get(hampcontrols(1),'string'));
    ampmin=str2double(get(hampcontrols(2),'string'));
    if(isnan(ampmax))
        msgbox('you have not entered a valid number for the maximum amplitude',...
            'Ooops!');
        return;
    end
    if(isnan(ampmin))
        msgbox('you have not entered a valid number for the minimum amplitude',...
            'Ooops!');
        return;
    end
    clipnow=[ampmin ampmax];
else
    clipnow=str2double(cliplevels{iclip});
end
end

function [cmapnow,cmapstring]=getcolormap 
%hfigs=getfigs;
hthisfig=gcf;
% ind=hfigs~=hthisfig;
% hotherfigs=hfigs(ind);
hcolormap=findobj(hthisfig,'tag','colormap');
colormaps=get(hcolormap,'string'); 
icolor=get(hcolormap,'value'); 
hflip=findobj(gcf,'tag','flipcolormap');
flip=get(hflip,'value');
hbrighten=findobj(gcf,'tag','brighten');
ibright=get(hbrighten,'value');
brightnesses=get(hbrighten,'string');
brightness=str2double(brightnesses{ibright});
m=128;
switch colormaps{icolor}
    case 'seisclrs'
        cmapnow=seisclrs(m);
    case 'parula'
        cmapnow=parula(m);
    case 'jet'
        cmapnow=jet(m);
    case 'redblue'
        cmapnow=redblue(m);
    case 'redblue2'
        cmapnow=redblue2(m);
    case 'redblue3'
        cmapnow=redblue3(m);
    case 'copper'
        cmapnow=copper(m);
    case 'blueblack'
        cmapnow=blueblack(m);
    case 'greenblack'
        cmapnow=greenblack(m);
    case 'bone'
        cmapnow=bone(m);
    case 'gray'
        cmapnow=gray(m);
    case 'bluebrown'
        cmapnow=bluebrown(m);
    case 'greenblue'
        cmapnow=greenblue(m);
    case 'winter'
        cmapnow=winter(m);
end
        
cmapstring=colormaps{icolor};

if(flip==1)
    cmapnow=flipud(cmapnow);
end
if(brightness~=0)
    cmapnow=brighten(cmapnow,brightness);
end

end

function hidecontrols
hthisfig=gcf;
hkids=get(hthisfig,'children');
hseismic=findobj(hthisfig,'tag','seismic');
hbmap=findobj(hthisfig,'tag','basemap');
vistate=cell(size(hkids));
xnot=.1;
for k=1:length(hkids)
    if(hkids(k)==hseismic)
        seisposn=get(hseismic,'position');
        set(hseismic,'position',[xnot seisposn(2) seisposn(3)+seisposn(1)-xnot seisposn(4)])
        vistate{k}='on';
    elseif(hkids(k)==hbmap)
        vistate{k}='on';
        hkidsb=get(hbmap,'children');
        visb=cell(size(hkidsb));
        for kk=1:length(hkidsb)
            visb{kk}=get(hkidsb(kk),'visible');
            set(hkidsb(kk),'visible','off');
        end
        set(hbmap,'visible','off');
    elseif(~strcmp(get(hkids(k),'type'),'colorbar'))
        vistate{k}=get(hkids(k),'visible');
        set(hkids(k),'visible','off'); 
    end
end
hcopyalt=findobj(hthisfig,'tag','clipboardalt');
set(hcopyalt,'userdata',{vistate visb seisposn});
set(hthisfig,'color','w');
end

function restorecontrols
hthisfig=gcf;
hkids=get(hthisfig,'children');
hseismic=findobj(hthisfig,'tag','seismic');
hbmap=findobj(hthisfig,'tag','basemap');
hcopyalt=findobj(hthisfig,'tag','clipboardalt');
udat=get(hcopyalt,'userdata');
vistate=udat{1};
visb=udat{2};
seisposn=udat{3};
for k=1:length(hkids)
    if(hkids(k)==hseismic)
        set(hseismic,'position',seisposn);
    elseif(hkids(k)==hbmap)
        hkidsb=get(hbmap,'children');
        for kk=1:length(hkidsb)
           set(hkidsb,'visible',visb{kk}); 
        end
        set(hbmap,'visible',vistate{k});
    elseif(~strcmp(get(hkids(k),'type'),'colorbar'))
        set(hkids(k),'visible',vistate{k});
    end
end
set(hthisfig,'color',.94*ones(1,3));
end

function view=currentview
hthisfig=gcf;
%get the 3 handles
hinline=findobj(hthisfig,'tag','inlinebox');
hxline=findobj(hthisfig,'tag','xlinebox');
htslice=findobj(hthisfig,'tag','tslicebox');
%get the text entries defining the view
itext=get(hinline,'string');
xtext=get(hxline,'string');
ttext=get(htslice,'string');
%determine the mode
mode=determinemode;
%define the view, it consists of text strings giving inline xline and time and the mode.
%mode is one of the three strings 'inline' 'xline' or 'tslice'
view={itext xtext ttext mode};
end

function setview(view)
hthisfig=gcf;
%get the 3 handles
hinline=findobj(hthisfig,'tag','inlinebox');
hxline=findobj(hthisfig,'tag','xlinebox');
htslice=findobj(hthisfig,'tag','tslicebox');
%set the view
set(hinline,'string',view{1});
set(hxline,'string',view{2});
set(htslice,'string',view{3});
%execute the proper callback
if(strcmp(view{4},'inline'))
    plotimage3D('inline');
elseif(strcmp(view{4},'xline'))
    plotimage3D('xline');
else
    plotimage3D('tslice');
end
end

function setaxesdir
hflipx=findobj(gcf,'tag','flipx');
hflipy=findobj(gcf,'tag','flipy');
hseismic=findobj(gcf,'tag','seismic');
hbmap=findobj(gcf,'tag','basemap');
dirflag=get(hflipx,'userdata');
mode=determinemode;
if(dirflag==1)
    set(hseismic,'xdir','normal');
    set(hbmap,'xdir','normal');
else
    set(hseismic,'xdir','reverse');
    set(hbmap,'xdir','reverse');
end
dirflag=get(hflipy,'userdata');
if(dirflag==1)
    if(strcmp(mode,'tslice'))
        set(hseismic,'ydir','reverse');
        set(hbmap,'ydir','reverse');
    else
        set(hseismic,'ydir','reverse');
        set(hbmap,'ydir','reverse');
    end
else
    if(strcmp(mode,'tslice'))
        set(hseismic,'ydir','normal');
        set(hbmap,'ydir','normal');
    else
        set(hseismic,'ydir','reverse');
        set(hbmap,'ydir','normal');
    end
end
end

function clearlocations
hfigs=getfigs;
hthisfig=gcf;
ind= hfigs~=hthisfig;
hotherfigs=hfigs(ind);
hlocate=findobj(hthisfig,'tag','locate');
existinglocations=get(hlocate,'userdata');
npts=length(existinglocations);
for k=1:npts
    thispoint=existinglocations{k};
    delete(thispoint);
end
set(hlocate,'userdata',[]);

%process the other figs
for k=1:length(hotherfigs)
    hlocate=findobj(hotherfigs(k),'tag','locate');
    existinglocations=get(hlocate,'userdata');
    npts=length(existinglocations);
    for kk=1:npts
        thispoint=existinglocations{kk};
        delete(thispoint);
    end
    set(hlocate,'userdata',[]);
end
end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','sane(''makepptslide'');');
%the title string will be stored as userdata
end

function show2dspectrum(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};
gridx=udat{7};
gridy=udat{8};
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
switch mode
    case 'inline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        dt=y(2)-y(1);
        fmax=.25/dt;
        fnyq=.5/dt;
        dx=x(2)-x(1);
        kxnyq=.5/gridx;
        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=seisplotfk(data,y,x,dname2,fmax,gridy,gridx);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        if(strcmp(gridon,'on'))
            set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
            set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
        end
        colormap(cmap);
        set(gcf,'position',pos,'visible','on');
        axes(datar{1})
        xlabel('xline number')
        htit=get(gca,'title');
        str=get(htit,'string');
        str{2}=['x-t space dx=' num2str(gridx) ', dt=' num2str(dt)];
        set(htit,'string',str);
        htit=get(datar{2},'title');
        str=get(htit,'string');
        str{2}=['kx-f space, kxnyq=' num2str(kxnyq,2) ', fnyq=' num2str(fnyq)];
        set(htit,'string',str);
        xdir=get(hseis,'xdir');
        ydir=get(hseis,'ydir');
        set(datar{1},'xdir',xdir,'ydir',ydir)
    case 'xline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        dt=y(2)-y(1);
        fmax=.25/dt;
        fnyq=.5/dt;
        dy=x(2)-x(1);
        kynyq=.5/gridy;
        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=seisplotfk(data,y,x,dname2,fmax,gridy,gridx);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        if(strcmp(gridon,'on'))
            set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
            set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
        end
        colormap(cmap)
        set(gcf,'position',pos,'visible','on');
        axes(datar{1})
        xlabel('inline number')
        htit=get(gca,'title');
        str=get(htit,'string');
        str{2}=['y-t space dy=' num2str(gridy) ', dt=' num2str(dt)];
        set(htit,'string',str);
        htit=get(datar{2},'title');
        str=get(htit,'string');
        str{2}=['ky-f space, kynyq=' num2str(kynyq,2) ', fnyq=' num2str(fnyq)];
        set(htit,'string',str);
        xdir=get(hseis,'xdir');
        ydir=get(hseis,'ydir');
        set(datar{1},'xdir',xdir,'ydir',ydir)
    case 'tslice'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        dy=y(2)-y(1);
        dx=x(2)-x(1);
        kynyq=.5/gridy;
        kxnyq=.5/gridx;
        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=seisplotfk(data,y,x,dname2,kynyq,gridy,gridx);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        colormap(cmap)
        if(strcmp(gridon,'on'))
            set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
            set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
        end
        set(gcf,'position',pos,'visible','on');
        axes(datar{1})
        xlabel('crossline number')
        ylabel('inline number')
        htit=get(gca,'title');
        str=get(htit,'string');
        str{2}=['x-y space dx=' num2str(gridx) ', dy=' num2str(gridy)];
        set(htit,'string',str);
        htit=get(datar{2},'title');
        str=get(htit,'string');
        str{2}=['kx-ky space, kxnyq=' num2str(kxnyq,2) ', kynyq=' num2str(kynyq,2)];
        set(htit,'string',str);
        axes(datar{2})
        xlabel('Crossline wavenumber');
        ylabel('Inline wavenumber');
        %flip axes if needed to match main fig
        xdir=get(hseis,'xdir');
        ydir=get(hseis,'ydir');
        set(datar{1},'xdir',xdir,'ydir',ydir)
end

%Make entry in windows list and set closerequestfcn
winname=['2D spectrum ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function showsvdsep(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

dname2={strrep(dname,'plotimage3D ... ',''), [mode ' ' num2str(thisone)]};
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
NEWFIGVIS='off';
datar=seisplotsvd_sep(data,y,x,dname2);
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',[dname2{1} ' ' dname2{2}]);
colormap(cmap);
if(strcmp(gridon,'on'))
    set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{3},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
end
set(gcf,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2} datar{3}],'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['SVD separation ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function showsurf(~,~)

hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

dname2=[strrep(dname,'plotimage3D ... ',''), mode ' ' num2str(thisone)];
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
% gridon=get(hseis,'xgrid');
% gridcolor=get(hseis,'gridcolor');
% gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
% datar=seisplotsvd_sep(data,y,x,dname2);
figure('visible','off')
surf(x,y,data);shading flat
hsurf=gca;
colormap(cmap);
set(gcf,'name',['Surface plot ' dname2])
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
% if(strcmp(gridon,'on'))
%     set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
%     set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
%     set(datar{3},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
% end
set(gcf,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set(hsurf,'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['Surface plot ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function footprint(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

hbmap=findobj(gcf,'tag','basemap');
udat=get(hbmap,'userdata');
dx=udat{7};
dy=udat{8};

dname2={strrep(dname,'plotimage3D ... ',''), [mode ' ' num2str(thisone)]};
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
NEWFIGVIS='off';
datar=seisplotsvd_foot(data,x,y,dx,dy,dname2);
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
colormap(cmap);
if(strcmp(gridon,'on'))
    set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{3},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{4},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{5},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{6},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
end
set(gcf,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2} datar{3} datar{4} datar{5} datar{6}],'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['Footprint ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function difference(~,~)
global PLOTIMAGE3DDIFFDIAL
if(~isempty(PLOTIMAGE3DDIFFDIAL))
    delete(PLOTIMAGE3DDIFFDIAL);
    PLOTIMAGE3DDIFFDIAL=[];
end
hfigs=getfigs;%get the grouped plotseis3D figures
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
ind=hfigs~=hthisfig;
hotherfigs=hfigs(ind);%other figures in this group
%get this figures info
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
% data=udat{1};
% x=udat{2};
% y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};
nameA=[dname ' ' mode ' ' num2str(thisone)];
%get other figures in group
if(isempty(hotherfigs))
    msgbox('Difference plots require that you have a ''group'' of at least two datasets.','Oops!');
    return
else
    namesB=cell(size(hotherfigs));
    for k=1:length(hotherfigs)
        hprevious=findobj(hotherfigs(k),'tag','previous');
        udat=get(hprevious,'userdata');
        % data=udat{1};
        % x=udat{2};
        % y=udat{3};
        mode=udat{4};
        thisone=udat{5};
        dname=udat{6};
        namesB{k}=[dname ' ' mode ' ' num2str(thisone)];
    end
    
end
%create a dialog
pos=get(hthisfig,'position');
width=pos(3)*.5;
ht=pos(4)*.25;
xnow=pos(1)+.5*(pos(3)-width);
ynow=pos(2)+.5*(pos(4)-ht);
hdial=figure('position',[xnow,ynow,width,ht]);
xnow=.05;ynow=.6;
width=.3;ht=.05;
uicontrol(hdial,'style','text','String',['A: ' nameA],'units','normalized','tag','namea',...
    'position',[xnow,ynow,width,ht],'userdata',hthisfig)
xnow=.4;ynow=.8;
width=.5;ht=.05;
uicontrol(hdial,'style','text','String','Choose dataset B','units','normalized','tag','nameb',...
    'position',[xnow,ynow,width,ht])
ynow=.4;ht=.4;
uicontrol(hdial,'style','listbox','String',namesB,'units','normalized','tag','namesb',...
    'position',[xnow,ynow,width,ht],'userdata',hotherfigs)

xnow=.55;ynow=.1;
width=.2;ht=.2;
hbutgrp=uibuttongroup(hdial,'units','normalized','position',[xnow,ynow,width,ht],'tag','option',...
    'title','Choose subtraction order');
uicontrol(hbutgrp,'style','radio','string','A - B','units','normalized','position',[0,.5,1,.5],...
    'enable','on','tag','AB','backgroundcolor','w');
uicontrol(hbutgrp,'style','radio','string','B - A','units','normalized','position',[0,0,1,.5],...
    'enable','on','tag','BA','backgroundcolor','w');
%do-it button
xnow=.05;
ynow=.2;
width=.1;
ht=.1;
uicontrol(hdial,'style','pushbutton','string','Do it','tag','doit','units','normalized',...
    'position',[xnow,ynow,width,ht],'callback',@differencedoit,...
    'backgroundcolor','c','tooltipstring','Click to create the difference plot of the selected datasets');
%dismiss button
xnow=.05;
ynow=.1;
width=.1;
ht=.1;
uicontrol(hdial,'style','pushbutton','string','Dismiss','tag','dismiss','units','normalized',...
    'position',[xnow,ynow,width,ht],'callback','plotimage3D(''dismissdifference'');',...
    'backgroundcolor','r','tooltipstring','Click to dismiss this dialog');

PLOTIMAGE3DDIFFDIAL=hdial;
%set(hdial,'closerequestfcn','plotimage3D(''dismissdifference'')','name','Plotimage3D Difference Dialog');
winname='Difference dialog';
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);

end

function differencedoit(~,~)
global PLOTIMAGE3DDIFFDIAL NEWFIGVIS
hdial=PLOTIMAGE3DDIFFDIAL;
%determine the A and B datasets
hnamea=findobj(hdial,'tag','namea');
tmp=get(hnamea,'string');
namea=tmp(4:end);
hA=get(hnamea,'userdata');%figure for dataset A
cmap=get(hA,'colormap');
hnamesb=findobj(hdial,'tag','namesb');
namesb=get(hnamesb,'string');
iB=get(hnamesb,'value');
hotherfigs=get(hnamesb,'userdata');
nameb=namesb{iB};
hB=hotherfigs(iB);
%get the two datasets
hprevious=findobj(hA,'tag','previous');
udat=get(hprevious,'userdata');
seisa=udat{1};
xa=udat{2};
ya=udat{3};
modea=udat{4};
hprevious=findobj(hB,'tag','previous');
udat=get(hprevious,'userdata');
seisb=udat{1};
xb=udat{2};
yb=udat{3};
modeb=udat{4};

if(length(xa)~=length(xb) || length(ya)~=length(yb))
    msgbox(['The selected datasets have different sizes and a difference is not possible. '...
        'If the section view is inline or crossline, make sure the tmin and tmax settings are '...
        'the same for both datasets and try again.'],'Oops!');
    return
end

%determine the subtraction order
hab=findobj(hdial,'tag','AB');
order=get(hab,'value');
NEWFIGVIS='off';
if(order==1)
    datar=seisplotdiff(seisa,seisb,ya,xa,namea,nameb);
    dname2=[namea '-' nameb];
else
    datar=seisplotdiff(seisb,seisa,ya,xa,nameb,namea);
    dname2=[nameb '-' namea];
end
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
colormap(cmap)
pos=get(hA,'position');
set(gcf,'position',pos,'visible','on')
%flip axes if needed to match main fig
hseis=findobj(hA,'tag','seismic');
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2} datar{3}],'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['difference ' dname2];
hwin=findobj(hA,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hA);

end

function showtvspectrum(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(gcf,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
t=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};
% get current clim to impose on new display
cl=get(gca,'clim');

switch mode
    case 'inline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];

        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=seisplottvs(data,t,x,dname2,nan,nan);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1})
        xlabel('xline number');
        set(gca,'clim',cl);
        set(gcf,'position',pos,'visible','on');
        
    case 'xline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];

        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=seisplottvs(data,t,x,dname2,nan,nan);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1})
        xlabel('inline number');
        set(gca,'clim',cl);
        set(gcf,'position',pos,'visible','on');
    otherwise
        return;
        
end

%Make entry in windows list and set closerequestfcn
winname=['TVS ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
udat=get(hfig,'userdata');
if(isempty(udat))
    udat=hthisfig;
else
    udat={udat hthisfig};
end
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',udat);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function spdcmp(~,~) %spectral decomp on vertical sections
global NEWFIGVIS SPECDPARMS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
[cmapnow,cmap]=getcolormap; %#ok<ASGLU>
hprevious=findobj(gcf,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
t=udat{3};
mode=udat{4};%inline or xline
thisone=udat{5};%the line number
dname=udat{6};%dataset name
% get current clim to impose on new display
% cl=get(gca,'clim');
dt=abs(t(2)-t(1));
fnyq=.5/dt;
ok=false;
name='SPEC DECOMP parameters';
while ~ok
    %put up a dialog to ask questions
    q={'Gaussian window size','Window increment','Start time','End time','Minimum frequency',...
        'Maximum frequency','Frequency increment'};
    if(isempty(SPECDPARMS))
        a={'0.01',num2str(2*dt),time2str(t(1)),time2str(t(end)),'5',num2str(round(fnyq/2)),'1.0'};
    else
        a=SPECDPARMS;
    end
    tt={'The is the standard deviation in seconds.','Should be much smaller than the window size.',...
        'Beginning analysis time (seconds)','Ending analysis time (seconds)','Lowest frequency (Hz)',...
        'Maximum frequency (Hz)','Frequency increment (Hz)'};
    ansfini=askthingsle('name',name,'questions',q,'answers',a,'tooltips',tt,...
        'masterfig',hthisfig);
    if(isempty(ansfini))
        return
    end
    SPECDPARMS=ansfini;
    twin=str2double(ansfini{1});
    if(isnan(twin))
        ok=false; %#ok<*NASGU>
    elseif(twin<0 || twin>1)
        ok=false;
    else
        ok=true;
    end
    tinc=str2double(ansfini{2});
    if(isnan(tinc))
        ok=false;
    elseif(tinc<0 || tinc>twin)
        ok=false;
    else
        ok=true;
    end
    tmin=str2double(ansfini{3});
    if(isnan(tmin))
        ok=false;
    elseif(tmin<t(1) || tmin>t(end))
        ok=false;
    else
        ok=true;
    end
    tmax=str2double(ansfini{4});
    if(isnan(tmax))
        ok=false;
    elseif(tmax<tmin || tmax>t(end))
        ok=false;
    else
        ok=true;
    end
    fmin=str2double(ansfini{5});
    if(isnan(fmin))
        ok=false;
    elseif(fmin<0 || fmin>fnyq)
        ok=false;
    else
        ok=true;
    end
    fmax=str2double(ansfini{6});
    if(isnan(fmax))
        ok=false;
    elseif(fmax<fmin || fmax>fnyq)
        ok=false;
    else
        ok=true;
    end
    delf=str2double(ansfini{7});
    if(isnan(delf))
        ok=false;
    elseif(delf<0 || delf>(fmax-fmin))
        ok=false;
    else
        ok=true;
    end
    if(~ok)
        name='Bad parameters,try again';
    end
end

%do the spectral decomp
phaseflag=3;
[amp,phs,tsd,fsd]=specdecomp(data,t,twin,tinc,fmin,fmax,delf,tmin,tmax,phaseflag,1,1); %#ok<ASGLU>
%test for cancel
if(isempty(amp))
    return;
end
ind=near(t,tmin,tmax);
switch mode
    case 'inline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=specd_viewer(data(ind,:),amp,t(ind),x,tsd,fsd,dname2,cmap);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1})
        xlabel('xline number');
        axes(datar{2})
        xlabel('xline number');
        set(gcf,'position',pos,'visible','on');
        
    case 'xline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        pos=get(gcf,'position');
        NEWFIGVIS='off';
        datar=specd_viewer(data(ind,:),amp,t(ind),x,tsd,fsd,dname2,cmap);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1})
        xlabel('inline number');
        axes(datar{2})
        xlabel('inline number');
        set(gcf,'position',pos,'visible','on');
    otherwise
        return;
        
end

%Make entry in windows list and set closerequestfcn
winname=['SPECD ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
udat=get(hfig,'userdata');
if(isempty(udat))
    udat=hthisfig;
else
    udat={udat hthisfig};
end
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',udat);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function specdtslice(~,~) %spectral decomp on time slices
global NEWFIGVIS SPECDPARMS SPECDPARMSTS SPECD_TWIN SPECD_TINC SPECD_FMIN SPECD_FMAX SPECD_DELF
global XCFIG YCFIG
%SPECDPARMS is used for sections while SPECDPARMSTS is for time slices
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
[cmapnow,cmap]=getcolormap; %#ok<ASGLU>
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};%tslice
tnow=udat{5};%the current time slice (time of)
dname=udat{6};%dataset name
%get the 3D seismic matrix
hbmap=findobj(hthisfig,'tag','basemap');
udat2=get(hbmap,'userdata');
seiss=udat2{1};
t=udat2{2};
% get current clim to impose on new display
% cl=get(gca,'clim');
dt=abs(t(2)-t(1));
fnyq=.5/dt;
ok=false;
name='SPEC DECOMP parameters';
while ~ok
    %put up a dialog to ask questions
    q={'Gaussian window size','Window increment','Time zone half-width','Minimum frequency',...
        'Maximum frequency','Frequency increment'};
    if(isempty(SPECDPARMSTS))
        if(isempty(SPECDPARMS))
            a={'0.01',num2str(2*dt),time2str(.050),'5',num2str(round(fnyq/2)),'5.0'};
        else
            a={SPECDPARMS{1}, SPECDPARMS{2}, time2str(.050), SPECDPARMS{5} SPECDPARMS{6} SPECDPARMS{7}};
        end
    else
        a=SPECDPARMSTS;
    end
    tt={'The is the standard deviation in seconds.','Should be much smaller than the window size.',...
        'The SpecD will extend this far above and below the present time (seconds)',...
        'Lowest frequency (Hz)','Maximum frequency (Hz)','Frequency increment (Hz)'};
    ansfini=askthingsle('name',name,'questions',q,'answers',a,'tooltips',tt,...
        'masterfig',hthisfig);
    if(isempty(ansfini))
        return
    end
    SPECDPARMSTS=ansfini;
    twin=str2double(ansfini{1});
    if(isnan(twin))
        ok=false; %#ok<*NASGU>
    elseif(twin<0 || twin>1)
        ok=false;
    else
        ok=true;
    end
    tinc=str2double(ansfini{2});
    if(isnan(tinc))
        ok=false;
    elseif(tinc<0 || tinc>twin)
        ok=false;
    else
        ok=true;
    end
    delT=str2double(ansfini{3});
    if(isnan(delT))
        ok=false;
    elseif(tnow-delT<t(1) || tnow+delT>t(end))
        ok=false;
    else
        ok=true;
    end
    fmin=str2double(ansfini{4});
    if(isnan(fmin))
        ok=false;
    elseif(fmin<0 || fmin>fnyq)
        ok=false;
    else
        ok=true;
    end
    fmax=str2double(ansfini{5});
    if(isnan(fmax))
        ok=false;
    elseif(fmax<fmin || fmax>fnyq)
        ok=false;
    else
        ok=true;
    end
    delf=str2double(ansfini{6});
    if(isnan(delf))
        ok=false;
    elseif(delf<0 || delf>(fmax-fmin))
        ok=false;
    else
        ok=true;
    end
    if(~ok)
        name='Bad parameters,try again';
    end
end

%set globals, these are picked up by seisplot_specdtslice
SPECD_TWIN=twin;
SPECD_TINC=tinc;
SPECD_FMIN=fmin;
SPECD_FMAX=fmax;
SPECD_DELF=delf;

%define time range
ind=near(t,tnow-delT,tnow+delT);

%Call seisplot_specdtslice
dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(tnow)];
pos=get(hthisfig,'position');
XCFIG=pos(1)+.5*pos(3);
YCFIG=pos(2)+.5*pos(4);
hseismic=findobj(hthisfig,'tag','seismic');
xdir=get(hseismic,'xdir');
ydir=get(hseismic,'ydir');
xg=get(hseismic,'xgrid');
yg=get(hseismic,'ygrid');
ga=get(hseismic,'gridalpha');
gc=get(hseismic,'gridcolor');
NEWFIGVIS='off';
datar=seisplot_specdtslice(seiss(ind,:,:),t(ind),x,y,dname2);
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
axes(datar{1})
xlabel('xline number');ylabel('inline number');
set(gca,'xdir',xdir,'ydir',ydir);
set(gca,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
axes(datar{2})
xlabel('xline number');ylabel('inline number');
set(gca,'xdir',xdir,'ydir',ydir);
set(gca,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
set(gcf,'position',pos,'visible','on');

%Make entry in windows list and set closerequestfcn
winname=['SPECD ' mode ' ' num2str(tnow)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
udat=get(hfig,'userdata');
if(isempty(udat))
    udat=hthisfig;
else
    udat={udat hthisfig};
end
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',udat);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function fdomtslice(~,~) %spectral decomp on time slices
global FDOMPARMSTS FDOM_TWIN FDOM_TINC FDOM_FMAX FDOM_TFMAX
global XCFIG YCFIG
%SPECDPARMS is used for sections while SPECDPARMSTS is for time slices
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
[cmapnow,cmap]=getcolormap; %#ok<ASGLU>
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};%tslice
tnow=udat{5};%the current time slice (time of)
dname=udat{6};%dataset name
%get the 3D seismic matrix
hbmap=findobj(hthisfig,'tag','basemap');
udat2=get(hbmap,'userdata');
seiss=udat2{1};
t=udat2{2};
% get current clim to impose on new display
% cl=get(gca,'clim');
dt=abs(t(2)-t(1));
fnyq=.5/dt;
ok=false;
name='FDOM parameters';
while ~ok
    %put up a dialog to ask questions
    q={'Gaussian window size','Window increment','Time zone half-width',...
        'Maximum frequency at Tref','Tref (time of maximum frequency)'};
    if(isempty(FDOMPARMSTS))
            a={'0.01',num2str(2*dt),time2str(.050),num2str(round(fnyq/2)),time2str(tnow)};
    else
        a=FDOMPARMSTS;
    end
    %check the value for tfdom and set to tnow
    a{5}=num2str(tnow);
    tt={'The is the standard deviation in seconds.','Should be much smaller than the window size.',...
        'The Fdom will extend this far above and below the present time (seconds)',...
        'Maximum frequency (Hz) at reference time','Reference time for Fmax (seconds)'};
    ansfini=askthingsle('name',name,'questions',q,'answers',a,'tooltips',tt,...
        'masterfig',hthisfig);
    if(isempty(ansfini))
        return
    end
    FDOMPARMSTS=ansfini;
    twin=str2double(ansfini{1});
    if(isnan(twin))
        ok=false; %#ok<*NASGU>
    elseif(twin<0 || twin>1)
        ok=false;
    else
        ok=true;
    end
    tinc=str2double(ansfini{2});
    if(isnan(tinc))
        ok=false;
    elseif(tinc<0 || tinc>twin)
        ok=false;
    else
        ok=true;
    end
    delT=str2double(ansfini{3});
    if(isnan(delT))
        ok=false;
    elseif(tnow-delT<t(1) || tnow+delT>t(end))
        ok=false;
    else
        ok=true;
    end
    fmax=str2double(ansfini{4});
    if(isnan(fmax))
        ok=false;
    elseif(fmax<0 || fmax>fnyq)
        ok=false;
    else
        ok=true;
    end
    tfmax=str2double(ansfini{5});
    if(isnan(tfmax))
        ok=false;
    elseif(tfmax<t(1) || tfmax>t(end))
        ok=false;
    else
        ok=true;
    end
    if(~ok)
        name='Bad parameters,try again';
    end
end

%set globals, these are picked up by seisplot_fdomtslice
FDOM_TWIN=twin;
FDOM_TINC=tinc;
FDOM_FMAX=fmax;
FDOM_TFMAX=tfmax;

%define time range
ind=near(t,tnow-delT,tnow+delT);

%Call seisplot_fdomtslice
dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(tnow)];
pos=get(hthisfig,'position');
XCFIG=pos(1)+.5*pos(3);
YCFIG=pos(2)+.5*pos(4);
hseismic=findobj(hthisfig,'tag','seismic');
xdir=get(hseismic,'xdir');
ydir=get(hseismic,'ydir');
xg=get(hseismic,'xgrid');
yg=get(hseismic,'ygrid');
ga=get(hseismic,'gridalpha');
gc=get(hseismic,'gridcolor');

datar=seisplot_fdomtslice(seiss(ind,:,:),t(ind),x,y,dname2);

hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
axes(datar{1})
xlabel('xline number');ylabel('inline number');
set(gca,'xdir',xdir,'ydir',ydir);
set(gca,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
axes(datar{2})
xlabel('xline number');ylabel('inline number');
set(gca,'xdir',xdir,'ydir',ydir);
set(gca,'xgrid',xg,'ygrid',yg,'gridalpha',ga,'gridcolor',gc);
set(gcf,'position',pos,'visible','on');

%Make entry in windows list and set closerequestfcn
winname=['FDOM ' mode ' ' num2str(tnow)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
currentfigs=get(hwin,'userdata');
if(ischar(currentwindows))
    currentwindows={currentwindows};
end
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
udat=get(hfig,'userdata');
if(isempty(udat))
    udat=hthisfig;
else
    udat={udat hthisfig};
end
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',udat);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function showtvphase(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
t=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

switch mode
    case 'inline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];

        pos=get(gcf,'position');
        NEWFIGVIS='off';
        haxes=seisplotphase(data,t,x,nan,nan,nan,20,dname2);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(haxes{1})
        xlabel('xline number');
        axes(haxes{4})
        xlabel('xline number');
        set(gcf,'position',pos,'visible','on');
        
    case 'xline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];

        pos=get(gcf,'position');
        NEWFIGVIS='off';
        haxes=seisplotphase(data,t,x,nan,nan,nan,20,dname2);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(haxes{1})
        xlabel('inline number');
        axes(haxes{4})
        xlabel('inline number');
        set(gcf,'position',pos,'visible','on');
    otherwise
        return;
        
end
%Make entry in windows list and set closerequestfcn
winname=['tv phase ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function showfxphase(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
thistag=get(gcf,'tag');
udat=get(hprevious,'userdata');
seis=udat{1};
x=udat{2};
t=udat{3};
mode=udat{4};
thisone=udat{5};%line number
dname=udat{6};
% get current clim to impose on new display
cl=get(gca,'clim');
fmax=nan;
%cmap=get(gcf,'colormap');
switch mode
    case 'inline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        pos=get(gcf,'position');
        flag=1;
        xname='xline';
        NEWFIGVIS='off';
        datar=seisplotfx(seis,t,x,dname2,nan,nan,fmax,xname,flag);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1});
        xlabel('xline number');
        set(gca,'clim',cl);
        set(gcf,'position',pos,'visible','on');
        
    case 'xline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];

        pos=get(gcf,'position');
        flag=1;
        xname='iline';
        NEWFIGVIS='off';
        datar=seisplotfx(seis,t,x,dname2,nan,nan,fmax,xname,flag);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1})
        xlabel('inline number');
        set(gca,'clim',cl);
        set(gcf,'position',pos,'visible','on');
        %colormap(cmap);
        
    otherwise
        return;
        
end

set(gcf,'tag',thistag);%this means that if pi3D window is 'fromsane' then so will be this window

%Make entry in windows list and set closerequestfcn
winname=['fx phase ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
udat=get(hfig,'userdata');
if(isempty(udat))
    udat=hthisfig;
else
    udat={udat hthisfig};
end
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',udat);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function showfxamp(~,~)
global NEWFIGVIS
hthisfig=gcf;%the pifig
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
thistag=get(gcf,'tag');
udat=get(hprevious,'userdata');
seis=udat{1};
x=udat{2};
t=udat{3};
mode=udat{4};
thisone=udat{5};%line number
dname=udat{6};
% get current clim to impose on new display
cl=get(gca,'clim');
fmax=nan;
%cmap=get(gcf,'colormap');
switch mode
    case 'inline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];
        pos=get(gcf,'position');
        flag=0;
        xname='xline';
        NEWFIGVIS='off';
        datar=seisplotfx(seis,t,x,dname2,nan,nan,fmax,xname,flag);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1});
        xlabel('xline number');
        set(gca,'clim',cl);
        set(gcf,'position',pos,'visible','on');
        %colormap(cmap)
    case 'xline'
        dname2=[strrep(dname,'plotimage3D ... ','') ' ' mode ' ' num2str(thisone)];

        pos=get(gcf,'position');
        flag=0;
        xname='iline';
        NEWFIGVIS='off';
        datar=seisplotfx(seis,t,x,dname2,nan,nan,fmax,xname,flag);
        NEWFIGVIS='on';
        hppt=addpptbutton([.95,.95,.025,.025]);
        set(hppt,'userdata',dname2);
        axes(datar{1})
        xlabel('inline number');
        set(gca,'clim',cl);
        set(gcf,'position',pos,'visible','on');
        %colormap(cmap)
    otherwise
        return;
        
end

set(gcf,'tag',thistag);%this means that if pi3D window is 'fromsane' then so will be this window

%Make entry in windows list and set closerequestfcn
winname=['fx amplitude ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
udat=get(hfig,'userdata');
if(isempty(udat))
    udat=hthisfig;
else
    udat={udat hthisfig};
end
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',udat);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function deconvolution(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

dname2=[strrep(dname,'plotimage3D ... ',''), [' ' mode ' ' num2str(thisone)]];
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
NEWFIGVIS='off';
datar=seisplotdecon(data,y,x,dname2);
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
colormap(cmap);
if(strcmp(gridon,'on'))
    set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
end
set(gcf,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2}],'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['Spiking decon ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
crf=get(hfig,'closerequestfcn');
set(hfig,'closerequestfcn',[crf 'plotimage3D(''closewindow'');'],'userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

%Gabor decon
function gabdec(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

dname2=[strrep(dname,'plotimage3D ... ',''), [' ' mode ' ' num2str(thisone)]];
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
NEWFIGVIS='off';
datar=seisplotgabdecon(data,y,x,dname2);
NEWFIGVIS='on';
hfig=gcf;
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
colormap(cmap);
if(strcmp(gridon,'on'))
    set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
end
set(hfig,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2}],'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['Gabor decon ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');

currentwindows=get(hwin,'string');
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
crf=get(hfig,'closerequestfcn');
set(hfig,'closerequestfcn',[crf 'plotimage3D(''closewindow'');'],'userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function dominentfreq(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
t=udat{3};
dt=t(2)-t(1);
fnyq=.5/dt;
mode=udat{4};
thisone=udat{5};
dname=udat{6};

%ask for time window
q={'Start time (sec)','End time (sec)'};
a={time2str(t(1)), time2str(t(end))};
a=askthingsle('name','Define time limits','questions',q,'answers',a);
if(isempty(a))
    return;
else
    tmin=str2double(a{1});
    tmax=str2double(a{2});
    if(isnan(tmin)||isnan(tmax))
        msgbox('Bad values, try again');
        return;
    end
    if(tmin>tmax)
        msgbox('Start time must be less the End time!, Try again');
        return;
    end
    if(tmin<t(1))
        tmin=t(1);
    end
    if(tmin>t(end))
        tmin=t(end);
    end
end
indt=near(t,tmin,tmax);

dname2=[strrep(dname,'plotimage3D ... ',''), [' ' mode ' ' num2str(thisone)]];
[colormapnow,cmap]=getcolormap; %#ok<ASGLU>
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
%datar=seisplotfilt(data,t,x,dname2);
twin=5*dt;
tinc=2*dt;
fmt0=[.5*fnyq,mean(t)];
NEWFIGVIS='off';
datar=seisplotfdom(data(indt,:),t(indt),x,twin,tinc,fmt0,dname2,cmap);
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
if(strcmp(gridon,'on'))
    set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
end
set(gcf,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2}],'xdir',xdir,'ydir',ydir)
%make the axes name agree with the main figure
xname=get(get(hseis,'xlabel'),'string');
yname=get(get(hseis,'ylabel'),'string');
axes(datar{1});xlabel(xname);ylabel(yname);
axes(datar{2});xlabel(xname);ylabel(yname);

%Make entry in windows list and set closerequestfcn
winname=['Dominent freq ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function filter(~,~)
global NEWFIGVIS
hthisfig=gcf;
if(strcmp(get(hthisfig,'tag'),'fromsane'))
    fromsane=true;
    ud=get(hthisfig,'userdata');
    hsane=ud{2};
else
    fromsane=false;
end
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
x=udat{2};
y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

dname2=[strrep(dname,'plotimage3D ... ',''), [' ' mode ' ' num2str(thisone)]];
cmap=get(hthisfig,'colormap');
hseis=findobj(hthisfig,'tag','seismic');
gridon=get(hseis,'xgrid');
gridcolor=get(hseis,'gridcolor');
gridalpha=get(hseis,'gridalpha');
pos=get(hthisfig,'position');
NEWFIGVIS='off';
datar=seisplotfilt(data,y,x,dname2);
NEWFIGVIS='on';
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);
colormap(cmap);
if(strcmp(gridon,'on'))
    set(datar{1},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
    set(datar{2},'xgrid',gridon,'ygrid',gridon,'gridcolor',gridcolor,'gridalpha',gridalpha);
end
set(gcf,'position',pos,'visible','on');
%flip axes if needed to match main fig
xdir=get(hseis,'xdir');
ydir=get(hseis,'ydir');
set([datar{1} datar{2}],'xdir',xdir,'ydir',ydir)

%Make entry in windows list and set closerequestfcn
winname=['Bandpass filter ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);
if(fromsane)
    %the only purpose of this is to store the sane figure handle
    uicontrol(hfig,'style','text','units','normalized','position',[0 0 .1 .1],'visible','off',...
        'tag','fromsane','userdata',hsane);
end
end

function amphist(~,~)
hthisfig=gcf;
hprevious=findobj(hthisfig,'tag','previous');
udat=get(hprevious,'userdata');
data=udat{1};
% x=udat{2};
% y=udat{3};
mode=udat{4};
thisone=udat{5};
dname=udat{6};

dname2=[strrep(dname,'plotimage3D ... ',''), [' ' mode ' ' num2str(thisone)]];

pos=get(hthisfig,'position');

inonzero= data~=0.0;

figure('position',[pos(1:2) .5*pos(3) .5*pos(4)]);
hist(data(inonzero),200);
xlabel('amplitude');ylabel('number of samples');
ht=title(['Amplitude histogram for ' dname2]);
ht.Interpreter='none';
grid
hppt=addpptbutton([.95,.95,.025,.025]);
set(hppt,'userdata',dname2);

%Make entry in windows list and set closerequestfcn
winname=['Amp histogram ' mode ' ' num2str(thisone)];
hwin=findobj(hthisfig,'tag','windows');
hfig=gcf;
currentwindows=get(hwin,'string');
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
set(hfig,'closerequestfcn','plotimage3D(''closewindow'')','userdata',hthisfig);

end

function tmin=get_tmin
htmin=findobj(gcf,'tag','tmin');
ival=get(htmin,'value');
tmins=get(htmin,'string');
tmin=str2double(tmins{ival});
end

function tmax=get_tmax
htmax=findobj(gcf,'tag','tmax');
ival=get(htmax,'value');
tmaxs=get(htmax,'string');
if(ival<=length(tmaxs))
    tmax=str2double(tmaxs{ival});
else
    tmax=str2double(tmaxs{end});
end
end

function flag=issane
%This function determines if the current figure was created by sane or not and returns a logical flag 
tag=get(gcf,'tag');
flag=false;
if(strcmp(tag,'fromsane'))
    udat=get(gcf,'userdata');
    if(iscell(udat))
        if(length(udat)==2)
            if(isgraphics(udat{2}))
                flag=true;
            end
        end
    end
end

end

function sd=sanedata
%this is used to communicate with SANE. When sane launches a plotimage3d
%window, it puts information in the userdata of the plotimage3D figure that
%is required for sane to know which dataset is sending the message. This
%function retrieves that data to send back to sane.
sd=get(gcf,'userdata');
end