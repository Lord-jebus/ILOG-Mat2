%% ============================================================
%%  MATEMATICAS 2 --- CLASE 4
%%  Script MATLAB: Sistemas Ax=b y balance de inventarios
%%  Archivo: clase4_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar seccion a seccion con Ctrl+Enter
%%  o el script completo con F5.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 4\n');
fprintf(' Sistemas Ax=b y balance de inventario\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: SISTEMA 2x2 --- BALANCE DE DOS CDs
%% ============================================================
%
% Dos plantas (P1: Montevideo, P2: Salto)
% Dos CDs (CD Norte, CD Sur)
% a_ij = fraccion del despacho de la planta j que llega al CD i
% x_j  = toneladas totales a despachar desde planta j
% b_i  = demanda del CD i (ton)

fprintf('--- BLOQUE 1: Sistema 2x2 ---\n\n');

A2 = [0.6  0.4;
      0.4  0.6];
b2 = [300; 240];

fprintf('Matriz A (fracciones de despacho):\n'); disp(A2);
fprintf('Vector b (demanda por CD, ton):   '); disp(b2');

%% Resolucion con backslash
x2 = A2 \ b2;
fprintf('Solucion x = A\\b:\n');
fprintf('  x1 (Montevideo): %.4f ton\n', x2(1));
fprintf('  x2 (Salto):      %.4f ton\n', x2(2));

%% Verificacion
residuo2 = norm(A2*x2 - b2);
fprintf('Residuo ||A*x - b|| = %.2e\n\n', residuo2);

%% Comprobacion fila a fila
fprintf('Verificacion por CD:\n');
CDs2 = {'CD Norte','CD Sur'};
for i = 1:2
    llegada = A2(i,:) * x2;
    fprintf('  %s: recibe %.2f ton (demanda: %.0f)\n', CDs2{i}, llegada, b2(i));
end
fprintf('\n');

%% ============================================================
%% BLOQUE 2: SISTEMA 3x3 --- BALANCE INVENTARIO TRES CDs
%% ============================================================

fprintf('--- BLOQUE 2: Sistema 3x3 ---\n\n');

A3 = [1 2 1;
      2 1 1;
      1 1 3];
b3 = [9; 8; 9];

fprintf('Sistema de balance 3x3:\n');
fprintf('A =\n'); disp(A3);
fprintf('b = '); disp(b3');

x3 = A3 \ b3;
fprintf('Solucion exacta (fracciones):\n');
fprintf('  x1 = %.6f = %d/7\n', x3(1), round(x3(1)*7));
fprintf('  x2 = %.6f = %d/7\n', x3(2), round(x3(2)*7));
fprintf('  x3 = %.6f = %d/7\n', x3(3), round(x3(3)*7));
fprintf('Residuo: %.2e\n\n', norm(A3*x3 - b3));

%% Mostrar la eliminacion paso a paso
fprintf('=== Eliminacion manual paso a paso ===\n');
Aug = [A3, b3];
fprintf('Matriz aumentada inicial:\n'); disp(Aug);

%% Paso 1: eliminar columna 1 en filas 2 y 3
Aug(2,:) = Aug(2,:) - (Aug(2,1)/Aug(1,1))*Aug(1,:);
Aug(3,:) = Aug(3,:) - (Aug(3,1)/Aug(1,1))*Aug(1,:);
fprintf('Despues de eliminar col 1 en F2 y F3:\n'); disp(Aug);

%% Paso 2: eliminar columna 2 en fila 3
Aug(3,:) = Aug(3,:) - (Aug(3,2)/Aug(2,2))*Aug(2,:);
fprintf('Despues de eliminar col 2 en F3:\n'); disp(Aug);
fprintf('(Forma triangular superior: lista para sustitucion hacia atras)\n\n');

%% ============================================================
%% BLOQUE 3: CASO LOGISTICO COMPLETO --- RED FRACCIONARIA
%% ============================================================
%
% 3 plantas (P1 Mvd, P2 Salto, P3 Rivera)
% 3 CDs (Norte, Centro, Sur)
% A(i,j) = fraccion del despacho de planta j que llega a CD i

fprintf('--- BLOQUE 3: Caso logistico completo ---\n\n');

plantas = {'Montevideo','Salto','Rivera'};
CDs3    = {'CD Norte','CD Centro','CD Sur'};

A_log = [0.5  0.3  0.2;
         0.3  0.5  0.1;
         0.2  0.2  0.7];

b_log = [500; 400; 350];   % demanda (ton)

fprintf('Red de distribucion A (fracciones):\n');
fprintf('         %-12s %-12s %-12s\n', plantas{:});
for i=1:3
    fprintf('%-10s', CDs3{i});
    fprintf('%-12.1f ', A_log(i,:));
    fprintf('\n');
end

fprintf('\nDemanda por CD (ton):\n');
for i=1:3, fprintf('  %s: %.0f ton\n', CDs3{i}, b_log(i)); end

%% Resolver sistema
x_log = A_log \ b_log;
fprintf('\nPlan de despacho optimo (A*x = b):\n');
cap_max = [500; 600; 450];   % capacidad maxima por planta (ton)
for k=1:3
    estado = '';
    if x_log(k) > cap_max(k), estado = ' *** SUPERA CAPACIDAD ***'; end
    fprintf('  %s: %.1f ton (cap. max: %.0f)%s\n', ...
            plantas{k}, x_log(k), cap_max(k), estado);
end
fprintf('Residuo: %.2e\n\n', norm(A_log*x_log - b_log));

%% Analisis de viabilidad
fprintf('=== Analisis de viabilidad ===\n');
excedente = max(0, x_log - cap_max);
for k=1:3
    if excedente(k) > 0
        fprintf('  PROBLEMA: %s supera capacidad en %.1f ton\n', plantas{k}, excedente(k));
    else
        fprintf('  OK:       %s dentro de capacidad (%.1f ton libres)\n', ...
                plantas{k}, cap_max(k)-x_log(k));
    end
end
fprintf('\n');

%% Simulacion: reduccion de demanda
fprintf('=== Simulacion: demanda reducida 20%% ===\n');
x_80 = A_log \ (0.8*b_log);
fprintf('Plan con demanda al 80%%:\n');
for k=1:3
    estado = '';
    if x_80(k) > cap_max(k), estado = ' *** SUPERA ***'; end
    fprintf('  %s: %.1f ton%s\n', plantas{k}, x_80(k), estado);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 4: CLASIFICACION DE SISTEMAS
%% ============================================================

fprintf('--- BLOQUE 4: Clasificacion de sistemas ---\n\n');

sistemas = {
    [1 2; 3 6],  [9; 27],  'Infinitas soluciones (rang=rang_aug<n)';
    [1 2; 3 6],  [9; 28],  'Incompatible (rang<rang_aug)';
    [1 2; 3 5],  [9; 14],  'Solucion unica (rang=rang_aug=n)';
    [1 2 1; 2 4 2; 0 0 1], [3;6;2], 'Infinitas (fila 2 = 2*fila 1)';
};

fprintf('%-45s | rang(A) | rang([A|b]) | Residuo   | Tipo\n', 'Sistema');
fprintf('%s\n', repmat('-',1,100));

for k = 1:size(sistemas,1)
    Ak  = sistemas{k,1};
    bk  = sistemas{k,2};
    desc= sistemas{k,3};
    rA  = rank(Ak);
    rAb = rank([Ak bk]);
    xk  = Ak \ bk;
    res = norm(Ak*xk - bk);
    fprintf('Caso %-2d: %-37s | %7d | %11d | %9.2e | %s\n', ...
            k, '', rA, rAb, res, desc);
end
fprintf('\n');

%% Regla de clasificacion
fprintf('Regla de clasificacion:\n');
fprintf('  rang(A)=rang([A|b])=n  => Solucion unica\n');
fprintf('  rang(A)=rang([A|b])<n  => Infinitas soluciones\n');
fprintf('  rang(A)<rang([A|b])    => Incompatible (sin solucion)\n\n');

%% ============================================================
%% BLOQUE 5: MULTIPLE ESCENARIOS DE DEMANDA
%% ============================================================

fprintf('--- BLOQUE 5: Multiples escenarios ---\n\n');

A_esc = [0.7  0.3;
         0.3  0.7];
%% Tres escenarios: columnas de B_esc
B_esc = [400  500  350;
         300  400  280];

escenarios = {'Base','Alto','Bajo'};
cap_P1 = 600; cap_P2 = 400;

%% Resolver todos los sistemas a la vez: A \ B_esc
X_esc = A_esc \ B_esc;

fprintf('%-8s | P1 (ton) | P2 (ton) | Cap.P1 OK? | Cap.P2 OK?\n', 'Escenario');
fprintf('%s\n', repmat('-',1,60));
for k=1:3
    ok1 = yesNo(X_esc(1,k) <= cap_P1);
    ok2 = yesNo(X_esc(2,k) <= cap_P2);
    fprintf('%-8s | %8.1f | %8.1f | %-10s | %s\n', ...
        escenarios{k}, X_esc(1,k), X_esc(2,k), ok1, ok2);
end
fprintf('\n');

%% Analisis de sensibilidad: delta en demanda
fprintf('=== Sensibilidad: cambio de +10/-5 ton en demanda ===\n');
b0  = [300; 240];
x0  = A_esc \ b0;
dlt = [10; -5];
x1  = A_esc \ (b0 + dlt);
fprintf('  dx_despacho = x_nuevo - x_base:\n');
fprintf('    P1: %+.4f ton por unidad de perturbacion\n', x1(1)-x0(1));
fprintf('    P2: %+.4f ton por unidad de perturbacion\n\n', x1(2)-x0(2));

%% ============================================================
%% BLOQUE 6: COMPARACION A\b vs inv(A)*b
%% ============================================================

fprintf('--- BLOQUE 6: A\\b vs inv(A)*b ---\n\n');

n_vals  = [10 50 100 200 500];
t_back  = zeros(size(n_vals));
t_inv   = zeros(size(n_vals));

fprintf('%-6s | %-16s | %-16s\n', 'Tamanio', 'Tiempo A\\b (s)', 'Tiempo inv(A)*b (s)');
fprintf('%s\n', repmat('-',1,42));

for k = 1:length(n_vals)
    n  = n_vals(k);
    Ak = rand(n,n)+n*eye(n);   % matriz bien condicionada
    bk = rand(n,1);

    t1 = tic;
    for rep=1:20, Ak\bk; end
    t_back(k) = toc(t1)/20;

    t2 = tic;
    for rep=1:20, inv(Ak)*bk; end
    t_inv(k) = toc(t2)/20;

    fprintf('%-6d | %-16.6f | %-16.6f\n', n, t_back(k), t_inv(k));
end
fprintf('\n(A\\b es sistematicamente mas rapido y numericamente estable)\n\n');

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 4 --- Sistemas Ax=b','NumberTitle','off',...
       'Position',[50 50 1300 800]);

%% Subplot 1: Plan de despacho 2x2
subplot(2,3,1);
bar([x2(1) x2(2)],'FaceColor',[0 0.32 0.58]);
set(gca,'XTickLabel',{'P1 Montevideo','P2 Salto'});
ylabel('Toneladas a despachar');
title('Plan de despacho sistema 2x2');
yline(0,'k--');
grid on;
for k=1:2
    text(k, x2(k)+8, sprintf('%.0f t', x2(k)), ...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 2: Verificacion por CD (sistema 2x2)
subplot(2,3,2);
llegada_2x2 = A2 * x2;
bar_data2 = [llegada_2x2, b2];
bar(bar_data2);
set(gca,'XTickLabel',CDs2,'XTickLabelRotation',10);
legend({'Recibido (Ax)','Demanda (b)'},'Location','best');
title('Verificacion: Ax vs b (sistema 2x2)');
ylabel('Toneladas');
grid on;

%% Subplot 3: Plan de despacho logistico 3x3
subplot(2,3,3);
colores = {[0 0.32 0.58],[0 0.51 0.31],[0.86 0.37 0.07]};
h = bar(x_log);
set(gca,'XTickLabel',plantas,'XTickLabelRotation',15);
hold on;
for k=1:3
    yline(cap_max(k),'--','Color',colores{k},'LineWidth',1.5);
end
ylabel('Toneladas a despachar');
title('Plan 3x3 con capacidades maximas');
legend({'Despacho requerido','Cap P1','Cap P2','Cap P3'},'Location','best');
grid on;

%% Subplot 4: Comparacion multiples escenarios
subplot(2,3,4);
bar_esc = X_esc';
b_h = bar(1:3, bar_esc);
b_h(1).FaceColor = [0 0.32 0.58];
b_h(2).FaceColor = [0 0.51 0.31];
set(gca,'XTickLabel',escenarios);
ylabel('Toneladas a despachar');
title('Multiples escenarios de demanda');
legend({'P1 (Montevideo)','P2 (Salto)'},'Location','best');
yline(cap_P1,'b--','LineWidth',1.5,'HandleVisibility','off');
yline(cap_P2,'g--','LineWidth',1.5,'HandleVisibility','off');
grid on;

%% Subplot 5: Eliminacion --- evolucion de la matriz aumentada
subplot(2,3,5);
Aug_ini  = [A3, b3];
Aug_paso1 = Aug_ini;
Aug_paso1(2,:) = Aug_paso1(2,:)-(Aug_paso1(2,1)/Aug_paso1(1,1))*Aug_paso1(1,:);
Aug_paso1(3,:) = Aug_paso1(3,:)-(Aug_paso1(3,1)/Aug_paso1(1,1))*Aug_paso1(1,:);
Aug_paso2 = Aug_paso1;
Aug_paso2(3,:) = Aug_paso2(3,:)-(Aug_paso2(3,2)/Aug_paso2(2,2))*Aug_paso2(2,:);

imagesc([Aug_ini(:,1:3); NaN(1,3); Aug_paso2(:,1:3)]);
colormap(gca,'cool'); colorbar;
title('Eliminacion: antes (filas 1-3) vs despues (filas 5-7)');
yticks([1 2 3 5 6 7]);
yticklabels({'F1','F2','F3','','F1''','F2''','F3'''});
xlabel('Columna'); grid on;

%% Subplot 6: Tiempo A\b vs inv(A)*b
subplot(2,3,6);
semilogy(n_vals, t_back*1000,'b-o','LineWidth',2,'DisplayName','A\b');
hold on;
semilogy(n_vals, t_inv*1000,'r-s','LineWidth',2,'DisplayName','inv(A)*b');
xlabel('Tamano del sistema n'); ylabel('Tiempo (ms, escala log)');
title('Eficiencia: A\b vs inv(A)*b');
legend('Location','best'); grid on;

sgtitle('MATEMATICAS 2 --- Clase 4: Sistemas A\mathbf{x}=\mathbf{b}', ...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 4)\n');
fprintf('==========================================\n\n');
fprintf('1. En el sistema 2x2, ¿cuanto despacha P2?\n');
fprintf('   Respuesta: x2 = %.4f ton\n\n', x2(2));

fprintf('2. ¿Que residuo obtienes al resolver el sistema 3x3?\n');
fprintf('   Respuesta: %.2e (debe ser practicamente cero)\n\n', ...
        norm(A3*x3-b3));

fprintf('3. Si la demanda del caso logistico baja al 70%%,\n');
fprintf('   ¿todas las plantas estan dentro de su capacidad?\n');
x_70 = A_log \ (0.7*b_log);
todo_ok = all(x_70 <= cap_max);
fprintf('   Respuesta: %s\n', yesNo(todo_ok));
if ~todo_ok
    idx = find(x_70 > cap_max);
    fprintf('   Plantas que aun superan: %s\n', strjoin(plantas(idx),', '));
end
fprintf('\n');

fprintf('4. Clasifica el siguiente sistema sin resolverlo:\n');
fprintf('   A=[1 3; 2 6], b=[4; 8]\n');
Aq=[1 3;2 6]; bq=[4;8];
fprintf('   rang(A)=%d, rang([A|b])=%d => ', rank(Aq), rank([Aq bq]));
if rank(Aq)==rank([Aq bq]) && rank(Aq)<size(Aq,2)
    fprintf('Infinitas soluciones\n\n');
elseif rank(Aq)<rank([Aq bq])
    fprintf('Incompatible\n\n');
else
    fprintf('Solucion unica\n\n');
end

fprintf('5. Resuelve A_esc * x = b_esc3 (escenario bajo)\n');
fprintf('   y verifica que P2 no supere su capacidad maxima.\n');
x_bajo = A_esc \ B_esc(:,3);
fprintf('   x_bajo = [%.1f; %.1f] ton\n', x_bajo(1), x_bajo(2));
fprintf('   P2 capacidad OK: %s\n\n', yesNo(x_bajo(2)<=cap_P2));
fprintf('==========================================\n');
fprintf('Fin del script clase4_datos.m\n');
fprintf('==========================================\n');

%% --- Funcion auxiliar ---------------------------------------
function s = yesNo(cond)
    if cond; s = 'SI'; else; s = 'NO'; end
end
