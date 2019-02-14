zw=0:50:30000;
nwaves=10;tmax=5;
xwavefront=zeros(nwaves,length(zw));
times=linspace(0,tmax,nwaves);
zo=zeros(1,nwaves);
for k=1:nwaves
   zo(k)=vo*(cosh(c*times(k))-1)/c;
   r=vo*sinh(c*times(k))/c;%radius
   xw=sqrt(r.^2-(zw-zo(k)).^2);
   ind=find(real(xw)<0.);
   if(~isempty(ind))
      xw(ind)=nan*ones(size(ind));
   end
   ind=find(imag(xw)~=0.0);
   if(~isempty(ind))
      xw(ind)=nan*ones(size(ind));
   end
   xwavefront(k,:) = real(xw);
end
figure;plot(xwavefront/1000,zw/1000);flipy;
xlabel('x kilometers');ylabel('z kilometers')
