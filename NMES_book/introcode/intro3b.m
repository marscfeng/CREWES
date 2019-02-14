clear;load testtrace.mat
figure
amax=max(abs(tracefar));
for k=1:10
   clip_level= amax*(.5)^(k-1);
   trace_clipped=clip(tracefar,clip_level);
   trace_adj=trace_clipped*amax/max(abs(trace_clipped));
   wtva(trace_adj+(k-1)*3*amax,t,'k',(k-1)*3*amax,1,1,1);
   ht=text((k-1)*3*amax,-.05,[int2str(-(k-1)*6) 'dB']);
   set(ht,'horizontalalignment','center')
end
flipy;ylabel('seconds');
prepfig
bigfont(gcf,1.7,1)
xlim([-.05 .55])

print -depsc .\intrographics\intro3b