%make two similar signals with one shifted slightly
close all
dt=.002;
tmax=1;
tlen=.1;
t1=.4;t2=.6;
lags=[-5  0  5];
shifts=[0 5];
theta=[0 45];
[r,tr]=reflec(tmax,dt,.1,3,4);
f1=figure;
fdom=30;
fs=8;
[w,tw]=ricker(dt,fdom,tlen);
ccpanel=1;
for kk=1:length(shifts)
    if(kk==1)
        f2=figure;
    else
        f3=figure;
    end
for j=1:length(theta)
    s1=convz(r,w);
    ind=near(tr,t1,t2);
    s2=stat(phsrot(s1,theta(j)),tr,shifts(kk)*dt);
    s1=s1(ind);
    s2=s2(ind);
    t=tr(ind)-t1;
    shift=.04;
    s2lag=s2;
    tlag=t;
    
    figure(f1)
    subplot(2,2,ccpanel)
    ccpanel=ccpanel+1;
    ccfunc=conv(s2,flipud(s1));
    ccfunc=ccfunc/sqrt(sum(s1.^2)*sum(s2.^2));
    tau=(-length(s1)+1:length(s1)-1)*dt;
    linesgray({tau,ccfunc,'-',.5,0})
    text(-.2,.8,['s_2 shift= ' num2str(dt*shifts(kk)) 's'],'fontsize',fs)
    text(-.2,.6,['s_2 rot= ' num2str(theta(j)) '^o'],'fontsize',fs)
    xlabel('lag (s)');ylabel('cc')
    grid
    if(kk==1)
        figure(f2)
    else
        figure(f3);
    end
    subplot(1,2,j)
    xlabel('lag (sec)')
    inc=shift/8;
    for k=1:length(lags)
        tlag=t+lags(k)*dt;
        hh=linesgray({t,s1+(k-1)*shift,'-',.5,.5,'o',2},{tlag,s2lag+(k-1)*shift,'-',.5,0,'o',1});
        ind=near(tau,-lags(k)*dt);
        cc=ccfunc(ind);
        text(.1,(k-1)*shift-2*inc,['Lag \tau = ', num2str(-dt*lags(k))],'fontsize',fs);
        text(.1,(k-1)*shift-3*inc,['cc = ' num2str(sigfig(cc,2))],'fontsize',fs)
    end
    xlim([-.05 .25])
    legend(hh,'s_1(t)','s_2(t)')
    set(gca,'yticklabel',[])
    title(['s_2 shifted by ' num2str(dt*shifts(kk)) 's, rotated by ', num2str(theta(j)) '^o'])
    grid
end

end
  figure(f1)
  prepfig
  bigfont(gcf,.8,1)
  print -depsc ..\signalgraphics\ccfuncs
  
  figure(f2)
  prepfig
  bigfont(gcf,.8,1)
  legendfontsize(.8)
  titlefontsize(.8,1)
  print -depsc2 ..\signalgraphics\ccpanel1
  
  figure(f3)
  prepfig
  bigfont(gcf,.8,1)
  legendfontsize(.8)
  titlefontsize(.8,1)
  print -depsc2 ..\signalgraphics\ccpanel2
  
