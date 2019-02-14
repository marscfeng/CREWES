fmax=100;
wmax=2*pi*fmax;
R=1.2*wmax;
x=linspace(-R,R,1000);
y=x;
C1x=x;
C1y=zeros(size(C1x));
C2x=x;
C2y=-sqrt(R^2-C2x.^2);
C3x=x;
C3y=-C2y;
figure;
hl=linesgray({C1x,C1y,'-',.5,.5},{C2x,C2y,'-',1,.3},{C3x,C3y,'-',1,.7},{zeros(size(x)),y,':',1,.5},...
    {0,0,'none',1,0,'+',10},{-wmax,0,'none',1,0,'*',10},{wmax,0,'none',1,0,'*',10});
ht1=text(-wmax,0,'-\omega_{max}','verticalalignment','bottom');
ht2=text(wmax,0,'\omega_{max}','verticalalignment','bottom');
ha1=arrow([200 400],[0,0],'C1','k',1,'-');
set(ha1(4),'verticalalignment','bottom')
ha2=arrow([650 550],[420 550],'C3','k',1,'-');
ha3=arrow([650 550],[-420 -550],'C2','k',1,'-');
h4a=arrow([800 900],[0 0],'','k',.5,'-');
text(920,10,'\infty','verticalalignment','middle');
h5a=arrow([-800 -900],[0 0],'','k',.5,'-');
text(-920,10,'-\infty','verticalalignment','middle','horizontalalignment','right');
fs=get(ha3(4),'fontsize');
text(-300,-50,'real axis','fontsize',.8*fs,'color',[.5 .5 .5])
text(-50,200,'imaginary axis','fontsize',.8*fs,'color',[.5 .5 .5],'rotation',90)
axis equal
set(gca,'visible','off')
%legend([hl(1) hl(2) hl(3)],'C1 contour','C2 contour','C3 contour')
prepfig
bigfont(gcf,1,1)
% set([ht1 ht2],'fontweight','normal');


print -dsvg ..\signalgraphics\integrationcontour
print -depsc2 ..\signalgraphics\integrationcontour
% if verLessThan('matlab','8.4') % 8.4 == R2014b
%     print -depsc2 contourR2013b
% else
%     print -depsc2 -r600 contourR2014b
% end