function [value,x,y,xl,il]=readhorizonfile(fname)
%
% [value,x,y,xl,il]=readhorizonfile(fname)
%
% Two types opf horizon files are recognized. With a .xyz extension, the file is assumed to come
% from Transform and usually has a header. Header lines start with # and are ignored. Five values
% are expected per line in file, and these are: inline#, xline#, x coord, y coord, and value. Missing values are
% flagged as -999.99 in file and are converted to nan by this function. With a .dat extension, the
% file is assumed to come from Kingdom and does not have a header. There are 3 values per file line,
% x coord, y coord, and value and there is no flag for missing values. This file is read from
% begining to end.
%
% fname ... name (including path) of the horizon file
%
% value ... vector of values of the horizon
% x ... vector of x coordinates, same size as value
% y ... vector of y coordinates, same size as value
% xl ... vector of crossline numbers, same size as value
% il ... vector of inline numbers, same size as value
% NOTE: xl and il are only meaningful for .xyz files
% NOTE: when in doubt about the file format, it is always usefule to view it first. You can use
% viewhorizonfile for this purpose.
%

%determine file type
ind=strfind(fname,'.');
n=length(fname);
if(isempty(ind) || length(ind)>1 || ind(1)~=n-3)
    error('unable to determine file type by extension');
end

ftype='xyz';
if(strcmp(fname(n-2:n),'dat'))
    ftype='dat';
end

%we don't know how long the file is so we read 1000 lines at a time. Extending the arrays as needed.
nlines=1000;

fid=fopen(fname);

switch ftype
    
    case 'xyz'
        done=false;
        value=nan*ones(nlines,1);
        x=value;
        y=value;
        xl=value;
        il=value;
        iline=0;
        %read past the header
        head=true;
        while head
            s=fgetl(fid);
            if(~strcmp(s(1),'#'))
                head=false;
            end
        end
        [v,c]=sscanf(s,'%f');
        if(c~=5)
            error(['Expected 5 values on line ' int2str(iline) ' but found only ' intstr(c)])
        end
        iline=1;
        value(iline)=v(5);
        x(iline)=v(3);
        y(iline)=v(4);
        xl(iline)=v(2);
        il(iline)=v(1);
        while ~done
            for k=1:nlines
                iline=iline+1;
                s=fgetl(fid);
                if(s==-1)
                    done=true;
                    break;
                end
                [v,c]=sscanf(s,'%f');
                if(c~=5)
                    error(['Expected 5 values on line ' int2str(iline) ' but found only ' intstr(c)])
                end
                value(iline)=v(5);
                x(iline)=v(3);
                y(iline)=v(4);
                xl(iline)=v(2);
                il(iline)=v(1);
            end
            tmp=nan*ones(nlines,1);
            value=[value;tmp];
            x=[x;tmp];
            y=[y;tmp];
            xl=[xl;tmp];
            il=[il;tmp];
        end
        ind=find(isnan(value));
        if(~isempty(ind))
            value(ind)=[];
            x(ind)=[];
            y(ind)=[];
            xl(ind)=[];
            il(ind)=[];
        end
        ind=find(value==-999.99);
        if(~isempty(ind))
            value(ind)=nan;
        end
        
        
    case 'dat'
        
end

fclose(fid);