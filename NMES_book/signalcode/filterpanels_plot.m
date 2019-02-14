close all
  
filterpanels

for k=1:5
    subplot(1,5,k);
    if(k==1)
        title('Broadband');
    else
        title([int2str(fmins{k}(1)) '-' int2str(fmaxs{k}(1)) 'Hz'])
    end
    ytick(0:.25:1.5)
    if(k>1);set(gca,'yticklabel',[]);end
    set(gca,'xticklabel',[]);set(gca,'ygrid','on')
end

subplot(1,5,1)
ylabel('time (sec)')
subplot(1,5,2)
text(800,.75,'A')
subplot(1,5,3)
text(200,.9,'B')
text(400,.25,'C')
subplot(1,5,4)
text(200,.9,'B')
text(400,.25,'C')
subplot(1,5,5)
text(400,.25,'C')
prepfig
bigfont(gcf,.8,1);

print -depsc ..\signalgraphics\filterpanels

figure
A0=As{1};
Am=max(A0);
linesgray({f,todb(A0,Am),'-',1.5,.85},{f,todb(As{2},Am),'-',.5,0},...
    {f,todb(As{3},Am),':',.5,.3},{f,todb(As{4},Am),'-',.5,.5}, {f,todb(As{5},Am),'-',.5,.75});
xlabel('frequency (Hz)')
ylabel('decibels')
xlim([0 100]);ylim([-120 0])
grid
legend('Total spectrum',[int2str(fmins{2}(1)) '-' int2str(fmaxs{2}(1)) 'Hz'],...
    [int2str(fmins{3}(1)) '-' int2str(fmaxs{3}(1)) 'Hz'],...
    [int2str(fmins{4}(1)) '-' int2str(fmaxs{4}(1)) 'Hz'],...
    [int2str(fmins{5}(1)) '-' int2str(fmaxs{5}(1)) 'Hz'],...
    'location','east');
prepfig
bigfont(gcf,1.25,1)
legendfontsize(1.25)

print -depsc .\signalgraphics\panelspectra