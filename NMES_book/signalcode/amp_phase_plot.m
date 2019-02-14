function amp_phase_plot(zs)
figure

rmax=ceil(max(real(zs)));
imax=ceil(max(imag(zs)));
cmax=max([rmax imax])+1;

g=.5;
ms=7;
line([-cmax cmax],[0 0],'linestyle',':','color',g*[1 1 1]);
line([0 0],[-cmax cmax],'linestyle',':','color',g*[1 1 1]);
h0=line(0,0,'marker','o','color','k','markersize',ms,'linestyle','none');
grid
xlabel('Real(z)');ylabel('Imaginary(z)')
axis square

for k=1:length(zs)
    [h1,h2,h3,h4,h5]=zplot(zs(k),k);
end
legend([h0 h1,h2,h3,h4,h5],'origin','complex number','amplitude','phase',...
    'real part','imaginary part','location','northwest');
prepfig;
bigfont(gcf,.75,1)


function [h1,h2,h3,h4,h5]=zplot(z,k)
zr=real(z);
zi=imag(z);
az=abs(z);
pz=180*atan2(zi,zr)/pi;
fs=12;
ms=7;
fudge=1.1;
h1=line(zr,zi,'marker','*','color','k','markersize',ms,'linestyle','none');
if(zr>0)
    ha='left';
else
    ha='right';
end
text(fudge*zr,zi,['z_' int2str(k)],'horizontalalignment',ha,'fontsize',fs)
h2=line([0 zr],[0 zi],'linestyle','-','color','k');
% text(zr/2,zi/2,['A_' int2str(k)],'backgroundcolor','w','horizontalalignment',...
%     'center','verticalalignment','middle','fontsize',fs);
text(zr/2,zi/2,['A_' int2str(k)],'horizontalalignment',...
    'center','verticalalignment','middle','fontsize',fs);

dth=1;
if(pz<0)
    %pz=360+pz;
    dth=-1;
end
theta=0:dth:pz;
xp=az*cosd(theta);
yp=az*sind(theta);

h3=line(xp,yp,'linestyle','-.','color',[.5 .5 .5]);
kmid=round(length(xp)/2);
% text(xp(kmid),yp(kmid),['\phi_' int2str(k) '=' int2str(pz) '^o'],'backgroundcolor','w','horizontalalignment',...
%     'center','verticalalignment','middle','fontsize',fs);
text(xp(kmid),yp(kmid),['\phi_' int2str(k) '=' int2str(pz) '^o'],'horizontalalignment',...
    'center','verticalalignment','middle','fontsize',fs);

h4=line(zr,0,'marker','s','markersize',.5*ms,'color','k','linestyle','none');
line([zr zr],[0 zi],'linestyle',':','color',[.5 .5 .5]);
h5=line(0,zi,'marker','d','markersize',.5*ms,'color','k','linestyle','none');
line([0 zr],[zi zi],'linestyle',':','color',[.5 .5 .5]);
% text(fudge*zr,0,['z' int2str(k) '_r'],'horizontalalignment',...
%     ha,'verticalalignment','middle','fontsize',fs)


