%% ============================================================
%%  MATEMÁTICAS 2 — CLASE 1
%%  Script MATLAB: Datos y ejercicios para procesar
%%  Archivo: clase1_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar sección a sección usando Ctrl+Enter (Run Section)
%%  o ejecutar el script completo con F5.
%%
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%%  No se requieren toolboxes adicionales.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMÁTICAS 2 — Clase 1\n');
fprintf(' Matrices: estructuras y tipos\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: DATASET — RED LOGÍSTICA URUGUAY
%% ============================================================
%
% CONTEXTO:
%   3 plantas de producción (filas):
%     1 = Montevideo,  2 = Salto,  3 = Rivera
%   4 centros de distribución (columnas):
%     1 = Maldonado,  2 = Paysandú,  3 = Tacuarembó,  4 = Colonia
%
% Costos de envío en USD por tonelada (promedio anual)
% Fuente: dato de caso ficticio para uso académico

fprintf('--- BLOQUE 1: Red Logística Uruguay ---\n');

% Nombres para facilitar interpretación
plantas = {'Montevideo', 'Salto', 'Rivera'};
centros = {'Maldonado', 'Paysandú', 'Tacuarembó', 'Colonia'};

% Matriz de costos de envío (USD/ton)
C_costo = [12  35  48   8;
           40  15  22  38;
           52  28  10  60];

% Matriz de tiempos de entrega (horas)
C_tiempo = [2.5   6.0   9.0   1.5;
            7.0   2.0   4.5   7.5;
           10.0   5.5   2.0  12.0];

% Matriz de capacidad máxima de envío (ton/semana)
C_cap = [500  300    0  800;
         200  600  400    0;
           0  350  700  150];

fprintf('\n== Matriz de costos (USD/ton) ==\n');
disp(C_costo);
fprintf('Dimensión: %d x %d\n\n', size(C_costo));

fprintf('== Matriz de tiempos (horas) ==\n');
disp(C_tiempo);

fprintf('== Matriz de capacidades (ton/semana) ==\n');
disp(C_cap);
fprintf('Celdas con capacidad cero (sin ruta): %d\n\n', sum(C_cap(:)==0));

%% ============================================================
%% BLOQUE 2: DATASET — INVENTARIOS SEMANALES POR ALMACÉN
%% ============================================================
%
% 3 almacenes (filas): 1=Norte, 2=Centro, 3=Sur
% 5 productos (columnas): A, B, C, D, E
% Unidades: pallets

fprintf('--- BLOQUE 2: Inventarios semanales ---\n');

productos = {'Prod.A', 'Prod.B', 'Prod.C', 'Prod.D', 'Prod.E'};
almacenes = {'Norte', 'Centro', 'Sur'};

I_inventario = [120   0   45   0  200;
                  0  85    0  310    0;
                 60   0  175    0   90];

fprintf('\n== Inventarios (pallets) ==\n');
fprintf('           %-8s %-8s %-8s %-8s %-8s\n', productos{:});
for k = 1:3
    fprintf('%-10s', almacenes{k});
    fprintf('%-8d ', I_inventario(k,:));
    fprintf('\n');
end

fprintf('\nTotal pallets en sistema: %d\n', sum(I_inventario(:)));
fprintf('Posiciones vacías (sin stock): %d de %d\n', ...
        sum(I_inventario(:)==0), numel(I_inventario));
fprintf('Densidad de inventario: %.1f%%\n\n', ...
        nnz(I_inventario)/numel(I_inventario)*100);

%% ============================================================
%% BLOQUE 3: DATASET — RED DE ADYACENCIA (5 NODOS)
%% ============================================================
%
% Red de distribución simplificada:
% Nodos:  1=Depósito Central, 2=Hub Norte, 3=Hub Sur,
%         4=Tienda A, 5=Tienda B
% Conexión (1) o sin conexión (0) — red no dirigida (simétrica)

fprintf('--- BLOQUE 3: Red de adyacencia ---\n');

nodos = {'Deposito', 'Hub Norte', 'Hub Sur', 'Tienda A', 'Tienda B'};

A_red = [0 1 1 0 0;
         1 0 0 1 1;
         1 0 0 1 0;
         0 1 1 0 1;
         0 1 0 1 0];

fprintf('\n== Matriz de adyacencia ==\n');
disp(A_red);

% Verificaciones
fprintf('¿Simétrica? %s\n', ynStr(isequal(A_red, A_red')));
fprintf('Número de conexiones (arcos): %d\n', nnz(A_red)/2);
fprintf('Densidad de la red: %.1f%%\n', nnz(A_red)/numel(A_red)*100);

% Grado de cada nodo (número de conexiones)
fprintf('\nGrado de cada nodo (número de conexiones directas):\n');
grados = sum(A_red, 2);
for k = 1:5
    fprintf('  %s: %d conexiones\n', nodos{k}, grados(k));
end
[~, nodo_critico] = max(grados);
fprintf('\nNodo más conectado (crítico): %s\n\n', nodos{nodo_critico});

%% ============================================================
%% BLOQUE 4: MATRICES ESPECIALES — GENERACIÓN Y PROPIEDADES
%% ============================================================

fprintf('--- BLOQUE 4: Matrices especiales ---\n\n');

% Identidad
I3 = eye(3);
fprintf('Identidad 3x3:\n'); disp(I3);

% Diagonal con costos fijos por almacén (USD/día)
costos_fijos = [500; 750; 300];
D_costos = diag(costos_fijos);
fprintf('Diagonal (costos fijos USD/día):\n'); disp(D_costos);
fprintf('Traza = costo fijo total: $%d/día\n\n', trace(D_costos));

% Triangular superior (ejemplo: modelo de flujo en etapas)
U_flujo = triu(magic(4));
fprintf('Triangular superior (ejemplo):\n'); disp(U_flujo);

% Triangular inferior
L_flujo = tril(magic(4));
fprintf('Triangular inferior (ejemplo):\n'); disp(L_flujo);

% Sparse
fprintf('Conversión a sparse (C_cap):\n');
S_cap = sparse(C_cap);
fprintf('Elementos no nulos: %d / %d\n', nnz(S_cap), numel(C_cap));
fprintf('Uso de memoria relativo: %.1f%% de la versión densa\n\n', ...
        nnz(S_cap)/numel(C_cap)*100);

%% ============================================================
%% BLOQUE 5: ANÁLISIS DE LA MATRIZ DE COSTOS
%% ============================================================

fprintf('--- BLOQUE 5: Análisis matriz de costos ---\n\n');

% Estadísticas generales
fprintf('Costo mínimo: $%d/ton\n', min(C_costo(:)));
fprintf('Costo máximo: $%d/ton\n', max(C_costo(:)));
fprintf('Costo promedio: $%.1f/ton\n', mean(C_costo(:)));
fprintf('Desviación estándar: $%.1f/ton\n\n', std(C_costo(:)));

% Ruta más económica
[val_min, idx_min] = min(C_costo(:));
[fi_min, col_min] = ind2sub(size(C_costo), idx_min);
fprintf('>> Ruta MÁS ECONÓMICA: %s → %s ($%d/ton)\n', ...
        plantas{fi_min}, centros{col_min}, val_min);

% Ruta más costosa
[val_max, idx_max] = max(C_costo(:));
[fi_max, col_max] = ind2sub(size(C_costo), idx_max);
fprintf('>> Ruta MÁS COSTOSA:   %s → %s ($%d/ton)\n\n', ...
        plantas{fi_max}, centros{col_max}, val_max);

% Costo mínimo por origen (planta más eficiente para cada destino)
fprintf('Costo mínimo por destino (mejor planta para cada CD):\n');
[min_col, mejor_planta] = min(C_costo, [], 1);
for k = 1:4
    fprintf('  %s ← mejor opción: %s ($%d/ton)\n', ...
            centros{k}, plantas{mejor_planta(k)}, min_col(k));
end

% Transpuesta
fprintf('\n== Transpuesta C_costo (CD x Planta) ==\n');
disp(C_costo');

%% ============================================================
%% BLOQUE 6: VISUALIZACIÓN
%% ============================================================

fprintf('\n--- BLOQUE 6: Visualizaciones ---\n');

figure('Name', 'Clase 1 — Visualizaciones', ...
       'NumberTitle', 'off', 'Position', [100 100 1200 800]);

% Subplot 1: Heatmap de costos
subplot(2,3,1);
imagesc(C_costo);
colorbar;
colormap(gca, 'hot');
set(gca, 'XTick', 1:4, 'XTickLabel', centros, ...
         'YTick', 1:3, 'YTickLabel', plantas);
title('Costos de envío (USD/ton)');
xlabel('Centro de distribución');
ylabel('Planta de origen');
% Añadir valores en celdas
for r = 1:3
    for c = 1:4
        text(c, r, num2str(C_costo(r,c)), ...
            'HorizontalAlignment','center', ...
            'FontWeight','bold', 'Color','white');
    end
end

% Subplot 2: Heatmap de tiempos
subplot(2,3,2);
imagesc(C_tiempo);
colorbar;
colormap(gca, 'cool');
set(gca, 'XTick', 1:4, 'XTickLabel', centros, ...
         'YTick', 1:3, 'YTickLabel', plantas);
title('Tiempos de entrega (horas)');
xlabel('Centro de distribución');
ylabel('Planta de origen');
for r = 1:3
    for c = 1:4
        text(c, r, num2str(C_tiempo(r,c)), ...
            'HorizontalAlignment','center', ...
            'FontWeight','bold', 'Color','black');
    end
end

% Subplot 3: Patrón de dispersión (inventarios)
subplot(2,3,3);
spy(sparse(I_inventario));
title(sprintf('Patrón disperso - Inventarios\nDensidad: %.0f%%', ...
    nnz(I_inventario)/numel(I_inventario)*100));
xlabel('Productos'); ylabel('Almacenes');
set(gca, 'XTick', 1:5, 'XTickLabel', productos, ...
         'YTick', 1:3, 'YTickLabel', almacenes);

% Subplot 4: Patrón de dispersión (capacidades)
subplot(2,3,4);
spy(sparse(C_cap));
title(sprintf('Patrón disperso - Capacidades\nDensidad: %.0f%%', ...
    nnz(C_cap)/numel(C_cap)*100));
xlabel('Centros de distribución'); ylabel('Plantas');

% Subplot 5: Red de adyacencia
subplot(2,3,5);
G = graph(A_red, nodos);
p = plot(G, 'Layout', 'force');
p.NodeColor = [0, 0.47, 0.84];
p.EdgeColor = [0.6 0.6 0.6];
p.NodeFontSize = 9;
p.MarkerSize = 10;
title('Red logística (grafo)');
axis off;

% Subplot 6: Grados de los nodos
subplot(2,3,6);
bar(grados, 'FaceColor', [0, 0.51, 0.31]);
set(gca, 'XTickLabel', nodos, 'XTickLabelRotation', 30);
ylabel('Número de conexiones');
title('Grado de cada nodo de la red');
grid on;

sgtitle('MATEMÁTICAS 2 — Clase 1: Análisis matricial de red logística', ...
        'FontSize', 13, 'FontWeight', 'bold');

fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 7: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 1)\n');
fprintf('==========================================\n\n');
fprintf('1. ¿Cuál es la dimensión de C_tiempo^T?\n');
fprintf('   Respuesta: _______\n\n');
fprintf('2. ¿En qué posición (i,j) está el máximo de C_costo?\n');
fprintf('   Respuesta: _______\n\n');
fprintf('3. ¿Cuántos pallets tiene en total el Almacén Norte?\n');
fprintf('   Respuesta: sum(I_inventario(1,:)) = %d\n\n', sum(I_inventario(1,:)));
fprintf('   ** Verifica corriendo: sum(I_inventario(1,:)) **\n\n');
fprintf('4. ¿Qué nodo de la red tiene más conexiones (mayor grado)?\n');
fprintf('   Respuesta: _______\n\n');
fprintf('5. Si duplicaras todos los costos de la matriz C_costo,\n');
fprintf('   ¿qué operación matemática realizarías?\n');
fprintf('   Pruébalo en MATLAB: _______\n\n');
fprintf('==========================================\n');
fprintf('Fin del script clase1_datos.m\n');
fprintf('==========================================\n');

%% ── Función auxiliar ────────────────────────────────────
function s = ynStr(val)
    if val; s = 'SÍ'; else; s = 'NO'; end
end
