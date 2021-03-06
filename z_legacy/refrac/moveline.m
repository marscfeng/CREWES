function moveline(action)
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

 if(nargin<1) %set the button down function
		set(gcf,'windowbuttondownfcn','moveline(''init'')');
		return;
	end
	if(strcmp(action,'init'))
		hline=gco;
		if(~strcmp(get(hline,'type'),'line'))
			return;
		end
		pt=get(gca,'currentpoint');
		set(hline,'userdata',pt(1,1:2));
		set(hline,'erasemode','xor','linestyle','.');
		
		set(gcf,'windowbuttonmotionfcn','moveline(''move'')');
		set(gcf,'windowbuttonupfcn','moveline(''fini'')');
		return;
	end
	if(strcmp(action,'move'))
		hline=gco;
		
		pt1=get(hline,'userdata');
		pt2=get(gca,'currentpoint');
		pt2=pt2(1,1:2);
		
		del=pt2-pt1;
		
		x=get(hline,'xdata');
		y=get(hline,'ydata');
		
		set(hline,'xdata',x+del(1));
		set(hline,'ydata',y+del(2));
		set(hline,'userdata',pt2);
		
		return;
	end
	
	if(strcmp(action,'fini'))
		hline=gco;
		set(hline,'erasemode','normal','linestyle','-');
		
		set(gcf,'windowbuttonmotionfcn','');
		set(gcf,'windowbuttonupfcn','');
		return;
	end
end
		
		