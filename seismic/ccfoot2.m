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
% ccx ... crosscorrelation in x between xgrid and slice. This is a 2-by-nlags matrix whose first row
%       is the ordinary crosscorrelation and the second is the crosscorrlation with the abs of the slice. 
% xlags ... the xlags for ccx
% ccy ... crosscorrelation in y between ygrid and slice. Same size and meaning as ccx
% ylags ... the ylags for slice
% xaqgrid ... the xline acquisition grid
% yaqgrid ... the yline acquisition grid
%

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

%bandlimit the grids
sigmax=.25;
sigmay=.25;
xlinegrid=wavenumber_gaussmask2(xlinegrid,sigmax,10);
xlinegrid=xlinegrid/max(xlinegrid(:));
ylinegrid=wavenumber_gaussmask2(ylinegrid,10,sigmay);
ylinegrid=ylinegrid/max(ylinegrid(:));

%need zero lag auto's for normalization
nx=length(x);
ny=length(y);
A0=sum(slice(:).^2);
Ax=sum(sum(xlinegrid(:,nxgrid+1:nxgrid+nx-1).^2));
Ay=sum(sum(ylinegrid(nygrid+1:nygrid+ny-1,:).^2));
%calculate the x correlation
xlags=-nxgrid:nxgrid;
nxlags=length(xlags);
ccx=zeros(2,nxlags);

for k=1:nxlags
    x1=nxgrid+1+xlags(k);
    tmpa=abs(slice).*xlinegrid(:,x1:x1+nx-1);
    tmp=slice.*xlinegrid(:,x1:x1+nx-1);
    ccx(1,k)=sum(tmp(:))/sqrt(A0*Ax);
    ccx(2,k)=sum(tmpa(:))/sqrt(A0*Ax);
end
%calculate the y correlation
ylags=-nygrid:nygrid;
nylags=length(ylags);
ccy=zeros(2,nylags);

for k=1:nylags
    y1=nygrid+1+ylags(k);
    tmpa=abs(slice).*ylinegrid(y1:y1+ny-1,:);
    tmp=slice.*ylinegrid(y1:y1+ny-1,:);
    ccy(1,k)=sum(tmp(:))/sqrt(A0*Ay);
    ccy(2,k)=sum(tmpa(:))/sqrt(A0*Ay);
end

xaqgrid=xlinegrid(:,nxgrid+1:nxgrid+nx);
yaqgrid=ylinegrid(nygrid+1:nygrid+ny,:);

