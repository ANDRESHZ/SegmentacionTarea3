function [X0,ObjActuPX]=SegmentarPX(X0,ObjActu)
    pos=0;
    n=size(X0,1);
    while size(ObjActu,1)>pos
        pos=pos+1;             
        jv=ObjActu(pos,1);
        iv=ObjActu(pos,2);
        X0(jv,iv)=0;
        izq=iv>1;
        der=iv<n;
        arr=jv>1;
        abj=jv<n;                
        %Vecindad 8
%         ver=zeros(1,8);
%         for pixs=1:size(ObjActu,1) %Ver si ya existe el pixel en la lista
%             ver(1)=ver(1)+(mean(ObjActu(pixs,:)==[jv,iv-1])==1).*1.0; %iz
%             ver(2)=ver(1)+(mean(ObjActu(pixs,:)==[jv-1,iv-1])==1).*1.0;%iz ar
%             ver(3)=ver(1)+(mean(ObjActu(pixs,:)==[jv-1,iv])==1).*1.0;%ar
%             ver(4)=ver(1)+(mean(ObjActu(pixs,:)==[jv-1,iv+1])==1).*1.0;%de ar
%             ver(5)=ver(1)+(mean(ObjActu(pixs,:)==[jv,iv+1])==1).*1.0;%de
%             ver(6)=ver(1)+(mean(ObjActu(pixs,:)==[jv+1,iv+1])==1).*1.0;%de ab
%             ver(7)=ver(1)+(mean(ObjActu(pixs,:)==[jv+1,iv])==1).*1.0;%ab
%             ver(8)=ver(1)+(mean(ObjActu(pixs,:)==[jv+1,iv-1])==1).*1.0;%iz ab
%         end
        if izq %izquierda
            if X0(jv,iv-1)==1
                ObjActu=[ObjActu;[jv,iv-1]];
                X0(jv,iv-1)=0;
            end                       
        end
        if izq&arr %izquierda arriba
            if X0(jv-1,iv-1)==1
                ObjActu=[ObjActu;[jv-1,iv-1]];
                X0(jv-1,iv-1)=0;
            end                       
        end
        if arr %arriba
            if X0(jv-1,iv)==1
                ObjActu=[ObjActu;[jv-1,iv]];
                X0(jv-1,iv)=0;
            end                       
        end
        if arr&der %derecha arriba
            if X0(jv-1,iv+1)==1
                ObjActu=[ObjActu;[jv-1,iv+1]];
                X0(jv-1,iv+1)=0;
            end                       
        end
        if der %derecha
            if X0(jv,iv+1)==1
                ObjActu=[ObjActu;[jv,iv+1]];
                X0(jv,iv+1)=0;
            end                       
        end
        if der&abj %derecha abajo
            if X0(jv+1,iv+1)==1
                ObjActu=[ObjActu;[jv+1,iv+1]];
                X0(jv+1,iv+1)=0;
            end                       
        end
        if abj %abajo
            if X0(jv+1,iv)==1
                ObjActu=[ObjActu;[jv+1,iv]];
                X0(jv+1,iv)=0;
            end                       
        end
        if izq&abj %izquierda abajo
            if X0(jv+1,iv-1)==1
                ObjActu=[ObjActu;[jv+1,iv-1]];
                X0(jv+1,iv-1)=0;
            end                       
        end
        %fin vecindad 8
    end
    ObjActuPX=ObjActu;
end