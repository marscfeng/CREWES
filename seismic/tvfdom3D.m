function [fdom3D,tfd] = tvfdom3D(seis3D,t,twin,tinc,fmt0,interpflag,p,fc)
% TVFDOM3D ... run tvfdom3 on a 3D volume
%
% [fdom3D,tfd] = tvfdom3D(seis3D,t,twin,tinc,fmt0,interpflag,p,fc)
%
% If S is the Fourier transform of seismic trace, then the dominant frequency is estimated by the
% centroid method fdom=Int(f*abs(S).^p)/Int(abs(S).^p) where f is frequency, Int is an integral over
% frequency, and p is typically 2. To make the calculation time variant, the signal is windowed with
% a sliding Gaussian of specified standard deviation and center time prior to the dominant frequency
% calculation. There will be one dominant frequency calculation for every discrete window position.
% The discrete window positions will be t(1):tinc:t(end) (tinc is the window increment). For best
% results tinc should be somewhat smaller than twin (twin is the window half-width) but somewhat
% greater than dt=t(2)-t(1). For example, if dt=.001, then twin=.01 and tinc=.004 are reasonable
% choices. However, all datasets are unique so it is best to try a several different choices.
%
% NOTE: tvfdom produces identical results to tvfdom3 or tvfdom3D but the latter are vectorized for
% speed on large datasets. The former is easier to understand but is slower. Use tvfdom on single
% traces or 2D data. If your data is organized as a 3D matrix use tvfdom3D. If it is a very large 2D
% matrix, and you are a confident coder, use tvfdom3 in a loop where you send it 1000 trace panels
% of data one at a time.
%
% seis3D ... seismic 3D volume. Must be a 3D matrix
% t ... time coordinate for s
% NOTE: Length of t must equal the number of rows of s
% twin ... width (seconds) of the Gaussian window (standard deviation)
% tinc ... temporal shift (seconds) between windows
% fmt0 ... length 2 vector specifying a maximum signal frequency at some
%           time. For example, if signal is known to be bounded by 100Hz at 1 second then
%           fmt0=[100,1]. This determines the maximum frequency of integration at that time. For all
%           other times, fm is hyperbolically interpolated. That is, for time tk, fmk will be
%           fmk=fmt0(1)*fmt0(2)/tk.
%           NOTE: fmt0 can be specified as a single scalar in which case it is assumed the maximum
%           frequency is fmt0 and not time variant.
% interpflag ... 0 means the fd values will fall on the sparse time grid of
%      tnot=t(1):tinc:t(end) while 1 means they will be interpolated with 1D spline to provide a
%      value for every t.
% ************ default is 1 ***********
% p ... small integer used in the calculation
% ************ default is 2 ***********
% fc ... causality factor, must be a value between 1 and 20. 1 means the
%       window is a symmetric Gaussian, while 10 means the Gaussian is asymmetric decaying 10 times
%       faster for times earlier than the center time. Negative numbers give an anticausal window.
% ************ default is 1 ***********
% NOTE: Values greater than 5 are not recommended. To get comparable resolution for two different
% calculations with fc=1 and fc=5, the value of twin for fc=1 should be half of that used for fc=5.
%
% fdom3D ... 3D matrix the the same second and third dimensions as seis3D.
%      The size of the first dimension depends on the choice for interpflag. Zero traces in seis3D
%      simply resylt in zero traces in fdom3D. This is always output in single precision assuming
%      that the result will be displayed but not processed further.
% tfd ... time coordinate vector for fd.

if(nargin<8)
    fc=1;
end
if(nargin<7)
    p=2;
end
if(nargin<6)
    interpflag=1;
end

sz=size(seis3D);
if(length(sz)~=3)
    error('input seismic matrix is not 3D')
end

nt=sz(1);
nx=sz(2);
ny=sz(3);

if(length(t)~=nt)
    error('time coordinate is the wrong size')
end
ievery=1;
tbegin=clock;
for k=1:ny
%for k=201
    %process each iline as a panel in tvfdom3
    spanel=squeeze(seis3D(:,:,k));
    test=sum(abs(spanel));
    ilive=find(test~=0);
    if(~isempty(ilive))
        [fd,tfd]=tvfdom3(spanel(:,ilive),t,twin,tinc,fmt0,interpflag,p,fc);
    end
    if(k==1)
        fdom3D=single(zeros(length(tfd),nx,ny));
    end
    fdom3D(:,ilive,k)=single(fd);
    if(rem(k,ievery)==0)
       time_used=etime(clock,tbegin);
       time_per_line=time_used/k;
       time_remaining=(ny-k-1)*time_per_line;
       disp(['TVFDOM3D: finished iline ' int2str(k) ', time used=' ...
           num2str(time_used/60) ' min'])
       disp(['time remaining ' num2str(time_remaining/60) ' min'])
    end
end
