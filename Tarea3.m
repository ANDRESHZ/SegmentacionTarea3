clc; clf; clear all; close all;
%% Incializacion 
addpath(genpath('TwIST_v2'));
fftnc = @(x) fftshift(fftn(fftshift(x)));
ifftnc = @(x) ifftshift(ifftn(ifftshift(x)));
n=79;
% data="TempCorrC1017";
%data="TempCorrC1025";
data="TempCorrC1032";
%data="TempCorrC1044";
load (data)
N=length(C02t)-1;
C02tN=zeros(79,79,N);
C13tN=C02tN;
C20tN=C02tN;
C31tN=C02tN;
for j1 = [1 : N] %Normalizamos todos los frames
    minimo=min(min(C02t{j1}));
    C02tN(:,:,j1)=(C02t{j1}-minimo)/(max(max(C02t{j1}))-minimo);
    minimo=min(min(C13t{j1}));
    C13tN(:,:,j1)=(C13t{j1}-minimo)/(max(max(C13t{j1}))-minimo);
    minimo=min(min(C20t{j1}));
    C20tN(:,:,j1)=(C20t{j1}-minimo)/(max(max(C20t{j1}))-minimo);
    minimo=min(min(C31t{j1}));
    C31tN(:,:,j1)=(C31t{j1}-minimo)/(max(max(C31t{j1}))-minimo);
end


%% Filtrar imagen
xorg=C02tN(:,:,23);%aqui se ajustan la imagenes a observar, si desa una secuancia use un For
x=xorg;
xfilt=imnlmfilt(xorg,'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
x=xfilt;
figure
imshow([xorg x],[],'InitialMagnification',1024)
C02tFILT=zeros(79,79,N);
for im=1:N %% filtramos identicamente a todas la imagenes
    C02tFILT(:,:,im)=imnlmfilt(C02tN(:,:,im),'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
end
%% Calculos de PSF basado en la imagen ON-line o Movil.
% imwrite(x,"Evidencias\x1.bmp")
[i, j] = find(ismember(x, max(x(:))));
xC=x(i-2:i+2,j-2:j+2);
minxC=min(xC(:));
PorBus=(1-minxC)/2; %porcentaje de buesqueda 33% podria variar respecto a la iluminacion generla de la imagen.
dist=zeros(1,4);
for iv=1:1:min((78-i),i-1)
    flag=0;
    if(x(i-iv,j)>=minxC*(1-PorBus)) %mirar arriba
     dist(1)=iv;
     flag=1;
    end
    if(x(i+iv,j)>=minxC*(1-PorBus)) %mirar abajo
     dist(2)=iv;
     flag=1;
    end
    if(x(i,j-iv)>=minxC*(1-PorBus)) %izquierda
     dist(3)=iv;
     flag=1;
    end
     if(x(i,j-iv)>=minxC*(1-PorBus)) %derecha
     dist(4)=iv;
     flag=1;
    end
    if (flag==0) %si no existe en ninguna direccion finalizamos
        break;
    end
end

distProm=int8(mean(dist));
PSF=zeros(n,n);
RecorPSF=x(i-distProm:i+distProm,j-distProm:j+distProm);
% RecorPSF=(RecorPSF-min(RecorPSF(:)))/(max(RecorPSF(:))-min(RecorPSF(:)));
RecorPSF=(RecorPSF-min(RecorPSF(:)));
PSF(40-distProm:40+distProm,40-distProm:40+distProm)=RecorPSF;
imshow([PSF],[],'InitialMagnification',1024)
%% Recortar PSF para generar border suaves
CiculoCorte = zeros(n, n); 
[xp, yp] = meshgrid(1:n, 1:n); 
CiculoCorte((xp - n/2).^2 + (yp - n/2).^2 <= (distProm).^2) = 1;
sigma = double((distProm*0.7));
gaussCirc = fspecial('gaussian', 79, sigma); 
gaussCirc=gaussCirc/max(max(gaussCirc));% normalizar
PSFmod=(gaussCirc.*(CiculoCorte-1)*-1)+(CiculoCorte.*PSF);
figure
imshow([xorg, x,CiculoCorte.*PSF],[],'InitialMagnification',1024)
PSFFinal= PSF.*CiculoCorte;
%% Twist Manual
alpha = 0.5;
beta = 0.25;
iterTWIST=300;
iteraTV=5;
lambdas=[0.86:-0.02:0.74];
for im=15%N-10
x=C02tFILT(:,:,im);
y=x;
IMGh=[y];
HH=0;
for j=lambdas
    HH=HH+1;
%     lambda = (4+(j*2))*2^(-j)
    lambda=j;
%     time0 = clock;
    x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,lambda,iteraTV);
%     disp(sprintf('Total elapsed time = %f secs\n', etime(clock,time0)));
    %mostrar imagenes
    tam=size(IMGh);
    if tam(2)==length(y)*4
        if HH==4
            IMG=IMGh;
        else
            IMG=[IMG;IMGh];
        end
        
        IMGh=x_twist/max(max(x_twist));
    else
        IMGh=[IMGh,x_twist/max(max(x_twist))];
    end   
end
IMG=[IMG;IMGh];
figure(3);
imshow(imresize(IMG,3,'box'));
title("Lambdas del "+lambdas(1)+" al "+ lambdas(end))
end

%% Metodo de Segmentacion de objetos
X0=x_twist/max(x_twist(:));
% X0=C02tFILT(:,:,23);
umbral=0.0032;
% umbral=0.6;
BinDetec=(X0>umbral).*1.0;%Binarizar los que identificamos como objetos
old=BinDetec;
figure(4)
imshow(imresize(BinDetec,3,'box'));
BinDetec2=BinDetec;
Incial=0;
ObjSeg=0;
BordesSeg=0;
for j=(1:n) %eje X 
    for i=(1:n)% Eje Y
        if BinDetec(j,i)==1
            [BinDetec,ObjActu]=SegmentarPX(BinDetec,[j,i]);
            BordeActu=ObtenerBordes(ObjActu);
            BinDetec2=[BinDetec2 BinDetec];
            figure(11)
            imshow([X0 BinDetec2],[]);
            %% Guardar datos de objetos segmentados (Pixeles y Bordes)
            [Incial,ObjSeg,BordesSeg]=GuardarDatos(Incial,ObjSeg,ObjActu,BordesSeg,BordeActu);
            %%
        end
    end 
end
%% Mostrar datos segmentados (sobre la imagen)
xSal=uint8(zeros(size(X0,1),size(X0,2),3));
X0_255=uint8(X0.*255);
xSal(:,:,1)=X0_255;
xSal(:,:,2)=X0_255;
xSal(:,:,3)=X0_255;
XI=xSal;
xSal=EncerrarObjetos(XI,BordesSeg,1,1,0);
xSal2=EncerrarObjetos(XI,BordesSeg,0,0,1);
figure(13)
imshow([XI,xSal,xSal2],[],'InitialMagnification',1024)
%% Buscar la mejor solucion de TwIST para aplicar sobre ella la Segmentacion ya probada
%datos TwIST
alpha = 0.5;
beta = 0.25;
iterTWIST=300;
iteraTV=5;
lambdas=[0.9:-0.02:0.4];
%datos Segmentacion
umbral=0.003;
ObjCount=zeros(1,length(lambdas));
auxSal=0;
for im=18:28
% x=C02tFILT(25:50,25:50,im);
x=C02tFILT(:,:,im);
y=x;
salir=0;
    for L=1:length(lambdas)
        lambda=lambdas(L);
        x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,lambda,iteraTV);
        X0=x_twist/max(x_twist(:));
        BinDetec=(X0>umbral).*1.0;%Binarizar los que identificamos como objetos
        ObjSeg=0;
        for j=(1:size(x,2)) %eje X 
            for i=(1:size(x,1))% Eje Y
                if BinDetec(j,i)==1
                    [BinDetec,ObjActu]=SegmentarPX(BinDetec,[j,i]);
                    ObjCount(L)=ObjCount(L)+1; 
                end
            end 
        end
        %% si se idnetifican menos objetos 2 veces seguidas se toma el mejor valor
        maxObj=max(ObjCount);
        if(maxObj>ObjCount(L))
            salir=salir+1;
            if salir>1
                break
            end
        end        
    end
    maxObj=max(ObjCount);
    posiciones=find(ismember(ObjCount, maxObj));
    if length(posiciones)>3
        posiciones=posiciones(1:4);
    end
    LambdaFinal=0;
    for posi=posiciones
        LambdaFinal=LambdaFinal+lambdas(posi);
    end
    %% Aplicar TwIST con mejor lambda
    LambdaFinal=LambdaFinal/length(posiciones);
    x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,LambdaFinal,iteraTV);
    %% Aplicar metodo de Segmentacion
    X0=x_twist/max(x_twist(:));
    BinDetec=(X0>umbral).*1.0;%Binarizar los que identificamos como objetos
    Incial=0;
    ObjSeg=0;
    BordesSeg=0;
    ObjActu=0;
    ObjActu=0;
    for j=(1:size(x,2)) %eje X 
        for i=(1:size(x,1))% Eje Y
            if BinDetec(j,i)==1
                [BinDetec,ObjActu]=SegmentarPX(BinDetec,[j,i]);
                BordeActu=ObtenerBordes(ObjActu);
                %% Guardar datos de objetos segmentados (Pixeles y Bordes)
                [Incial,ObjSeg,BordesSeg]=GuardarDatos(Incial,ObjSeg,ObjActu,BordesSeg,BordeActu);
            end
        end 
    end
    %% Mostrar datos segmentados (sobre la imagen)
    xinit=uint8(zeros(size(x,1),size(x,2),3));
    X_255=uint8(x.*255);
    xinit(:,:,1)=X_255;
    xinit(:,:,2)=X_255;
    xinit(:,:,3)=X_255;
    
    xSal=uint8(zeros(size(x,1),size(x,2),3));
    X0_255=uint8(X0.*255);
    xSal(:,:,1)=X0_255;
    xSal(:,:,2)=X0_255;
    xSal(:,:,3)=X0_255;
    
    XI=xSal;
    xSal=EncerrarObjetos(xSal,BordesSeg,1,1,1);
    figure(13)
    imshow([xinit XI,xSal],[],'InitialMagnification',1024)
    if auxSal==0
        Xs=[xinit;XI;xSal];
    else
        Xs=[Xs,[xinit;XI;xSal]];
    end
    auxSal=1;
end
figure(30)
 imshow(Xs,[],'InitialMagnification',1024)