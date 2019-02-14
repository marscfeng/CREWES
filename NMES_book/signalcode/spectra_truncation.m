dt=.002;%time sample size
tmax=1.022;%Picked to make the length a power of 2
[r,t]=reflec(tmax,dt,.2,3,4);%reflectivity
r(end-100:end)=0;%zero the last 100 samples
r(end-50)=.1;%put a spike in the middle of the zeros
fmin=[10 5];fmax=[60 20];%used for filtf
n=4;%Butterworth order
sbm=butterband(r,t,fmin(1),fmax(1),2*n,1);%minimum phase butterworth
sbz=butterband(r,t,fmin(1),fmax(1),n,0);%zero phase butterworth
mw1=mwindow(length(sbz),5);
sbzw=sbz.*mw1;
mw2=mwindow(length(sbz),10);
sbzw2=sbz.*mw2;
figure
subplot(2,1,1)
linesgray({t,sbz,'-',.75,.75},{t,sbzw,'-',.5,.4},{t,sbzw2,'-',.5,0});
xlabel('time (sec)')
xlim([0 .4])
subplot(2,1,2)
dbspec(t,[sbz sbzw sbzw2],'linewidths',[.75 .5 .5],'graylevels',[.75 .4 0]);
legend('zero-phase butterband','zero-phase butterband 5% tapered',...
    'zero-phase butterband 10% tapered','location','northeast'); 
prepfig
bigfont(gcf,.8,1)
legendfontsize(.8)

print -depsc ..\signalgraphics\spectratrunc