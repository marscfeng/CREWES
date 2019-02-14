[r,t]=reflec(1,.002,.2);

tic
for k=1:100
   r2=clip(t,.05);
end
toc

tic
for k=1:100
   r2=fortclip(t,.05);
end
toc
