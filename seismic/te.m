function seiste=te(seis,t,t1,t2)
% TE: trace equlization over a time window
% 
% seiste=te(seis,t,t1,t2)
%
% seis ... input seismic matrix
% t ... time coordinate for seis
% t1 ... start time of time window
% t2 ... end time of time window
% 
%
% G.F. Margrave, CREWES, 2018
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

%trace equalize design window
ntr=size(seis,2);
anom=zeros(1,ntr);
for k=1:ntr
    tmp=seis(:,k);
    idesign=near(t,t1,t2);
    anom(k)=norm(tmp(idesign));
end
ilive= anom~=0;
a0=mean(anom(ilive));
for k=1:ntr
    if(anom(k)~=0)
        seiste(:,k)=seis(:,k)*a0/anom(k);
    end
end