function SegyTraceInspector(segyfile,hbutton,tmax)
% GUI to inspect single traces in a SEGY file and determine endianness and data format
%
% SegyTraceInspector(segyfile,hbutton)
%
% segyfile ... full fname of file including complete relative path, may also be a SegyFile Object
% hbutton ... handle of a uicontrol into which the most recent choice of endianness and dataformat
%       will be stored in userdata. Will be a cell array of length 3.
% *********** default = [] ************* (none)
% NOTE, if hbutton is provided then the command udat=get(hbutton,'userdata') will return a cell
% array of length 3. udat{1} will be a string either 'b' or 'l' indicating big or
% little endian while udat{2} will be an integer from the list [1 5 6 8 3 2] indicating 
% {'IBM 4 byte','IEEE 4 byte float','IEEE 8 byte float','1-byte integer','2-byte integer','4-byte integer'}
% respectively and ud{3} will be the maximum desired time (could be the phrase 'all' or a number)
% tmax ... initial value for tmax 
% ********* default is 'all' *********

if(isa(segyfile,'SegyFile'))
    sf=segyfile;
    segyfile=sf.FileName;
else
    if(~exist(segyfile,'file'))
        msgbox(['File ' segyfile ' not found']);
        return
    end
    sf=SegyFile(segyfile);
end
if(nargin<2)
    hbutton=[];
elseif(~isgraphics(hbutton))
    error('hbutton is not a valid graphics component');
end

warning off

if(nargin<3)
    tmax='all';
end


if(sf.FormatCode==6)
    sf.FormatCode=1;
end

formatcodes=[1 5 6 8 3 2];
formatnames={'IBM 4 byte','IEEE 4 byte float','IEEE 8 byte float',...
    '1-byte integer','2-byte integer','4-byte integer'};
iformat=find(sf.FormatCode==formatcodes);
if(isempty(iformat))
    msgbox('SegyFile has an unrecognized data format code. Cannot continue');
    return;
end

endianness={'Big endian','Little endian'};
endians={'b','l'};
iend=1;
if(sf.ByteOrder==endians{2})
    iend=2;
end

if(isgraphics(hbutton))
    set(hbutton,'userdata',{endians{iend},formatcodes(iformat),'all'})%last entry is Tmax
end

hcurrentfig=gcf;
pos=get(hcurrentfig,'position');
xc=pos(1)+.5*pos(3);
yc=pos(2)+.5*pos(4);
fight=500;figwid=800;
ii=1;
ind=find(segyfile=='\');
if(~isempty(ind))
    ii=ind(end)+1;
end


%itrace=floor(sf.Trace.TracesInFile/2);
%find a non-zero trace to read
ntr=sf.Trace.TracesInFile;
del=round(ntr/10);%will grab 10 traces
it=1:del:ntr;
s=sf.Trace.read(it,'data');
a=sum(abs(s));
while sum(a)==0
   if(del==1)
        msgbox('dataset appears to be all zero traces');
        return;
   end
   del=max([round(del/2),1]);
   it=1:del:ntr;
   s=sf.Trace.read(it,'data');
   a=sum(abs(s));
end

%itrace=1000;
jj=find(a>0);
itrace=it(jj(1));

st=sf.Trace.read(itrace,'data');
dt=single(sf.Trace.SampleInterval)/1000000;
t=dt*(0:length(st)-1)';
[SF,f]=fftrl(st,t);

hfig=figure('visible','off','position',[xc-figwid*.5,yc-fight*.5,figwid,fight],'CloseRequestFcn',...
    @dismiss,'menubar','none','toolbar','none','numbertitle','off',...
    'name',['SegyTraceInspector for ' segyfile(ii:end)]);
ysep=.025;
xsep=.01;
x0=.1;
y0=.1;
axwid=1-2*x0;
axht=(1-2*y0-2*ysep)/3;
axes('units','normalized','position',[x0,y0+2*(axht+ysep),axwid,axht]);
plot(t,st);xlabel('seconds');
xlim([t(1) t(end)]);
grid
titlein('Trace display');
set(gca,'xaxislocation','top','tag','traceax');

axes('units','normalized','position',[x0,y0+axht,axwid,axht],'tag','spectra');
plot(f,abs(SF));xlabel('Hertz');
xlim([f(1) f(end)])
grid
titlein('Spectrum');
set(gca,'tag','spectra','yaxislocation','right')

uicontrol(hfig,'style','text','string','','tag','message','units','normalized','position',...
    [x0+xsep,y0+2*axht,axwid-2*xsep,2*ysep],'fontsize',10,'foregroundcolor','r');

ht=(axht-3*ysep)/3;
ynow=y0+ht;
xnow=x0;
wid=(axwid-4*xsep)/6;
uicontrol(hfig,'style','text','string','Trace #','units','normalized',...
    'position',[xnow,ynow,.5*wid,ht],'horizontalalignment','right');
xnow=xnow+.5*wid+xsep;
uicontrol(hfig,'style','edit','string',num2str(itrace),'units','normalized','position',...
    [xnow,ynow+.25*ht,wid,ht],'callback',@newtrace,...
    'tooltipstring',['Enter an integer between 1 and ' int2str(sf.Trace.TracesInFile)],...
    'tag','trace','userdata',hbutton);
xnow=xnow+2*wid+xsep;
uicontrol(hfig,'style','text','String','Byte Order','units','normalized','position',...
    [xnow,ynow+.6*ht,wid,ht]);
uicontrol(hfig,'style','popupmenu','string',endianness,'units','normalized','position',...
    [xnow,ynow,wid,ht],'value',iend,'tooltipstring','Choose byte order',...
    'tag','endian','callback',@newtrace,'userdata',endians);
xnow=xnow+2*wid+xsep;
uicontrol(hfig,'style','text','String','Maximum time','units','normalized','position',...
    [xnow,ynow+.6*ht,wid,ht]);
if(~ischar(tmax))
    tmax=num2str(tmax);
end
uicontrol(hfig,'style','edit','string',tmax,'units','normalized','position',...
    [xnow,ynow,wid,ht],'value',iend,'tooltipstring','Enter max time in seconds',...
    'tag','tmax','callback',@newtrace);
ynow=.5*y0;
xnow=x0+.5*wid+xsep;
uicontrol(hfig,'style','pushbutton','string','Dismiss','units','normalized','tag','dismiss',...
    'position',[xnow,ynow,wid,ht],'callback',@dismiss,'userdata',sf);
xnow=xnow+2*wid+xsep;
uicontrol(hfig,'style','text','String','Data Format','units','normalized','position',...
    [xnow,ynow+.6*ht,wid,ht]);
uicontrol(hfig,'style','popupmenu','string',formatnames,'units','normalized','tag','format',...
    'position',[xnow,ynow,wid,ht],'callback',@newtrace,'value',iformat,'userdata',formatcodes,...
    'tooltipstring','Choose data format');
if(isgraphics(hbutton))
    uicontrol(hfig,'style','text','string',...
        'WARNING: The final state of this figure determines byte order, data format, and trace length for your data.',...
        'units','normalized','position',[x0,0,.9,.5*ht],'foregroundcolor','r','fontweight','bold',...
        'fontsize',10)
end
newtrace;
set(hfig,'visible','on');
end

function newtrace(~,~)
    hdiss=findobj(gcf,'tag','dismiss');
    sf=get(hdiss,'userdata');
    ntr=sf.Trace.TracesInFile;
    %get trace number
    htr=findobj(gcf,'tag','trace');
    hbutton=get(htr,'userdata');
    hmsg=findobj(gcf,'tag','message');
    val=get(htr,'string');
    itrace=str2double(val);
    if(isnan(itrace))
        itrace=floor(ntr/2);
        set(htr,'string',int2str(itrace));
        set(hmsg,'string','Trace number invalid, chosing central trace');
    elseif(itrace<1 || itrace>ntr)
        itrace=floor(ntr/2);
        set(htr,'string',int2str(itrace));
        set(hmsg,'string','trace number too large, showing central trace');
    else
        set(hmsg,'string',['Showing trace number ' int2str(itrace) ' out of ' int2str(ntr)]);
    end
    %get endian code
    hend=findobj(gcf,'tag','endian');
    iend=get(hend,'value');
    endians=get(hend,'userdata');
    sf.ByteOrder=endians{iend};
    %get format code
    hformat=findobj(gcf,'tag','format');
    iformat=get(hformat,'value');
    formatcodes=get(hformat,'userdata');
    sf.FormatCode=formatcodes(iformat);
    %get tmax
    htmax=findobj(gcf,'tag','tmax');
    val=get(htmax,'string');
    tmax=str2double(val);
    if(isnan(tmax))
        tmax=1000;
        set(htmax,'string','all');
    end
    %read trace
    st0=sf.Trace.read(itrace,'data');
    dt=single(sf.Trace.SampleInterval)/1000000;
    t0=dt*(0:length(st0)-1)';
    it=near(t0,0,tmax);
    t=t0(it);
    st=st0(it);
    
    [SF,f]=fftrl(st,t);
    %update button
    if(isgraphics(hbutton))
        if(length(st0)==length(st))
            set(hbutton,'userdata',{endians{iend},formatcodes(iformat),'all'}); 
        else
            set(hbutton,'userdata',{endians{iend},formatcodes(iformat),tmax}); 
        end
    end
    %plot
    htraceax=findobj(gcf,'tag','traceax');
%     htr=findobj(htraceax,'type','line');
%     set(htr,'ydata',st);
    axes(htraceax);
    plot(t,st);xlabel('seconds');
    xlim([0 t(end)])
    grid
    titlein('Trace display');
    set(gca,'xaxislocation','top','tag','traceax');
    %spectra
    hspectra=findobj(gcf,'tag','spectra');
    axes(hspectra)
    plot(f,abs(SF));xlabel('Hertz')
    grid
    titlein('Spectrum');
    set(gca,'tag','spectra','yaxislocation','right');
    
%     htr=findobj(hspectra,'type','line');
%     set(htr,'ydata',abs(sf));
    
end
    
function dismiss(~,~)
%     global SEGYTI_ENDIAN SEGYTI_FORMATCODE
%     %get endian code
%     hend=findobj(gcf,'tag','endian');
%     iend=get(hend,'value');
%     endians=get(hend,'userdata');
%     SEGYTI_ENDIAN=endians{iend};
%     %get format code
%     hformat=findobj(gcf,'tag','format');
%     iformat=get(hformat,'value');
%     formatcodes=get(hformat,'userdata');
%     SEGYTI_FORMATCODE=formatcodes(iformat);
    delete(gcf)
end