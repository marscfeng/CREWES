function telluser(action)
%
% G.F. Margrave Feb 1994
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

global QS

if(strcmp(action,'init'))
        hmaster=gcf;
		qs=QS;
		%build the dialog box
		hdial=figure('visible','off','menubar','none','numbertitle','off');
		sep=.1;
		nrows=2;
		%
		% assume 6 chars in 50 pixesl
		%
		charpix=6;
		%
		% now the message
		%
		q=qs(1,:);
		ind=find(q==1);
		if(~isempty(ind))
			q=q(1:ind(1)-1);
		end
		figwidth=50*ceil(length(q)/charpix);
		height=.4;
		figheight=10*(nrows);
		ynow=1-height-sep;
		xnow=sep;
        width=.8;
        pospar=get(hmaster,'position');
		px=pospar(1)+pospar(3)/2;
		py=pospar(2)+pospar(4)/2;
		set(hdial,'position',[px-figwidth*.5 py-figheight*.5 figwidth 3*figheight],'visible','on');
        
		uicontrol('style','text','string',q,'units','normalized',...
					'position',[xnow ynow width height]);
		% the ok button
		%ynow=ynow-sep-height;
        w=.2;
        x=.5-w/2;
        h=.5;
        y=0;
		uicontrol('style','pushbutton','string','OK','units','normalized','position',...
			[x,y,w,h],'callback','telluser(''button'')');
		set(hdial,'name',qs(2,:));
		
		
		return;
	end
	%
	% handle the ok button
	%
	if(strcmp(action,'button'))
		close(gcf);
		return;
	end