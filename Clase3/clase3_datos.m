%% ============================================================
%%  MATEMATICAS 2 --- CLASE 3
%%  Script MATLAB: Producto matriz-vector y flujos logisticos
%%  Archivo: clase3_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar seccion a seccion con Ctrl+Enter (Run Section)
%%  o el script completo con F5.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 3\n');
fprintf(' Producto matriz-vector: A*v\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: DATASET PRINCIPAL --- COSTO POR PLANTA
%% ============================================================
%
% Red: 3 plantas x 4 centros de distribucion (CDs)
% Plantas: 1=Montevideo, 2=Salto, 3=Rivera
% CDs:     1=Maldonado, 2=Paysandu, 3=Tacuarembo, 4=Colonia
%
% C(i,j) = costo de envio desde planta i a CD j (USD/ton)
% v(j)   = volumen enviado al CD j esta semana (ton)

fprintf('--- BLOQUE 1: Costo total por planta ---\n\n');

plantas = {'Montevideo','Salto','Rivera'};
CDs     = {'Maldonado','Paysandu','Tacuarembo','Colonia'};

C = [12  35  48   8;
     40  15  22  38;
     52  28  10  60];

v = [50; 80; 30; 60];   % volumen por CD (vector columna)

fprintf('Matriz de costos C (%dx%d):\n', size(C));
disp(C);
fprintf('Vector de volumenes v (%dx%d):\n', size(v));
disp(v');

%% Producto A*v
b = C * v;

fprintf('Costo total por planta b = C*v (%dx%d):\n', size(b));
for k = 1:3
    fprintf('  %s: $%.0f/semana\n', plantas{k}, b(k));
end

%% Analisis de resultados
fprintf('\n--- Analisis de eficiencia ---\n');
[bMin, iMin] = min(b);
[bMax, iMax] = max(b);
fprintf('Planta mas eficiente:  %s ($%.0f)\n', plantas{iMin}, bMin);
fprintf('Planta mas costosa:    %s ($%.0f)\n', plantas{iMax}, bMax);
fprintf('Diferencia absoluta:   $%.0f\n', bMax-bMin);
fprintf('Sobrecoste relativo:   %.1f%%\n\n', (bMax/bMin-1)*100);

%% Verificacion manual del elemento b(1)
fprintf('Verificacion manual b(1) = C(1,:)*v:\n');
manual_b1 = 0;
for j = 1:4
    fprintf('  C(1,%d)*v(%d) = %d*%d = %d\n', j,j, C(1,j), v(j), C(1,j)*v(j));
    manual_b1 = manual_b1 + C(1,j)*v(j);
end
fprintf('  TOTAL b(1) = $%d\n\n', manual_b1);

%% ============================================================
%% BLOQUE 2: FLUJOS RECIBIDOS POR CD
%% ============================================================
%
% F(i,j) = fraccion del despacho de planta j que va al CD i
% u(j)   = toneladas totales despachadas por planta j
% carga_CD = F * u = toneladas recibidas por cada CD

fprintf('--- BLOQUE 2: Flujos recibidos por CD ---\n\n');

F = [0.40  0.20  0.10;
     0.10  0.50  0.20;
     0.20  0.10  0.40;
     0.30  0.20  0.30];

u = [200; 150; 100];   % despacho por planta (ton)

fprintf('Matriz de flujos F (%dx%d):\n', size(F));
disp(F);
fprintf('Despacho por planta u:\n');
for k=1:3, fprintf('  %s: %d ton\n', plantas{k}, u(k)); end

%% Calcular carga recibida por CD
carga_CD = F * u;

fprintf('\nCarga recibida por CD (F*u):\n');
for k=1:4, fprintf('  %s: %.0f ton\n', CDs{k}, carga_CD(k)); end

%% Verificacion de balance
fprintf('\n--- Verificacion de balance ---\n');
total_despachado = sum(u);
total_recibido   = sum(carga_CD);
fprintf('Total despachado: %.0f ton\n', total_despachado);
fprintf('Total recibido:   %.0f ton\n', total_recibido);
fprintf('Balance OK: %s\n', mat2str(abs(total_despachado-total_recibido)<1e-9));
fprintf('(Las columnas de F suman 1: %s)\n\n', ...
    mat2str(all(abs(sum(F,1)-1)<1e-9)));

%% CD con mayor y menor carga
[~,iMax] = max(carga_CD);
[~,iMin] = min(carga_CD);
fprintf('CD con mayor carga: %s (%.0f ton)\n', CDs{iMax}, carga_CD(iMax));
fprintf('CD con menor carga: %s (%.0f ton)\n\n', CDs{iMin}, carga_CD(iMin));

%% ============================================================
%% BLOQUE 3: PROPIEDADES DE LINEALIDAD
%% ============================================================

fprintf('--- BLOQUE 3: Propiedades de linealidad ---\n\n');

% Dos vectores de clientes
vA = [20; 10;  0;  5];
vB = [30;  0; 40; 10];
k  = 2.5;

%% Aditividad: A(u+v) = Au + Av
lhs_add = C * (vA + vB);
rhs_add = C*vA + C*vB;
fprintf('Aditividad A(vA+vB) == AvA + AvB: %s\n', ...
    mat2str(norm(lhs_add-rhs_add) < 1e-9));

fprintf('Costo Cliente A:          [%d %d %d]\n', (C*vA)');
fprintf('Costo Cliente B:          [%d %d %d]\n', (C*vB)');
fprintf('Costo combinado (suma):   [%d %d %d]\n', rhs_add');
fprintf('Costo directo (A(vA+vB)): [%d %d %d]\n\n', lhs_add');

%% Homogeneidad: A(k*v) = k*(A*v)
lhs_hom = C * (k * vA);
rhs_hom = k * (C * vA);
fprintf('Homogeneidad A(k*vA) == k*(A*vA): %s\n', ...
    mat2str(norm(lhs_hom-rhs_hom) < 1e-9));
fprintf('Si k=%.1f (volumen x%.1f), costo x%.1f exactamente.\n\n', k, k, k);

%% ============================================================
%% BLOQUE 4: CASOS ESPECIALES DEL VECTOR v
%% ============================================================

fprintf('--- BLOQUE 4: Casos especiales ---\n\n');

%% v = 1 (vector de unos): suma de filas
v_unos = ones(4, 1);
suma_filas = C * v_unos;
fprintf('C * 1 (suma de cada fila = costo enviar 1 ton por ruta a TODOS los CDs):\n');
for k=1:3, fprintf('  %s: $%d/ton-ruta\n', plantas{k}, suma_filas(k)); end

%% v = e_j (vector canonico): columna j de C
for j = 1:4
    ej = zeros(4,1); ej(j) = 1;
    col_j = C * ej;
    fprintf('\nC * e%d (costos hacia %s solamente):\n', j, CDs{j});
    for k=1:3
        fprintf('  %s: $%d/ton\n', plantas{k}, col_j(k));
    end
end

%% v = w (pesos = distribucion proporcional)
fprintf('\n');
w = [0.25; 0.35; 0.20; 0.20];   % fracciones (suman 1)
fprintf('Pesos w (distribucion proporcional a los CDs): ');
disp(w');
costo_prom_ponderado = C * w;
fprintf('C * w (costo unitario promedio ponderado por planta):\n');
for k=1:3
    fprintf('  %s: $%.2f/ton\n', plantas{k}, costo_prom_ponderado(k));
end

%% ============================================================
%% BLOQUE 5: ANALISIS DE SENSIBILIDAD
%% ============================================================

fprintf('\n--- BLOQUE 5: Analisis de sensibilidad ---\n\n');

v0    = [50; 80; 30; 60];     % vector base
delta = [10;  0; -5;  0];     % perturbacion: +10 ton Maldonado, -5 ton Tacuarembo

costo_base = C * v0;
costo_delta = C * delta;      % tasa de cambio por unidad de alpha

fprintf('Costo base por planta:\n');
for k=1:3, fprintf('  %s: $%.0f\n', plantas{k}, costo_base(k)); end

fprintf('\nCambio de costo por unidad de perturbacion (C * delta):\n');
for k=1:3
    signo = ''; if costo_delta(k)>0, signo='+'; end
    fprintf('  %s: %s$%.0f por unidad de alpha\n', plantas{k}, signo, costo_delta(k));
end

fprintf('\nTrayectoria de costo para distintos alpha:\n');
fprintf('%-8s | %-12s | %-12s | %-12s\n','alpha','Montevideo','Salto','Rivera');
fprintf('%s\n', repmat('-',1,52));
for alpha = -2:1:2
    b_al = costo_base + alpha * costo_delta;
    fprintf('  %+.0f    | $%-10.0f | $%-10.0f | $%-10.0f\n', ...
        alpha, b_al(1), b_al(2), b_al(3));
end

%% ============================================================
%% BLOQUE 6: PROYECCION DE CARGA CON CRECIMIENTO
%% ============================================================

fprintf('\n--- BLOQUE 6: Proyeccion de carga con crecimiento ---\n\n');

carga_0 = carga_CD;          % carga inicial por CD
tasas   = [1.12; 1.08; 1.05; 1.10];  % tasa de crecimiento semanal por CD
cap_max = [200; 180; 160; 200];       % capacidad maxima por CD (ton)

fprintf('Proyeccion de carga por CD (ton/semana):\n');
fprintf('%-14s | ', 'CD');
for t=0:5, fprintf('Sem %-2d | ', t); end; fprintf('\n');
fprintf('%s\n', repmat('-',1,14+8*6));

for k=1:4
    fprintf('%-14s | ', CDs{k});
    for t=0:5
        carga_t = carga_0(k) * tasas(k)^t;
        if carga_t > cap_max(k)
            fprintf('*%-5.0f | ', carga_t);   % supera capacidad
        else
            fprintf(' %-5.0f | ', carga_t);
        end
    end
    fprintf('\n');
end
fprintf('(* = supera capacidad maxima)\n\n');

% Semana en que CD1 supera capacidad
t_critico = log(cap_max(1)/carga_0(1)) / log(tasas(1));
fprintf('CD1 (Maldonado) supera capacidad en semana %.1f\n', t_critico);
fprintf('Accion requerida antes de la semana %d\n\n', ceil(t_critico));

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 3 --- Producto Matriz-Vector', ...
       'NumberTitle','off','Position',[50 50 1300 800]);

%% Subplot 1: Costo por planta
subplot(2,3,1);
bar(b,'FaceColor',[0 0.32 0.58]);
set(gca,'XTickLabel',plantas);
ylabel('Costo semanal (USD)');
title('Costo total por planta: C \cdot v');
grid on;
for k=1:3
    text(k, b(k)+150, sprintf('$%.0f',b(k)), ...
        'HorizontalAlignment','center','FontWeight','bold','FontSize',9);
end

%% Subplot 2: Carga por CD
subplot(2,3,2);
bar(carga_CD,'FaceColor',[0 0.51 0.31]);
set(gca,'XTickLabel',CDs,'XTickLabelRotation',20);
ylabel('Toneladas recibidas');
title('Carga recibida por CD: F \cdot u');
yline(mean(carga_CD),'r--','LineWidth',1.5);
legend({'Carga','Promedio'},'Location','best');
grid on;
for k=1:4
    text(k, carga_CD(k)+1.5, sprintf('%.0f t',carga_CD(k)), ...
        'HorizontalAlignment','center','FontWeight','bold','FontSize',9);
end

%% Subplot 3: Superposicion de flujos (clientes A y B)
subplot(2,3,3);
bA = C * vA; bB = C * vB; bAB = C * (vA+vB);
x  = 1:3;
bar_data = [bA, bB, bAB];
b_h = bar(x, bar_data);
b_h(1).FaceColor = [0.2 0.6 0.8];
b_h(2).FaceColor = [0.9 0.5 0.1];
b_h(3).FaceColor = [0.2 0.7 0.3];
set(gca,'XTickLabel',plantas,'XTickLabelRotation',15);
ylabel('Costo (USD)');
title('Superposicion: A+B vs combinado');
legend({'Cliente A','Cliente B','Combinado'},'Location','best');
grid on;

%% Subplot 4: Trayectoria de sensibilidad
subplot(2,3,4);
alphas = -3:0.1:3;
costos_al = zeros(3, length(alphas));
for idx=1:length(alphas)
    costos_al(:,idx) = costo_base + alphas(idx)*costo_delta;
end
plot(alphas, costos_al(1,:), 'b-', 'LineWidth', 2); hold on;
plot(alphas, costos_al(2,:), 'g-', 'LineWidth', 2);
plot(alphas, costos_al(3,:), 'r-', 'LineWidth', 2);
xline(0,'k--'); grid on;
xlabel('Parametro \alpha (perturbacion)');
ylabel('Costo total (USD)');
title('Sensibilidad del costo a perturbacion');
legend(plantas,'Location','best');

%% Subplot 5: Proyeccion de carga (4 semanas)
subplot(2,3,5);
semanas = 0:5;
colors_cd = {[0 0.45 0.70],[0.80 0.40 0],[0 0.60 0],[0.64 0.08 0.18]};
hold on;
for k=1:4
    carga_proj = carga_0(k) * tasas(k).^semanas;
    plot(semanas, carga_proj, '-o', 'Color', colors_cd{k}, 'LineWidth', 2, ...
         'DisplayName', CDs{k});
    yline(cap_max(k), '--', 'Color', colors_cd{k}, 'LineWidth', 0.8, ...
          'HandleVisibility','off');
end
xlabel('Semana'); ylabel('Carga (ton)');
title('Proyeccion de carga por CD (-- = cap. max)');
legend('Location','best'); grid on;

%% Subplot 6: Mapa de calor de contribuciones al costo de Planta 1
subplot(2,3,6);
contrib = C(1,:) .* v';   % contribucion de cada CD al costo de Planta 1
bar(contrib, 'FaceColor', [0.5 0 0.5]);
set(gca,'XTickLabel',CDs,'XTickLabelRotation',20);
ylabel('Contribucion al costo (USD)');
title('Contribucion al costo de Planta 1 (Montevideo)');
grid on;
total_p1 = sum(contrib);
for k=1:4
    text(k, contrib(k)+30, sprintf('$%d\n(%.0f%%)',contrib(k),contrib(k)/total_p1*100), ...
        'HorizontalAlignment','center','FontSize',8);
end

sgtitle('MATEMATICAS 2 --- Clase 3: Producto Matriz-Vector', ...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 3)\n');
fprintf('==========================================\n\n');
fprintf('1. ¿Que planta tiene el mayor costo semanal con los\n');
fprintf('   volumenes actuales? ¿Y la de menor costo?\n');
fprintf('   Respuesta: mayor=%s, menor=%s\n\n', plantas{iMax}, plantas{iMin});

fprintf('2. Si los volumenes de Maldonado y Colonia se intercambian\n');
fprintf('   (v = [60;80;30;50]), ¿sube o baja el costo de Montevideo?\n');
v_swap = [60;80;30;50];
b_swap = C * v_swap;
dif = b_swap(1) - b(1);
fprintf('   Respuesta: %s $%.0f (de $%.0f a $%.0f)\n\n', ...
    ternario(dif>0,'SUBE','BAJA'), abs(dif), b(1), b_swap(1));

fprintf('3. Calcula C * e3 (vector canonico j=3) manualmente\n');
fprintf('   y verifica en MATLAB.\n');
e3 = [0;0;1;0]; Ce3 = C*e3;
fprintf('   Resultado: [%d, %d, %d] (costos hacia Tacuarembo)\n\n', Ce3');

fprintf('4. ¿En que semana supera la carga de CD4 (Colonia) su\n');
fprintf('   capacidad maxima de 200 ton con crecimiento del 10%%?\n');
t_cd4 = log(cap_max(4)/carga_0(4)) / log(tasas(4));
fprintf('   Respuesta: semana %.1f (redondear a %d)\n\n', t_cd4, ceil(t_cd4));

fprintf('5. Verifica la propiedad A(k*vA) = k*(A*vA) con k=3.\n');
fprintf('   ¿Que significa practicamente triplicar vA?\n');
k3 = 3; lhs5 = C*(k3*vA); rhs5 = k3*(C*vA);
fprintf('   Igualdad: %s\n', mat2str(norm(lhs5-rhs5)<1e-9));
fprintf('   Significado: el costo se triplica exactamente.\n\n');
fprintf('==========================================\n');
fprintf('Fin del script clase3_datos.m\n');
fprintf('==========================================\n');

%% -- Funciones auxiliares ------------------------------------
function s = ternario(cond, a, b)
    if cond; s=a; else; s=b; end
end
