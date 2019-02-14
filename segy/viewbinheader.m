function viewbinheader(binhdr,msg)
% VIEWBINHDR: Put up a GUI to browse SEGY binary header
%
% viewbinhdr(binhdr,msg)
%
% binhdr ... binary header structure as returned from SegyFile or readsegy.
% msg ... text message to display at the top of the window
% ************ default '' *************
%
% G.F. Margrave, CREWES, 2017
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
% 
if(~ischar(binhdr))
    action='init';
else
    action=binhdr;
end

if(strcmp(action,'init'))
    
    if(nargin<2)
        msg='';
    end
    
    fn=fieldnames(binhdr);
    
    nfields=length(fn);
    
    data=cell(nfields,2);
    for k=1:nfields
        data{k,2}=binhdr.(fn{k});
        data{k,1}=fn{k};
    end
    
    
    
    hf=figure;
    pos=get(hf,'position');
    figwid=300;
    fight=600;
    
    set(hf,'name','Binary Header Viewer','numbertitle','off','menubar','none','toolbar','none',...
        'position',[pos(1), 200, figwid fight]);
    %'position',[pos(1)+.5*(pos(3)-figwid), pos(2)+.5*(pos(4)-fight), figwid fight]);
    
    xnot=.05;
    ynot=.8;
   
    ht=.02;
    ysep=.02;
    
    
    tabht=.7;
    tabwid=.8;
    ynow=.1;
    xnow=xnot;
    fudge=.9;
    colwids={.5*figwid*tabwid*fudge, .5*figwid*tabwid*fudge};
    
    uitable(hf,'data',data,'ColumnName',{'Name','Value'},'units','normalized',...
        'position',[xnow ynow tabwid tabht],'columnwidth',colwids,'rowname',[]);
    
    xnow=xnot;
    ynow=ynot+ht;
    uicontrol(hf,'style','text','string',msg,'tag','msg','units','normalized',...
        'position',[xnow,ynow,.8,8*ht],'fontsize',10,'fontweight','bold');
    
    return;
end