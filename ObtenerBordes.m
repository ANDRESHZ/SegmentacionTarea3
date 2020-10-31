function BordeActu=ObtenerBordes(ObjActu)
    BordeActu=[-1000,-1000];
    aux=0;
    for Nxy=1:(size(ObjActu,1))% mirar cuales son bordes (N de cordenadas X Y)              
        v8=Vecindad8(ObjActu,Nxy);              
        if v8<8
            if size(BordeActu,1)==1 & aux==0;
                BordeActu=ObjActu(Nxy,:);
                aux=1;
            else
                BordeActu=[BordeActu;ObjActu(Nxy,:)];
            end    
        end
    end
            
end