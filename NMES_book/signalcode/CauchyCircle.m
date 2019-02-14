clf

% Let's plot a circle

% First, we define the centre and radius of the circle
z0 = [3.5,3.5]; 
r0 = 2.5; 

% second, we plot the centre of the circle and label it. 
hold on
plot(z0(1),z0(2),'ko','MarkerFaceColor','k')
txt2 = '   z_0';
text(z0(1),z0(2)+.1,txt2)


% third, we plot the circle itself
t = linspace(0,1,1000);
x = z0(1) + r0*cos(2*pi*t);
y = z0(2) + r0*sin(2*pi*t);
plot(x,y,'k')

% now we make the plot look nice, add the arrowhead
xticks([0 1 2 3 4 5 6 7])
yticks([0 1 2 3 4 5 6 7])
axis equal
arrowh([x(125) x(126)],[y(125) y(126)],'k',400);
grid
xlim([z0(1)-r0-1, z0(1)+r0+1]);
ylim([z0(2)-r0-1, z0(2)+r0+1]);
hold off

% Then pick the large fonts and print out the plot
set(gca, 'FontName', 'Arial')
prepfig
bigfont(gcf,1.2,1)
%print(gcf, 'CauchyCircle', '-djpeg')
%print -dpdf ..\signalgraphics\samp_interpB

