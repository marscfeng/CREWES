function [shotmig,illumination]=pspi_shot_tmig(shot,t,x,vel,xv,tau,xshot,frange)
% PSPI_SHOT: shot record migration by the PSPI algorithm
%
% [shotmig,illumination]=pspi_shot_tmig(shot,t,x,vel,xv,zv,xshot,frange)
%
% PSPI_SHOT_TMIG performs 2D prestack time migration for PP events on a
% single shot record. Required inputs are the shot record, which must be
% regularly sampled in both x and t, and a p-wave RMS velocity model. The
% velocity model is a time (tau) matrix and the migrated shot will have the
% same dimensions as the velocity model. The cross-correlation imaging
% condition is used so the shot record should be gained before migration
% (see TGAIN). This code has been adapted from the depth migration code
% pspi_shot by altering the extrapolation routine to leave out the
% time-shift term (see PSPI_ISPF). Additionally, the extrapolation is
% direct from the surface to each tau level instead of being recursive as
% in pspi_shot. This allows the input RMS velocities to be used directly
% reather than being decomposed into interval velocities.
%
%
% shot ... shot record stored as a matrix, one trace per column
% t ... time coordinate vector for shot
% x ... x coordinate vector for shot (x should be regularly sampled).
% NOTE: size(shot) must equal [length(t), length(x)]
% NOTE: the x sample interval for data and velocity model should be the
% same. Ideally, this means that both should be sampled at 1/2 the geophone
% spacing. This will usually require trace interpolation for the shot.
% vel...velocity model in time. Velocities should be RMS not interval. 
%       Remember, this is time migration so only very weak lateral
%       gradients will be correctly handled.
% xv ... x (column) coordinate vector for velocity model
% NOTE: dx=x(2)-x(1) must equal xv(2)-xv(1).
% tau ... time (row) coordinate vector for velocity model
% NOTE: (tau(2)-tau(1))/(t(2)-t(1) must be an integer.
% NOTE: size(vel) must equal [length(tau), length(xv)]
% NOTE: The velocity model time coodinate defines the tau step:
%      dtau=tau(2)-tau(1) and the maximum tau that is stepped to. 
%      Currently tau must be regularly sampled. When dtau>dt (the usual
%      case, dt=t(2)-t(1)) samples between two tau levels will be
%      interpolated from the extrapolated sections above and below. The x
%      coordinates of the shot record must be contained within the x
%      coordinate span of the velocity model. If the shot does not span the
%      entire velocity model then the shot will be automatically padded
%      with zero traces.
%      Traces are automatically padded in time to minimize operator
%      wrap-around and the pad is re-zero'd every 10 steps.
% xshot ... x coordinate of shot (a scalar). 
% frange... two element vector giving the frequency range (min and max) to
% be migrated. Example, migrate all frequencies up to 60 Hz: frange=[0 60];
%  ****** default is all frequencies ******
% NOTE: runtime is linearly proportional to the number of frequencies to be
% migrated. There is nothing to be gained by migrating noise or extremely
% low amplitude frequencies.
%
% shotmig...time migrated output using crosscorrelation imaging contition
% illumination ... illum or shot strength at each image point: 
% NOTE: Both shotmig is the same size as the input
%   velocity model.
%
% G.F. Margrave 2016
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

%***get sizes of things***
[Ntv,Nx]=size(vel);
dtau=tau(2)-tau(1);
[nt,nx]=size(shot);
dt=t(2)-t(1);
small=1e-04;
dx=xv(2)-xv(1);
dxs=x(2)-x(1);
%*************************
%test shot dimensions
if(length(x)~=nx)
    error('shot x axis incorrect');
end
if(length(t)~=nt)
    error('shot t axis incorrect');
end
%test vel dimensions
if(length(tau)~=Ntv)
    error('velocity tau axis incorrect');
end
if(length(xv)~=Nx)
    error('velocity x axis incorrect');
end
if(abs(dxs-dx)>small)
    error('velocity model and shot must have same x sample size')
end
%determine if the velocity model spans the shot
xmins=min(x);xmaxs=max(x);
xminv=min(xv);xmaxv=max(xv);
if(xmins<xminv || xmaxs>xmaxv)
    error(['Shot x coordinates fall outside the span of the velocity model.'...
        ' Velocity model must be extended']);
end


%test to see if shot and velocity are on same grid
if(abs(dx*floor((xmaxs-xmins)/dx)-(xmaxs-xmins))>small)
    error('Velocity model and shot record are not on the same x grid');
end
%test for regular shot sampling
if(sum(abs(diff(diff(x))))>small)
    error('Shot record must be regularly sampled in x');
end
%default is to migrate all frequencies
if(nargin<8)
    frange=[0 inf];
end

%now, pad the shot with zero traces if needed
npadmin=0;
npadmax=0;
if(xmins>xminv)
    npadmin=round((xmins-xminv)/dx);
end
if(xmaxs<xmaxv)
    npadmax=round((xmaxv-xmaxs)/dx);
end
if(npadmin+npadmax>0)
    shot=[zeros(nt,npadmin) shot zeros(nt,npadmax)];
end
x=xv;
nx=length(x);
%pad the shot out so that number of traces is a power of 2
nx2=2^nextpow2(nx);

if(nx<nx2)
    shot=[shot zeros(nt,nx2-nx)];%pad shot with zeros
    vel=[vel vel(:,end)*ones(1,nx2-nx)];%extend vel with last trace
end
x2=(0:nx2-1)*dx;
        
%determine the temporal pad
%pad by enough to hold 10 dz steps
tmax=max(t);
vmin=min(vel(:));
tpad=2*10*dtau/vmin;%twice the vertical travel time for 10 steps at slow velocity
npad=round(tpad/dt);
npow=nextpow2(nt+npad);
ntnew=2^npow;%make the new length a power of 2
npad=ntnew-nt;
%pad the traces in time
shot=[shot;zeros(npad,nx2)];
t=dt*(0:ntnew-1);

%fk transform the shot record
[shotfk,f,k]=fktran(shot,t,x2);
shotfk=fftshift(shotfk,2);%pspi_ips wants a wrapped wavenumber spectrum

if(frange(1)==0)
    frange(1)=f(2);%don't use 0 Hz
end
if(frange(2)>f(end))
    frange(2)=f(end);
end

%[nf,cd]=size(shotfk);
nf=length(f);
indf=near(f,frange(1),frange(2));%frequencies to migrate
nf2=length(indf);

%***build the source***
%design a secret 85 degree dip limit on energy from the shot. This is done
%to attenuate high angle noise from the shot model. It is a very good
%thing.
xlim=dtau*tand(85);
nwindow=round(1.2*2*xlim/dx)+1;%size of a spatial window to be applied to the source
nx0=round(xshot/dx)+1;
nwin2=round((nwindow-1)/2);
mw=mwindow(nwindow,10)';
if((nx0-nwin2)<1)
    %here the window hangs off the left edge
    nskip=nwin2-nx0;%number of samples to skip at beginning of window
    window=[mw((nskip+1):end) zeros(1,nx2-(nwindow-nskip))];
elseif(nx0+nwin2>nx2)
    %here the window hangs off the right edge
    nlast=nwindow-(nx0+nwin2-nx2);
    window=[zeros(1,nx2-nlast) mw(1:nlast)];
else
    %here the window is fully within the span of the model
    nbegin=nx0-nwin2;
    window=[zeros(1,nbegin-1) mw zeros(1,nx2-nwindow-nbegin+1)];
end
temp=zeros(nf,nx2);
for j=indf
	temp(j,:)=window.*greenseed2(1,dx*[0:nx2-1],xshot,f(j),f(end),vel(1,:),dtau,1);
end
sourcefk=ifft(temp,[],2);
%**********************
%build the piecwise constant velocity model by the Bagaini method
%the first two input parameters are a mystery but seem to work
vel_blocked=Bagaini(length(x)-1,10,vel);

%allocate arrays
shotmigcc=zeros(Ntv,nx2);
shotmigdec=zeros(Ntv,nx2);
illumination=zeros(Ntv,nx2);

time1=clock;
timeused=0.0;
ievery=25;
for j=1:Ntv-1
    if((rem(j,ievery)-2)==0)
        disp([' pspi prestack mig working on depth ',num2str(j),' of ',num2str(Ntv),...
            ' time left ~ ' int2str(timeremaining) '(s)'])
    else
        disp([' pspi prestack mig working on depth ',num2str(j),' of ',num2str(Ntv)])
    end
    if(rem(j,10)==0)
        shotfk=ps_rezero(shotfk,f,dx,tmax);
        sourcefk=ps_rezero(sourcefk,f,dx,tmax);
    end
    %step the data down
	ftemp=pspi_ips(shotfk(indf,:),f(indf),dx,vel(j,:),vel_blocked(j,:),dtau);
    %step the source model down
	stemp=pspi_ips(sourcefk(indf,:),f(indf),dx,vel(j,:),vel_blocked(j,:),-dtau);
    %ftemp and stemp are in the (x,f) domain.
    if(j==141)
        disp('Break')
    end
    %imaging conditions
	rcc=ftemp.*conj(stemp);%trivial reflectivity estimate
    illum=stemp.*conj(stemp);%illumination is the shot power
    rdec=rcc./(illum+stab*max(abs(illum(:))));%stabilized decon reflectivity estimate
    %At this point, rcc and rdec are frequency and wavenumber dependent
    %Sum rcc and rdec over temporal frequencyn to get the final estimates
	shotmigcc(j+1,:)=real(sum(rcc)+sum(rcc(1:nf2-1,:)))/(2*nf2-1)/2/pi;
    shotmigdec(j+1,:)=real(sum(rdec)+sum(rdec(1:nf2-1,:)))/(2*nf2-1)/2/pi;
    illumination(j+1,:)=real(sum(illum)+sum(illum(1:nf2-1,:)))/(2*nf2-1);
    %transform back to (k,f) domain
	shotfk(indf,:)=ifft(ftemp,[],2);
	sourcefk(indf,:)=ifft(stemp,[],2);
    timenow=clock;
    timeused=etime(timenow,time1)+timeused;
    time1=timenow;
    timeremaining=(Ntv-1)*timeused/j-timeused;
    %disp([' elapsed time ',int2str(timeused),' (s), estimated time remaining '...
    %    ,int2str(timeremaining),' (s)']);
end
shotmigcc=shotmigcc(:,1:nx);
shotmigdec=shotmigdec(:,1:nx);
illumination=illumination(:,1:nx);
disp(['shot migrated in ' int2str(timeused) '(s)'])