% make a synthetic reflectivity and a minimum phase wavelet
[r,t]=reflec(1,.001);%synthetic reflectivity
[w,tw]=wavemin(.001,30,.2);%min phase wavelet
s=convm(r,w);%convolve them using convm
%now plot the results using subplot to make 3 rows in the figure
figure
subplot(3,1,1)
plot(tw,w);%note this wavelet plot will have a different time scale from the other subplots
subplot(3,1,2)
plot(t,r)
subplot(3,1,3)
plot(t,s)
%now lets fix up the first subplot to have the same time scale as the
%others. We us "pad" for this
subplot(3,1,1)
plot(t,pad_trace(w,r))
% now lets do the convolution with a convolution matrix
%build a convolution matrix from w that is the right size to convolve with
%r
cmtx=convmtx(w,length(r));%the convolution matrix
plotimage(cmtx)%view it with plotimage
cmtxm=cmtx(1:1001,:);%grabbing the first 1001 rows because we want to simulate convm
plotimage(cmtxm)
s2=cmtxm*r;%this should be identical to s. Is it?
figure
plot(t,s,t,s2,'r.')%this plot suggests s and s2 are pretty close
sum(abs(s-s2))%this is a more precise test of equivalence
eps%eps tells me thee precision of my computer
% the fact that sum(abs(s-s2)) is similar to eps tells me that s and s2
% are equivalent to machine precision.
%%
%another way to make a convolution matrix is with the qmatrix command
%Q is the measure of attenuation in rocks. A Q of infinity means no
%attenuation while a Q of 50 is lots of attenuation.
qmat=qmatrix(inf,t,w,tw);%inf means "infinity" here.
plotimage(qmat)
title('Stationary Q matrix')
qmat2=qmatrix(50,t,w,tw);%another matrix for Q=50.
plotimage(qmat2)
title('Nonstationary Q matrix')
%compare the above two Q matrices. Note the difference between stationary
%and nonstationary
sinf=qmat*r;%stationary trace
s50=qmat2*r;%nonstationary trace
figure
plot(t,sinf,t,s50,'r.')%compare the traces in the time domain
dbspec(t,[sinf s50])%compare the traces in the frequency domain
