function htherm=uithermometer(hparent,pos,name,levels,nbuttons,cbstring)

if(isgraphics(hparent))
    action='init';
else
    action=hparent;
end

if(strcmp(action,'init'))
    htherm=uipanel(hparent,'units','normalized','position',pos,'title',name);
    
    if(2*floor(length(levels)/2)==length(levels))
        %even number
        ilevel=length(levels)/2;%central level
    else
        %odd number
        ilevel=floor(length(levels)/2)+1;%central level
    end
    dl=abs(levels(1)-levels(2));
    if(pos(4)>pos(3)) %vertical orientation
        nlevels=length(levels);
        if(nlevels<nbuttons)
            nbuttons=nlevels;
        end
        %force nbuttons to be odd
        nbut2=floor(nbuttons/2);
        nbuttons=2*nbut2+1;
        %define levels for each button
        del=abs(levels(1)-levels(ilevel))/nbut2;
        del2=abs(levels(end)-levels(ilevel))/nbut2;
        lvls=zeros(1,nbuttons);
        for k=1:nbut2
           tmp=levels(1)+(k-1)*del;%exact value
           lvls(k)=levels(1)+floor((tmp-levels(1))/dl)*dl;%nearest sample
           tmp2=levels(end)-(k-1)*del2;
           lvls(nbuttons-k+1)=ceil(tmp2/dl)*dl;%nearest sample
        end
        lvls(nbut2+1)=levels(ilevel);
        nlevels=length(lvls);
        %redefine ilevel
        ilevel=near(lvls,levels(ilevel));
        wid1=.1;
        ysep=.1;xsep=.1;
        ht=(1-2*ysep)/nlevels;
        bgkol=.5*ones(1,3);
        selkol=[1 0 0];
        ynow=1-ysep;
        xnow=xsep+.5*wid1;
        hobj=zeros(1,nlevels);
        for k=1:nlevels
            hobj(k)=uicontrol(htherm,'style','pushbutton','string','','units','normalized',...
                'position',[xnow,ynow,wid1,ht],'backgroundcolor',bgkol,'userdata',lvls(k),...
                'callback','uithermometer(''select'');','tooltipstring',num2str(lvls(k)),...
                'tag','level');
            ynow=ynow-ht;
            if(k==ilevel)
                set(hobj(k),'backgroundcolor',selkol);
            end
        end
        
        %text annotation
        xnow=xnow+wid1;
        wid2=(1-xnow-xsep);
        ht2=.05;
        yshift=.5*(ht2-ht);
        ynow=1-ysep-yshift;
        uicontrol(htherm,'style','text','units','normalized','position',[xnow,ynow,wid2,ht2],...
            'string',['--' num2str(lvls(1))],'horizontalalignment','left');
        
        pos=get(hobj(end),'position');
        ynow=pos(2)-yshift;
        uicontrol(htherm,'style','text','units','normalized','position',[xnow,ynow,wid2,ht2],...
            'string',['--' num2str(lvls(nlevels))],'horizontalalignment','left');
        %L=1-2*ysep;%total length of thermometer
        %ynow=1-ysep-L*ilevel/nlevels-yshift;
        pos=get(hobj(nbut2+1),'position');
        ynow=pos(2)-yshift;
        uicontrol(htherm,'style','text','units','normalized','position',[xnow,ynow,wid2,ht2],...
            'string',['--' num2str(lvls(ilevel(1)))],'horizontalalignment','left','tag','ilevel');
        
        set(htherm,'userdata',{hobj,cbstring,lvls,ilevel,bgkol,selkol,ysep,yshift})
        ynow=0.02;
        xnow=.1;
        w=.3;h=.05;
        xsep=.1;
        uicontrol(htherm,'style','pushbutton','string','^','units','normalized','tag','up',...
            'position',[xnow,ynow,w,h],'callback','uithermometer(''select'');',...
            'tooltipstring','Step up','fontsize',12);
        xnow=xnow+w+2*xsep;
        uicontrol(htherm,'style','pushbutton','string','v','units','normalized','tag','down',...
            'position',[xnow,ynow,w,h],'callback','uithermometer(''select'');',...
            'tooltipstring','Step down');
    end
    
elseif(strcmp(action,'select'))
    %this is called by a button push on the thermometer. It executes the callback
    hthisobj=gcbo;
    htherm=get(hthisobj,'parent');
    udat=get(htherm,'userdata');
    hobj=udat{1};
    cbstring=udat{2};
    levels=udat{3};
    ioldlevel=udat{4};
    bgkol=udat{5};
    selkol=udat{6};
    %ysep=udat{7};
    yshift=udat{8};
    tag=get(hthisobj,'tag');
    if(~strcmp(tag,'level'))
        hbutt=hthisobj;
        if(strcmp(tag,'up'))
            inc=-1;
        else
            inc=1;
        end
        %look though the objects and find the red one
%         ired=zeros(size(hobj));
%         for k=1:length(hobj)
%             kol=get(hobj(k),'backgroundcolor');
%             if(kol(1)==1)
%                 ired(k)=1;
%             end
%         end
%         nred=sum(ired);
%         if(nred>1)
%             ind=find(ired==1);
%             if(inc==-1)
%                 set(hobj(ired(ind(2:end))),'backgroundcolor',bgkol);
%                 ired=ired(ind(1));
%             else
%                 set(hobj(ired(ind(1:end-1))),'backgroundcolor',bgkol);
%                 ired=ired(ind(end));
%             end
%         end
        ilevel=ioldlevel+inc;
        if(ilevel<1); ilevel=1; end
        if(ilevel>length(hobj)); ilevel=length(hobj); end
        hthisobj=hobj(ilevel);
        tbut=get(hthisobj,'userdata');
        set(hbutt,'userdata',tbut);
        
    end
    
    %nlevels=length(levels);
    ilevel=find(hthisobj==hobj);
    
    set(hobj(ioldlevel),'backgroundcolor',bgkol);
    set(hobj(ilevel),'backgroundcolor',selkol);
    ht=findobj(htherm,'tag','ilevel');
    pos=get(ht,'position');
    pos2=get(hthisobj,'position');
    %L=1-2*ysep;
    ynow=pos2(2)-yshift;
    set(ht,'string',['--' num2str(levels(ilevel))],'position',[pos(1) ynow pos(3:4)]);
    udat{4}=ilevel;
    set(htherm,'userdata',udat);
    eval(cbstring);
elseif(strcmp(action,'set'))
    %this is called by an external program to set the thermometer level. The callback is not
    %executed
    htherm=pos;
    thislevel=name;
    udat=get(htherm,'userdata');
    hobj=udat{1};
    levels=udat{3};
    %nlevels=length(levels);
    ilevel=near(levels,thislevel);%nearest button level to this level
    hthisobj=hobj(ilevel(1));
    ioldlevel=udat{4};
    bgkol=udat{5};
    selkol=udat{6};
    %ysep=udat{7};
    yshift=udat{8};
    set(hobj(ioldlevel),'backgroundcolor',bgkol);
    set(hobj(ilevel(1)),'backgroundcolor',selkol);
    ht=findobj(htherm,'tag','ilevel');
    pos=get(ht,'position');
    pos2=get(hthisobj,'position');
    %L=1-2*ysep;
    ynow=pos2(2)-yshift;
    set(ht,'string',['--' num2str(thislevel)],'position',[pos(1) ynow pos(3:4)]);
    udat{4}=ilevel(1);
    set(htherm,'userdata',udat);
end