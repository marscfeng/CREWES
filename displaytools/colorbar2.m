function colorbar2(haxe,state)

if(nargin==1)
    if(ischar(haxe))
        haxe=gca;
        state=haxe;
    else
        state='on';
    end
end

posax=get(haxe,'position');



if(strcmp(state,'on'))
    hcb=colorbar(haxe);
    posax2=get(haxe,'position');
    del=posax(3)-posax2(3);
    poscb=get(hcb,'position');
    set(haxe,'position',posax);
    set(hcb,'position',[poscb(1)+del poscb(2:4)])
else
    colorbar(haxe,state);
end

