dt=.001;
tlen=2;
fdom=30;
[w,tw]=wavemin(dt,fdom,tlen,3);
delt=[0 dt 10*dt 100*dt];
ws=zeros(length(w),length(delt));
ws(:,1)=w;
[W,f]=fftrl(w,tw);
Ps=zeros(length(W),length(delt));
phs=Ps;
Ps(:,1)=angle(W);
phs(:,1)=angle(W);
for k=2:length(delt)
    ws(:,k)=stat(w,tw,delt(k));
    [W,f]=fftrl(ws(:,k),tw);
    Ps(:,k)=angle(W);
    phs(:,k)=phs(:,1)+2*pi*f*delt(k);
end

fs=12;
figure
subplot(3,1,1)
%plot(tw,ws)
linesgray({tw,ws(:,1)},{tw,ws(:,2),':'},{tw,ws(:,3)},{tw,ws(:,4)});
legend('0ms shift','1ms shift','10ms shift','100ms shift')
xlim([0 .2])
xlabel('time (s)')
text(.005,.1,'a)','fontsize',fs);
subplot(3,1,2)
%plot(f,angle(Ws))
linesgray({f,Ps(:,1)},{f,Ps(:,2),':'},{f,Ps(:,3)},{f,Ps(:,4)});
xlim([0 200]);
ytick([-3.14 0 3.14]);
set(gca,'ygrid','on')
set(gca,'yticklabel',{'-\pi' '0' '\pi'},'ygrid','on')
xlabel('frequency (Hz)')
text(5,1.3*pi,'b)','fontsize',fs);
subplot(3,1,3)
%plot(f,phs)
linesgray({f,phs(:,1)},{f,phs(:,2),':'},{f,phs(:,3)},{f,phs(:,4)});
xlabel('frequency (Hz)')
xlim([0 200])
ylim([-20 150])
set(gca,'ygrid','on')
text(5,125,'c)','fontsize',fs);
prepfig
bigfont(gcf,1,1);
legendfontsize(1.2)

print -depsc .\signalgraphics\phaseshift


%%
%graph tangent
pie=pi+10*eps;
dtheta=6*pie/1000;
theta=-1.5*pie:dtheta:1.5*pie;
y=tan(theta);
ind=find(abs(y)>10);
y(ind)=nan;

figure
h=patch([-pi pi pi -pi],[-10 -10 10 10],.95*[1 1 1]);
h2=patch([-pi/2 pi/2 pi/2 -pi/2],[-10 -10 10 10],.9*[1 1 1]);
set(h,'edgecolor','none')
set(h2,'edgecolor','none')
hold on
hh=plot(theta,y,'k',[-pi/2 -pi/2],[-10 10],'k:',[pi/2 pi/2],[-10 10],'k:',...
    [-pi -pi],[-10 10],'k--',[pi pi],[-10 10],'k--',[0 0],[-10 10],'k:');
ylim([-8 8])
xtick([-3.14 -1.57 0 1.57 3.14])
set(gca,'xticklabel',{'-\pi' '-\pi/2' '0' '\pi/2' '\pi'})
xlabel('angle (radians)');ylabel('tangent')
legend([hh(1) h h2],'tangent','range of ATAN2','range of ATAN','location','northwest');
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)

print -depsc .\signalgraphics\tangent
