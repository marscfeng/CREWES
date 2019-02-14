function [slicem,mask,kx,ky]=wavenumber_gaussmask2(slice,sigmax,sigmay,whiten,delkx,delky,stab,izero)
% WAVENUMBER_GAUSSMASK2: apply a 2D Gaussian mask to the 2DFFT of a seismic timeslice or depthslice
%
% [slicem,mask,kx,ky]=wavenumber_gaussmask2(slice,sigmax,sigmay,whiten,delkx,delky,stab,izero)
%
% This version is preferred over wavenumber_gaussmask. The difference being this version used fft2
% directly while wavenumber_gaussmask uses fktran which caused a slight asymmetry.
%
% It is often desirable to apply a filter that suppresses the higher wavenumbers on a seismic time
% or depth slice. This function does that by performing a 2D FFT on the slice and then pointwise
% multiplying the wavenumber spectrum by a Gaussian mask. The Gaussian mask has the same dimensions
% as the spectrum and is a either a decaying or growing Guassian in both kx and ky. Both masks are
% unity at the origin and decay (or grow) away from the origin. The total mask is the pointwise
% product of the kx and ky masks.
%
% An option exists now to whiten the spatial spectrum before applying the Gaussian mask. This is
% done in close analogy to temporal deconvolution meaning that the whitening process divides the
% data spectrum by its smoothed self. The smoothed self is really formed just from the data amplitude
% spectrum (no phase) which is convolved with a 2D boxcar of user spcified dimensions. A stability
% constant of stab*Amax (Amax is the maximum of the amplitude spectrum) is added to the data
% spectrum before smoothing. The returned mask is the combined effect (pointwise product) of the
% Gaussian mask and the whitening operator. The combined mask is normalized to have a maximum of 1.
%
% slice ... input time slice, the column coordinate is x and the row coordinate is y.
% sigmax ... stdev of mask in kx expressed as a fraction of kxnyq. That is the actual stddev is
%               sigmax*kxnyq. Positive values give decay while negative values mean growth.
% sigmay ... similar for sigmax but in the ky direction
% whiten ... 0, dont do spatial whitening, 1 means do it
% ********* default = 0 ***********
% delkx, delky, stab are only inportant for spatial whitening. nan also gets the default
% delkx ... width of boxcar smoother in kx, as a fraction of nyquist. Larger is smoother but also slower.
% ********* default = .05 ********
% delky ... width of boxcar smoother in ky, as a fraction of nyquist. Larger is smoother but also slower.
% ********* default = .05 ********
% stab ... small positive number expressing the amount of whiten noise added to the spectrum before
%           smoothing in the design of the inverse operator.
% ********* default =.1 *********
% izero ... 1 means rezero anything that was zero before the filter, 0 means don't
% ********* default = 1 *********************
%
% slicem ... the wavenumber filtered slice
% mask ... the applied Gaussian mask. Same size as fft(slicem);
% kx,ky ... waevnumber coordinates for plotting mask
%
% G.F. Margrave, Margrave-Geo, 2019
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

if(nargin<8)
    izero=nan;
end
if(nargin<7)
    stab=nan;
end
if(nargin<6)
    delky=nan;
end
if(nargin<5)
    delkx=nan;
end
if(nargin<4)
    whiten=nan;
end
if(isnan(whiten))
    whiten=0;
end
if(isnan(delkx))
    delkx=.05;
end
if(isnan(delky))
    delky=.05;
end
if(isnan(stab))
    stab=.1;
end
if(isnan(izero))
    izero=1;
end
if(izero==1)
    jzero=slice==0;
end

if(sigmax<0)
    sigmax=1i*sigmax;
end
if(sigmay<0)
    sigmay=1i*sigmay;
end


%forward transform
[ny,nx]=size(slice);
ny2=2^nextpow2(2*ny);
nx2=2^nextpow2(2*nx);
dkx=1/nx2;
kx=-.5:dkx:.5-dkx;
dky=1/ny2;
ky=(-.5:dky:.5-dky)';

if(whiten==1)
    Slice=fftshift(fft2(slice,ny2,nx2));
    Atmp=abs(Slice);
    Amax=max(Atmp(:));
    nbx=round(delkx*nx2/2)*2+1;%an odd number
    nby=round(delky*ny2/2)*2+1;%an odd number
    D=conv2(Atmp+stab*Amax,ones(nbx,nby),'same')/(nbx*nby);
    D=D/max(D(:));%this is the whitening operator
else
    D=[];
    Slice=fftshift(fft2(slice,ny2,nx2));
end


%define Gaussian mask
kny=.5;
knx=.5;
kkx2=kx(ones(size(ky)),:).^2;
kky2=ky(:,ones(size(kx))).^2;
sigmay2=(kny*sigmay)^2;
sigmax2=(knx*sigmax)^2;
gy=exp(-kky2/sigmay2);
gx=exp(-kkx2/sigmax2);

%apply the mask
if(isempty(D))
    mask=gx.*gy;
else
    %combine Gaussians with whitening
    tmp=(gx.*gy)./D;
    mask=tmp/max(tmp(:));%normalize mask operator to max of 1
end
Slicem=Slice.*mask;

%Inverse transform
tmp=ifft2(fftshift(Slicem));
% A1=max(abs(slice(:)));
% A2=max(abs(tmp(:)));
% slicem=real(tmp(1:ny,1:nx))*A1/A2;
% The three lines above were to rescale the output to have the same max as the input. However, I
% have now normalized the mask to have a maximum of 1 and I don't think I need the rescaling.
slicem=real(tmp(1:ny,1:nx));

if(izero==1)
    slicem(jzero)=0;
end