function mm_adjust(handle, parent)
% function mm_adjust(handle, parent)
%
% Where:
%   handle = handle to figure to adjust
%   parent = handle to parent figure (optional)
%
% mm_adjust moves the figure represented by handle to the center of the
% monitor that the parent is displayed on. If a parent handle is not
% provided or parent is empty, the monitor that is currently dislaying the
% mouse pointer is used.
%
% Examples:
%   mm_adjust(plot(sin(1:10)));
%   mm_adjust(plot(sin(1:10)),[]);
%   mm_adjust(plot(sin(1:10)),parent);
%  
%  Authors: Kevin Hall, 2017
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

narginchk(1,2);

if nargin <2
    parent = []; %set parent handle to empty if it was not supplied
end

%Get monitor position(s) and mouse pointer position in pixels
grootunits = get(0,'Units');
set(0,'Units','pixels');
monitorpos = get(0,'MonitorPosition');
parentpos = get(0,'PointerLocation');
set(0,'Units',grootunits);

%calculate x,y in pixels for center of all monitors
monitorcenter = monitorpos(:,1:2) +monitorpos(:,3:4)./2; 
    
if ~isempty(parent)
    %get dimensions of parent figure in pixels
    parentunits = get(parent,'Units');
    set(parent,'Units','pixels');
    parentpos = get(parent,'Position');
    set(parent,'Units',parentunits);
    %calculate x,y in pixels for center of parent figure
    parentpos = [parentpos(1)+parentpos(3)/2 parentpos(2)+parentpos(4)/2];
end

%Get coordinates for center of current monitor
%calculate dx and dy
nummonitors=size(monitorcenter,1);
dxdy = parentpos(ones(1,nummonitors),:)-monitorcenter;
%calculate distance between pointer and all monitor centers
pmdist = sqrt(dxdy(:,1).^2 +dxdy(:,2).^2);
%find x,y of monitor center the parent figure center (or mouse pointer) is closest to
monitorcenter = monitorcenter(pmdist == min(pmdist),:); 

%Get coordinates for center of figure we're updating, and update
figunits = get(handle,'Units');
set(handle,'Units','pixels');
figpos = get(handle,'Position');
%This next bit is key...
figpos = [monitorcenter(1)-figpos(3)/2 monitorcenter(2)-figpos(4)/2 figpos(3) figpos(4)];
set(handle,'Position',figpos); %set updated figure position
set(handle,'Units',figunits);

end %end function
