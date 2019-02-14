load wellog
figure
plot(tlog,rcs);
for k=1:7
    [rsyn,tsyn]=reflec(max(tlog),tlog(2)-tlog(1),max(rcs),k);
    line(tlog,rsyn+k*1.1*max(rcs));
end