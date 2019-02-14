function [ccx,xlags,ccy,ylags,xaqgrid,yaqgrid]=ccfoot(slice,x,y,dx,dy,flag)
% CCFOOT ... measure footprint on a time slice
% [ccx,xlags,ccy,ylags,xgrid,ygrid]=ccfoot(slice,x,y,dx,dy)
%
% 
% slice ... input time slice
% x ... x (column) coordinate for slice
% y ... y (row) coordinate for slice
% dx ... line spacing in x during acquisition
% dy ... line spacing in y during acquisition
% flag ... 1 means normalize the correlations, 0 means don't
%
% ccx ... crosscorrelation in x between xgrid and slice
% xlags ... the xlags for ccx
% ccy ... crosscorrelation in y between ygrid and slice
% ylags ... the ylags for slice
% xaqgrid ... the xline acquisition grid
% yaqgrid ... the yline acquisition grid
%
%
% G.F. Margrave, Devon, 2017
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

%build xlinegrid
dxrow=abs(x(2)-x(1));
nxgrid=round(dx/dxrow);
xlinegrid=zeros(length(y),length(x)+2*nxgrid,'like',slice);
x2=(1:size(xlinegrid,2));

%build ylinegrid
dycol=abs(y(2)-y(1));
nygrid=round(dy/dycol);
ylinegrid=zeros(length(y)+2*nygrid,length(x),'like',slice);
y2=(1:size(ylinegrid,1))';

%populate grids
ix=nxgrid:nxgrid:length(x2)-1;
for k=1:length(ix)
    xlinegrid(:,ix(k))=1;
end
% seisplot(xlinegrid,y,x2);
iy=nygrid:nygrid:length(y2)-1;
for k=1:length(iy)
    ylinegrid(iy(k),:)=1;
end
% seisplot(ylinegrid,y2,x);

%bandlimit the grids
sigmax=.25;
sigmay=.25;
ynom=1:length(y);
xnom=1:length(x);
xlinegrid=wavenumber_gaussmask2(xlinegrid,sigmax,10);
xlinegrid=xlinegrid/max(xlinegrid(:));
ylinegrid=wavenumber_gaussmask2(ylinegrid,10,sigmay);
ylinegrid=ylinegrid/max(ylinegrid(:));
% figure
% subplot(2,1,1)
% seisplota(xlinegrid,ynom,x2);
% subplot(2,1,2)
% seisplota(ylinegrid,y2,xnom)
% prepfiga
% figure
% subplot(2,1,1)
% plot(x2,xlinegrid(round(length(ynom)/2),:))
% subplot(2,1,2)
% plot(y2,ylinegrid(:,round(length(xnom)/2)))

%need zero lag auto's for normalization
nx=length(x);
ny=length(y);
A0=sum(slice(:).^2);
Ax=sum(sum(xlinegrid(:,nxgrid+1:nxgrid+nx-1).^2));
Ay=sum(sum(ylinegrid(nygrid+1:nygrid+ny-1,:).^2));
%calculate the x correlation
xlags=-nxgrid:nxgrid;
nxlags=length(xlags);
ccx=zeros(1,nxlags);

% A=max(abs(slice(:)));
for k=1:nxlags
    x1=nxgrid+1+xlags(k);
    tmp=abs(slice).*xlinegrid(:,x1:x1+nx-1);
    %tmp=slice.*xlinegrid(:,x1:x1+nx-1);
    ccx(k)=sum(tmp(:))/sqrt(A0*Ax);
end
%calculate the y correlation
ylags=-nygrid:nygrid;
nylags=length(ylags);
ccy=zeros(1,nylags);
ccy0=ccy;
for k=1:nylags
    y1=nygrid+1+ylags(k);
    tmp=abs(slice).*ylinegrid(y1:y1+ny-1,:);
    tmp0=slice.*ylinegrid(y1:y1+ny-1,:);
    ccy(k)=sum(tmp(:))/sqrt(A0*Ay);
    ccy0(k)=sum(tmp0(:))/sqrt(A0*Ay);
end
% figure
% subplot(1,2,1)
% plot(xlags,ccx)
% subplot(1,2,2)
% plot(ylags,ccy)

xaqgrid=xlinegrid(:,nxgrid+1:nxgrid+nx);
yaqgrid=ylinegrid(nygrid+1:nygrid+ny,:);

