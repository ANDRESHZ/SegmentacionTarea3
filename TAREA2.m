clc; clf; close all; clear all;
%% Inicio
addpath(genpath('TwIST_v2'));
fftnc = @(x) fftshift(fftn(fftshift(x)));
ifftnc = @(x) ifftshift(ifftn(ifftshift(x)));

%data="TempCorrC1017";
%data="TempCorrC1025";
%data="TempCorrC1032";
 data="TempCorrC1044";
load (data)
N=length(C02t)-1;
C02tN=zeros(79,79,N);
C13tN=C02tN;
C20tN=C02tN;
C31tN=C02tN;
for j1 = [1 : N]
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
xorg=C02tN(:,:,27);%aqui se ajustan la imagenes a observar, si desa una secuancia use un For
x=xorg;

xfilt=imnlmfilt(xorg,'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
x=xfilt;
figure
imshow([xorg x],[],'InitialMagnification',1024)
%% Calculos de PSF basado en la imagen ON-line.
% imwrite(x,"Evidencias\x1.bmp")
[i, j] = find(ismember(x, max(x(:))));
xC=x(i-2:i+2,j-2:j+2)
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
n=79;
distProm=int8(mean(dist));
PSF=zeros(n,n);
RecorPSF=x(i-distProm:i+distProm,j-distProm:j+distProm);
% RecorPSF=(RecorPSF-min(RecorPSF(:)))/(max(RecorPSF(:))-min(RecorPSF(:)));
RecorPSF=(RecorPSF-min(RecorPSF(:)));
PSF(40-distProm:40+distProm,40-distProm:40+distProm)=RecorPSF;
imshow([PSF],[],'InitialMagnification',1024)
%% Recoewrtar PSF para generar border suaves
CiculoCorte = zeros(n, n); 
[xp, yp] = meshgrid(1:n, 1:n); 
CiculoCorte((xp - n/2).^2 + (yp - n/2).^2 <= (distProm).^2) = 1;
sigma = double((distProm*0.7));
gaussCirc = fspecial('gaussian', 79, sigma); 
gaussCirc=gaussCirc/max(max(gaussCirc));% normalizar
PSFmod=(gaussCirc.*(CiculoCorte-1)*-1)+(CiculoCorte.*PSF);
figure
imshow([PSF, (CiculoCorte-1).*(-1).*PSF, gaussCirc,PSFmod],[],'InitialMagnification',1024)
figure
imshow([xorg, x,CiculoCorte.*PSF],[],'InitialMagnification',1024)
PSFFinal= PSF.*CiculoCorte;
%% Sacamos la PSF real
delta=zeros(n,n);
delta(40:41,39:40)=1;
figure
imshow(delta)
% imwrite(delta,"Evidencias\delta.bmp")
PSFReal=fftnc(PSFmod)./fftnc(delta);
ImgenREF=imnoise(delta,'salt & pepper',0.05);
yy = abs(ifftnc(fftnc(PSFmod).*fftnc(ImgenREF)));
figure
imshow([ImgenREF, yy],[],'InitialMagnification',1024)
%% filtro inverso
clc;
yy = abs(ifftnc(fftnc(CiculoCorte.*PSFFinal)./fftnc(x)));
yy=yy/max(yy(:));
figure(9)
imshow([x, yy],[],'InitialMagnification',1024)

for kkk=0.001:0.005:0.1  
    yyREg=deconvreg(x,CiculoCorte.*PSFFinal,kkk);
    figure(10)
    imshow([x, (yyREg-min(yyREg(:)))/(max(yyREg(:)))-min(yyREg(:))],[],'InitialMagnification',1024)
%     pause(1)
end

%% Wiener

yyWie=deconvwnr(x,PSFFinal);
figure
imshow([x, (yyWie-min(yyWie(:)))/(max(yyWie(:)))-min(yyWie(:))],[],'InitialMagnification',1024)

signal_var = var(x(:));
NSR = 0.0007 / signal_var;
yyWie=deconvwnr(x,PSF,NSR);
figure
imshow([,x, (yyWie-min(yyWie(:)))/(max(yyWie(:)))-min(yyWie(:))],[],'InitialMagnification',1024)

%% Richardson Lucy

yyRL=deconvlucy(x,PSFFinal,10,0.2)
figure
imshow([xorg,x, (yyRL-min(yyRL(:)))/(max(yyRL(:)))-min(yyRL(:))],[],'InitialMagnification',1024)



%% L1 MAgic
x=xorg;
largescale = 1;
n = 78;
II = x(1:0+n,1:0+n);
N = n*n;
I = II/norm(II(:));
%I = I - mean(I(:));
x = reshape(I,N,1);
% num obs
K = 2000;
% permutation P and observation set OMEGA
P = randperm(N)';
q = randperm(N/2-1)+1;
OMEGA = q(1:K/2)';
% measurement matrix
if (largescale)
  A = @(z) A_f(z, OMEGA, P);
  At = @(z) At_f(z, N, OMEGA, P);
  % obsevations
  b = A(x);
  % initial point
  x0 = At(b);
else
  FT = 1/sqrt(N)*fft(eye(N));
  A = sqrt(2)*[real(FT(OMEGA,:)); imag(FT(OMEGA,:))];
  A = [1/sqrt(N)*ones(1,N); A];
  At = [];
  % observations
  b = A*x;
  % initial point
  x0 = A'*b;
end
imshow(II/max(max(II)))

IMGh=II/max(max(II));
HH=0;
for j=[2,3,4,6,8:1:10]%iteraciones=(multiplos de 4)-1 
    HH=HH+1
    epsilon =(4+(j*2))*3^(-j)
       
    tvI = sum(sum(sqrt([diff(I,1,2) zeros(n,1)].^2 + [diff(I,1,1); zeros(1,n)].^2 )));
    disp(sprintf('Original TV = %.3f', tvI));
    time0 = clock;
    xp =  tvqc_logbarrier(x0, A, At, b, epsilon, 1e-4,3, 1e-8, 100);
    Ip = reshape(xp, n, n);
    disp(sprintf('Total elapsed time = %f secs\n', etime(clock,time0)));
    tam=size(IMGh);
    if tam(2)==n*4
        if HH==4
            IMG=IMGh;
        else
            IMG=[IMG;IMGh];
        end
        
        IMGh=Ip/max(max(Ip));
    else
        IMGh=[IMGh,Ip/max(max(Ip))];
    end   
end
IMG=[IMG;IMGh];
figure
imshow(imresize(IMG,3,'box'));

%% Twist Manual
% x=(yyRL-min(yyRL(:)))/(max(yyRL(:)))-min(yyRL(:));
x=xfilt;
% x=imnlmfilt(xorg,'ComparisonWindowSize',7,'SearchWindowSize',21,"DegreeOfSmoothing",0.01);
alpha = 0.5;
beta = 0.25;
iteraTV=5;
iterTWIST=300;
y=x;
IMGh=[y];
HH=0;
lambdas=[0.88:-0.02:0.68];
for j=lambdas
    HH=HH+1
%     lambda = (4+(j*2))*2^(-j)
    lambda=j
    time0 = clock;
    x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,lambda,iteraTV);
    disp(sprintf('Total elapsed time = %f secs\n', etime(clock,time0)));
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
figure
imshow(imresize(IMG,3,'box'));
title("Lambdas del "+lambdas(1)+" al "+ lambdas(end))
