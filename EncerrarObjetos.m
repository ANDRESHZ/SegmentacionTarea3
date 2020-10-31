function xSal=EncerrarObjetos(xSal,BordesSeg,Cuadros,Mas,Bordes)
%Cuadros: si es mayor a 0 hace recuadros sobre los objetos.
%  Mas: cunatos pixeles alrededor del recudaro se movera.
%Bordes: si es mayor a 0 Colorea los bordes del objeto.
Nbordes=size(BordesSeg,3);
    for Z=1:Nbordes
        minX=1000;
        minY=1000;
        maxX=-1;
        maxY=-1;
       for X=1:size(BordesSeg,1)
           if BordesSeg(X,1,Z)>0 & minX>BordesSeg(X,1,Z)-Mas
               minX=BordesSeg(X,1,Z)-Mas;
           end
           if BordesSeg(X,2,Z)>0 & minY>BordesSeg(X,2,Z)-Mas
               minY=BordesSeg(X,2,Z)-Mas;
           end
           if(BordesSeg(X,1,Z)>0 & BordesSeg(X,2,Z)>0)& Bordes>0%% marcar Bordes
               xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z,3)+1)=100;
               xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z+1,3)+1)=100;
               xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z+2,3)+1)=xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z+2,3)+1)*0.5;
           end
       end
       maxX=max(BordesSeg(:,1,Z))+Mas;
       maxY=max(BordesSeg(:,2,Z))+Mas;

       if Cuadros>0
           xSal(minX:maxX,minY,mod(Z,3)+1)=200*(Z/Nbordes)+50;
           xSal(minX:maxX,maxY,mod(Z,3)+1)=200*(Z/Nbordes)+50;
           xSal(minX,minY:maxY,mod(Z,3)+1)=200*(Z/Nbordes)+50;
           xSal(maxX,minY:maxY,mod(Z,3)+1)=200*(Z/Nbordes)+50;
       end
    end
end