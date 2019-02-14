clear;load testtrace.mat
figure
plot(t,tracefar,'k')
[h,hva]=wtva(tracefar+.02,t,'k',.02,1,-1,1);
axis([.2 .8 -.02 .04])
xlabel('time (sec)')
prepfiga
bigfont(gcf,1.7,1)

print -deps .\intrographics\intro3a
