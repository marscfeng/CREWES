function h=plotlogs(logsection,z,x,dname,haxe,xcur)
%PLOTLOGS: Plot a section of logs as wiggles
%
% h=plotlogs(logsection,z,x,dname,haxe,xcur)
%
% Used to plot a cross section of similar logs as wiggles. The x-range of the logs is divided into a
% number of equal width "bins", one per log. Each log is then plotted in this bin and the maximum
% excursion of a log trace is given by the parameter xcur times the bin width. So xcur=1 means
% logs will never overplot each other but there may be lots of empty space. xcur=2 means a given log
% may actually plot on top of its neighbors but that is usually rare and the empty space is better
% filled. There is no way to tell from this plot what the numerical values of the logs are. You can
% judge their sililarity and observed trends. In this way it is much like a seismic section plot.
%
% logsection ... the section of logs as a matrix, one log per column. All logs must be the same
%       length and type.
% z ... depth (or time) coordinate for the logs. The length(z) must equal size(logsection,1).
% x ... distance coordinate for the log position. The length(x) must equal size(logsection,2).
% dname ...  dataset name used to title the plot
%  *********** default = '' ****************
% haxe ... handle of axes to plot in.
%  *********** default is to open a new figure and create a new axes (nan gets default) **********
% xcur ... maximum trace excursion expressed as a multiple of the box width.
%  *********** default = 2 ****************
% 
% h = array of handles of the plotted logs, one per log.
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

if(nargin<6)
    xcur=2;
end
if(nargin<5)
   haxe=nan; 
end
if(isnumeric(haxe))
    if(isnan(haxe))
        figure
        haxe=gca;
    end
end
if(nargin<4)
    dname='';
end

axes(haxe)

xmin=min(x);
xmax=max(x);
nlogs=size(logsection,2);

if(nlogs==1)
    error('this function only works for more than one log');
end

xwid=(xmax-xmin)/(nlogs-1);

xmin=xmin-.5*xwid*xcur;
xmax=xmax+.5*xwid*xcur;
lmax=max(logsection(:));
lmin=min(logsection(:));
h=zeros(size(x));
for k=1:nlogs
    thislog=logsection(:,k);
    x1=x(k)-.5*xwid*xcur;
    x2=x(k)+.5*xwid*xcur;
    m=(x2-x1)/(lmax-lmin);
    b=x1-m*lmin;
    h(k)=line(thislog*m+b,z,'color','k');
end
set(haxe,'xlim',[xmin xmax],'ydir','reverse')
title(dname)

if(nargout==0)
    clear h
end