function wavepropfig1()
%wavepropfig1 creates an eps figure for the book, wave propagation
%   no inputs, no outputs. This is admittedly a bit of a hack.

xleft=-2;  % I needed just a little more space on the left
xright=6;  % here is the right side
kink = 2;  % we want the minimum velocity at kink


x = linspace(xleft,xright,500);
t = Slowness(x);

% plot (x,mywave(Slowness(x)))

figure(1)
clf
hold on
for j=0:5
  h = plot(x,t+j,'k'), h.Color = [.8 .8 .8]; % draw curves in gray
end

plot(x,4.5*mywave(0-Slowness(x)),'k')
plot(x,5+4.5*mywave(5-Slowness(x)),'k')
plot(x,10+4.5*mywave(10-Slowness(x)),'k')
plot(x,15+4.5*mywave(15-Slowness(x)),'k')
title('One-way wave propagation')
xlabel('Position')
ylabel('Time')
prepfig
bigfont(gcf,.8,1)

print -depsc hetero_waveform

figure(2)
clf
hold on
for j=0:5
  h = plot(x,t+j,'k'), h.Color = [.8 .8 .8];
end

plot(x,3*mywave(0-Slowness(x))./c(x),'k')
plot(x,5+3*mywave(5-Slowness(x))./c(x),'k')
plot(x,10+3*mywave(10-Slowness(x))./c(x),'k')
plot(x,15+3*mywave(15-Slowness(x))./c(x),'k')

title('One-way wave propagation')
xlabel('Position')
ylabel('Time')
prepfig
bigfont(gcf,.8,1)

function y = c(x) 
    % velocity = c(x). the reciprocal of the derivative of slowness
  y = 1 ./(1 + 4 ./(1 + (x-kink).^2));
end

% this is the antiderivative of the velocity a(x) in the wave equation
function y = Slowness(x)
  y = (x + 4*(atan(1*(x-kink))-atan(0-kink))); % normalized so Slowness(0) = 0
end

% this is the waveform shape to plot. a simple bump, between x=0,2.
function y = mywave(x)  
    y = max(0,1-(x-1).^2);
end

% this is the waveform shape to plot. A Ricker wavelet
function y = mywaveRW(x)  
    s = .5;
    x=x-1;
    y = (1-(x/s).^2).*exp(-.5*(x/s).^2);
end

end

