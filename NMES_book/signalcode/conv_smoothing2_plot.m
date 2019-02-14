conv_smoothing2

figure
inc=max(abs(sn));
fs=10;
for k=1:length(tsmo)+3
    plot(t,sfilt(:,k)+(k-1)*inc,'k');
    if(k==1)
        hold
        text(tmax,0,'Noise free trace','fontsize',fs);
    elseif(k==2)
        text(tmax,inc,'Noisy trace','fontsize',fs);
    elseif(k<length(tsmo)+3)
        text(tmax,(k-1)*inc,['tsmo=' num2str(tsmo(k-2)) 's'],'fontsize',fs);
    else
        text(tmax,(k-1)*inc,'filtf','fontsize',fs);
    end
end
xlim([0 1.4])
xtick(0:.2:1);
ytick([]);
prepfig
bigfont(gcf,1.5,1)
xlabel('time (s)')

print -depsc .\signalgraphics\convosmooth