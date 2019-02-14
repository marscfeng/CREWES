% make a synthetic reflectivity and a minimum phase wavelet
dt=.002;
tmax=2;
fdom=30;
[r,t]=reflec(tmax,dt);%synthetic reflectivity
[w,tw]=wavemin(dt,fdom,.2);%min phase wavelet
s=convm(r,w,0);%convolve them using convm
%now plot the results using subplot to make 3 rows in the figure
figure
subplot(3,1,1)
plot(t,pad_trace(w,r))%note the use of pad to extend the wavelet with zeros
title('wavelet')
xlabel('time (sec)')
subplot(3,1,2)
plot(t,r)
title('reflectivity')
xlabel('time (sec)')
subplot(3,1,3)
plot(t,s)
title('s=convm(r,w)')
xlabel('time (sec)')
h1=gcf;
prepfig

% now lets do the convolution with a convolution matrix
%build a convolution matrix from w that is the right size to convolve with
%r
cmtx=convmtx(w,length(r));%the convolution matrix
plotimage(cmtx)%view it with plotimage
title('Convolution matrix with all rows')
h2=gcf;
kmax=floor(tmax/dt)+1;
cmtxm=cmtx(1:kmax,:);%grabbing the first tmax rows because we want to simulate convm
plotimage(cmtxm)
title('Convolution matrix after row truncation')
h3=gcf;
s2=cmtxm*r;%this should be identical to s. Is it?
figure
plot(t,s,t,s2,'r.')%this plot suggests s and s2 are pretty close
title('Comparison of convm and convolution matrix results')
legend('Convm','Convolution matrix')
a=sum(abs(s-s2))/length(s);%this is a more precise test of equivalence
b=eps;%eps tells me the precision of my computer
title(['Convm compared to convmtx, ave error=' num2str(a) ' and eps=' num2str(b)])
prepfig
figure(h3);figure(h2);figure(h1)
% the fact that sum(abs(s-s2)) is similar to eps tells me that s and s2
% are equivalent to machine precision.
%%
%another way to make a convolution matrix is with the qmatrix command
%Q is the measure of attenuation in rocks. A Q of infinity means no
%attenuation while a Q of 50 is lots of attenuation.
Q=50;
qmat=qmatrix(inf,t,w,tw);%inf means "infinity" here.
plotimage(qmat,t,t)
xlabel('seconds')
title('Stationary Q matrix, uses Q=infinity')
h1=gcf;
qmat2=qmatrix(Q,t,w,tw);%another matrix for Q=50.
plotimage(qmat2,t,t)
xlabel('seconds')
title(['Nonstationary Q matrix, Q=' int2str(Q)])
h2=gcf;
%compare the above two Q matrices. Note the difference between stationary
%and nonstationary
sinf=qmat*r;%stationary trace
sQ=qmat2*r;%nonstationary trace
figure
plot(t,sinf,t,sQ,'r')%compare the traces in the time domain
legend('Stationary',['Nonstationary, Q=' int2str(Q)])
prepfig
h3=gcf;
figure
hh=dbspec(t,[sinf sQ]);%compare the traces in the frequency domain
set(hh{2},'color','r')
title('Amplitude spectra of stationary and nonstationary traces')
legend('Stationary',['Nonstationary, Q=' int2str(Q)])
prepfig
figure(h3);figure(h2);figure(h1)
%%
%examine local spectra in two windows
t1=.2*max(t);
t2=.6*max(t);
twin=.4*max(t);
inwin1=near(t,t1,t1+twin);%finds the samples in window 1
inwin2=near(t,t2,t2+twin);%finds the samples in window 2
[S1inf,f]=fftrl(sinf(inwin1),t(inwin2));%Spectrum in win1
S2inf=fftrl(sinf(inwin2),t(inwin2));%spectrum in win2
S1Q=fftrl(sQ(inwin1),t(inwin2));%Spectrum in win1
S2Q=fftrl(sQ(inwin2),t(inwin2));%spectrum in win2
figure
plot(f,abs(S1inf),f,abs(S2inf),'r')
title('Stationary case')
legend(['Window 1 at ' num2str(t1+.5*twin) ' s'],...
    ['Window 2 at ' num2str(t2+.5*twin) ' s'])
prepfig
h1=gcf;
figure
plot(f,abs(S1Q),f,abs(S2Q),'r')
title(['Nonstationary case, Q=' int2str(Q)])
legend(['Window 1 at ' num2str(t1+.5*twin) ' s'],...
    ['Window 2 at ' num2str(t2+.5*twin) ' s'])
prepfig
figure(h1)
