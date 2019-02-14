% fresnel zones
f=[20:20:200];
z=10:50:4000;
it=near(z,3000);
figure;
v=3000;
w=zeros(1,length(z)+1);
for k=1:length(f)
   w(1)=v/(2*f(k));
	w(2:end)=sqrt(2*z*v/f(k)).*sqrt(1+v./(8*f(k)*z));
	line([0 z],w);
   if(rem(k,2)==1)
	   text(z(end),w(end),[int2str(f(k)) 'Hz.'])
   else
      %text(z(it),w(it+5),[int2str(f(k)) 'Hz.'])
   end
end
xlabel('depth (meters)');ylabel('Fresnel zone (meters)')
bigfont(gca,1.8,1)
