function viewtextheader(arg1,dname)
% 
% viewtextheader(texthdr,dname)
%        or
% viewtextheader(SegyFileObj,dname)
%
% texthdr ... the text header as a character matrix
% SegyFileObj ... a SegyFile object
% dname ... name of the dataset (used to annotate the display)
% ********** default = '' *********
%
%

if(isa(arg1,'SegyFile'))
    texthdr=arg1.TextHeader.read;
else
   texthdr=arg1; 
end

if(nargin<2)
    dname='';
end

ss=get(0,'screensize');

% nlines=40;
fs=8;
% pixperline=10*fs/8;
% fight=nlines*pixperline;%figure height
ynot=100;
figwd=600;
fight=ss(4)-ynot-50;

hfig=figure('menubar','none','toolbar','none','numbertitle','off');
%pos=hfig.Position;
xnot=200;
hfig.Position=[xnot ynot figwd fight];
uicontrol(hfig,'style','listbox','string',texthdr,'units','normalized','position',[.1 .05 .8 .8],...
    'horizontalalignment','left','fontsize',fs);

if(~isempty(dname))
    set(gcf,'name',['SEGY Text header for ',dname]);
else
    set(gcf,'name','SEGY Text header');
end

