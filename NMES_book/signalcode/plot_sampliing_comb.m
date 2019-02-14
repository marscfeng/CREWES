sampling_comb2

figure
nplot=0;
labels={'a)', 'b)', 'c)', 'd)', 'e)', 'f)'};
for k=1:length(delt)
    nplot=nplot+1;
    subplot(length(delt),2,nplot)
    plot(t,c(:,k),'k')
    xlim([1.9 2.1])
    ylim([0 1.5])
    text(1.9,1.2,labels{nplot});
    if(k==1); title('Time'); end
    if(k==3); xlabel('time (s)'); end
    nplot=nplot+1;
    subplot(length(delt),2,nplot)
    plot(f,C(:,k),'k')
    xlim([-500 500])
    xtick([-500 -250 0 250 500])
    yl=get(gca,'ylim');
    text(-500,.6*yl(2),labels{nplot});
    if(k==1); title('Frequency'); end
    if(k==3); xlabel('frequency (Hz)'); end
end
prepfig
bigfont(gcf,.7,1);
titlefontsize(1,1)

print -depsc2 -r600 ..\signalgraphics\combs