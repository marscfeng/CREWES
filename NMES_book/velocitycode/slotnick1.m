x=1:50:35000;
vo=1800;c=.6;nrays=10;
thetamin=5;thetamax=80;
deltheta=(thetamax-thetamin)/nrays;
zraypath=zeros(nrays,length(x));
for k=1:nrays
	theta=thetamin+(k-1)*deltheta;
	p=sin(pi*theta/180)/vo;
	cs=cos(pi*theta/180);
	z = (sqrt( 1/(p^2*c^2) - (x-cs/(p*c)).^2) -vo/c);
	ind=find(imag(z)~=0.0);
	if(~isempty(ind))
		z(ind)=nan*ones(size(ind));
	end
	ind=find(real(z)<0.);
	if(~isempty(ind))
		z(ind)=nan*ones(size(ind));
	end
	zraypath(k,:) = real(z);
end
figure;plot(x/1000,zraypath/1000);flipy;
xlabel('x kilometers');ylabel('z kilometers')
