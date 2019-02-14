function [amp,tout]=specdecomp3D(s,t,twin,tinc,fout,tmin,tmax)
% specdecomp3D: This is a 3D version of specdecomp. 
%
% [amp,tout]=specdecomp3D(s,t,twin,tinc,fout,tmin,tmax)
% 
% This function calls the 2D spectral decomposition function, specdecomp, on each 2D slice defined
% by haveing the 3rd dimension constant. Because spectral decompotion increases the dimensionality
% by 1, for a 3D volume the result is 4D. This is potentially a very large output data volume. For
% this reason, the output frequencies are defined by an explicit list rather than start, end, and
% increment. Be cautious about requesting too many output frequencies as your computer may explode.
% See specdecomp for more discussion on the computation.
%
% s ... 3D seismic matrix, one trace per column. Dimension 1 is time, 2 is x, and 3 is y.
% t ... time coordinate for s
% NOTE: Length of t must equal size(s,1)
% twin ... width (seconds) of the Gaussian window (standard deviation)
% tinc ... temporal shift (seconds) between windows, this is the output time sample rate. If in
%       doubt, make this twice the input time sample rate.
% fout ... list of frequencies at which the output volumes are desired. Should be integer values.
% tmin ... minimum output time (seconds)
% ********** default = t(1) ***********
% tmax ... maximum output time (seconds)
% ********** default = t(end) ***********
%
% amp ... Cell array of 3D amplitude spectral decomp matrices, one for each entry in fout. 
% tout ... time coordinate for amp
% 
% G.F. Margrave, Devon, 2018
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
    tmax=t(end);
end
if(nargin<6)
    tmin=t(1);
end

[nt,nx,ny]=size(s);
if((nt-1)*(nx-1)*(ny-1)==0)
   error('specdecomp3D is for 3D matrices only, use specdecomp for 2D');
end

t=t(:);
if(length(t)~=nt)
    error('t has the wrong length')
end

if(tinc>twin)
    error('tinc should be less than twin');
end

%loop over y=constant lines
fmin=min(fout);fmax=max(fout);df=1;
phaseflag=3;
for k=1:ny
   s2d=squeeze(s(:,:,k));
   [amp2d,phs,tout,f2d]=specdecomp(s2d,t,twin,tinc,fmin,fmax,df,tmin,tmax,phaseflag); %#ok<ASGLU>
   if(k==1)
       %allocate output volumes
       amp=cell(size(fout));
       for j=1:length(fout)
          amp{j}=zeros(length(tout,nx,ny));
       end
   end
   for j=1:length(fout)
       jf=near(f2d,fout(j));
       amp{j}(:,:,k)=amp2d(:,:,jf(1));
   end
end
   