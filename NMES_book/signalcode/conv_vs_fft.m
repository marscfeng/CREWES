N=4:1024;
nreps=1000;
tc=zeros(size(N));
tc2=zeros(size(N));
tfft=zeros(size(N));

for k=1:length(N)
    s1=rand(1,N(k));
    s2=s1;
    ss2=s2(1:round(length(s2)/4));
    tic
    for kk=1:nreps
        tmp=conv(s1,s2);
    end
    tc(k)=toc;
    tic
    for kk=1:nreps
        tmp=conv(s1,ss2);
    end
    tc2(k)=toc;
    tic
    for kk=1:nreps
        tmp=ifft(fft(s1).*fft(s2));
    end
    tfft(k)=toc;
    if(rem(k,20)==0)
        disp(['Finished k=' int2str(k)])
    end
end