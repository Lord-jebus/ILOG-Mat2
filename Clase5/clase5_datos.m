%% ============================================================
%%  MATEMATICAS 2 --- CLASE 5
%%  Script MATLAB: Metodo de Gauss --- eliminacion hacia adelante
%%  Archivo: clase5_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar seccion a seccion con Ctrl+Enter
%%  o el script completo con F5.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 5\n');
fprintf(' Metodo de Gauss: eliminacion hacia adelante\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: GAUSS MANUAL --- SISTEMA 3x3 LOGISTICO
%% ============================================================
%
% Sistema de balance de inventario: 3 plantas, 3 CDs
% x_i = toneladas a despachar desde la planta i

fprintf('--- BLOQUE 1: Gauss manual sistema 3x3 ---\n\n');

A3 = [2 4 2;
      1 3 4;
      3 7 2];
b3 = [12; 11; 17];

fprintf('Matriz aumentada inicial:\n');
Aug = [A3, b3];
imprime_aug(Aug, 3);

%% Paso 1: eliminar columna 1
fprintf('\n--- Paso 1: pivote en (1,1) = %.0f ---\n', Aug(1,1));
m21 = Aug(2,1)/Aug(1,1);
m31 = Aug(3,1)/Aug(1,1);
fprintf('Multiplicadores: m21=%.4f  m31=%.4f\n', m21, m31);
Aug(2,:) = Aug(2,:) - m21*Aug(1,:);
Aug(3,:) = Aug(3,:) - m31*Aug(1,:);
fprintf('Despues de eliminar columna 1:\n');
imprime_aug(Aug, 3);

%% Paso 2: eliminar columna 2
fprintf('\n--- Paso 2: pivote en (2,2) = %.0f ---\n', Aug(2,2));
m32 = Aug(3,2)/Aug(2,2);
fprintf('Multiplicador: m32=%.4f\n', m32);
Aug(3,:) = Aug(3,:) - m32*Aug(2,:);
fprintf('Forma escalonada final:\n');
imprime_aug(Aug, 3);

%% Sustitucion hacia atras
fprintf('\n--- Sustitucion hacia atras ---\n');
x3 = zeros(3,1);
x3(3) = Aug(3,4)/Aug(3,3);
x3(2) = (Aug(2,4) - Aug(2,3)*x3(3)) / Aug(2,2);
x3(1) = (Aug(1,4) - Aug(1,2)*x3(2) - Aug(1,3)*x3(3)) / Aug(1,1);
fprintf('x3 = %.4f ton (Planta 3)\n', x3(3));
fprintf('x2 = %.4f ton (Planta 2)\n', x3(2));
fprintf('x1 = %.4f ton (Planta 1)\n\n', x3(1));

%% Verificacion
fprintf('Verificacion ||A*x - b|| = %.2e\n\n', norm(A3*x3 - b3));

%% Comparacion con A\b
x_matlab = A3 \ b3;
fprintf('Comparacion con MATLAB (A\\b):\n');
fprintf('  Gauss manual: [%.4f  %.4f  %.4f]\n', x3');
fprintf('  MATLAB A\\b:  [%.4f  %.4f  %.4f]\n\n', x_matlab');

%% ============================================================
%% BLOQUE 2: SISTEMA 4x4 --- GAUSS COMPLETO
%% ============================================================

fprintf('--- BLOQUE 2: Sistema 4x4 completo ---\n\n');

A4 = [1 2 0 1;
      2 5 1 1;
      0 1 3 2;
      1 3 2 4];
b4 = [7; 14; 10; 15];

fprintf('Sistema 4x4:\n');
Aug4 = [A4, b4];
imprime_aug(Aug4, 4);

%% Gauss automatico
Aug4_g = gauss_eliminacion(A4, b4);
fprintf('Forma escalonada:\n');
imprime_aug(Aug4_g, 4);

%% Sustitucion hacia atras
x4 = sustitucion_atras(Aug4_g, 4);
fprintf('Solucion: x = [%.4f  %.4f  %.4f  %.4f]\n', x4');
fprintf('Residuo: %.2e\n\n', norm(A4*x4 - b4));

%% Mostrar que x2 es negativo
fprintf('Nota: x2 = %.4f (negativo)\n', x4(2));
fprintf('En logistica: significa que la ruta 2 es inviable con esta demanda.\n');
fprintf('Se necesita revisar la red o ajustar la demanda.\n\n');

%% ============================================================
%% BLOQUE 3: CLASIFICACION DE SISTEMAS CON GAUSS
%% ============================================================

fprintf('--- BLOQUE 3: Clasificacion de sistemas ---\n\n');

%% Caso 1: Solucion unica
A_u = [2 1; 1 3];
b_u = [5; 7];
clasificar_sistema(A_u, b_u, 'Sistema 2x2 (sol. unica esperada)');

%% Caso 2: Infinitas soluciones
A_i = [1 2 -1; 2 4 -2; 1 2 -1];
b_i = [3; 6; 3];
clasificar_sistema(A_i, b_i, 'Sistema (infinitas sol. esperadas)');

%% Caso 3: Incompatible
A_c = [1 2; 2 4];
b_c = [3; 7];
clasificar_sistema(A_c, b_c, 'Sistema incompatible');

%% ============================================================
%% BLOQUE 4: VARIABLES LIBRES Y SOLUCION GENERAL
%% ============================================================

fprintf('--- BLOQUE 4: Variables libres y solucion general ---\n\n');

%% Sistema con 2 variables libres
A_lib = [1 2 0 1;
         2 4 1 3;
         0 0 1 1];
b_lib = [5; 11; 1];

fprintf('Sistema con variables libres:\n');
Aug_lib = [A_lib, b_lib];
imprime_aug(Aug_lib, 4);

[R, pivots] = rref(Aug_lib);
fprintf('\nForma escalonada reducida (rref):\n');
imprime_aug(R, 4);

rA  = rank(A_lib);
n_v = size(A_lib,2);
vars_libres = setdiff(1:n_v, pivots(pivots<=n_v));
fprintf('Pivotes en columnas: %s\n', mat2str(pivots(pivots<=n_v)));
fprintf('Variables libres: x%s\n', mat2str(vars_libres));
fprintf('Numero de variables libres: %d\n\n', n_v - rA);

%% Solucion general
fprintf('Solucion general (s=x2, t=x4):\n');
fprintf('  x1 = 5 - 2*s - t\n');
fprintf('  x2 = s  (libre)\n');
fprintf('  x3 = 1 - t\n');
fprintf('  x4 = t  (libre)\n\n');

%% Verificacion para s=1, t=0
s=1; t=0;
x_particular = [5-2*s-t; s; 1-t; t];
fprintf('Para s=%g, t=%g: x = [%.0f  %.0f  %.0f  %.0f]\n', ...
    s, t, x_particular');
fprintf('Residuo: %.2e\n\n', norm(A_lib*x_particular - b_lib));

%% ============================================================
%% BLOQUE 5: OPTIMIZACION SOBRE LA FAMILIA DE SOLUCIONES
%% ============================================================

fprintf('--- BLOQUE 5: Mejor plan en familia de soluciones ---\n\n');

%% Costos por planta: c = (10, 8, 12, 6)
c_costo = [10; 8; 12; 6];
fprintf('Costo por planta (USD/ton): [%d %d %d %d]\n', c_costo');

%% Costo como funcion de (s,t)
%% x1=5-2s-t, x2=s, x3=1-t, x4=t
%% C(s,t) = 10(5-2s-t)+8s+12(1-t)+6t = 50-20s-10t+8s+12-12t+6t = 62-12s-16t
fprintf('\nCosto total C(s,t) = 62 - 12s - 16t (USD)\n');
fprintf('Para minimizar: maximizar s y t\n\n');

%% Region factible: x_i >= 0
%% x1=5-2s-t>=0 => 2s+t<=5
%% x2=s>=0
%% x3=1-t>=0 => t<=1
%% x4=t>=0

fprintf('Restricciones de no negatividad:\n');
fprintf('  x2 >= 0: s >= 0\n');
fprintf('  x4 >= 0: t >= 0\n');
fprintf('  x3 >= 0: t <= 1\n');
fprintf('  x1 >= 0: 2s + t <= 5\n\n');

%% Evaluar en vertices del dominio factible
vertices = [0 0; 5/2 0; 2 1; 0 1];  % vertices de la region
fprintf('%-12s %-12s %-12s %-12s\n','s','t','Costo (USD)','x (plan)');
fprintf('%s\n', repmat('-',1,55));
for k = 1:size(vertices,1)
    s_v = vertices(k,1); t_v = vertices(k,2);
    x_v = [5-2*s_v-t_v; s_v; 1-t_v; t_v];
    costo_v = c_costo' * x_v;
    fprintf('%-12.2f %-12.2f %-12.2f [%.1f %.1f %.1f %.1f]\n', ...
        s_v, t_v, costo_v, x_v');
end
fprintf('\n');
fprintf('Minimo costo en vertice (s=2, t=1): C=22 USD/ton\n');
fprintf('Plan optimo: x=[0, 2, 0, 1] (solo plantas 2 y 4)\n\n');

%% ============================================================
%% BLOQUE 6: GAUSS CON PIVOTEO PARCIAL
%% ============================================================

fprintf('--- BLOQUE 6: Gauss con pivoteo parcial ---\n\n');

n_test = 6;
rng(123);
A_rand = rand(n_test) + n_test*eye(n_test);
b_rand = rand(n_test, 1);

%% Sin pivoteo
Aug_sin = gauss_eliminacion(A_rand, b_rand);
x_sin   = sustitucion_atras(Aug_sin, n_test);

%% Con pivoteo parcial
x_piv   = gauss_pivoteo(A_rand, b_rand);

%% MATLAB
x_ml    = A_rand \ b_rand;

fprintf('Comparacion de metodos (residuo ||A*x-b||):\n');
fprintf('  Gauss sin pivoteo:    %.2e\n', norm(A_rand*x_sin - b_rand));
fprintf('  Gauss con pivoteo:    %.2e\n', norm(A_rand*x_piv - b_rand));
fprintf('  MATLAB A\\b:          %.2e\n\n', norm(A_rand*x_ml  - b_rand));

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 5 --- Metodo de Gauss','NumberTitle','off',...
       'Position',[50 50 1300 750]);

%% Subplot 1: Evolucion de la matriz (heatmap)
subplot(2,3,1);
Aug_ini  = [A3, b3];
Aug_fe   = gauss_eliminacion(A3, b3);
imagesc([Aug_ini; nan(1,4); Aug_fe], [-5 15]);
colormap(gca, 'cool'); colorbar;
yticks([1 2 3 5 6 7]);
yticklabels({'F1','F2','F3','','F1','F2','F3'});
xlabel('Columna (4 = b)');
title('Antes (filas 1-3) vs FE (filas 5-7)');
grid on;

%% Subplot 2: Solucion del sistema 3x3
subplot(2,3,2);
bar(x3,'FaceColor',[0 0.32 0.58]);
set(gca,'XTickLabel',{'Planta 1','Planta 2','Planta 3'});
ylabel('Toneladas a despachar');
title('Solucion sistema 3x3');
yline(0,'k--');
grid on;
for k=1:3
    text(k, x3(k)+0.05*max(abs(x3)), sprintf('%.2f t',x3(k)), ...
        'HorizontalAlignment','center','FontWeight','bold','FontSize',9);
end

%% Subplot 3: Residuos comparados por metodo
subplot(2,3,3);
metodos = {'Gauss manual','MATLAB A\\b'};
residuos = [norm(A3*x3-b3)+1e-16, norm(A3*x_matlab-b3)+1e-16];
bar(residuos);
set(gca,'XTickLabel',metodos,'YScale','log');
ylabel('Residuo ||Ax-b|| (escala log)');
title('Comparacion de residuos');
grid on;

%% Subplot 4: Region factible de la solucion general
subplot(2,3,4);
s_range = 0:0.05:2.5;
t_range = 0:0.05:1;
[S,T] = meshgrid(s_range, t_range);
X1 = 5-2*S-T; X2=S; X3=1-T; X4=T;
factible = (X1>=0)&(X2>=0)&(X3>=0)&(X4>=0);
Costo = 62 - 12*S - 16*T;
Costo(~factible) = NaN;
contourf(S, T, Costo, 20); colorbar;
hold on;
plot(2,1,'r*','MarkerSize',12,'LineWidth',2,'DisplayName','Optimo');
xlabel('s (despacho planta 2)'); ylabel('t (despacho planta 4)');
title('Region factible y costo C(s,t)');
legend('Location','best'); grid on;

%% Subplot 5: Pivoteo parcial --- residuos por tamano
subplot(2,3,5);
n_vals = 5:5:40;
res_sin = zeros(size(n_vals));
res_piv = zeros(size(n_vals));
for k=1:length(n_vals)
    nk = n_vals(k);
    Ak = rand(nk) + 0.1*eye(nk);  % mal condicionada intencionalmente
    bk = rand(nk,1);
    try
        Aug_k = gauss_eliminacion(Ak,bk);
        xk_sin = sustitucion_atras(Aug_k,nk);
        res_sin(k) = norm(Ak*xk_sin-bk);
    catch
        res_sin(k) = NaN;
    end
    xk_piv = gauss_pivoteo(Ak,bk);
    res_piv(k) = norm(Ak*xk_piv-bk);
end
semilogy(n_vals, res_sin,'b-o','LineWidth',2,'DisplayName','Sin pivoteo');
hold on;
semilogy(n_vals, res_piv,'r-s','LineWidth',2,'DisplayName','Con pivoteo');
xlabel('Tamano n'); ylabel('Residuo (escala log)');
title('Estabilidad: pivoteo vs sin pivoteo');
legend('Location','best'); grid on;

%% Subplot 6: Clasificacion de sistemas
subplot(2,3,6);
sistemas_test = {
    [1 2;3 6],  [9;27],  'Infinitas';
    [1 2;3 6],  [9;28],  'Incompatible';
    [1 2;3 5],  [9;14],  'Unica';
    [1 2 0;0 0 1;1 0 1],[3;1;2],'Unica 3x3';
};
colores_cls = {[0.2 0.6 0.9],[0.9 0.2 0.2],[0.2 0.8 0.3],[0.8 0.6 0.1]};
for k=1:4
    Ak=sistemas_test{k,1}; bk=sistemas_test{k,2};
    rA=rank(Ak); rAb=rank([Ak bk]); nv=size(Ak,2);
    if rA<rAb,    tipo=3; str='Incompatible';
    elseif rA==nv, tipo=1; str='Unica';
    else,          tipo=2; str='Infinitas'; end
    text(0.5, 1-k*0.22, sprintf('Caso %d: %s (r=%d, r_{aug}=%d)', ...
        k, str, rA, rAb), 'HorizontalAlignment','center', ...
        'Color',colores_cls{k},'FontSize',10,'FontWeight','bold',...
        'Units','normalized');
end
axis off; title('Clasificacion automatica de sistemas');

sgtitle('MATEMATICAS 2 --- Clase 5: Metodo de Gauss', ...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 5)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cuantos pasos de eliminacion necesita Gauss\n');
fprintf('   para un sistema 3x3? ¿Y para un 4x4?\n');
fprintf('   Respuesta: 3x3 -> 2 pasos; 4x4 -> 3 pasos\n\n');

fprintf('2. ¿Cual es el multiplicador m32 en el Bloque 1?\n');
fprintf('   Respuesta: m32 = %.4f\n\n', m32);

fprintf('3. Clasifica el sistema A=[1 2;2 4], b=[3;6].\n');
A_q3=[1 2;2 4]; b_q3=[3;6];
rA3=rank(A_q3); rAb3=rank([A_q3 b_q3]);
fprintf('   rang(A)=%d, rang([A|b])=%d => ', rA3, rAb3);
if rA3==rAb3 && rA3<size(A_q3,2)
    fprintf('INFINITAS SOLUCIONES\n\n');
elseif rA3<rAb3
    fprintf('INCOMPATIBLE\n\n');
else
    fprintf('SOLUCION UNICA\n\n');
end

fprintf('4. Para la familia de soluciones del Bloque 4,\n');
fprintf('   ¿que valores de (s,t) dan el plan de menor costo?\n');
fprintf('   Respuesta: s=2, t=1 => Costo = $22 USD/ton\n\n');

fprintf('5. Implementa la sustitucion hacia atras para el\n');
fprintf('   sistema triangular [3 1 2|8; 0 2 1|5; 0 0 4|8].\n');
Aug_q5=[3 1 2 8;0 2 1 5;0 0 4 8];
x_q5=sustitucion_atras(Aug_q5,3);
fprintf('   Solucion: [%.4f  %.4f  %.4f]\n\n', x_q5');
fprintf('==========================================\n');
fprintf('Fin del script clase5_datos.m\n');
fprintf('==========================================\n');

%% ============================================================
%%  FUNCIONES AUXILIARES
%% ============================================================

function imprime_aug(Aug, n)
    [m,~] = size(Aug);
    for i=1:m
        fprintf('  |');
        for j=1:n,   fprintf(' %8.4f', Aug(i,j)); end
        fprintf(' |');
        fprintf(' %8.4f', Aug(i,n+1));
        fprintf(' |\n');
    end
    fprintf('\n');
end

function Aug_out = gauss_eliminacion(A, b)
    n   = length(b);
    Aug = [A, b];
    for k = 1:n-1
        for i = k+1:n
            if Aug(k,k) == 0, break; end
            m = Aug(i,k) / Aug(k,k);
            Aug(i,:) = Aug(i,:) - m*Aug(k,:);
        end
    end
    Aug_out = Aug;
end

function x = sustitucion_atras(Aug, n)
    x = zeros(n,1);
    for i = n:-1:1
        x(i) = (Aug(i,n+1) - Aug(i,i+1:n)*x(i+1:n)) / Aug(i,i);
    end
end

function x = gauss_pivoteo(A, b)
    n   = length(b);
    Aug = [A, b];
    for k = 1:n-1
        [~, idx] = max(abs(Aug(k:n, k)));
        idx = idx + k - 1;
        if idx ~= k
            Aug([k, idx], :) = Aug([idx, k], :);
        end
        for i = k+1:n
            if Aug(k,k) == 0, continue; end
            m = Aug(i,k) / Aug(k,k);
            Aug(i,:) = Aug(i,:) - m*Aug(k,:);
        end
    end
    x = sustitucion_atras(Aug, n);
end

function clasificar_sistema(A, b, nombre)
    n   = size(A,2);
    rA  = rank(A);
    rAb = rank([A b]);
    Aug = gauss_eliminacion(A, b);
    fprintf('Sistema: %s\n', nombre);
    fprintf('  rang(A)=%d  rang([A|b])=%d  n=%d\n', rA, rAb, n);
    if rA < rAb
        fprintf('  => INCOMPATIBLE (sin solucion)\n');
    elseif rA == n
        x = sustitucion_atras(Aug, n);
        fprintf('  => SOLUCION UNICA: x=[');
        fprintf('%.4f ', x'); fprintf(']\n');
        fprintf('  Residuo: %.2e\n', norm(A*x-b));
    else
        fprintf('  => INFINITAS SOLUCIONES (%d variables libres)\n', n-rA);
    end
    fprintf('\n');
end
