% MPL. Make some figures showing interpolation of samples.
% For  chapter on discrete signals (First figure) 
close all
dt=.001; % sampling rate
tmax=1; % interval range
t = -tmax:dt:tmax;
s = (1-10*t.^2).*exp(-8*t.^2);
stepsize = 200;
samp = 1:stepsize:length(t);
ssamp = s(samp);

bump = 0*t;
bump( abs(t) <= (stepsize+1)*dt/2 ) = 1;

%figure(1)
%plot(t,s,'-',t(samp),s(samp),'o',t, bump)

% Let's build a piecewise constant approximation, using translates of a
% bump function

papprox = 0*t;
for j=1:length(samp)
    papprox( abs(t - t(samp(j))) <= (stepsize+1)*dt/2) = s(samp(j));
end
%figure(2) 
%plot(t,papprox,'-', t(samp),s(samp),'o')


figure(1)
    subplot(2,1,1)
    hold on
    plot(t,s,'-k',t(samp),s(samp),'ok')
    linesgray({t,bump,'-',.1,.5})
    %xlabel("Time")
    ylabel("Amplitude")
    xticks([-1.0 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0])
    ylim([-1,1])
    hold off
    subplot(2,1,2)
    plot(t,papprox,'-k', t(samp),s(samp),'ok')
    %xlabel("Time")
    ylabel("Amplitude")
    xticks([-1.0 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0])
    ylim([-1,1])
    set(gca, 'FontName', 'Arial')


prepfig
bigfont(gcf,1.2,1)
print(gcf, 'samp_interpA', '-djpeg')
%print -depsc ..\signalgraphics\samp_interpA


% Now using the sinc function
sbump = sinc(t/(dt*stepsize));

sapprox = 0*t;
for j=1:length(samp)
    sapprox = sapprox + s(samp(j))*sinc((t-t(samp(j)))/(dt*stepsize));
end


figure(2) 
    subplot(2,1,1)
    hold on
    plot(t,s,'-k', t(samp),s(samp),'Ok')
    linesgray({t,sbump,'-',.1,.5})
    %xlabel("Time")
    ylabel("Amplitude")
    xticks([-1.0 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0])
     ylim([-1,1])
  hold off
    subplot(2,1,2)
    plot(t(samp),s(samp),'ok')
    hold on
    for j=4:(length(samp)-3)
        linesgray({t,s(samp(j))*sinc((t-t(samp(j)))/(dt*stepsize)),'-',.1,.5})
        %plot(t,s(samp(j))*sinc((t-t(samp(j)))/(dt*stepsize)),'k')
    end
    plot(t,sapprox,'-k')
    %xlabel("Time")
    ylabel("Amplitude")
    xticks([-1.0 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0])
    ylim([-1,1])
    hold off

prepfig
bigfont(gcf,1.2,1)
print(gcf, 'samp_interpB', '-djpeg')
%print -dpdf ..\signalgraphics\samp_interpB


%%

tlen=.1;
t1=.4;t2=.6;
lags=[-5  0  5];
shifts=[0 5];
theta=[0 45];
[r,tr]=reflec(tmax,dt,.1,3,4);
f1=figure;
fdom=30;
fs=8;
[w,tw]=ricker(dt,fdom,2);

plot(tw,w,[.2 .3],[-1,1])

%%
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
  %print -depsc ..\signalgraphics\ccfuncs
  
  figure(f2)
  prepfig
  bigfont(gcf,.8,1)
  legendfontsize(.8)
  titlefontsize(.8,1)
  %print -depsc2 ..\signalgraphics\ccpanel1
  
  figure(f3)
  prepfig
  bigfont(gcf,.8,1)
  legendfontsize(.8)
  titlefontsize(.8,1)
  %print -depsc2 ..\signalgraphics\ccpanel2
  
