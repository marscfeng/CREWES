function datar=seisplottwo(seis1,t1,x1,dname1,seis2,t2,x2,dname2)
% SEISPLOTTWO: plots two seismic gathers side-by-side in separate axes
%
% datar=seisplottwo(seis1,t1,x1,dname1,seis2,t2,x2,dname2)
%
% A new figure is created and divided into two same-sized axes (side-by-side). The first
% seismic gather is platted as an image in the left-hand-side and the second seismic gather is
% plotted as an image in the right-hand-side. Controls are provided to adjust the clipping and
% to brighten or darken the image plots. The data should be regularly sampled in both t and x.
%
% seis1 ... first seismic matrix
% t1 ... time coordinate vector for seis1
% x1 ... space coordinate vector for seis1
% dname1 ... text string nameing the first seismic matrix. Enter [] or '' for no name.
% seis2 ... second seismic matrix
% t2 ... time coordinate vector for seis2
% x2 ... space coordinate vector for seis2
% dname2 ... text string nameing the first seismic matrix. Enter [] or '' for no name.
%
% datar ... Return data which is a length 2 cell array containing
%           data{1} ... handle of the first seismic axes
%           data{2} ... handle of the second seismic axes
% These return data are provided to simplify plotting additional lines and
% text in either axes.
% 
% G.F. Margrave, Devon, 2017
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

if(~ischar(seis1))
    action='init';
else
    action=seis1;
end

datar=[];%initialize return data to null

if(strcmp(action,'init'))
    
    if(nargin==2)
        seis2=t1;
        t1=(0:size(seis1,1)-1)';
        x1=(0:size(seis1,2)-1);
        t2=(0:size(seis2,1)-1)';
        x2=(0:size(seis2,2)-1);
        dname1=[];
        dname2=[];
    end
    
    
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
    
    if(nargin<7)
        dname1=[];
    end
    if(nargin<8)
        dname2=[];
    end

    xwid=.35;
    yht=.8;
    xsep=.1;
    xnot=.1;
    ynot=.1;
    

    figure
    hax1=subplot('position',[xnot ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis1);
    clim=[am-clip*sigma am+clip*sigma];
        
    imagesc(x1,t1,seis1,clim);colormap(seisclrs)
    brighten(.5);
    grid
    title(dname1,'interprete','none')
    maxmeters=7000;
    if(max(t1)<10)
        ylabel('time (s)')
    elseif(max(t1)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('depth (ft)')
    end
    if(max(x1)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    %make a clip control

    xnow=xnot+xwid;
    wid=.055;ht=.05;sep=.005;
    ynow=ynot+yht-ht;
    clipinfo1={clips,am,sigma,amax,amin,hax1};
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip1','units','normalized',...
        'position',[xnow,ynow,1.2*wid,ht],'callback','seisplottwo(''clip1'')','value',iclip,...
        'userdata',clipinfo1,'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    
    ht=.5*ht;
    ynow=ynow-sep;
    uicontrol(gcf,'style','pushbutton','string','brighten','tag','brighten','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottwo(''brighten'')',...
        'tooltipstring','push once or multiple times to brighten the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','pushbutton','string','darken','tag','darken','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','seisplottwo(''brighten'')',...
        'tooltipstring','push once or multiple times to darken the images');
    ynow=ynow-ht-sep;
    uicontrol(gcf,'style','text','string','lvl 0','tag','brightness','units','normalized',...
        'position',[xnow,ynow,wid,ht],...
        'tooltipstring','image brightness (both images)','userdata',0);
    ynow=ynow-ht-sep;
    ampchoices={'Amp independent','#1 is master','#2 is master'};
    hamp=uicontrol(gcf,'style','popupmenu','string',ampchoices,'tag','ampcontrol','units','normalized',...
        'position',[xnow,ynow,1.2*wid,ht],'callback','seisplottwo(''ampcontrol'')','value',1);
    
    set(hax1,'tag','seis1');
    
    hax2=subplot('position',[xnot+xwid+xsep ynot xwid yht]);

    [clips,clipstr,clip,iclip,sigma,am,amax,amin]=getclips(seis2);

    %clim=[amin am+clip*sigma];
    clim=[am-clip*sigma am+clip*sigma];
        
    imagesc(x2,t2,seis2,clim);colormap(seisclrs)
    brighten(.5);
    grid
    title(dname2,'interprete','none')
    
    if(max(t2)<10)
        ylabel('time (s)')
    elseif(max(t2)<maxmeters)
        ylabel('depth (m)')
    else
        ylabel('(depth (ft)')
    end
    if(max(x2)<maxmeters)
        xlabel('distance (m)')
    else
        xlabel('distance (ft)')
    end
    %make a clip control

    xnow=xnot+2*xwid+xsep;
    ht=.05;
    ynow=ynot+yht-ht;
    %wid=.045;sep=.005;
    clipinfo2={clips,am,sigma,amax,amin,hax2};
    uicontrol(gcf,'style','popupmenu','string',clipstr,'tag','clip2','units','normalized',...
        'position',[xnow,ynow,1.2*wid,ht],'callback','seisplottwo(''clip2'')','value',iclip,...
        'userdata',clipinfo2,'tooltipstring',...
        'clip level is the number of standard deviations from the mean at which amplitudes are clipped')
    ynow=ynow-.5*ht;
    uicontrol(gcf,'style','pushbutton','string','Ave. Amp. Spectra','tag','aveamp','units','normalized',...
        'position',[xnow,ynow,wid,.5*ht],'callback','seisplottwo(''aveamp'');','tooltipstring',...
        'Compare the average amplitude spectra');
    
    %zoom buttons
    wid=.1;
    pos=get(hax1,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    ynow=.97;
    uicontrol(gcf,'style','pushbutton','string','Zoom #1 like #2','units','normalized',...
        'position',[xnow ynow wid .5*ht],'tag','1like2','callback','seisplottwo(''equalzoom'');');
    
    pos=get(hax2,'position');
    xnow=pos(1)+.5*pos(3)-.5*wid;
    uicontrol(gcf,'style','pushbutton','string','Zoom #2 like #1','units','normalized',...
        'position',[xnow ynow wid .5*ht],'tag','2like1','callback','seisplottwo(''equalzoom'');');
    
    set(hamp,'userdata',{clipinfo1 clipinfo2});
    
    bigfig; %enlarge the figure to get more pixels
    bigfont(gcf,1.6,1); %enlarge the fonts in the figure
    boldlines(gcf,4,2); %make lines and symbols "fatter"
    whitefig;
    
    set(hax2,'tag','seis2');
    if(iscell(dname1))
        dn1=dname1{1};
    else
        dn1=dname1;
    end
    if(iscell(dname2))
        dn2=dname2{1};
    else
        dn2=dname2;
    end
    set(gcf,'name',['Compare ' dn1 ' & ' dn2],'closerequestfcn','seisplottwo(''close'');');
    if(nargout>0)
        datar=cell(1,2);
        datar{1}=hax1;
        datar{2}=hax2;
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
    hax=udat{6};
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
    amax=udat{4};
    amin=udat{5};
    sigma=udat{3};
    hax=udat{6};
    if(iclip==1)
        %clim=[amin amax];
        clim=[amin amax];
    else
        clip=clips(iclip-1);
        clim=[am-clip*sigma,am+clip*sigma];
        %clim=[amin am+clip*sigma];
    end
    set(hax,'clim',clim);
elseif(strcmp(action,'ampcontrol'))
    hamp=gcbo;
    clipinfo=get(hamp,'userdata');
    c1=clipinfo{1};
    c2=clipinfo{2};
    mode=get(hamp,'value');
    hclip1=findobj(gcf,'tag','clip1');
    hclip2=findobj(gcf,'tag','clip2');
    switch mode
        case 1
            set(hclip1,'userdata',c1);
            set(hclip2,'userdata',c2);
        case 2
            hax2=c2{6};
            c2=c1;
            c2{6}=hax2;
            set(hclip1,'userdata',c1);
            set(hclip2,'userdata',c2);
        case 3
            hax1=c1{6};
            c1=c2;
            c1{6}=hax1;
            set(hclip1,'userdata',c1);
            set(hclip2,'userdata',c2);
    end
    seisplottwo('clip1');
    seisplottwo('clip2');
    
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
elseif(strcmp(action,'aveamp')||strcmp(action,'spectra'))
%     %ask for time zone
%     hseis1=findobj(gcf,'tag','seis1');
%     hi1=findobj(hseis1,'type','image');
%     t1=get(hi1,'ydata');
%     %yl=get(hseis1,'ylim');
%     tbeg=t1(1);
%     tend=t1(end);
%     prompt={'Start of time window (sec)','End of time window (sec)'};
%     numlines=1;
%     defaultans={time2str(tbeg), time2str(tend)};
%     name='Specify time window for spectra';
%     answer=inputdlg(prompt,name,numlines,defaultans);
%     if(isempty(answer))
%         return
%     end
%     tbeg=str2double(answer{1});
%     tend=str2double(answer{2});
%     doover=false;
%     if(isnan(tbeg) || isnan(tend) || tbeg<t1(1) || tend>t1(end) || tbeg>tend)
%         doover=true;
%     end
%     while doover
%         name='Something is worng with your values';
%         defaultans=answer;
%         answer=inputdlg(prompt,name,numlines,defaultans);
%         if(isempty(answer))
%             return;
%         end
%         tbeg=str2double(answer{1});
%         tend=str2double(answer{2});
%         doover=false;
%         if(isnan(tbeg) || isnan(tend) || tbeg<t1(1) || tend>t1(end) || tbeg>tend)
%             doover=true;
%         end
%     end
%     
%     havespec=findobj(gcf,'tag','aveamp');
%     hprevfig=get(havespec,'userdata');
%     if(isgraphics(hprevfig))
%         delete(hprevfig);
%     end
%     
%     
%     seis1=get(hi1,'cdata');
%     hseis2=findobj(gcf,'tag','seis2');
%     hi2=findobj(hseis2,'type','image');
%     t2=get(hi2,'ydata');
%     seis2=get(hi2,'cdata');
%     
%     [A1,f1]=aveampspec(seis1,t1,tbeg,tend);
%     [A2,f2]=aveampspec(seis2,t2,tbeg,tend);
%     
%     name1=hseis1.Title.String;
%     name2=hseis2.Title.String;
%     
%     Amax=max([max(A1) max(A2)]);
%     
%     pos=get(gcf,'position');
%     hspec=figure;
%     wid=.5*pos(3);ht=.5*pos(4);
%     x0=pos(1)+.5*(pos(3)-wid);
%     y0=pos(2)+.5*(pos(4)-ht);
%     set(hspec,'position',[x0 y0 wid ht]);
%     hh=plot(f1,todb(A1,Amax),f2,todb(A2,Amax));
%     set(hh,'linewidth',2);
%     xlabel('frequency (Hz)');ylabel('decibels')
%     grid;
%     hl=legend(name1,name2,'location','northeast');
%     set(hl,'interpreter','none');
%     title(['Average amplitude spectra for t1=' time2str(tbeg) ' to t2=' time2str(tend)])
%     
%     set(havespec,'userdata',hspec);
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
    hspec=findobj(hmaster,'tag','aveamp');
    hspecwin=get(hspec,'userdata');
    if(isempty(hspecwin))
        %make the spectral window if it does not already exist
        pos=get(hmaster,'position');
        wid=pos(3)*.5;ht=pos(4)*.5;
        x0=pos(1)+pos(3)-wid;y0=pos(2);
        hspecwin=figure('position',[x0,y0,wid,ht],'closerequestfcn','seisplottwo(''closespec'');','userdata',hmaster);
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
            'position',[xnow,ynow,wid,ht],'callback','seisplottwo(''spectra'');','userdata',times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','text','string','tmax:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        times=t(end):-tinc:tinc;
        stimes=num2strcell(times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','popupmenu','string',stimes,'units','normalized','tag','tmax',...
            'position',[xnow,ynow,wid,ht],'callback','seisplottwo(''spectra'');','userdata',times);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','text','string','db range:','units','normalized',...
            'position',[xnow,ynow,wid,ht])
        db=-20:-20:-160;
        idb=near(db,-100);
        dbs=num2strcell(db);
        ynow=ynow-ht-sep;
        uicontrol(gcf,'style','popupmenu','string',dbs,'units','normalized','tag','db','value',idb,...
            'position',[xnow,ynow,wid,ht],'callback','seisplottwo(''spectra'');','userdata',db);
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
    legend('Seis1 (left)','Seis2 (right)'); 
    title(['Average ampltude spectra, tmin=' time2str(tmin) ', tmax=' time2str(tmax)]); 
elseif(strcmp(action,'closespec'))
    hfig=gcf;
    hdaddy=get(hfig,'userdata');
    hspec=findobj(hdaddy,'tag','aveamp');
    set(hspec,'userdata',[]);
    delete(hfig);
    if(isgraphics(hdaddy))
        figure(hdaddy);
    end
elseif(strcmp(action,'close'))
    haveamp=findobj(gcf,'tag','aveamp');
    hspec=get(haveamp,'userdata');
    if(isgraphics(hspec))
        delete(hspec);
    end
    delete(gcf);
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
iclip=iclip(1);
clip=clips(iclip);

end