function unit_vector_plot(zs,ks)
figure

rmax=ceil(max(real(zs)));
imax=ceil(max(imag(zs)));
cmax=max([rmax imax])+1;

g=.5;
ms=7;
line([-cmax cmax],[0 0],'linestyle',':','color',g*[1 1 1]);
line([0 0],[-cmax cmax],'linestyle',':','color',g*[1 1 1]);
draw_unit_circle(1000);
grid
xlabel('Real(z)');ylabel('Imaginary(z)')
axis square
h1=zeros(size(zs));
h2=h1;
for k=1:length(zs)
    [h1(k),h2(k)]=zplot(zs(k),ks(k));
end
%legend([h0 h1,h2,h3,h4,h5],'origin','complex number','amplitude','phase','real part','imaginary part');
prepfig;
bigfont(gcf,.75,1)


function [h1,h2]=zplot(z,k)
zr=real(z);
zi=imag(z);
theta=180*atan2(zi,zr)/pi;
ms=7;
h1=line(zr,zi,'marker','*','color','k','markersize',ms,'linestyle','none');
h2=text(zr,zi,['  \nu=' int2str(k)],'rotation',theta);


function draw_unit_circle(n)
%n=number of points around unit circle
theta=linspace(0,2*pi,n);
zs=exp(i*theta);
x=real(zs);
y=imag(zs);
line(x,y,'linestyle','-','linewidth',.5,'color',.5*[1 1 1])

