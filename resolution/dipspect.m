function h=dipspect(a,t,dx,f,vo,c,z)
% DIPSPECT: make dip spectral analysis plot for v(z)
%
% h=dipspect(a,t,dx,f,vo,c,z)
%
% DIPSPECT makes a dip spectral analysis plot for v=vo+cz
% If z is not provided, then it is computed with 
% z=linspace(0,zmax,nz). Here, zmax is computed as the maximum
% depth for the supplied record length and nz=500. (If z is
% provided as a single number, then it is taken to be nz).
%
% a ... aperture
% t ... maximum recording time
% dx ... spatial sampling interval
% f ... frequency of interest
% vo ... initial velocity
% c ... accelerator ( v(z) = vo +c*z )
% z ... vector of depths for which limits are computed
% h ... returned as a length 3 vector of graphics handles of the three curves. h(1) record length,
%       h(2) aperture, h(3) spatial aliasing
%
% G.F. Margrave, CREWES Project, 1997, 2018
%
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

if(nargin<7)
	z=500;
end

if(length(z)==1)
	[thetar,z]=threc(t,vo,c,z);
else
	thetar=threc(t,vo,c,z);
end
ir=find(imag(thetar)==0);

thap=thaper(a,vo,c,z);
inda=find(imag(thap)==0);
thal = thalias(dx,f,vo,c,z);
indal=find(imag(thal)==0);

figure;

%plot(z(ir),thetar(ir),thrline,z,thap,thapline,z(indal),thal(indal),thaline);
h=linesgray({z(ir),thetar(ir),'-',1,0},{z,thap,'-',2,.5,},{z(indal),thal(indal),':',1,0});
legend(['Record length limit, T=' num2str(t) ' sec'],...
	['Aperture limit, A=' int2str(a) ' lu'],...
	['Spatial aliasing limit, dx=' int2str(dx) ' lu, f=' ...
	int2str(f) ' Hz']);

ylabel('scattering angle (degrees)');xlabel('depth')
	
title([' Dipspect chart for vo= ' int2str(vo) ' c= ' num2str(c)])
grid