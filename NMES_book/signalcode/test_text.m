%
figure
xlim([-1 1])
ylim([-1 1])
text(0,0,'\omega_1 = \Sigma x_k','fontsize',24);

if verLessThan('matlab','8.4') % 8.4 == R2014b
    print -depsc testR2013b
else
    print -depsc testR2014b
end
