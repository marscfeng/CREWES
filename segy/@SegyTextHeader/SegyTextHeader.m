classdef SegyTextHeader < File
%
%classdef SegyTextHeader
%
% SEG-Y textual file header class
%
% Usage: thdr = SegyTextHeader(filename,permission,byteorder,segyrevision)
%
% Where:
%   filename     = string containing full file name or a file id from fopen
%   permission   = string containing file permissions to use with fopen
%                     (optional), default is 'r' (see help fopen)
%   byteorder    = string containing 'b' or 'l' for big- or little-endian
%                     (optional), default is 'n' (see help fopen)
%   segyrevision = 0, 1, or 2
%   gui          = 0: no prompts,
%                  1: text prompts
%                  figure handle or empty: gui prompts
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.
%
% Authors: Kevin Hall 2009, 2017
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

properties (Hidden = false)
    SIZE   = 3200.0; %Header size in bytes    
    OFFSET = 0;      %Header offset from beginning of file in bytes

end

properties
    TextFormat    = 'ascii'; %Text format: 'ascii' (default) or 'ebcdic'
    SegyRevision  = []; %SEG-Y revision number: 0, 1 (default), or 2 
end

methods %public methods
    
    %Constructor
    function obj = SegyTextHeader(filename,permission,byteorder,segyrevision,gui)
        if nargin <1 || isempty(filename)
            filename = -1;
        end
        if nargin <2
            permission = [];
        end
        if nargin <3
            byteorder = [];
        end
        if nargin <4
            segyrevision = [];
        end
        if nargin <5
            gui = 1;
        end
        
        %Call superclass constructor
        obj = obj@File(filename,permission,byteorder,gui);
        if obj.FileID > 0 && obj.fsize >=3200 %File.openFile did not fail and there is a text file header
            obj = obj.guessTextFormat;
        end
                            
        if isempty(segyrevision)
            obj = obj.guessSegyRevision;
        else
            obj.SegyRevision = segyrevision;
        end
        
        if isempty(obj.SegyRevision) %..and, if that failed...
            obj.SegyRevision=1;
        end

    end
    
    %Set methods

    function set.SegyRevision(obj,v)
        if isnumeric(v) || isempty(v)
            obj.SegyRevision=v;
        else
            mm_errordlg('@SegyTextHeader: SegyRevision must be numeric',...
                'Error!',obj.GUI)
        end
    end
    
    function set.TextFormat(obj,v)
        if ischar(v)
            v=lower(v);
            switch(v)
                case('ascii')
                    obj.TextFormat = v;
                case('ebcdic')
                    obj.TextFormat = v;
                otherwise
                    mm_errordlg('@SegyTextHeader: TextFormat must be ''ascii'' or ''ebcdic''',...
                        'Error!',obj.GUI);
            end
        elseif isempty(v)
            obj.TextFormat = v;
        else
             mm_errordlg('@SegyTextHeader: TextFormat must be char',...
                        'Error!',obj.GUI);
        end
    end    
    
end % end methods
    
end