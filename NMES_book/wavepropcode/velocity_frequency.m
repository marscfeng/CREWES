%frequency dependent velocity picture
f0=12500;
f=1:10:f0;
v=3000;
Q=[20 50 80 100 150 200];
lw=[.5 .7 .9 1.1 1.3 1.5];
gl=[0 .1 .2 .4 .6 .8];
names=cell(1,6);
figure
for k=1:length(Q)
vf=velf(v,Q(k),f,f0);
%line(log10(f),vf,'color',gl(k)*ones(1,3),'linewidth',lw(k));
if(floor(k/2)*2==k)
    line(f,vf,'color',gl(k)*ones(1,3),'linewidth',lw(k),'linestyle',':');
else
    line(f,vf,'color',gl(k)*ones(1,3),'linewidth',lw(k),'linestyle','-');
end
names{k}=['Q=' num2str(Q(k))];
end
patch([0 200 200 0],[2600 2600 3000 3000],[-1 -1 -1 -1],.9*ones(1,3))
patch([10000 13000 13000 10000],[2600 2600 3000 3000],[-1 -1 -1 -1],.9*ones(1,3),'facealpha',.5)
text(10000,2700,'Well logging band');
text(100,2700,'Seismic band')
legend(names)
%xlabel('log10(frequency)');
xlabel('frequency');
ylabel('velocity (m/s)')
grid
prepfig
bigfont(gcf,1.5,1)
print -depsc wavepropgraphics\velf.eps