function sect = sectconv(sect,t,w,tw)
% SECTCONV: convolves a wavelet with a seismic section
%
% sectout = sectconv(sectin,t,w,tw)
%
% SECTCONV convolves a wavelet with a seismic section.
%
% sectin ... input section of size nsamp x ntr. That is one trace per
%	column.
% t ... nsamp long time coordinate vector for sectin
% w ... wavlet to be convolved with section
% tw ... time coordinate vector for wavelet. Abort will occur if wavelet
%	and sectin have different time sample rates.
% sectout ... output section of size nsamp x ntr.
%
% G.F. Margrave, CREWES Project, University of Calgary, 1996
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

[nsamp,ntr]=size(sect);

dt=t(2)-t(1);
dtw=tw(2)-tw(1);
small = 1.e06*eps;
if( abs( dt-dtw ) > small )
	error(' wavelet and section must have same sample rates ');
end
nz=near(tw,0.);
if(abs(tw(nz)) > small)
	disp('WARNING from sectconv: Wavelet has no sample at time zero');
end

for k=1:ntr
	sect(:,k) = convz( sect(:,k),w,nz);
end