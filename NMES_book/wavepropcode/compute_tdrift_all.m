compute_tdrift

figure
subplot(1,2,1)
plot(vp,z,'k');flipy;grid
xlabel('velocity m/s');
ylabel('depth (m)')
title('P-wave velocity from a Canadian well')

subplot(1,2,2)
%linesgray({tdr(:,1),z,'-',.5,0},{tdr(:,2),z,'-',.75,.3},{tdr(:,3),z,'-',1.25,.6});
linesgray({tdr(:,1),z,'-',.5,0},{tdr(:,2),z,'-.',.5,0},{tdr(:,3),z,':',.5,0});
flipy;
grid;
ylabel('depth (m)');xlabel('drift time (s)')
title('two-way drift times');
legend(['Q= ' num2str(Q(1))],['Q= ' num2str(Q(2))],['Q= ' num2str(Q(3))])

prepfig
bigfont(gcf,1.25,1)

print -depsc wavepropgraphics\drift.eps