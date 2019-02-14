lengths=64:1024;%signal lengths to test
times=zeros(size(lengths));%array for times for each length
l2=[64 128 256 512 1024];%power of 2 lengths
tl2=zeros(size(l2));%array for times of each l2 length
nreps=1000;%number of repititions for each length
t1=clock;%grab start time
for k=1:length(lengths)
    s=rand(1,lengths(k));%generate a random number vector
    tic %start time
    for kk=1:nreps
        S=fft(s);%here is where all the work happens
    end
    times(k)=toc;%grab elapsed time for nreps reps.
    ind=find(lengths(k)==l2);%check for a power of 2 length
    if(~isempty(ind))
        tl2(ind)=times(k);%store result for power of 2
    end
end
timeused=etime(clock,t1);%total time. Same as sum(times)
disp(['total time ' int2str(timeused) 's for '...
    int2str(nreps*length(lengths)) 'ffts']);
tnln=lengths.*log(lengths);%proportional to exp. time for nlog(n)
tn2=lengths.^2;%proportional to expected time for n^2
tnln=tnln*times(100)/tnln(100);%scale tnln2 to these results
tn2=tn2*times(100)/tn2(100);%scale t2 to these results

hh=linesgray({lengths,times,'-',.5,0.7},{lengths,tnln,'-',.5,0},...
    {lengths,tn2,':',.5,0},{l2,tl2,'none',.5,0,'.',6});
