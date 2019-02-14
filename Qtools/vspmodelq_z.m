function [vsp,t,up,down]=vspmodelq_z(vp,rho,Q,z,w,tw,tmax,zr,f0,rflag,fpress,smult,fmult,zmult)
% VSPMODELQ_Z: creates a 1D synthetic VSP with Q
%
% [vsp,t,up,down]=vspmodelq_z(vp,rho,Q,z,w,tw,tmax,zr,f0,rflag,fpress,smult,fmult,zmult)
%
% VSPMODELQ_Z differes from VSPMODELQ in that it provides depth dependent control of the multiple
%       content. Multiples can be turned on and off as a function of depth.
%
% The algorithm is essentially that of Ganley (1981) with adaptations
% described in recent (2013,2014) CREWES reports by Margrave. The method
% uses 1-D visco-acoustic layer (e.g. propagator) matrices to compute a synthetic
% VSP. The input requires equal length vectors specifying velocity,
% density, Q, and the depths to layer boundaries. Velocities are assumed
% specified at the frequency f0 and are adjusted using the Azimi dispersion
% law (see Aki and Richards) to the frequences relevant to the model at
% hand. There can be any number of layers and input parameters can be
% prescribed directly from logs (use BLOCKLOGS if blocking is desired and
% Q can be deduced from the logs using FAKEQ). Model parameters must be
% specified from z=0 so most well logs will require that an overburden be
% attached (BLOCKLOGS can do this). Options exist to compute either a
% pressure or a displacement solution and to turn multiples on and off.
% Frequency dependent reflectivities (as required by Q theory) can also be
% turned on and off. The solution is a very high fidelity one that
% accurately models effects over a broad frequency range. It is a 1D solution so
% there is no spreading. However, transmission and attenuation losses are
% precisely computed.  For non-zero source depth use VSPMODELQS (CREWES
% sponsors only).
%
% vp ... p-wave velocity in each layer
% rho ... density in each layer
% Q  ... Q value in each layer
% z ... depths to layer tops (need not be regular)
% **** Requirement: z(1) must be 0 and length(z)=length(vp)=length(rho)=length(Q)
% w ... wavelet (can be causal or noncausal)
% tw ... time coordinate for wavelet
% tmax ... maximum record time
% zr ... vector of desired receiver depths (in increasing order)
% **** Requirement: all zr must lie between z(1) and z(end) *****
% f0 ... frequency at which vp has been measured.
% ********* default = 12500 Hz ************
%  The default is appropriate for well log velocities
% rflag ... 0 means calculate reflectivity with complex velocities
%           1 means calculate reflectivity with input velocities
% ********* default = 0 **********
% fpress ... 0 means a displacement seismogram
%            1 means a pressure seismogram
% ********* default = 0 ***********
% smult ... flag controlling surface multiples. 1 means they are on, 0 means they are off.
% ********* default = 1 ************
% NOTE: fmult can now be an array of flags corresponding to the depths in zmult. This means fmult and
% zmult must be vectors of the same length. If you wish no depth dependence, just make fmult a
% single number and default zmult. Otherwise, fmult(k) applies to the depths zmult(k)->zmult(k+1) .
% Since zmult is the same length as fmult, an extra entry is always padded onto zmult that is equal
% to the z(end).
% fmult ... Array of flags, one per each entry in zmult, turning on and off internal multiples as
%           described below.
% fmult(k) ... 0 means primaries only, but still with tranmission loss
%          ... 1 means all internal multiples
%          ... 2 means no multiples and no transmission loss
% ********* default = 1 ***********
% zmult ... array of depths at which the fmult flags apply. Must be the same length as fmult and
%           zmult(1) must be 0. An extra entry will be attached to the end of zmult with the value
%           z(end). Flag fmult(k) applies for the depth interval zmult(k)< z <= zmult(k+1).
% ********* default = 0 ***********
%
% vsp ... vsp wavefield
% up ... separated upgoing field
% down ... separated downgoing field
% t ... time coordinate for vsp
% vsp, up, down are all of size length(t) rows by length(zr) columns
%
% by G.F. Margrave, 2013-2018
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

if(nargin<14)
    zmult=0;
end
if(nargin<13)
    fmult=1;
end
if(nargin<12)
    smult=1;
end
if(nargin<11)
    fpress=0;
end
if(nargin<10)
    rflag=0;
end
if(nargin<9)
    f0=12500;
end
if(length(vp)~=length(z) || length(rho)~=length(z) || length(Q)~=length(z))
    error('vp, rho, Q, and z must all be equal length');
end
if(z(1)~=0)
    error('z(1) must be 0')
end

if(length(fmult)~=length(zmult))
    error('fmult and zmult must be the same size vectors');
end
if(zmult(1)~=0)
    error('the first entry in zmult must be 0');
end
zmult=[zmult(:); z(end)];

dzr=diff(zr);
ind=find(dzr<0, 1);
if(~isempty(ind))
    error('Receiver depths must be increasing');
end
if(zr(1)<z(1))
    error('First zr must be greater than 0');
end
if(zr(end)>z(end))
    error('Last zr must be less than z(end) [end of logs]')
end

%force column vectors
vp=vp(:);
rho=rho(:);
Q=Q(:);
z=z(:);

%install a fake, highly attenuative, last layer
vp=[vp;vp(end)];
rho=[rho;rho(end)];
Q=[Q;20];
z=[z;z(end)+100*(z(2)-z(1))];

%reflection coefficients for incidence from above
%note this definition is the negative of Ganley 1981
r=(vp(2:end).*rho(2:end)-vp(1:end-1).*rho(1:end-1))./...
    (vp(2:end).*rho(2:end)+vp(1:end-1).*rho(1:end-1));
r0=1;%surface reflection coefficient for incidence from above.

%adjust for noncausal wavelet
tshift=0;
if(tw(1)<0)
    tshift=-tw(1);
    tw=tw+tshift;
end
%the final result will be time shifted if tshift is not zero

%pad wavelet to length tmax
dt=tw(2)-tw(1);
t=0:dt:tmax;
%pad t to the next power of 2
n=nextpow2(length(t));
t=(0:2^n-1)*dt;

wp=pad_trace(w,t);

%Fourier transform wavelet
[W,f]=fftrl(wp,t);


h=abs(diff(z));%layer thicknesses
U1=zeros(length(f),1);%upgoing wave in layer 1
Dn=zeros(length(f),1);%downgoing wave in layer n

%allocate space for up and downgoing fields
Up=zeros(length(f),length(zr));
Down=Up;

Rp=1;
if(fpress==0)
    Rp=-1;
end

%define reciprocal Q
rQ=1./Q;
%Loop over frequencies
ieveryf=100;%means we will write a progress note every 10 frequencies
t0=clock;
for kk=2:length(f)%skip zero frequency because the phase velocity blows up
    %calculate frequency dependent phase velocity
    c=vp.*((1-(rQ/pi)*log(f(kk)/f0))).^(-1);
    %and the complex velocity
    cc=c.*(1-.5*rQ*1i);
    %initialize space for the extrapolation matricies
    Ak=zeros(2,2,length(r));
    %loop over z and calculate A which is the extrapolation matrix
    %connecting the solution in layer 1 with the solution in the half space
    A=[1 0;0 1];%start with identity matrix
    imult=1;
    for k=1:length(r)
        %determine present multiple flag layer
        if(z(k+1)>zmult(imult+1))
           while  z(k+1)>zmult(imult+1)
               imult=imult+1;
               if(imult==length(zmult))
                   imult=imult-1;
                   break;
               end
           end
        end
        %reflection coefficients for incidence from above
        %this is the reflection coefficient for the interface between layer k and k+1
        %note this definition is the negative of Ganley 1981
        if(rflag==0)
            rk=(cc(k+1)*rho(k+1)-cc(k)*rho(k))/(cc(k+1)*rho(k+1)+cc(k)*rho(k));
        else
            %rk=r(k);
            rk=(vp(k+1)*rho(k+1)-vp(k)*rho(k))/(vp(k+1)*rho(k+1)+vp(k)*rho(k));
        end
        %surpress bottom reflection
        if(k==length(r))
            rk=0;
        end
        R=rk;%reflection coefficient
        T=1-R;%transmission coefficient
        P=exp(-pi*f(kk)*h(k)*rQ(k)/c(k))*exp(-2*pi*f(kk)*h(k)*1i/c(k));%propagator
        PI=1/P;
        %the Ak are 2x2 upward extrapolation matrices. They take the
        %wavefield at the top of layer k+1 across the kth interface and to
        %the top of layer k. See Ganley (1981) eqns 36 and 37 and remember
        %that rk defined here is the negative of Ganley's defn.
        %Ak(:,:,k)=[PI/T, -rpress*R*PI/T; -rpress*R*P/T, P/T];%original
       if(fmult(imult)==1)
            %the is the case for full physics (all multiples and Q)
            Ak(:,:,k)=[PI/T, Rp*R*PI/T; Rp*R*P/T, P/T];%remember rpress==-1 for displacement and +1 for pressure
        elseif (fmult(imult) == 0)
            Ak(:,:,k)=[PI/T, 0; Rp*R*P/T, P*(1+R)];%this form of the layer matrix turns off internal multiples
       elseif(fmult(imult)==2)
            Ak(:,:,k)=[PI, 0; Rp*R*P, P];%this form of the layer matrix turns off internal multiples and turns off transmission losses
        end
        A=A*Ak(:,:,k);
    end
    %solve for upgoing wave in layer 1 and downgoing wave in halfspace
    if(smult==1)%here is where surface multiples are handled
        Dn(kk)=W(kk)/(A(1,1)+Rp*r0*A(2,1));%include surface multiples
    else
        Dn(kk)=W(kk)/A(1,1);%don't include surface multiples
    end
    U1(kk)=A(2,1)*Dn(kk);
    %now we know the total wavefield in layer 1 and in the half space
    %It remains to extrapolate this wavefield to each receiver depth
    %Because the Ak (saved above) are upward extrapolators, we extrapolate
    %up to each receiver from the known half-space solution (Dn).
    A=Ak(:,:,length(r));%initialize A with the bottom layer matrix
    ktop=length(r);%this is the layer number for the topmost layer included in A
    for k=length(zr):-1:1
        %determine which layer the receiver is in
        ind=find(z>zr(k));
        inlayer=ind(1)-1;
        %determine extrapolator from the half-space to this geophone, this
        %is built by augmenting the previous A with more layer matrices as
        %needed
        for jj=ktop-1:-1:inlayer%note that we are counting down here
            A=Ak(:,:,jj)*A;%multiply the next few layer matrices into A
        end
        ktop=inlayer;%update ktop
        %determine wavefield at the top of inlayer
        Wavefield=A*[Dn(kk); 0];
        %now shift to the geophone position within the layer
        dz=zr(k)-z(inlayer);%should always be non-negative
        %P=exp(-pi*f(kk)*dz*rQ(k)/c(k))*exp(-2*pi*1i*f(kk)*dz/vp(inlayer));
        P=exp(-pi*f(kk)*dz*rQ(k)/c(inlayer))*exp(-2*pi*1i*f(kk)*dz/c(inlayer));
        PI=1/P;
        Pcausal=exp(2*pi*1i*f(kk)*tshift);
        Down(kk,k)=Wavefield(1)*P*Pcausal;
        Up(kk,k)=Wavefield(2)*PI*Pcausal;
    end
    %write progress note
    if(rem(kk,ieveryf)==0)
        tnow=clock;
        timeused=etime(tnow,t0);
        timerem=timeused*(length(f)/kk-1);
        disp(['Finished frequency ' int2str(kk) ' of ' int2str(length(f))])
        disp(['Time used ' int2str(timeused) ' (s), est. remaining ' int2str(timerem) ' (s)'])
    end
end

%inverse Fourier transform
%make sure Nyquist is real (ifftrl will not work right with complex Nyquist)
Up(end,:)=real(Up(end,:));
Down(end,:)=real(Down(end,:));
[up,t]=ifftrl(Up,f);
down=ifftrl(Down,f);

%limit to tmax
imax=round(tmax/dt)+1;
up=up(1:imax,:);
down=down(1:imax,:);
t=t(1:imax);

vsp=up+down;
tnow=clock;
timeused=etime(tnow,t0);
disp(['VSPMODELQ completed in ' int2str(timeused) ' (s)'])