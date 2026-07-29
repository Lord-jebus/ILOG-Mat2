%% ============================================================
%%  MATEMATICAS 2 --- CLASE 14
%%  Script MATLAB: Vectores en R^n --- Normas y Distancias
%%  Archivo: clase14_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 14\n');
fprintf(' Vectores en R^n: Normas y Distancias\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: ESTADOS LOGISTICOS COMO VECTORES
%% ============================================================

fprintf('--- BLOQUE 1: Vectores logisticos ---\n\n');

%% Datos de la red (4 CDs)
CDs = {'D1 Mald','D2 Tac','D3 Col','D4 Art'};

%% Diferentes estados como vectores en R^4
d_sem1  = [300; 250; 200; 180];   % demanda semana 1
d_sem2  = [320; 230; 210; 170];   % demanda semana 2
s0      = [450; 320; 180; 270];   % stock inicial
repos   = [280; 260; 220; 190];   % reposicion semana 1
e_prev  = [20; -15;  8;  -3];    % error de prevision

fprintf('Estados logisticos:\n');
fprintf('%-12s | %s | %s | %s | %s\n','Estado',CDs{:});
fprintf('%s\n', repmat('-',1,55));
estados = {d_sem1,'Demanda S1'; d_sem2,'Demanda S2';
           s0,'Stock ini.'; repos,'Reposicion'; e_prev,'Error prev.'};
for k = 1:5
    fprintf('%-12s | %5.0f | %5.0f | %5.0f | %5.0f\n',...
        estados{k,2}, estados{k,1}');
end
fprintf('\n');

%% Operaciones vectoriales
fprintf('Operaciones:\n');
stock_final = s0 + repos - d_sem1;
fprintf('s1 = s0 + r - d1 = [%s] ton\n', num2str(stock_final','%.0f '));
fprintf('Stock negativo en: %s\n', mat2str(find(stock_final < 0)));
demanda_total = d_sem1 + d_sem2;
fprintf('d1 + d2 (2 fabricas) = [%s]\n', num2str(demanda_total','%.0f '));
demanda_110 = 1.1 * d_sem1;
fprintf('1.1*d1 (+10%%) = [%s]\n\n', num2str(demanda_110','%.0f '));

%% ============================================================
%% BLOQUE 2: NORMAS --- CALCULO E INTERPRETACION
%% ============================================================

fprintf('--- BLOQUE 2: Normas ---\n\n');

%% Normas de d_sem1
fprintf('Normas de d_sem1 = [%s]:\n', num2str(d_sem1','%.0f '));
n1  = norm(d_sem1, 1);
n2  = norm(d_sem1, 2);
ni  = norm(d_sem1, Inf);
fprintf('  ||d||_1   = %.4f (L1, suma valores absolutos)\n', n1);
fprintf('  ||d||_2   = %.4f (L2, euclidea)\n', n2);
fprintf('  ||d||_inf = %.4f (L_inf, componente maxima)\n\n', ni);

%% Verificar identidad L2
n2_manual = sqrt(d_sem1' * d_sem1);
fprintf('Verificacion ||d||_2 = sqrt(d^T*d) = %.4f\n\n', n2_manual);

%% Desigualdad entre normas
fprintf('Desigualdad: ||v||_inf <= ||v||_2 <= ||v||_1 <= sqrt(n)*||v||_2\n');
n = length(d_sem1);
fprintf('  %.4f <= %.4f <= %.4f <= %.4f\n', ni, n2, n1, sqrt(n)*n2);
fprintf('  Se cumple: %s\n\n', mat2str(ni<=n2 && n2<=n1 && n1<=sqrt(n)*n2));

%% Normas del error de prevision
fprintf('Normas del error de prevision e = [%s]:\n', num2str(e_prev','%.0f '));
ne1 = norm(e_prev,1); ne2 = norm(e_prev,2); nei = norm(e_prev,Inf);
fprintf('  ||e||_1   = %.4f ton (volumen total de ajuste)\n', ne1);
fprintf('  ||e||_2   = %.4f ton (error cuadratico global)\n', ne2);
fprintf('  ||e||_inf = %.4f ton (peor desvio individual: CD%d)\n',...
    nei, find(abs(e_prev)==nei));

%% Verificacion SLA: ningun CD con desvio > 15 ton
sla_limite = 15;
fprintf('\nSLA: ningun CD con desvio > %d ton\n', sla_limite);
fprintf('  ||e||_inf = %.1f ', nei);
if nei <= sla_limite
    fprintf('=> SLA CUMPLIDO\n\n');
else
    fprintf('=> SLA NO CUMPLIDO (CDs: %s)\n\n',...
        mat2str(find(abs(e_prev) > sla_limite)));
end

%% ============================================================
%% BLOQUE 3: DISTANCIA ENTRE VECTORES
%% ============================================================

fprintf('--- BLOQUE 3: Distancia entre vectores ---\n\n');

%% 4 semanas de demanda
D_sem = [300 320 280 310;
         250 230 270 260;
         200 210 190 205;
         180 170 200 185];

fprintf('Datos de 4 semanas (columnas):\n');
fprintf('%-8s | S1 | S2 | S3 | S4\n', 'CD');
for d=1:4
    fprintf('%-8s | %3.0f| %3.0f| %3.0f| %3.0f\n', CDs{d}, D_sem(d,:));
end
fprintf('\n');

%% Matriz de distancias L2
nsem = size(D_sem,2);
D_mat = zeros(nsem);
for i=1:nsem
    for j=1:nsem
        D_mat(i,j) = norm(D_sem(:,i)-D_sem(:,j), 2);
    end
end

fprintf('Matriz de distancias L2:\n');
fprintf('     ');
for s=1:nsem, fprintf('  S%d   ',s); end
fprintf('\n');
for i=1:nsem
    fprintf('S%d | ', i);
    for j=1:nsem, fprintf('%6.2f ', D_mat(i,j)); end
    fprintf('\n');
end

%% Semanas mas parecidas y mas distintas
D_upper = triu(D_mat,1);
D_upper(D_upper==0) = Inf;
[min_d, idx_min] = min(D_upper(:));
[r1,c1] = ind2sub([nsem,nsem], idx_min);
D_upper2 = triu(D_mat,1);
[max_d, idx_max] = max(D_upper2(:));
[r2,c2] = ind2sub([nsem,nsem], idx_max);
fprintf('\nSemanas mas PARECIDAS:   S%d - S%d (d_2 = %.2f ton)\n', r1,c1,min_d);
fprintf('Semanas mas DIFERENTES:  S%d - S%d (d_2 = %.2f ton)\n\n', r2,c2,max_d);

%% ============================================================
%% BLOQUE 4: BALANCE DE INVENTARIO VECTORIAL
%% ============================================================

fprintf('--- BLOQUE 4: Balance de inventario ---\n\n');

%% Datos de inventario - 4 semanas
s_ini = [450; 320; 180; 270];
s_min = [80;  60;  40;  50];   % stock minimo deseado

demandas = {[200;150;100;130], [220;160;90;140], ...
            [190;140;110;125], [210;155;105;135]};
repos_plan = {[180;140;110;120],[200;150;100;130],...
              [210;160;90;125], [195;145;115;130]};

fprintf('Simulacion de 4 semanas:\n');
fprintf('%-8s | Stock ini | S1 fin | S2 fin | S3 fin | S4 fin\n','CD');
fprintf('%s\n',repmat('-',1,62));

s_t = s_ini;
stocks = zeros(4,5);
stocks(:,1) = s_ini;
rotura = false;
for t = 1:4
    s_t = s_t + repos_plan{t} - demandas{t};
    stocks(:,t+1) = s_t;
    if any(s_t < 0)
        rotura = true;
    end
end
for d=1:4
    fprintf('%-8s | %9.0f | %6.0f | %6.0f | %6.0f | %6.0f\n',...
        CDs{d}, stocks(d,:));
end
fprintf('Rotura de stock en alguna semana: %s\n', yesNo(rotura));
fprintf('Stock final vs minimo:\n');
for d=1:4
    ok = stocks(d,end) >= s_min(d);
    fprintf('  %s: %.0f ton (min=%d) => %s\n',...
        CDs{d}, stocks(d,end), s_min(d), yesNo(ok));
end
fprintf('\n');

%% ============================================================
%% BLOQUE 5: VECTOR UNITARIO Y PATRON RELATIVO
%% ============================================================

fprintf('--- BLOQUE 5: Vector unitario ---\n\n');

d = d_sem1;
d_hat = d / norm(d, 2);

fprintf('d = [%s]\n', num2str(d','%.0f '));
fprintf('||d||_2 = %.4f\n', norm(d,2));
fprintf('d_hat = d/||d||_2 = [%s]\n', num2str(d_hat','%.4f '));
fprintf('||d_hat||_2 = %.6f (debe ser 1.0)\n\n', norm(d_hat,2));

fprintf('Interpretacion: el patron relativo de demanda es\n');
for k=1:4
    fprintf('  %s: %.1f%% del total\n', CDs{k}, d_hat(k)^2/sum(d_hat.^2)*100);
end
fprintf('\n');

%% Si la demanda total crece de 930 a 1200 ton con el mismo patron
total_nuevo = 1200;
d_nuevo = total_nuevo * d_hat;
fprintf('Si demanda total sube a %.0f ton (mismo patron):\n', total_nuevo);
fprintf('  d_nuevo = [%s]\n\n', num2str(d_nuevo','%.1f '));

%% ============================================================
%% BLOQUE 6: COMPARACION DE NORMAS PARA UN SLA
%% ============================================================

fprintf('--- BLOQUE 6: Eleccion de norma segun SLA ---\n\n');

errores = {[30;1;1;1],'Desvio concentrado D1';
           [10;10;10;10],'Desvio uniforme';
           [20;-20;10;-10],'Desvio mixto';
           [50;-30;15;-10;30],'Desvio 5 CDs'};

sla_lim = 25;
fprintf('SLA: ningun CD con desvio > %d ton (norma L_inf)\n\n', sla_lim);
fprintf('%-25s | L1  | L2   | Linf | SLA OK?\n', 'Tipo de error');
fprintf('%s\n', repmat('-',1,60));
for k = 1:4
    ek = errores{k,1};
    l1 = norm(ek,1); l2 = norm(ek,2); li = norm(ek,Inf);
    ok = li <= sla_lim;
    fprintf('%-25s | %3.0f | %5.1f | %4.0f | %s\n',...
        errores{k,2}, l1, l2, li, yesNo(ok));
end
fprintf('\n');

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 14 --- Vectores en R^n','NumberTitle','off',...
    'Position',[30 30 1350 800]);

%% Subplot 1: Vectores de demanda (comparacion visual)
subplot(2,3,1);
bar(D_sem);
set(gca,'XTickLabel',CDs,'XTickLabelRotation',20);
ylabel('Toneladas'); title('Demanda por CD (4 semanas)');
legend({'S1','S2','S3','S4'},'Location','best'); grid on;

%% Subplot 2: Comparacion de normas
subplot(2,3,2);
norms_d = [norm(d_sem1,1), norm(d_sem1,2), norm(d_sem1,Inf)];
bar(norms_d,'FaceColor',[0 0.32 0.58]);
set(gca,'XTickLabel',{'L_1','L_2','L_\infty'});
ylabel('Valor'); title('Normas de d_{sem1}');
grid on;
for k=1:3
    text(k,norms_d(k)+5,sprintf('%.1f',norms_d(k)),...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 3: Heatmap de distancias entre semanas
subplot(2,3,3);
imagesc(D_mat); colorbar; colormap(gca,'hot');
set(gca,'XTick',1:4,'XTickLabel',{'S1','S2','S3','S4'});
set(gca,'YTick',1:4,'YTickLabel',{'S1','S2','S3','S4'});
title('Distancias L_2 entre semanas');
xlabel('Semana j'); ylabel('Semana i');
for i=1:4; for j=1:4
    text(j,i,sprintf('%.0f',D_mat(i,j)),'HorizontalAlignment','center',...
        'Color','white','FontWeight','bold','FontSize',9);
end; end

%% Subplot 4: Evolucion del inventario
subplot(2,3,4);
plot(0:4, stocks', 'LineWidth', 2);
hold on;
for d=1:4, yline(s_min(d),'--','LineWidth',1); end
xlabel('Semana'); ylabel('Toneladas');
title('Evolucion de stock por CD');
legend(CDs,'Location','best'); grid on;
xticks(0:4);

%% Subplot 5: Vector unitario vs vector original
subplot(2,3,5);
bar([d/max(d), d_hat]);
set(gca,'XTickLabel',CDs,'XTickLabelRotation',20);
title('Vector original (normalizado) vs unitario');
legend({'d/max(d)','d\_hat'},'Location','best'); grid on;

%% Subplot 6: Circulo unitario para distintas normas (en 2D)
subplot(2,3,6);
theta = linspace(0, 2*pi, 1000);
%% L2: circulo
x2 = cos(theta); y2 = sin(theta);
%% L1: cuadrado rotado 45 grados
x1 = zeros(1,5); y1 = zeros(1,5);
pts_l1 = [1 0; 0 1; -1 0; 0 -1; 1 0];
%% Linf: cuadrado
pts_li = [1 1; -1 1; -1 -1; 1 -1; 1 1];
plot(x2,y2,'b-','LineWidth',2,'DisplayName','L_2 (esfera)');
hold on;
plot(pts_l1(:,1),pts_l1(:,2),'r-','LineWidth',2,'DisplayName','L_1 (diamante)');
plot(pts_li(:,1),pts_li(:,2),'g-','LineWidth',2,'DisplayName','L_\infty (cuadrado)');
axis equal; grid on; legend('Location','best');
title('Bolas unitarias en 2D'); xlabel('v_1'); ylabel('v_2');

sgtitle('MATEMATICAS 2 --- Clase 14: Vectores en R^n',...
    'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 14)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cual es ||d_sem1||_1? ¿Que representa logisticamente?\n');
fprintf('   Respuesta: %.1f ton (demanda total en todos los CDs)\n\n', n1);

fprintf('2. ¿Cual es la distancia L2 entre S1 y S2?\n');
fprintf('   Respuesta: %.4f ton\n\n', D_mat(1,2));

fprintf('3. ¿Hay rotura de stock en la simulacion de 4 semanas?\n');
fprintf('   Respuesta: %s\n\n', yesNo(rotura));

fprintf('4. ¿Se cumple el SLA (desvio max. 15 ton) con el error e=[%s]?\n',...
    num2str(e_prev','%.0f '));
fprintf('   ||e||_inf = %.1f => %s\n\n', nei, yesNo(nei<=15));

fprintf('5. Calcula ||d_hat||_2 y verifica que es 1.\n');
fprintf('   Respuesta: %.6f\n\n', norm(d_hat,2));
fprintf('==========================================\n');
fprintf('Fin del script clase14_datos.m\n');
fprintf('==========================================\n');

%% --- Funcion auxiliar ---
function s = yesNo(v)
    if v; s = 'SI'; else; s = 'NO'; end
end
