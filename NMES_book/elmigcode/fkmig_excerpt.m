%forward fk transform
[fkspec,f,kx] = fktran(seis,tnew,xnew,nsampnew,ntrnew,0,0);
ve = v/2; %exploding reflector velocity
%compute kz
dkz= df/ve;
kz = ((0:length(f)-1)*dkz)';
kz2=kz.^2;
%now loop over wavenumbers
for j=1:length(kx)
% apply masks
    tmp=fkspec(:,j).*fmask.*dipmask;
%compute f's which map to kz
    fmap = ve*sqrt(kx(j)^2 + kz2);
    ind=find(fmap<=fmaxmig);
%now map samples by interpolation
    fkspec(:,j) = zeros(length(f),1); %initialize output spectrum to zero
    if( ~isempty(ind) )
        %compute cosine scale factor
        if( fmap(ind(1))==0)
            scl=ones(size(ind));
            li=length(ind);
            scl(2:li)=ve*kz(ind(2:li))./fmap(ind(2:li));
        else
            scl=ve*kz(ind)./fmap(ind);
        end
        %complex sinc interpolation
        fkspec(ind,j) = scl.*csinci(tmp,f,fmap(ind),[lsinc,ntable]);
    end
    if( floor(j/kpflag)*kpflag == j)
        disp(['finished wavenumber ' int2str(j)]);
    end
end
%inverse transform
[seismig,tmig,xmig]=ifktran(fkspec,f,kx);
