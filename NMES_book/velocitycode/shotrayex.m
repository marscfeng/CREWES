function [x,t]=shootray(v,z,p)
%... code not displayed
iprop=1:length(z)-1;
sn = v(iprop)*p;
cs=sqrt(1-sn.*sn);
vprop=v(iprop)*ones(1,length(p));
thk=abs(diff(z))*ones(1,length(p));
if(size(sn,1)>1)
 	x=sum( (thk.*sn)./cs);
 	t=sum(thk./(vprop.*cs));
else
 	x=(thk.*sn)./cs;
 	t=thk./(vprop.*cs);
end
%assign infs
if(~isempty(ichk))
	x(pchk)=inf*ones(size(pchk));
	t(pchk)=inf*ones(size(pchk));
end
