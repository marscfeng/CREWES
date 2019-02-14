f=0:250;
fdom1=40;fdom2=80;fdom3=120;
R1=exp(-f.^2/(fdom1^2)).*(2*f.^2)/(sqrt(pi)*fdom1^2);
R2=exp(-f.^2/(fdom2^2)).*(2*f.^2)/(sqrt(pi)*fdom2^2);
R3=exp(-f.^2/(fdom3^2)).*(2*f.^2)/(sqrt(pi)*fdom3^2);