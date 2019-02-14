trcs=501:-100:1;
figure;
for k=1:length(trcs)
	trace=seis(:,trcs(k));
   env=abs(hilbert(trace));
   if(k==1)
      emax=max(env);
   end
   envdb=todb(env,emax);
   line(t,envdb);
end
