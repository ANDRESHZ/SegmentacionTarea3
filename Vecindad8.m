function v8=Vecindad8(pixeles,Nxy)
    x=pixeles(Nxy,1);
    y=pixeles(Nxy,2);
    ver1=zeros(1,8);
    for pixs=1:size(pixeles,1) %Ver si ya existe el pixel en la lista
        ver1(1)=ver1(1)+(mean(pixeles(pixs,:)==[x,y-1])==1).*1.0; %iz
        ver1(2)=ver1(2)+(mean(pixeles(pixs,:)==[x-1,y-1])==1).*1.0;%iz ar
        ver1(3)=ver1(3)+(mean(pixeles(pixs,:)==[x-1,y])==1).*1.0;%ar
        ver1(4)=ver1(4)+(mean(pixeles(pixs,:)==[x-1,y+1])==1).*1.0;%de ar
        ver1(5)=ver1(5)+(mean(pixeles(pixs,:)==[x,y+1])==1).*1.0;%de
        ver1(6)=ver1(6)+(mean(pixeles(pixs,:)==[x+1,y+1])==1).*1.0;%de ab
        ver1(7)=ver1(7)+(mean(pixeles(pixs,:)==[x+1,y])==1).*1.0;%ab
        ver1(8)=ver1(8)+(mean(pixeles(pixs,:)==[x+1,y-1])==1).*1.0;%iz ab
    end
    v8=sum(ver1);
end