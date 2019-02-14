t=linspace(0,5,5000);
w = 1;
M = 1;
N = 8;

g = zeros(N,5000);
for n=1:N
    g(n,:) = exp(-(t-(n-2)*M).^2/w^2);
end

sg = sum(g,1);

plot(t,g','k',t,sg,'k')
ylim([0,2])

title("Sum of Gaussians")
xlabel("Time (s)")
ylabel("Amplitude")
prepfig()