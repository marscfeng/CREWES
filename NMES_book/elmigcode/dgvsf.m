%make receiver sampling chart
figure
f=40:1:160;
v0=[500:500:2500];
%dg=zeros(length(v0),length(f));
for k=1:length(v0)
	dg=v0(k)./(2*f);
	line(f,dg);
	text(f(end),dg(end),[int2str(v0(k)) ' m/s'])
end

xlabel('maximum frequency (Hertz)');
ylabel('\Delta g (meters)');
grid;bigfont(gca,1.8,1)
axis([40 200 0 35])
