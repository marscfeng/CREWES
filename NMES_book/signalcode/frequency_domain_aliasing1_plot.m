frequency_domain_aliasing1

tbeg=.55;tend=.6;
ind1=near(t1,tbeg,tend);ind2=near(t2,tbeg,tend);ind4=near(t4,tbeg,tend);
figure
subplot(2,1,1)
linesgray({t1(ind1),s1(ind1),'-',1,.7,'*',3},{t2(ind2),s2(ind2),'-',.5,0},...
    {t4(ind4),s4(ind4),':',1,0});
xlabel('time (sec)');legend('\Delta t =.001s','\Delta t =.002s','\Delta t =.004s');
xlim([tbeg tend])
xtick(tbeg:.01:tend);

subplot(2,1,2)
linesgray({f1,abs(S1),'-',1,.7},{f2,abs(S2),'-',.5,0},...
    {f4,abs(S4),':',.5,0});
xlabel('frequency (Hz)');legend('\Delta t =.001s','\Delta t =.002s','\Delta t =.004s');
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8);

print -depsc ..\signalgraphics\fd_aliasing1a

ind=near(tint,tbeg,tend);
figure
linesgray({tint(ind),s1i(ind),'-',1.5,.7,'o',2},{tint(ind),s2i(ind),'-',.5,0,'x',2},...
    {tint(ind),s4i(ind),'-',1,.3,'*',2});
% linesgray({tint(ind),s1i(ind),'-',1.5,.7},{tint(ind),s2i(ind),'-',.5,0},...
%     {tint(ind),s4i(ind),':',1,0});
xlabel('time (sec)');legend('\Delta t =.001','\Delta t =.002','\Delta t =.004');
prepfig
bigfont(gcf,.8,1);
legendfontsize(.8);
xlim([tbeg tend])
xtick(tbeg:.01:tend);

print -depsc ..\signalgraphics\fd_aliasing1b
