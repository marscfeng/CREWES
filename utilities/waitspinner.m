function waitspinner(action,posn)
% WAITSPINNER ... uses JAVA to put a little spinner in your figure to indicate busy
%
% waitspinner(action,posn)
%
% action ... string, either 'start' or 'stop'
% posn ... four element vector spcifying location and size of spinner in pixels
%          posn(1:2) is the x,y position of lower left corner of spinner in current fig
%          posn(3:4) is the width,height of spinner in pixels
% Example:
% Put a spinner of 40x40 pixels in the upper left corner of current figure:
%   pos=get(gcf,'position');
%   spinnersize=[40 40];
%   waitspinner('start',[pos(3)-spinnersize(1), pos(4)-spinnersize(2), spinnersize]);
%   drawnow
% Turn the spinner off
%   waitspinner('stop');
%
% NOTE: Don't have more than one of these going at a time.
%
% G.F. Margrave 2017
%
global jObj

if(strcmp(action,'start'))
    if(length(posn)<4)
        posn=[posn(1:2) 80 80];
    end
    
    try
        % R2010a and newer
        iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
        iconsSizeEnums = javaMethod('values',iconsClassName);
        SIZE_32x32 = iconsSizeEnums(2);  % (1) = 16x16,  (2) = 32x32
        jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, '');  % icon, label
    catch
        % R2009b and earlier
        redColor   = java.awt.Color(1,0,0);
        blackColor = java.awt.Color(0,0,0);
        jObj = com.mathworks.widgets.BusyAffordance(redColor, blackColor);
    end
    jObj.setPaintsWhenStopped(false);  % default = false
    jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)
    javacomponent(jObj.getComponent, posn, gcf);
    jObj.start;
 
elseif(strcmp(action,'end')||strcmp(action,'stop'))
    jObj.stop;
    jObj.setBusyText('All done!');
    clear jObj
end
    
    