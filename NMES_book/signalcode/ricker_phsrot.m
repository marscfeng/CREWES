dt=.0005;
tlen=.2;
fdom=30;
[w,tw]=ricker(dt,fdom,tlen);
wa=hilbert(w);
wh=imag(wa);
wperp=-imag(wa);
wperp2=phsrot(w,90);

figure
%plot(tw,w,tw,wperp)
hhh=linesgray({tw,wh,'-',1,.3},{tw,wperp,'-',1,.7},{tw,w,'-',.5,0});
xlabel('time (sec)')
legend([hhh(3) hhh(1:2)],'30 Hz Ricker','Hilbert transform of Ricker',...
    '90^o phase rotation','location','northwest','location','northeast')
prepfig
xlim([-.1 .11])
xtick(-.08:.04:.08)
grid
bigfont(gcf,1.8,1);boldlines(gcf,1.5)
%legendfontsize(2)
print -depsc .\signalgraphics\ricker_hilbert

angles=0:45:315;
w45=cosd(45)*w+sind(45)*wperp;
w135=cosd(135)*w+sind(135)*wperp;
w180=cosd(180)*w+sind(180)*wperp;
w225=cosd(225)*w+sind(225)*wperp;
w270=cosd(270)*w+sind(270)*wperp;
w315=cosd(315)*w+sind(315)*wperp;

figure
% plot(tw,[w wperp w45 w135 w180 w225 w270 w315])
% xlabel('time(sec)')
% legend({'Ricker 0^\circ','Ricker 90^\circ','Ricker 45^\circ',...
%     'Ricker 135^\circ','Ricker 180^\circ','Ricker 225^\circ','Ricker 270^\circ',...
%     'Ricker 315^\circ'})
% plot(tw,[w w45 w135 w225 w315])
% xlabel('time(sec)')
% legend({'Ricker 0^\circ','Ricker 90^\circ','Ricker 45^\circ',...
%     'Ricker 135^\circ','Ricker 180^\circ','Ricker 225^\circ','Ricker 270^\circ',...
%     'Ricker 315^\circ'})
inc=.05;
fs=10;
%plot(tw,[w w45+inc wperp+2*inc w135+3*inc w180+4*inc w225+5*inc w270+6*inc w315+7*inc])
linesgray({tw,w,'-',.5,.2},{tw,w45+inc,'-',.5,.2},{tw,wperp+2*inc,'-',.5,.2},...
    {tw,w135+3*inc,'-',.5,.2},{tw,w180+4*inc,'-',.5,.2},{tw,w225+5*inc,'-',.5,.2},...
    {tw,w270+6*inc,'-',.5,.2},{tw,w315+7*inc,'-',.5,.2});
for k=1:length(angles)
    ht=text(.05,(k-1)*inc,['Rotated ' int2str(angles(k)) '^\circ']);
    set(ht,'horizontalalignment','right','verticalalignment','bottom',...
        'fontsize',fs);
end
xlabel('time (sec)')
% legend({'Ricker 0^\circ','Ricker 45^\circ',...
%     'Ricker 135^\circ','Ricker 225^\circ',...
%     'Ricker 315^\circ'})
grid
xtick(-.04:.02:.04);
xlim([-.05 .05])
prepfig
bigfont(gcf,1.8,1);boldlines(gcf,1.5)

print -depsc .\signalgraphics\ricker_rotations
