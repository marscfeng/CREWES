function hbar=WaitBar(k,n,msg,name,position)
%
% hbar=WaitBar(k,n,msg,name,position)
% 
% k ... gives current state, starts with 0 to initialize the waitbar
% n ... maximum that k will ever be
% msg ... string placed in upper center of GUI announcing current progress
% name ... string used as the Figure name (in the title bar)
% position ... 2 element or 4 element vector giving position in pixels
%       If length is 2, then position(1) is width, position (2) is height, and the WaitBar is
%       centered over the current figure.
%       If length is 4, then position(1:2) gives (x,y) of lower left corner and position(3,4) gives
%       width.
% ********** default is centered over gcf and 400 pixels wide and 100 high **************
% Note: if there is no current figure, the waitbar is placed in the center of the screen
%
% NOTE: There is a cancel button on the waitbar. WaitBar defines the global WaitBarContinue with the
% value initially set to true. Pushing the cancel button sets this value to false.
%
% Calling modes:
% To initialize:  hbar=WaitBar(0,n,msg,name,position);
% To update:      Waitbar(k,hbar,msg);
%
% Example:
% global WaitBarContinue
% n = 100;
% A = 500;
% a = zeros(n);
% hbar=WaitBar(0,n,'Computation beginning','Progress...',[400 100]);
% t0=clock;
% for i = 1:n
%     a(i) = max(abs(eig(rand(A))));
%     if(rem(i,10)==0)
%         if(~WaitBarContinue)
%             delete(hbar)
%             break
%         end
%         tnow=clock;
%         timeper=etime(tnow,t0)/i;
%         timeleft=(n-i)*timeper;
%         WaitBar(i,hbar,['Time remaining ' int2str(timeleft) ' sec']);
%     end
% end
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

global WaitBarContinue

if ischar(k)
    action=k;
elseif k==0
    action='init';
else
    action='update';
end
if(strcmp(action,'init'))
    if(nargin<5)
        if(isempty(get(0,'children')))
            ss=get(0,'screensize');
            xc=ss(3)*.5;
            yc=ss(4)*.5;
        else
            pos=get(gcf,'position');
            xc=pos(1)+.5*pos(3);
            yc=pos(2)+.5*pos(4);
        end
        figwid=400;
        fight=100;
        position=[xc-.5*figwid,yc-.5*fight,figwid,fight];
    elseif(length(position)==2)
         if(isempty(get(0,'children')))
            ss=get(0,'screensize');
            xc=ss(3)*.5;
            yc=ss(4)*.5;
        else
            pos=get(gcf,'position');
            xc=pos(1)+.5*pos(3);
            yc=pos(2)+.5*pos(4);
        end
        position=[xc yc position];
    end
        
    hbar=figure('position',position,'menubar','none','toolbar','none','numbertitle','off',...
        'name',name,'closerequestfcn','WaitBar(''cancel'');');
    hmsg=uicontrol(hbar,'style','text','string',msg,'units','normalized','tag','message',...
        'position',[.1,.8,.8,.15],'fontsize',10);
    N=min([n 100]);
    x0=.1;
    xN=.9;
    wid=(xN-x0)/N;
    hprog=zeros(1,N);
    xj=x0;
    yj=.45;
    ht=.1;
    for j=1:N
        hprog(j)=uicontrol(hbar,'style','text','units','normalized','position',[xj,yj,wid,ht],...
            'backgroundcolor',ones(1,3));
        xj=xj+wid;
    end
    set(hmsg,'userdata',{n,N,hprog})
    
    WaitBarContinue=true;
    
    uicontrol(hbar,'style','pushbutton','String','Cancel','units','normalized',...
        'position',[.4 .1 .2 .2],'callback','WaitBar(''cancel'');','tag','cancel')
    drawnow;
elseif(strcmp(action,'update'))
    hbar=n;
    hmsg=findobj(hbar,'tag','message');
    udat=get(hmsg,'userdata');
    hprog=udat{3};
    n=udat{1};
    N=udat{2};
    K=round(N*(k+1)/n);
    for j=1:K
        if(j<N)
            set(hprog(j),'backgroundcolor',[1 0 0]); 
        else
            hcancel=findobj(hbar,'tag','cancel');
            set(hcancel,'string','close')
        end
    end
    set(hmsg,'string',msg);
    drawnow;
elseif(strcmp(action,'cancel'))
    WaitBarContinue=false;
    delete(gcf);
end