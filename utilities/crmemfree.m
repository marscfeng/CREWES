function fm = crmemfree
%function fm = crmemfree;
%
% Attempts to return free memory in bytes
% Returns [] on failure
%
% Authors: Kevin Hall, 2018
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

if ispc
    %we get to use the builtin Matlab memory() function
    try
        [~,uv] = memory;
        fm = uv.PhysicalMemory.Available;
    catch
        fm = [];
    end
elseif isunix
    %Tested on CentOS 7.4 (RedHat variant)
    %vmstat reports in kilobytes
    try
        [s,r] = system('vmstat'); %get virtual memory status
        %load redhat_vmstat_for_kevin.mat
        if s
            fm=[];
            return
        end        
        r = strsplit(r); %should be 3 rows
        r = reshape(r(7:end-1),17,2);%
        r = cell2struct(r(:,2),r(:,1));
        fm = sum(str2double({r.free r.cache}))*1024;
    catch
        fm = [];
    end
elseif ismac
    try
        %Tested on MacOS/X
        %vm_stat reports in pages, where one page is 4096 bytes
        [s,r] = system('vm_stat'); %get virtual memory status
        %load mac_vm_stat_for_kevin.mat
        if s
            fm=[];
            return
        end
        
        %load mac_vm_stat_for_kevin.mat
        pagesize = 4096; %bytes
        r = strsplit(r,{':',' ','\n'});
        
        fr = strcmp(r,'free');
        fr = [false fr(1:end-1)];
        ia = strcmp(r,'inactive');
        ia = [false ia(1:end-1)];
        sp = strcmp(r,'speculative');
        sp = [false sp(1:end-1)];
        fm = sum(str2double([r(fr) r(ia) r(sp)]))*pagesize;
    catch
        fm =[];
    end
end