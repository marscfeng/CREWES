%dft_frequencies_plot

ns=[3 4];
syms={'*' 'o'};
sizes=[6 8];
dt=.004;
fnyq=.5/dt;

figure

%plot the unit circle
theta=0:.01:2*pi;
xunit=cos(theta);
yunit=sin(theta);
hunit=linesgray({xunit,yunit,'-',.5,.5});
xlim([-1.5 1.5]);ylim([-1.5 1.5]);
axis square
grid

xf=cell(size(ns));
yf=xf;
fs=xf;
ws=xf;

for k=1:length(ns)
    dw=2*pi/ns(k);
    df=2*fnyq/ns(k);
    ws{k}=0:dw:2*pi;
    fs{k}=0:df:2*fnyq;
    xf{k}=cos(ws{k});
    yf{k}=sin(ws{k});
end

hh=linesgray({xf{1},yf{1},'none',.5,0,syms{1},sizes(1)},{xf{2},yf{2},'none',.5,0,syms{2},sizes(2)});

for k=1:length(ns)
    x=xf{k};
    y=yf{k};
    if(k==1)
        ha='left';
        nudge=0.1;
    else
        ha='right';
        nudge=-0.1;
    end
    for j=1:length(fs{k})-1
        theta=ws{k}(j)*180/pi;
        theta2=theta;
        if(theta2>90 && theta2<=180); theta2=180-theta2; end
        f=round(fs{k}(j)*10)/10;
        if(f>fnyq); f=-2*fnyq+f; end
%         text(x(j)+nudge*cos(theta),y(j)+nudge*sin(theta),num2str(f),'horizontalalignment',ha,'rotation',theta);
        text((1+nudge)*cosd(theta),(1+nudge)*sind(theta),num2str(f),'rotation',theta,'horizontalalignment',ha);
    end
end
legend(hh,['N= ' num2str(ns(1))],['N= ' num2str(ns(2))],'location','northwest');
xlabel('real axis');ylabel('imaginary axis')
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)
    
print -depsc ..\signalgraphics\freq_values_3_4    
    
%%
%dft_frequencies_plot

ns=[8 9];
syms={'*' 'o'};
sizes=[6 8];
dt=.004;
fnyq=.5/dt;

figure

%plot the unit circle
theta=0:.01:2*pi;
xunit=cos(theta);
yunit=sin(theta);
hunit=linesgray({xunit,yunit,'-',.5,.5});
xlim([-1.5 1.5]);ylim([-1.5 1.5]);
axis square
grid

xf=cell(size(ns));
yf=xf;
fs=xf;
ws=xf;

for k=1:length(ns)
    dw=2*pi/ns(k);
    df=2*fnyq/ns(k);
    ws{k}=0:dw:2*pi;
    fs{k}=0:df:2*fnyq;
    xf{k}=cos(ws{k});
    yf{k}=sin(ws{k});
end

hh=linesgray({xf{1},yf{1},'none',.5,0,syms{1},sizes(1)},{xf{2},yf{2},'none',.5,0,syms{2},sizes(2)});

for k=1:length(ns)
    x=xf{k};
    y=yf{k};
    if(k==1)
        ha='left';
        nudge=0.1;
    else
        ha='right';
        nudge=-0.1;
    end
    for j=1:length(fs{k})-1
        theta=ws{k}(j)*180/pi;
        theta2=theta;
        if(theta2>90 && theta2<=180); theta2=180-theta2; end
        f=round(fs{k}(j)*10)/10;
        if(f>fnyq); f=-2*fnyq+f; end
%         text(x(j)+nudge*cos(theta),y(j)+nudge*sin(theta),num2str(f),'horizontalalignment',ha,'rotation',theta);
        text((1+nudge)*cosd(theta),(1+nudge)*sind(theta),num2str(f),'rotation',theta,'horizontalalignment',ha);
    end
end
legend(hh,['N= ' num2str(ns(1))],['N= ' num2str(ns(2))],'location','northwest');
xlabel('real axis');ylabel('imaginary axis')
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)
    
print -depsc ..\signalgraphics\freq_values_8_9 