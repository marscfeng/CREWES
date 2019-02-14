reflec_spec
figure
subplot(3,1,3)
plot(f,R,'k')
ylim([-60 0]);xlim([0 250])
ytick([0 -30 -60]);grid
ylabel('dB');xlabel('Hz');


subplot(3,1,1)
plot(f,S1,'k',fwr,Wr,'k:')
ylim([-60 0]);xlim([0 250])
ytick([-60 -30 0]);grid
ylabel('dB');

subplot(3,1,2)
plot(f,S2,'k',fwm,Wm,'k:')
ylim([-60 0]);xlim([0 250])
ytick([-60 -30 0]);grid
ylabel('dB');

prepfig