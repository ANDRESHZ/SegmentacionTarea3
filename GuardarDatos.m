function [Incial,ObjSeg,BordesSeg]=GuardarDatos(Incial,ObjSeg,ObjActu,BordesSeg,BordeActu)
    if Incial==0
                    ObjSeg=ObjActu;
                    BordesSeg=BordeActu;
                    Incial=1;
    else
    %ObjSeg
    tamObjs=size(ObjSeg,1);
    if(tamObjs>size(ObjActu,1))
        ObjActu=[ObjActu;zeros(tamObjs-size(ObjActu,1),2)];
    elseif (tamObjs<size(ObjActu,1))
        ObjSeg=[ObjSeg;zeros(size(ObjActu,1)-tamObjs,2)];
        tamObjs=size(ObjActu,1);
    end
    ObjSegAUX=zeros(tamObjs,2,size(ObjSeg,3)+1);
    ObjSegAUX(:,:,1:size(ObjSeg,3))=ObjSeg;
    ObjSegAUX(:,:,end)=ObjActu;
    ObjSeg=ObjSegAUX;

    %BordesSeg
    tamBord=size(BordesSeg,1);
    if(tamBord>size(BordeActu,1))
        BordeActu=[BordeActu;zeros(tamBord-size(BordeActu,1),2)];
    elseif (tamBord<size(BordeActu,1))
        BordesSeg=[BordesSeg;zeros(size(BordeActu,1)-tamBord,2)];
        tamBord=size(BordeActu,1);        
    end
    BordesSegAUX=zeros(tamBord,2,size(BordesSeg,3)+1);
    BordesSegAUX(:,:,1:size(BordesSeg,3))=BordesSeg;
    BordesSegAUX(:,:,end)=BordeActu;
    BordesSeg=BordesSegAUX;
end