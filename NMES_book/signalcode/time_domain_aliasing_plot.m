close all

time_domain_aliasing_central2

rr=[zeros(size(r));r;zeros(size(r))];
ra=[r;r;r];
ta=dt*(-length(r):2*length(r)-1)';
figure;
subplot(2,1,1)
linesgray({ta,rr,'-',.5,0})
xlim([-1 2])
subplot(2,1,2)
linesgray({ta,ra,'-',.5,.5},{t,r,'-',.5,0})
xlim([-1 2])
xlabel('time (sec)')
prepfig
legend('time-domain aliases','original trace','location','northwest')
bigfont(gcf,.8,1)

print -depsc ..\signalgraphics\timealias



%theory say sm and sm2 should be identical. Are they?
figure;
subplot(2,1,1)
h1=linesgray({t,wimp,'-',.5,.5});
subplot(2,1,2)
h2=linesgray({t,s_fd,'-',1.5,.7},{t,s_td,'-',.5,0});
xlabel('time (sec)')
legend([h1 h2],'Wavelet','Multiplication in Fourier domain','Direct convolution')
prepfig
bigfont(gcf,.8,1)
print -depsc ..\signalgraphics\timedomainwraparound

%to avoid time-domain aliasing, we apply a zero pad to r before filtering

rpa=[rp;rp;rp];
tpa=dt*(-length(rp):2*length(rp)-1)';
figure
subplot(2,1,1)
h3=linesgray({tpa,rpa,'-',.5,.5},{tp,rp,'-',.5,0});
xlabel('time (sec)')
xlim([-1.5 3])
legend(h3,'time-domain aliases','padded reflectivity');
%apply the filter to rp

subplot(2,1,2)
linesgray({tp,s_fdp,'-',1.5,.7},{t,s_td,'-',.5,0});
xlabel('time (sec)')
legend('Padded and filtered in freq. domain','Direct convolution');
prepfig
bigfont(gcf,.8,1)
legendfontsize(.8)

print -depsc ..\signalgraphics\timealiasingpadded