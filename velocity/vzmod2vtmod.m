function [v,t]=vzmod2vtmod(vel,z,dt)
%  VZMOD2VTMOD: Compute Vint(x,t) from Vint(x,z)
%
%  [v,t]=vzmod2vtmod(vel,z,dt)
%
%  VZMOD2VAVEMOD converts an interval velocity model in depth (such as the
%  models required for finite difference modelling) into an average velocity
%  model in time (such as is required for time-depth conversion)
%
%  vel..........is the input velocity model in depth. Each row is a
%               constant depth.
%  z........depth coordinate for vel, length(z) = size(vel,1) 
%  dt.... desired time sample rate
%
%  v .... interval velocity in time
%  t ....... output two-way time coordinate
%
%  G.F. Margrave, 2017
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

if(length(z)~=size(vel,1))
    error('vel and z sizes are not compatible')
end
nx=size(vel,2);
%loop through the model a first time in order to detemine the maximum traveltime
tmax=0;
for k=1:nx
    tau=2*vint2t(vel(:,k),z);
    if(tau(end)>tmax)
        tmax=tau(end);
    end
end
t=(0:dt:tmax)';%two way time for output
v=zeros(length(t),nx);
for k=1:nx
   tv=2*vint2t(vel(:,k),z);%two way time at kth location
   if(tv(end)<tmax)%extend the last interval velocity if needed
       tv(end)=tmax;
   end
   v(:,k)=interp1(tv,vel(:,k),t);
   if(rem(k,100)==0)
       disp(['finished location ' int2str(k) ' of ' int2str(nx)])
   end
end
