nw=4;
dt=.001;
tlen=1;
f1=5*ones(1,nw);
f2=10*ones(1,nw);
f3=f1(1)+15*(1:nw);
f4=f3+10;
leg=cell(1,nw);

for k=1:nw
    [w,tw]=ormsby(f1(k),f2(k),f3(k),f4(k),tlen,dt);
    [W,fw]=fftrl(w,tw);
    if(k==1)
        waves=ones(length(w),nw);
        Waves=ones(length(W),nw);
    end
    waves(:,k)=w;
    Waves(:,k)=W;
    %leg{k}=['f1-f2-f3-f4=' int2str(f1(k)) '-' int2str(f2(k)) '-' int2str(f3(k)) '-' int2str(f4(k)) ' (Hz)'];
    leg{k}=['Ormsby ' int2str(f1(k)) '-' int2str(f2(k)) '-' int2str(f3(k)) '-' int2str(f4(k)) ' (Hz)'];
end

figure
lw=linspace(1.5,.5,nw);
gl=linspace(.7,0,nw);
for k=1:nw
    subplot(2,1,1)
    %plot(tw,waves(:,k))
    linesgray({tw,waves(:,k),'-',lw(k),gl(k)});
    if(k==1)
        hold on
        grid
    end
    subplot(2,1,2)
    %plot(fw,abs(Waves(:,k)))
    linesgray({fw,abs(Waves(:,k)),'-',lw(k),gl(k)});
    if(k==1)
        hold on
        grid
    end
end
subplot(2,1,1)
xlabel('time (sec)')
xlim([-.05 .05])
subplot(2,1,2)
xlabel('frequency (Hz)')
xlim([0 125])
legend(leg)

prepfig
bigfont(gcf,.75,1)

print -depsc ..\signalgraphics\fatskinny1