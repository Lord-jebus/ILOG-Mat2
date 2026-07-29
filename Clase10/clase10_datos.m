%% ============================================================
%%  MATEMATICAS 2 --- CLASE 10
%%  Script MATLAB: Ecuaciones Matriciales AX=B
%%  Distribucion Multi-Origen
%%  Archivo: clase10_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 10\n');
fprintf(' Ecuaciones Matriciales AX=B\n');
fprintf('==========================================\n\n');

%% ============================================================
%% DATOS DEL CASO LOGISTICO
%% ============================================================

%% Red de distribucion (misma para todas las fabricas)
%% A(i,j) = fraccion del despacho de planta j que llega a CD i
A = [0.5  0.3  0.2;
     0.3  0.5  0.2;
     0.2  0.2  0.6];

%% Demandas de 3 fabricas clientes (columnas de B)
B = [300  450  200;
     200  100  350;
     150  250  100];

%% Capacidades de las plantas (ton/semana)
cap = [800; 600; 400];

%% Costos de despacho por planta (USD/ton)
c_tarifa = [8; 12; 15];

%% Nombres
plantas   = {'P1 Mvd','P2 Salto','P3 Rivera'};
CDs       = {'CD Norte','CD Sur','CD Este'};
fabricas  = {'Fabrica F1','Fabrica F2','Fabrica F3'};

%% ============================================================
%% BLOQUE 1: VERIFICACION Y RESOLUCION BASICA
%% ============================================================

fprintf('--- BLOQUE 1: Verificacion y resolucion ---\n\n');

%% Dimensiones
fprintf('Dimensiones del problema:\n');
fprintf('  A: %dx%d (CDs x Plantas)\n', size(A));
fprintf('  B: %dx%d (CDs x Fabricas)\n', size(B));
fprintf('  X (solucion esperada): %dx%d (Plantas x Fabricas)\n\n', size(A,2), size(B,2));

%% Verificar compatibilidad
rA  = rank(A);
rAB = rank([A B]);
fprintf('rang(A) = %d\n', rA);
fprintf('rang([A|B]) = %d\n', rAB);
fprintf('Sistema compatible: %s\n\n', yesNo(rA == rAB));

%% Resolver AX = B
X = A \ B;

fprintf('Solucion X = A\\B (Plantas x Fabricas):\n');
fprintf('%-10s | %-12s | %-12s | %-12s\n','Planta',fabricas{:});
fprintf('%s\n', repmat('-',1,52));
for p = 1:3
    fprintf('%-10s | %12.4f | %12.4f | %12.4f\n', plantas{p}, X(p,:));
end

%% Verificacion con norma de Frobenius
res_F = norm(A*X - B, 'fro');
fprintf('\nResiduo ||AX-B||_F = %.2e\n\n', res_F);

%% Equivalencia: verificar que coincide con sistemas individuales
fprintf('Equivalencia con sistemas individuales:\n');
for f = 1:3
    xf = A \ B(:,f);
    dif = norm(xf - X(:,f));
    fprintf('  Fabrica %d: ||x_j - X(:,j)|| = %.2e\n', f, dif);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 2: ANALISIS POR FABRICA
%% ============================================================

fprintf('--- BLOQUE 2: Analisis por fabrica ---\n\n');

fprintf('%-14s | %-8s | %-8s | %-8s | %-10s | %-10s\n',...
    'Fabrica','P1 (t)','P2 (t)','P3 (t)','Total (t)','Costo ($)');
fprintf('%s\n', repmat('-',1,72));

for f = 1:3
    xf    = X(:,f);
    total = sum(xf);
    costo = c_tarifa' * xf;
    fprintf('%-14s | %8.1f | %8.1f | %8.1f | %10.1f | %10.0f\n',...
        fabricas{f}, xf(1), xf(2), xf(3), total, costo);
end
fprintf('\n');

%% Viabilidad por planta y fabrica
fprintf('Analisis de viabilidad (X <= cap):\n');
for f = 1:3
    xf = X(:,f);
    ok = all(xf <= cap);
    if ~ok
        idx = find(xf > cap);
        fprintf('  %s: NO VIABLE - %s supera capacidad\n',...
            fabricas{f}, plantas{idx(1)});
    else
        fprintf('  %s: VIABLE (holgura min: %.0f ton en %s)\n',...
            fabricas{f}, min(cap-xf), plantas{find(cap-xf==min(cap-xf))});
    end
end
fprintf('\n');

%% Fabricas negativas (fisicamente inviables)
fprintf('Componentes negativas en X:\n');
hay_neg = false;
for f = 1:3
    neg = X(:,f) < -1e-6;
    if any(neg)
        hay_neg = true;
        fprintf('  %s: %s tiene valor negativo (%.4f ton)\n',...
            fabricas{f}, plantas{find(neg,1)}, X(find(neg,1),f));
    end
end
if ~hay_neg, fprintf('  Ninguna (todos los planes son fisicamente viables)\n'); end
fprintf('\n');

%% ============================================================
%% BLOQUE 3: MULTIPLES SEMANAS PARA UNA FABRICA
%% ============================================================

fprintf('--- BLOQUE 3: Multiples semanas (Fabrica F1) ---\n\n');

%% Demandas de F1 durante 4 semanas
B_F1 = [300  320  280  350;
        200  190  220  180;
        150  160  140  170];

semanas = {'Sem 1','Sem 2','Sem 3','Sem 4'};

fprintf('Demandas F1 por semana:\n');
fprintf('%-10s | %s | %s | %s | %s\n','CD',semanas{:});
fprintf('%s\n', repmat('-',1,52));
for i = 1:3
    fprintf('%-10s | %5.0f | %5.0f | %5.0f | %5.0f\n',...
        CDs{i}, B_F1(i,:));
end

%% Resolver todos los sistemas a la vez
X_F1 = A \ B_F1;
res_F1 = norm(A*X_F1 - B_F1,'fro');
fprintf('\nResiduo ||AX_F1 - B_F1||_F = %.2e\n\n', res_F1);

fprintf('Plan de despacho F1 por semana:\n');
fprintf('%-10s | %s | %s | %s | %s\n','Planta',semanas{:});
fprintf('%s\n', repmat('-',1,52));
for p = 1:3
    fprintf('%-10s | %5.1f | %5.1f | %5.1f | %5.1f\n',...
        plantas{p}, X_F1(p,:));
end

%% Costo semana a semana
costos_sem = c_tarifa' * X_F1;
fprintf('\nCosto F1 por semana (USD):\n');
for k = 1:4
    fprintf('  %s: $%.0f\n', semanas{k}, costos_sem(k));
end
fprintf('  Costo promedio: $%.0f\n\n', mean(costos_sem));

%% ============================================================
%% BLOQUE 4: RELACION CON LA INVERSA
%% ============================================================

fprintf('--- BLOQUE 4: AX=B y la inversa de A ---\n\n');

%% Calcular inversa con Gauss-Jordan
n = size(A,1);
[R_inv, ~] = rref([A, eye(n)]);
A_inv_rref = R_inv(:, n+1:end);

%% Comparar con inv(A)
A_inv_matlab = inv(A);
dif_inv = norm(A_inv_rref - A_inv_matlab, 'fro');
fprintf('Inversa via rref([A|I]):\n'); disp(A_inv_rref);
fprintf('Diferencia con inv(A): %.2e\n\n', dif_inv);

%% Verificar A*A^-1 = I
fprintf('Verificacion A * A^-1:\n'); disp(A * A_inv_matlab);

%% Resolver AX=B via inversa
X_via_inv = A_inv_matlab * B;
fprintf('X via inv(A)*B:\n'); disp(X_via_inv);
fprintf('Diferencia con A\\B: %.2e\n\n', norm(X_via_inv - X, 'fro'));

%% Analisis de sensibilidad: si demanda de F1 cambia en dB
dB = zeros(3,3); dB(:,1) = [10; 0; -5];
dX = A_inv_matlab * dB;
fprintf('Sensibilidad: si demanda F1 cambia en (10,0,-5) ton:\n');
fprintf('  Cambio en plan F1: [%.4f  %.4f  %.4f]\n', dX(:,1)');
fprintf('  Plan base F1:      [%.4f  %.4f  %.4f]\n', X(:,1)');
fprintf('  Plan nuevo F1:     [%.4f  %.4f  %.4f]\n', (X(:,1)+dX(:,1))');
fprintf('  Planta con mayor variacion: %s\n\n',...
    plantas{find(abs(dX(:,1))==max(abs(dX(:,1))))});

%% ============================================================
%% BLOQUE 5: SIMULACION DE RENEGOCIACION DE RED
%% ============================================================

fprintf('--- BLOQUE 5: Simulacion de cambio de red ---\n\n');

%% Fabrica mas cara
costos_fab = c_tarifa' * X;
[~, fab_cara] = max(costos_fab);
fprintf('Fabrica mas cara: %s ($%.0f/semana)\n\n', fabricas{fab_cara}, max(costos_fab));

%% Simular cambio: reducir fraccion de P2 (cara) hacia F3
fprintf('Simulacion: reducir a_{23} de %.2f a %.2f\n', A(2,3), A(2,3)-0.05);
A_new = A;
A_new(2,3) = A(2,3) - 0.05;  % reducir fraccion de P2 al CD 3
A_new(3,3) = A(3,3) + 0.05;  % compensar con P3

X_new = A_new \ B;
costos_new = c_tarifa' * X_new;

fprintf('\nComparacion de costos antes/despues:\n');
fprintf('%-14s | Costo base | Costo nuevo | Ahorro\n', 'Fabrica');
fprintf('%s\n', repmat('-',1,55));
for f = 1:3
    ahorro = costos_fab(f) - costos_new(f);
    fprintf('%-14s | %10.0f | %11.0f | %6.0f\n',...
        fabricas{f}, costos_fab(f), costos_new(f), ahorro);
end
fprintf('%s\n', repmat('-',1,55));
fprintf('%-14s | %10.0f | %11.0f | %6.0f\n',...
    'TOTAL', sum(costos_fab), sum(costos_new), sum(costos_fab)-sum(costos_new));
fprintf('\n');

%% Verificar viabilidad del nuevo plan
fprintf('Viabilidad del nuevo plan:\n');
for f = 1:3
    ok = all(X_new(:,f) <= cap) && all(X_new(:,f) >= -1e-6);
    fprintf('  %s: %s\n', fabricas{f}, yesNo(ok));
end
fprintf('\n');

%% ============================================================
%% BLOQUE 6: EFICIENCIA COMPUTACIONAL
%% ============================================================

fprintf('--- BLOQUE 6: Eficiencia A\\B vs inv(A)*B ---\n\n');

n_vals = [5, 20, 50, 100];
k_col  = 10;  % numero de columnas de B
fprintf('%-6s | %-12s | %-14s | ratio\n','n','A\\B (ms)','inv(A)*B (ms)');
fprintf('%s\n', repmat('-',1,45));

for n = n_vals
    Ak = rand(n) + n*eye(n);
    Bk = rand(n, k_col);
    t1 = timeit(@() Ak\Bk) * 1000;
    t2 = timeit(@() inv(Ak)*Bk) * 1000;
    fprintf('%-6d | %12.4f | %14.4f | %.1fx\n', n, t1, t2, t2/t1);
end
fprintf('\n(A\\B es mas rapido; inv(A)*B tiene mayor costo de factorizacion)\n\n');

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 10 --- AX=B: Distribucion Multi-Origen',...
       'NumberTitle','off','Position',[30 30 1350 800]);

%% Subplot 1: Plan de despacho por fabrica
subplot(2,3,1);
bar(X);
set(gca,'XTickLabel',plantas,'XTickLabelRotation',15);
ylabel('Toneladas a despachar');
title('Plan de despacho por fabrica (columnas de X)');
legend(fabricas,'Location','northeast');
hold on;
for p=1:3, yline(cap(p),'--','LineWidth',1); end
grid on;

%% Subplot 2: Costo por fabrica
subplot(2,3,2);
bar(costos_fab,'FaceColor','flat');
colors_f = {[0.2 0.5 0.8],[0.1 0.7 0.3],[0.8 0.3 0.1]};
h = bar(costos_fab);
h.CData = cell2mat(colors_f');
set(gca,'XTickLabel',{'F1','F2','F3'});
ylabel('Costo total (USD/semana)');
title('Costo por fabrica');
grid on;
for f=1:3
    text(f, costos_fab(f)+50, sprintf('$%.0f',costos_fab(f)),...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 3: Utilizacion de capacidad por planta y fabrica
subplot(2,3,3);
uso_pct = (X ./ cap) * 100;
imagesc(uso_pct');
colorbar; caxis([0 120]);
colormap(gca,'summer');
set(gca,'XTick',1:3,'XTickLabel',plantas,'XTickLabelRotation',15);
set(gca,'YTick',1:3,'YTickLabel',{'F1','F2','F3'});
title('Utilizacion de capacidad (%)');
xlabel('Planta'); ylabel('Fabrica');
for p=1:3; for f=1:3
    text(p,f,sprintf('%.0f%%',uso_pct(p,f)),...
        'HorizontalAlignment','center','FontWeight','bold','Color','white');
end; end

%% Subplot 4: Planes F1 por semana
subplot(2,3,4);
bar(X_F1');
set(gca,'XTickLabel',semanas);
ylabel('Toneladas');
title('Plan de F1 por semana (4 semanas)');
legend(plantas,'Location','best'); grid on;

%% Subplot 5: Costo F1 por semana
subplot(2,3,5);
plot(1:4, costos_sem,'b-o','LineWidth',2,'MarkerSize',8);
hold on;
yline(mean(costos_sem),'r--','LineWidth',1.5,'DisplayName','Promedio');
set(gca,'XTick',1:4,'XTickLabel',semanas);
ylabel('Costo (USD)'); title('Costo de F1 semana a semana');
legend({'Costo','Promedio'},'Location','best'); grid on;
for k=1:4
    text(k, costos_sem(k)+20, sprintf('$%.0f',costos_sem(k)),...
        'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end

%% Subplot 6: Comparacion base vs nueva red
subplot(2,3,6);
costos_comp = [costos_fab; costos_new]';
bar(costos_comp);
set(gca,'XTickLabel',{'F1','F2','F3'});
ylabel('Costo (USD/semana)');
title('Costo: red original vs red renegociada');
legend({'Red original','Red nueva'},'Location','best'); grid on;
ahorro_total = sum(costos_fab) - sum(costos_new);
text(2, max(costos_comp(:))*0.85, sprintf('Ahorro total: $%.0f',ahorro_total),...
    'HorizontalAlignment','center','FontSize',10,'FontWeight','bold','Color',[0 0.5 0]);

sgtitle('MATEMATICAS 2 --- Clase 10: Ecuaciones Matriciales AX=B',...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 10)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿En que se diferencia resolver AX=B de resolver\n');
fprintf('   k sistemas A*x_j=b_j por separado?\n');
fprintf('   Respuesta: igual resultado, pero AX=B usa UNA sola\n');
fprintf('   factorizacion de A (mas eficiente).\n\n');

fprintf('2. Calcula el residuo ||AX-B||_F para el caso principal.\n');
fprintf('   Respuesta: %.2e\n\n', norm(A*X-B,'fro'));

fprintf('3. ¿Que fabrica tiene el mayor costo en el escenario base?\n');
fprintf('   Respuesta: %s ($%.0f/semana)\n\n', fabricas{fab_cara}, max(costos_fab));

fprintf('4. Si la demanda de F2 aumenta 10%%, ¿como recalcularias\n');
fprintf('   el plan usando la inversa de A?\n');
B_new2 = B; B_new2(:,2) = 1.1*B(:,2);
X_new2 = A_inv_matlab * B_new2;
fprintf('   X_nuevo(:,2) = inv(A)*1.1*b2 = [%.1f  %.1f  %.1f]\n\n',...
    X_new2(:,2)');

fprintf('5. ¿Es el plan de la Fabrica F3 fisicamente viable?\n');
fprintf('   (Verificar: todos x_j >= 0 y x_j <= capacidad)\n');
xf3 = X(:,3);
viable_f3 = all(xf3 >= -1e-6) && all(xf3 <= cap);
fprintf('   Respuesta: %s\n', yesNo(viable_f3));
if ~viable_f3
    fprintf('   Componentes: [%.1f  %.1f  %.1f]\n', xf3');
end
fprintf('\n==========================================\n');
fprintf('Fin del script clase10_datos.m\n');
fprintf('==========================================\n');

%% --- Funcion auxiliar ---
function s = yesNo(v)
    if v; s = 'SI'; else; s = 'NO'; end
end
