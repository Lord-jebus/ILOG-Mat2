%% ============================================================
%%  MATEMÁTICAS 2 — CLASE 2
%%  Script MATLAB: Operaciones con matrices — datos y ejercicios
%%  Archivo: clase2_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar sección a sección con Ctrl+Enter (Run Section)
%%  o el script completo con F5.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMÁTICAS 2 — Clase 2\n');
fprintf(' Operaciones con matrices\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: DATASET PRINCIPAL — DOS SEMANAS DE OPERACIÓN
%% ============================================================
%
% Red: 3 plantas x 4 centros de distribución
% Plantas: 1=Montevideo, 2=Salto, 3=Rivera
% CDs:     1=Maldonado, 2=Paysandú, 3=Tacuarembó, 4=Colonia
% Unidades: USD por tonelada

fprintf('--- BLOQUE 1: Dataset principal ---\n\n');

plantas = {'Montevideo','Salto','Rivera'};
cds     = {'Maldonado','Paysandú','Tacuarembó','Colonia'};

% Matrices de costo de envío por semana
C1 = [12  35  48   8;
      40  15  22  38;
      52  28  10  60];

C2 = [14  33  50  10;
      38  17  24  36;
      55  30  12  58];

C3 = [13  36  49   9;
      39  14  23  37;
      53  29  11  61];

fprintf('== Semana 1 (USD/ton) ==\n'); disp(C1);
fprintf('== Semana 2 (USD/ton) ==\n'); disp(C2);
fprintf('== Semana 3 (USD/ton) ==\n'); disp(C3);

%% ============================================================
%% BLOQUE 2: SUMA Y RESTA
%% ============================================================

fprintf('--- BLOQUE 2: Suma y resta ---\n\n');

% Costo acumulado en 2 semanas
C_acum2 = C1 + C2;
fprintf('== Costo acumulado S1 + S2 ==\n');
disp(C_acum2);

% Costo acumulado en 3 semanas
C_acum3 = C1 + C2 + C3;
fprintf('== Costo acumulado S1 + S2 + S3 ==\n');
disp(C_acum3);

% Variación S1 → S2
DeltaC_12 = C2 - C1;
fprintf('== Variación S2 - S1 (USD/ton) ==\n');
disp(DeltaC_12);

% Análisis de la variación
fprintf('Rutas que AUMENTARON de S1 a S2:\n');
[fi, col] = find(DeltaC_12 > 0);
for k = 1:length(fi)
    fprintf('  %s → %s: +$%d/ton\n', plantas{fi(k)}, cds{col(k)}, DeltaC_12(fi(k),col(k)));
end

fprintf('\nRutas que BAJARON de S1 a S2:\n');
[fi, col] = find(DeltaC_12 < 0);
for k = 1:length(fi)
    fprintf('  %s → %s: $%d/ton\n', plantas{fi(k)}, cds{col(k)}, DeltaC_12(fi(k),col(k)));
end
fprintf('\n');

% Variación acumulada S1 → S3
DeltaC_13 = C3 - C1;
fprintf('== Variación acumulada S3 - S1 ==\n');
disp(DeltaC_13);

%% ============================================================
%% BLOQUE 3: MULTIPLICACIÓN ESCALAR
%% ============================================================

fprintf('--- BLOQUE 3: Multiplicación escalar ---\n\n');

% Escenarios de ajuste de tarifa
ajustes = struct();
ajustes.descuento10  = 0.90 * C1;
ajustes.sinCambio    = 1.00 * C1;
ajustes.aumento5     = 1.05 * C1;
ajustes.aumento15    = 1.15 * C1;
ajustes.aumento25    = 1.25 * C1;

fprintf('Costo total del sistema por escenario:\n');
fprintf('  -10%% (descuento): $%.0f total\n',     sum(ajustes.descuento10(:)));
fprintf('   0%% (sin cambio): $%.0f total\n',     sum(ajustes.sinCambio(:)));
fprintf('  +5%% (aumento 5):  $%.0f total\n',    sum(ajustes.aumento5(:)));
fprintf('  +15%% (aumento 15): $%.0f total\n',   sum(ajustes.aumento15(:)));
fprintf('  +25%% (aumento 25): $%.0f total\n\n', sum(ajustes.aumento25(:)));

% Promedio de 2 semanas
C_prom2 = 0.5 * (C1 + C2);
fprintf('== Costo promedio (S1 + S2)/2 ==\n');
disp(C_prom2);

% Promedio de 3 semanas
C_prom3 = (1/3) * (C1 + C2 + C3);
fprintf('== Costo promedio (S1+S2+S3)/3 ==\n');
disp(C_prom3);

% Promedio ponderado (más peso a la semana más reciente)
C_ponderado = 0.2*C1 + 0.3*C2 + 0.5*C3;
fprintf('== Promedio ponderado (20%%S1 + 30%%S2 + 50%%S3) ==\n');
disp(C_ponderado);
fprintf('(Más peso a datos recientes: útil para pronóstico)\n\n');

%% ============================================================
%% BLOQUE 4: MULTIPLICACIÓN MATRICIAL
%% ============================================================

fprintf('--- BLOQUE 4: Multiplicación matricial ---\n\n');

% CASO A: Tarifas x Volúmenes
% Tarifas: 3 plantas x 2 CDs grandes (simplificado)
T = [12 35;
     40 15;
     52 28];

% Volúmenes: 2 CDs x 3 categorías de producto (ton/semana)
V = [100  50  80;
      60 120  40];

fprintf('T (tarifas USD/ton) — %dx%d:\n', size(T));
disp(T);
fprintf('V (volúmenes ton/semana) — %dx%d:\n', size(V));
disp(V);

% Verificación de dimensiones
fprintf('Dimensiones compatibles: T(%dx%d) * V(%dx%d) = TV(%dx%d)\n\n', ...
    size(T,1),size(T,2), size(V,1),size(V,2), size(T,1),size(V,2));

% Producto
TV = T * V;
fprintf('== TV: Costo total por planta x categoría (USD/semana) ==\n');
disp(TV);

% Verificación manual del elemento (1,1)
manual_11 = T(1,:) * V(:,1);
fprintf('Verificación manual (TV)_(1,1) = %d * %d + %d * %d = %d\n', ...
    T(1,1), V(1,1), T(1,2), V(2,1), manual_11);

% ¿Cómo se comparan los costos por planta? (sumar filas de TV)
costo_por_planta = sum(TV, 2);
fprintf('\nCosto total semanal por planta (USD):\n');
for k = 1:3
    fprintf('  %s: $%.0f\n', plantas{k}, costo_por_planta(k));
end
[~, mejor_planta] = min(costo_por_planta);
fprintf('  → Planta más eficiente: %s\n\n', plantas{mejor_planta});

% CASO B: Análisis con vector de volúmenes para decisión de ruta
fprintf('--- CASO B: Decisión de ruta con volumen esperado ---\n\n');

% Volumen esperado por CD (ton/semana)
Vol_CD = [50; 80; 30; 60];  % columna: [Maldonado; Paysandú; Tacuarembó; Colonia]
fprintf('Volumen esperado por CD (ton/semana):\n');
for k = 1:4
    fprintf('  %s: %d ton\n', cds{k}, Vol_CD(k));
end
fprintf('\n');

% Costo por planta = C1 * Vol_CD (anticipo al producto matriz-vector de Clase 3)
costo_C1 = C1 * Vol_CD;
fprintf('Costo semanal total por planta (usando tarifas S1):\n');
for k = 1:3
    fprintf('  %s: $%.0f\n', plantas{k}, costo_C1(k));
end
[minCosto, mejorIdx] = min(costo_C1);
fprintf('  → Decisión: usar %s (costo $%.0f)\n\n', plantas{mejorIdx}, minCosto);

% ¿Y si usamos las tarifas de S2?
costo_C2 = C2 * Vol_CD;
fprintf('Con tarifas de Semana 2:\n');
for k = 1:3
    fprintf('  %s: $%.0f\n', plantas{k}, costo_C2(k));
end
[~, mejorIdx2] = min(costo_C2);
fprintf('  → Decisión: usar %s\n\n', plantas{mejorIdx2});

%% ============================================================
%% BLOQUE 5: PRODUCTO ELEMENTO A ELEMENTO (HADAMARD)
%% ============================================================

fprintf('--- BLOQUE 5: Producto Hadamard (.*)  ---\n\n');

% Factor de urgencia por ruta (1=normal, 2=urgente, 3=crítico)
Urgencia = [1 2 1 3;
            2 1 3 1;
            1 3 2 1];

fprintf('Urgencia por ruta (1=normal, 3=crítico):\n');
disp(Urgencia);

% Costo ponderado por urgencia
C_urgente = C1 .* Urgencia;
fprintf('Costo ponderado por urgencia (C1 .* Urgencia):\n');
disp(C_urgente);

% Ruta más costosa considerando urgencia
[val, idx] = max(C_urgente(:));
[fi, col] = ind2sub(size(C_urgente), idx);
fprintf('Ruta de mayor prioridad ponderada: %s → %s ($%d ajustado)\n\n', ...
    plantas{fi}, cds{col}, val);

% Demostrar diferencia entre * y .*
fprintf('Demostración: * vs .* NO son iguales:\n');
A_demo = [1 2; 3 4];
B_demo = [2 0; 1 2];
fprintf('A * B (multiplicación matricial):\n'); disp(A_demo * B_demo);
fprintf('A .* B (Hadamard):\n'); disp(A_demo .* B_demo);

%% ============================================================
%% BLOQUE 6: PROPIEDADES — VERIFICACIÓN COMPUTACIONAL
%% ============================================================

fprintf('--- BLOQUE 6: Verificación de propiedades ---\n\n');

A = C1; B = C2; k = 1.15; l = 0.90;

% Conmutatividad de la suma
fprintf('A+B == B+A:           %s\n', ynStr(isequal(A+B, B+A)));

% Distributividad escalar sobre suma de matrices
fprintf('k(A+B) == kA+kB:      %s\n', ynStr(isequal(k*(A+B), k*A+k*B)));

% Distributividad escalar sobre suma de escalares
fprintf('(k+l)A == kA+lA:      %s\n', ynStr(isequal((k+l)*A, k*A+l*A)));

% No conmutatividad multiplicación matricial
P = [2 3; 1 4];
Q = [1 0; 2 1];
fprintf('PQ == QP (esperado NO): %s\n', ynStr(isequal(P*Q, Q*P)));

% (AB)^T = B^T * A^T
X = C1; Y = [1 0 1 0; 0 1 0 1; 1 1 0 0; 0 0 1 1];  % 4x4
% X*Y no es definido (3x4 * 4x4 = 3x4): sí es válido
XY = X * Y;
fprintf('(XY)^T == Y^T*X^T:    %s\n\n', ynStr(isequal(XY', Y'*X')));

%% ============================================================
%% BLOQUE 7: DATASET EXTENDIDO — 4 PLANTAS × 3 REGIONES
%% ============================================================

fprintf('--- BLOQUE 7: Dataset extendido (nivel avanzado) ---\n\n');

% 4 plantas x 3 CDs regionales
T_ext = [10  28  45  12;
         35  12  20  40;
         48  22  8   55]';
% T_ext es 4x3 (plantas x CDs regionales)

% Volúmenes: 3 CDs x 5 regiones destino
V_ext = [80  60  40  90  50;
         30 100  70  20  80;
         60  40  90  50  30];

fprintf('Tarifas extendidas T (%dx%d):\n', size(T_ext)); disp(T_ext);
fprintf('Volúmenes V (%dx%d):\n', size(V_ext)); disp(V_ext);

% Producto
TV_ext = T_ext * V_ext;
fprintf('Costo total T*V (%dx%d):\n', size(TV_ext)); disp(TV_ext);

% ¿Qué planta tiene el menor costo total?
costo_total_ext = sum(TV_ext, 2);
fprintf('Costo total por planta (suma de todas las regiones):\n');
for k = 1:4
    fprintf('  Planta %d: $%.0f\n', k, costo_total_ext(k));
end
[~, idx_min] = min(costo_total_ext);
fprintf('  → Planta óptima: Planta %d\n\n', idx_min);

% Efecto combinado: costos +8%, volúmenes -5%
factor = 1.08 * 0.95;
fprintf('Efecto de costos +8%% y volúmenes -5%%:\n');
fprintf('  Factor neto: %.4f (%.2f%% de cambio)\n', factor, (factor-1)*100);
TV_nuevo = factor * TV_ext;
fprintf('  Costo total nuevo: $%.0f (antes: $%.0f)\n\n', ...
    sum(TV_nuevo(:)), sum(TV_ext(:)));

%% ============================================================
%% BLOQUE 8: VISUALIZACIÓN
%% ============================================================

fprintf('--- BLOQUE 8: Visualizaciones ---\n');

figure('Name','Clase 2 — Operaciones Matriciales', ...
       'NumberTitle','off','Position',[50 50 1300 850]);

% 1. Comparación S1 vs S2
subplot(2,3,1);
bar_data = [C1(:), C2(:)];
bar(bar_data);
title('Costos por ruta: S1 vs S2');
xlabel('Ruta (índice lineal)');
ylabel('USD/ton');
legend({'Semana 1','Semana 2'},'Location','best');
grid on;

% 2. Heatmap de variación
subplot(2,3,2);
imagesc(DeltaC_12);
colorbar; colormap(gca,'RdYlGn');
set(gca,'XTick',1:4,'XTickLabel',cds,'XTickLabelRotation',30,...
        'YTick',1:3,'YTickLabel',plantas);
title('Variación S2−S1 (verde=baja, rojo=sube)');
for r=1:3; for c=1:4
    text(c,r,sprintf('%+d',DeltaC_12(r,c)),'HorizontalAlignment','center','FontWeight','bold');
end; end

% 3. Escenarios de ajuste de tarifa
subplot(2,3,3);
pct = [-10 0 5 15 25];
totales = arrayfun(@(p) sum(sum((1+p/100)*C1)), pct);
bar(pct, totales, 'FaceColor', [0 0.47 0.84]);
xlabel('Variación tarifaria (%)');
ylabel('Costo total del sistema (USD)');
title('Sensibilidad: ajuste tarifario');
grid on;
xticks(pct);
xticklabels(arrayfun(@(p)sprintf('%+d%%',p), pct, 'UniformOutput',false));

% 4. Costo total por planta (resultado TV)
subplot(2,3,4);
bar(costo_por_planta, 'FaceColor', [0 0.51 0.31]);
set(gca,'XTickLabel',plantas);
ylabel('Costo total semanal (USD)');
title('Costo total por planta (T \times V)');
grid on;
for k=1:3
    text(k, costo_por_planta(k)+200, sprintf('$%.0f',costo_por_planta(k)), ...
        'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
end

% 5. Comparación sin/con urgencia
subplot(2,3,5);
x = 1:numel(C1);
bar(x, [C1(:), C_urgente(:)]);
legend({'Costo normal','Costo × urgencia'},'Location','best');
xlabel('Ruta (índice lineal)');
ylabel('USD/ton');
title('Efecto del factor de urgencia (Hadamard)');
grid on;

% 6. Costos por planta: decisión S1 vs S2
subplot(2,3,6);
bar_planta = [costo_C1, costo_C2];
bar(bar_planta);
set(gca,'XTickLabel',plantas);
legend({'Tarifas S1','Tarifas S2'},'Location','best');
ylabel('Costo total (USD, dado Vol\_CD)');
title('Decisión de planta: S1 vs S2');
grid on;
[~,min1]=min(costo_C1); [~,min2]=min(costo_C2);
text(min1-0.15, costo_C1(min1)*0.95,'★','FontSize',16,'Color',[0 0.47 0],'FontWeight','bold');
text(min2+0.05, costo_C2(min2)*0.95,'★','FontSize',16,'Color',[0.8 0.2 0],'FontWeight','bold');

sgtitle('MATEMÁTICAS 2 — Clase 2: Operaciones Matriciales', ...
        'FontSize',13,'FontWeight','bold');

fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 9: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 2)\n');
fprintf('==========================================\n\n');
fprintf('1. ¿Cuál es el elemento (2,3) de C_prom2?\n');
fprintf('   (costo promedio Salto → Tacuarembó en 2 semanas)\n');
fprintf('   Respuesta: _______\n\n');
fprintf('2. ¿En qué ruta bajó más el costo de S1 a S2?\n');
fprintf('   Usa: [val, idx] = min(DeltaC_12(:))\n');
fprintf('   Respuesta: _______\n\n');
fprintf('3. Calcula 1.08 * 0.95 (efecto neto de costos +8%% y volumen -5%%).\n');
fprintf('   ¿Sube o baja el costo total? ¿En qué porcentaje?\n');
fprintf('   Respuesta: _______\n\n');
fprintf('4. ¿Qué diferencia hay entre C1 * C2 y C1 .* C2?\n');
fprintf('   ¿Cuál de las dos está definida en este caso? ¿Por qué?\n');
fprintf('   Respuesta: _______\n\n');
fprintf('5. Usando costo_por_planta, ¿cuánto ahorra elegir\n');
fprintf('   la planta más eficiente vs la menos eficiente?\n');
fprintf('   Respuesta: $%.0f de diferencia\n\n', max(costo_por_planta)-min(costo_por_planta));
fprintf('==========================================\n');
fprintf('Fin del script clase2_datos.m\n');
fprintf('==========================================\n');

%% ── Función auxiliar ────────────────────────────────────────
function s = ynStr(val)
    if val; s = 'SÍ ✓'; else; s = 'NO ✗'; end
end
