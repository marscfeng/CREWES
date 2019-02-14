close all

filtering;

nt=length(t);

figure
subplot(2,1,1)
linesgray({t,r,'-',.5,.7},{t,sbz+.1,'-',.5,.5},{t,sfz+.2,'-',.5,.3},{t,soz+.3,'-',.5,0});
xlabel('time (sec)');
%legend('input','butter z','filtf z','ormsby z')

subplot(2,1,2)
hh1=dbspec(t,[r sbz sfz soz],'windowflags',[0 0 0 0],'linewidths',[.5,.5,.5,.5],'graylevels',[.7,.5,.3,0]);
%set(hh(4),'linestyle','none','marker','.')
legend('input','butterband','filtf','filtorm','location','southwest')
ylim([-100 0])
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)

print -depsc ..\signalgraphics\filtering1z

figure
subplot(2,1,1)
linesgray({t,r,'-',.5,.7},{t,sbm+.1,'-',.5,.5},{t,sfm+.2,'-',.5,.3},{t,som+.3,'-',.5,0});
xlabel('time (sec)');
%legend('input','butter m','filtf m','ormsby m')

subplot(2,1,2)
hh1=dbspec(t,[r sbm sfm som],'linewidths',[.5,.5,.5,.5],'graylevels',[.7,.5,.3,0]);
%set(hh(4),'linestyle','none','marker','.')
legend('input','butterband','filtf','filtorm','location','southwest')
ylim([-100 0])
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8)

print -depsc ..\signalgraphics\filtering1m
