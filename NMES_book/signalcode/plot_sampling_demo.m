sampling_demo

figure
subplot(2,1,1)
linesgray({t1,s1,'-',.5,0},{t1(1:inc:end),s2(1:inc:end),'none',.5,.5,'o',3})
xlabel('time (sec)')
xlim([.3 .7]);ylim([-1.5 1])
text(.3,.8,'a)')
hl=legend('continuous signal','sampling locations');
set(hl,'position',[0.7    0.63    0.1619    0.0739]);
grid
subplot(2,1,2)
linesgray({t1,s2,'-',.5,0},{t1(1:inc:end),s2(1:inc:end),'none',.5,.5,'o',3})

xlabel('time (sec)')
xlim([.3 .7]);ylim([-1.5 1])
text(.3,.8,'b)')
hl=legend('sampled signal','sampling locations');
set(hl,'position',[0.7    0.15    0.1619    0.0739]);
prepfig
bigfont(gcf,1.5,1)
grid
legendfontsize(1)

print -depsc .\signalgraphics\samplingtime

figure
subplot(2,1,1)
plot(f1,S1/max(S1),'k');
xlim([-375 375])
legend('continuous spectrum')
xlabel('frequency (Hz)')
text(-375,0.8,'a)') 
grid
subplot(2,1,2)
hh=linesgray({f1,S2/max(S2),'-',.5,.5},{f1(ind),S2(ind)/max(S2),'-',.5,0});
hl=legend(hh,'Aliases','Principal band');
set(hl,'position',[.7    0.4369    0.1687    0.1050]);
xlim([-375 375])
xlabel('frequency (Hz)')
text(-375, 0.8,'b)')
prepfig
grid
bigfont(gcf,1.5,1)
legendfontsize(1)

print -depsc .\signalgraphics\samplingfrequency

%% aliased case
sampling_demo_a

figure
subplot(2,1,1)
linesgray({t1,s1,'-',.5,0},{t1(1:inc:end),s2(1:inc:end),'none',.5,.5,'o',3})
legend('continuous signal','sampling locations')
xlabel('time (sec)')
xlim([.3 .7])
text(.3,.8,'a)')
subplot(2,1,2)
linesgray({t1,s2,'-',.5,0},{t1(1:inc:end),s2(1:inc:end),'none',.5,.5,'o',3})
legend('sampled signal','sampling locations')
xlabel('time (sec)')
xlim([.3 .7])
text(.3,.8,'b)')
prepfig
legendfontsize(.75)

print -depsc .\signalgraphics\samplingtime

figure
subplot(2,1,1)
plot(f1,S1/max(S1),'k');
xlim([-375 375])
legend('continuous spectrum')
xlabel('frequency (Hz)')
text(-375,0.8,'a)') 
grid
subplot(2,1,2)
hh=linesgray({f1,1.25*S2/max(S2),'-',.5,.5},{f1(ind),1.25*S2(ind)/max(S2),'-',.5,0});
hp1=patch([-170 -80 -80 -170],[0 0 1 1],[-1 -1 -1 -1],.95*[1 1 1]);
hp2=patch([170 80 80 170],[0 0 1 1],[-1 -1 -1 -1],.95*[1 1 1]);
legend([hh hp1],'Aliases','Principal band','Aliased frequencies');
xlim([-375 375])
ylim([0 1])
xlabel('frequency (Hz)')
text(-375, 0.8,'b)')
grid
prepfig
legendfontsize(.75)

print -depsc .\signalgraphics\samplingfrequency