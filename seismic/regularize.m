function [seis2,x2,y2,s2,s1]=regularize(seis,x,y)
% REGULARIZE ... regularize the trace spacing on a 2D seismic section
%
% [seis2,x2,y2,s2,s1]=regularize(seis,x,y)
%
% The input seismic section is assumed to be regular in t but irregular in terms of distance alone
% the trace. This method works best if the line is nearly regular in its trace spacing. That is if
% there is a dominant trace spacing that occurs most of the time with some variation. Repeated
% traces are no problem but large gaps are. Method: compute the Euclidean intertrace distances from
% the input (x,y). The output trace spacing will be the mode of the input spacing (that is the most
% frequently occuring spacing). Given this spacing, the output coordinate defines bin centers into
% which the input traces are stacked (and fold normalized). After this, any trace gaps are filled
% with the average of the first trace before and after the gap. This is a very simple method, it is
% not structurally aware. It works well on arbitrary lines from well-sampled 3D volumes.
%
% seis ... input seismic matrix x ... x trace coordinate for seis. 
% NOTE: length(x) must equal size(seis,2) 
% y ... y trace coordinate for seis 
% ********* default zeros(size(x)) *********** 
% NOTE: x and y can also be matrices. In this case, the first rows of each should be geographic
% coordinates from which Euclidean distance can be calculated. The remaining rows can be other types
% of coordinates like inline and crossline that correlate with x and y. These will then all be
% interpolated into corresponding X2 and Y2 on output.
% seis2 ... output seismic matrix 
% x2 ... x trace coordinate for seis2 
% y2 ... ytrace coordinate for seis2 
% s2 ... distance coordinate for seis2. Distance is calculated from the first trace.
% s1 ... distance coordinate for the input seis
% NOTE: length(x2) will always equal size(seis2,x) and the same with y2. Also
% sum(abs(diff(diff(s2)))) will always be zero. The latter means that s2 is regularly spaced.
% NOTE2: If the input line has constant y coordinate, then x2 will be regularly spaced. Similarly y2
% will be regular if x is constant. For both x and y changing, as is the case for an arbitrary line
% from a 3D volume, then only s2 will be regular on output. When plotting using Matlab's image
% command, the x axis is only correctly annotated if it is regular. This is true for CREWES display
% tools such as plotimage, seisplot, etc that use the image facility. Thus for arbitrary lines, it
% is best to use s2 for the trace coordinate.
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
if(nargin<3)
    y=zeros(size(x));
end

if(size(x,2)==1)
    x=x';
end
if(size(y,2)==1)
    y=y';
end


[nt,nx]=size(seis);
if(size(x,2)~=nx)
    error('x has the wrong size');
end
if(size(y,2)~=nx)
    error('y has the wrong size');
end


ds=sqrt((x(1,2:nx)-x(1,1:nx-1)).^2+(y(1,2:nx)-y(1,1:nx-1)).^2);%inter trace distance
s1=[0 cumsum(ds)];%distance coordinate for line
ds2=mode(ds);%this will be the new regular intertrace spacing
smax=ceil(s1(end)/ds2)*ds2;
s2=0:ds2:smax;
ns=length(s2);
seis2=zeros(nt,ns);
fold=zeros(1,ns);
for k=1:nx
    is=round(s1(k)/ds2)+1;
    seis2(:,is)=seis2(:,is)+seis(:,k);
    fold(is)=fold(is)+1;
end
ind=find(fold>1);
for k=ind
    seis2(:,k)=seis2(:,k)/fold(k);
end
ind=find(fold==0);
for k=ind
    if(k>1 && k<ns)
        seis2(:,k)=.5*(seis2(:,k-1)+seis2(:,k+1));
    elseif(k==1)
        seis2(:,k)=seis2(:,k+1);
    else
        seis2(:,k)=seis2(:,k-1);
    end
end

ncoords=size(x,1);%number of coordinates to interpolate
x2=zeros(ncoords,length(s2));
y2=x2;
ind=find(ds>0);
for k=1:ncoords
    x2(k,:)=interp1(s1(ind),x(k,ind),s2,'linear','extrap');
    y2(k,:)=interp1(s1(ind),y(k,ind),s2,'linear','extrap');
end
