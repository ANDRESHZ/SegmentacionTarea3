clc; clf; close all; clear all;
data="TempCorrC1017"
% data="TempCorrC1025"
% data="TempCorrC1032"
% data="TempCorrC1044"
load (data)
N=length(C02t)-1;%Eliminamos la ultima imagen negra
x=zeros(79*2, 79*2, N);
%% Grabar videos de las secuencias de imagenes (gracias @Image Analyst)
frames = cell(N,1);
frames(:) = {zeros(1024, 1024, 1, 'uint8')}; %%obligamos a ser positivos}
MapaColor = cell(N,1);
MapaColor(:) = {zeros(256, 1)};% una capa de escala de gris
datoVideo = struct('cdata', frames, 'colormap', MapaColor);
set(gcf, 'renderer', 'zbuffer');%%opciones (OpenGL,zbuffer,painters)

for j = [1,1 : N]
    minimo=min(min(C02t{j}));
    a=(C02t{j}-minimo)/(max(max(C02t{j}))-minimo);
    minimo=min(min(C13t{j}));
    b=(C13t{j}-minimo)/(max(max(C13t{j}))-minimo);
    minimo=min(min(C20t{j}));
    c=(C20t{j}-minimo)/(max(max(C20t{j}))-minimo);
    minimo=min(min(C31t{j}));
    d=(C31t{j}-minimo)/(max(max(C31t{j}))-minimo);
	cla reset;
	set(gcf, 'Units', 'Normalized', 'Outerposition', [1, 1, 1, 1]);%%aseguramos que quede completo
	imshow([a,b;c,d],[],'InitialMagnification',1024);
    imwrite(imresize(a,6,'box'),"Evidencias\"+data+" "+j+".bmp")
	drawnow;
	FrameActu = getframe(gca);
	datoVideo(j) = FrameActu;
end
	startingFolder = pwd;%carpta incial del visor de archivos
	[nombBase, Carpeta] = uiputfile('*.avi', 'Video');
	if nombBase == 0 
		return;%%si pulso cancelar cierro
	end
	nombCompleto = fullfile(Carpeta, nombBase);
	[Carpeta, nombBase, ext] = fileparts(nombCompleto);
    ObjEscritura = VideoWriter(nombCompleto, 'Uncompressed AVI');
	open(ObjEscritura);
	nframes = length(datoVideo);
	for k = 2 : nframes 
	   writeVideo(ObjEscritura, datoVideo(k));
	end
	close(ObjEscritura);