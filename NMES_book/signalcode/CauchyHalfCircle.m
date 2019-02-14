clf

% Let's plot a half circle, with some decorations

% First, we define the centre and radius of the circle
z0 = [30,0]; 
r0 = 140; 

% second, we plot the centre of the circle and label it. 
hold on
plot(z0(1),z0(2),'ko','MarkerFaceColor','k')
txt2 = ' \omega';
text(z0(1),z0(2)+10,txt2)
%%
% third, we plot the half circle itself
t = linspace(.5,1,1000);
x = z0(1) + r0*cos(2*pi*t);
y = z0(2) + r0*sin(2*pi*t);
plot(x,y,'k')
plot([x(1) x(1000)],[0 0],'k')

% fourth, plot the radius vector and label it
plot([z0(1) x(600)],[z0(2) y(600)],'k')
plot(x(600),y(600),'ko','MarkerFaceColor','k')
txt3 = '     R';
text(.6*x(600),.6*y(600),txt3)

%%

% fifth, add the arrow heads
arrowh([x(800) x(801)],[y(800) y(801)],'k',200);
arrowh([110 100],[0 0],'k',200);


% now we make the plot look nice, add the arrowhead
xticks([-120 -80 -40 0  40  80 120  160])
yticks([-160 -140 -120 -100 -80 -60 -40 -20 0 20])
axis equal
grid
xlim([z0(1)-r0-10, z0(1)+r0+10]);
ylim([z0(2)-r0-10, 30]);
hold off

%%
% Then pick the large fonts and print out the plot
set(gca, 'FontName', 'Arial')
prepfig
bigfont(gcf,1.2,1)
print(gcf, 'CauchyHalfCircle', '-djpeg')
%print -dpdf ..\signalgraphics\samp_interpB

