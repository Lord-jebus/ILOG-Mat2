%% ============================================================
%%  MATEMATICAS 2 --- CLASE 13
%%  Script MATLAB: Mini-caso 2 --- Red Logistica TransUY S.A.
%%  Archivo: clase13_datos.m
%%
%%  EMPRESA: TransUY S.A. (caso ficticio)
%%  5 plantas --> 4 centros de distribucion en Uruguay
%%  + evaluacion de incorporar P6 en Melo
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('============================================\n');
fprintf(' MATEMATICAS 2 --- Clase 13\n');
fprintf(' Mini-caso 2: TransUY S.A.\n');
fprintf(' Analisis de Red Logistica Uruguay\n');
fprintf('============================================\n\n');

%% ============================================================
%% DATOS DEL CASO
%% ============================================================

%% Plantas (columnas de A)
plantas = {'P1 Mvd','P2 Can','P3 Sal','P4 Pay','P5 Riv'};

%% Centros de Distribucion (filas de A)
CDs = {'D1 Mald','D2 Tac','D3 Col','D4 Art'};

%% Matriz de distribucion A (4x5)
%% a_ij = fraccion del despacho de planta j que llega a CD i
A = [0.40  0.10  0.00  0.20  0.00;
     0.00  0.20  0.50  0.30  0.20;
     0.35  0.40  0.00  0.00  0.30;
     0.00  0.10  0.30  0.30  0.50];

%% Vector de demanda semanal (ton/semana)
b = [320; 280; 240; 160];

%% Costos de despacho por planta (USD/ton)
c = [10; 8; 12; 9; 11];

%% Capacidades maximas (ton/semana)
cap = [700; 600; 500; 550; 450];

%% Datos de P6 propuesta (Melo)
a6    = [0.10; 0.20; 0.30; 0.40];
c6    = 9;         % USD/ton
cap6  = 400;       % ton/sem
inv6  = 250000;    % USD de inversion

fprintf('Datos cargados. Red %dx%d.\n\n', size(A));

%% ============================================================
%% PASO 1: DIMENSIONES
%% ============================================================

fprintf('=== PASO 1: DIMENSIONES ===\n');
[m, n] = size(A);
fprintf('A: %d CDs (filas) x %d plantas (columnas)\n', m, n);
fprintf('b: %d x 1 (demanda por CD)\n', length(b));
fprintf('c: %d x 1 (costos por planta)\n\n', length(c));

%% ============================================================
%% PASO 2: RANGO Y GRADOS DE LIBERTAD
%% ============================================================

fprintf('=== PASO 2: RANGO Y GRADOS DE LIBERTAD ===\n');
r = rank(A);
k = n - r;
fprintf('rang(A) = %d\n', r);
fprintf('n = %d (plantas)\n', n);
fprintf('Grados de libertad k = n - r = %d\n\n', k);

if k == 0
    fprintf('=> Plan UNICO: sin flexibilidad operativa.\n\n');
elseif k == 1
    fprintf('=> 1 LAZO CERRADO: un parametro libre para optimizar.\n\n');
else
    fprintf('=> %d LAZOS CERRADOS: %d parametros libres.\n\n', k, k);
end

%% ============================================================
%% PASO 3: COMPATIBILIDAD
%% ============================================================

fprintf('=== PASO 3: COMPATIBILIDAD ===\n');
rAb = rank([A, b]);
fprintf('rang([A|b]) = %d\n', rAb);
if r == rAb
    fprintf('Sistema COMPATIBLE: la demanda es alcanzable.\n\n');
else
    fprintf('Sistema INCOMPATIBLE: la demanda NO puede satisfacerse.\n\n');
    fprintf('Deteniendo analisis.\n'); return;
end

%% ============================================================
%% PASO 4: LAZO CERRADO (ESPACIO NULO)
%% ============================================================

fprintf('=== PASO 4: LAZO CERRADO ===\n');
N = null(A, 'r');
fprintf('Base de Nul(A) (via null(A,r)):\n');
fprintf('  n1 = [%s]\n', num2str(N(:,1)','%.4f '));
fprintf('Verificacion ||A*n1|| = %.2e\n', norm(A*N(:,1)));

fprintf('\nInterpretacion del lazo n1:\n');
for p = 1:n
    ni = N(p,1);
    if abs(ni) > 1e-4
        if ni > 0
            fprintf('  %s AUMENTA en %.4f*t ton\n', plantas{p}, ni);
        else
            fprintf('  %s DISMINUYE en %.4f*t ton\n', plantas{p}, abs(ni));
        end
    end
end
fprintf('\n');

%% ============================================================
%% PASO 5: INVERTIBILIDAD Y CONDICION
%% ============================================================

fprintf('=== PASO 5: CONDICION DEL MODELO ===\n');
if m == n && r == n
    fprintf('A es cuadrada e invertible. cond(A) = %.4f\n', cond(A));
else
    %% Para matrices no cuadradas, usar la pseudoinversa
    Ap = pinv(A);
    cond_est = norm(A,2) * norm(Ap,2);
    fprintf('A no es cuadrada. Numero de condicion estimado: %.4f\n', cond_est);
    if cond_est < 100
        fprintf('Modelo CONFIABLE (bien condicionado).\n');
    elseif cond_est < 1e4
        fprintf('Modelo ACEPTABLE.\n');
    else
        fprintf('Modelo DUDOSO (mal condicionado).\n');
    end
end
fprintf('\n');

%% ============================================================
%% PASO 6: SOLUCION PARTICULAR
%% ============================================================

fprintf('=== PASO 6: SOLUCION PARTICULAR ===\n');
[R_aug, piv] = rref([A, b]);
xp = zeros(n, 1);
vars_basicas = piv(piv <= n);
xp(vars_basicas) = R_aug(1:r, end);

fprintf('Plan base (vars. libres = 0):\n');
fprintf('%-12s | Despacho (ton) | Capacidad | Holgura | OK?\n', 'Planta');
fprintf('%s\n', repmat('-',1,65));
for p = 1:n
    holgura = cap(p) - xp(p);
    ok = (xp(p) >= -1e-6) && (xp(p) <= cap(p)+1e-6);
    estado = '';
    if xp(p) < -1e-6,    estado = 'NEG!'; end
    if xp(p) > cap(p),   estado = 'CAP!'; end
    if abs(xp(p)) < 1e-6, estado = 'inactiva'; end
    fprintf('%-12s | %14.4f | %9.0f | %7.2f | %s %s\n',...
        plantas{p}, xp(p), cap(p), holgura, yesNo(ok), estado);
end
fprintf('\nResiduo ||A*xp - b|| = %.2e\n', norm(A*xp - b));
costo_base = c' * max(xp, 0);
fprintf('Costo base: $%.2f/semana\n\n', costo_base);

%% ============================================================
%% PASO 7: OPTIMIZACION SOBRE EL LAZO
%% ============================================================

fprintf('=== PASO 7: OPTIMIZACION ===\n');
n1 = N(:,1);
delta = c' * n1;
fprintf('delta = c^T * n1 = %.4f USD por unidad de t\n', delta);
if delta < 0
    fprintf('El lazo REDUCE el costo. Maximizar t.\n\n');
else
    fprintf('El lazo AUMENTA el costo. Minimizar t.\n\n');
end

%% Calcular intervalo factible [t_min, t_max]
t_lower = -Inf;  % limites inferiores
t_upper =  Inf;  % limites superiores
fprintf('Restricciones de factibilidad (xp + t*n1 en [0, cap]):\n');
for p = 1:n
    ni = n1(p);
    if abs(ni) > 1e-10
        %% xp(p) + t*ni >= 0
        t_lim_0 = -xp(p) / ni;
        %% xp(p) + t*ni <= cap(p)
        t_lim_c = (cap(p) - xp(p)) / ni;
        if ni > 0
            t_lower = max(t_lower, t_lim_0);
            t_upper = min(t_upper, t_lim_c);
        else
            t_upper = min(t_upper, t_lim_0);
            t_lower = max(t_lower, t_lim_c);
        end
        fprintf('  %s: t_lim(>=0)=%.4f, t_lim(<=cap)=%.4f\n',...
            plantas{p}, ternVal(ni>0,t_lim_0,t_lim_c),...
            ternVal(ni>0,t_lim_c,t_lim_0));
    end
end
if isinf(t_lower), t_lower = 0; end
fprintf('\nRango factible: [%.4f, %.4f]\n', t_lower, t_upper);

if t_lower > t_upper
    fprintf('Region factible vacia: revisar datos.\n\n');
    t_opt = 0;
else
    if delta < 0
        t_opt = t_upper;
    else
        t_opt = t_lower;
    end
end
fprintf('t* = %.4f\n', t_opt);

x_opt = xp + t_opt * n1;
x_opt = max(x_opt, 0);  % correccion numerica
costo_opt = c' * x_opt;
ahorro_sem = costo_base - costo_opt;
ahorro_anual = ahorro_sem * 52;

fprintf('\nPlan OPTIMO (t*=%.4f):\n', t_opt);
fprintf('%-12s | Despacho (ton) | Capacidad | Uso\n', 'Planta');
fprintf('%s\n', repmat('-',1,50));
for p = 1:n
    uso_pct = x_opt(p)/cap(p)*100;
    fprintf('%-12s | %14.2f | %9.0f | %5.1f%%\n',...
        plantas{p}, x_opt(p), cap(p), uso_pct);
end
fprintf('\nCosto optimo: $%.2f/semana\n', costo_opt);
fprintf('Ahorro semanal: $%.2f\n', ahorro_sem);
fprintf('Ahorro anual: $%.0f\n\n', ahorro_anual);

%% Verificar entrega a cada CD
entrega_opt = A * x_opt;
fprintf('Verificacion de entregas:\n');
for d = 1:m
    pct = entrega_opt(d)/b(d)*100;
    fprintf('  %s: %.2f/%.0f ton (%.1f%%)\n',...
        CDs{d}, entrega_opt(d), b(d), pct);
end
fprintf('\n');

%% ============================================================
%% PASO 8: ANALISIS DE SENSIBILIDAD
%% ============================================================

fprintf('=== PASO 8: ANALISIS DE SENSIBILIDAD ===\n');

%% Escenario +10% demanda
b_alto = 1.1 * b;
fprintf('Escenario demanda +10%%: b = [%s]\n', num2str(b_alto','%.0f '));

[R_alto, piv_alto] = rref([A, b_alto]);
xp_alto = zeros(n,1);
xp_alto(piv_alto(piv_alto<=n)) = R_alto(1:r, end);

%% Optimizar con demanda alta
delta_alto = delta;  % mismo lazo, mismo delta
if delta_alto < 0
    t_alto = t_upper * 1.1;  % escalar aprox
else
    t_alto = t_lower * 1.1;
end
x_opt_alto = max(xp_alto + max(0,t_alto) * n1, 0);

fprintf('Plan con demanda +10%%:\n');
excede_cap = false;
excede_neg = false;
for p = 1:n
    supera = x_opt_alto(p) > cap(p) + 1e-3;
    negativo = x_opt_alto(p) < -1e-3;
    estado = '';
    if supera, estado = '*** SUPERA CAPACIDAD ***'; excede_cap = true; end
    if negativo, estado = '*** NEGATIVO ***'; excede_neg = true; end
    fprintf('  %s: %.2f ton (cap: %d) %s\n',...
        plantas{p}, x_opt_alto(p), cap(p), estado);
end

if excede_cap || excede_neg
    fprintf('\nPLAN NO VIABLE con demanda +10%%\n');
    fprintf('ACCIONES POSIBLES:\n');
    fprintf('  1. Activar P4 (actualmente inactiva)\n');
    fprintf('  2. Ampliar capacidad de P1\n');
    fprintf('  3. Incorporar P6 (analisis a continuacion)\n\n');
else
    fprintf('\nPlan viable con demanda +10%%.\n\n');
end

%% Escenario -15% demanda
b_bajo = 0.85 * b;
[R_bajo, piv_bajo] = rref([A, b_bajo]);
xp_bajo = zeros(n,1);
xp_bajo(piv_bajo(piv_bajo<=n)) = R_bajo(1:r,end);
x_opt_bajo = max(xp_bajo + t_opt*0.85 * n1, 0);
costo_bajo = c' * x_opt_bajo;
fprintf('Escenario -15%% (costo): $%.2f/semana\n\n', costo_bajo);

%% ============================================================
%% BLOQUE: EVALUACION DE P6 (MELO)
%% ============================================================

fprintf('=== EVALUACION DE P6 EN MELO ===\n\n');

A6  = [A, a6];
c6v = [c; c6];
cap6v = [cap; cap6];
plantas6 = [plantas, {'P6 Melo'}];

r6 = rank(A6);
k6 = size(A6,2) - r6;
fprintf('Con P6: rang=%d, gdl=%d\n', r6, k6);

%% Verificar que P6 no es columna dependiente
if r6 > r
    fprintf('P6 agrega una ruta independiente: gdl aumenta en 1.\n\n');
else
    fprintf('P6 es linealmente dependiente de las plantas actuales.\n');
    fprintf('No agrega grados de libertad adicionales.\n\n');
end

%% Resolver con P6
rAb6 = rank([A6, b]);
if r6 == rAb6
    fprintf('Sistema con P6: COMPATIBLE\n\n');
    x6 = A6 \ b;  % solucion de minima norma
    costo6 = c6v' * max(x6, 0);
    fprintf('Plan referencia con P6:\n');
    for p = 1:6
        fprintf('  %s: %.2f ton\n', plantas6{p}, max(x6(p),0));
    end
    fprintf('Costo referencia con P6: $%.2f/semana\n\n', costo6);

    %% Optimizacion con P6
    N6 = null(A6, 'r');
    fprintf('Lazos con P6: %d lazo(s)\n', k6);
    delta6 = c6v' * N6;
    fprintf('Efecto de lazos: [%s]\n\n', num2str(delta6,'%.4f '));

    %% Payback
    costo_opt6 = costo6;  % aproximacion sin optimizacion completa
    ahorro_anual6 = (costo_base - costo_opt6) * 52;
    fprintf('Comparacion de costos:\n');
    fprintf('  Costo base (sin P6):   $%.2f/sem\n', costo_base);
    fprintf('  Costo optimo (sin P6): $%.2f/sem\n', costo_opt);
    fprintf('  Costo ref. (con P6):   $%.2f/sem\n', costo6);
    fprintf('\n');

    if ahorro_anual6 > 0
        payback6 = inv6 / ahorro_anual6;
        fprintf('Ahorro anual con P6 vs base: $%.0f\n', ahorro_anual6);
        fprintf('Inversion P6: $%.0f\n', inv6);
        fprintf('Payback: %.1f anos\n', payback6);
        if payback6 <= 5
            decision = 'CONVIENE (payback <= 5 anos)';
        elseif payback6 <= 10
            decision = 'EVALUAR (payback 5-10 anos)';
        else
            decision = 'NO CONVIENE en el corto plazo';
        end
        fprintf('Decision: %s\n\n', decision);
    else
        fprintf('P6 no reduce el costo con estos parametros.\n\n');
    end
else
    fprintf('Sistema con P6: INCOMPATIBLE\n\n');
end

%% ============================================================
%% BLOQUE: DECISION FINAL
%% ============================================================

fprintf('============================================\n');
fprintf('DECISION EJECUTIVA --- TransUY S.A.\n');
fprintf('============================================\n\n');

fprintf('RESUMEN DEL ANALISIS:\n');
fprintf('  Grados de libertad actuales: %d\n', k);
fprintf('  Costo base:    $%.2f/semana\n', costo_base);
fprintf('  Costo optimo:  $%.2f/semana\n', costo_opt);
fprintf('  Ahorro anual (optimizacion sin inversion): $%.0f\n\n', ahorro_anual);

fprintf('RECOMENDACION:\n');
fprintf('  1. INMEDIATO: Implementar el plan optimo.\n');
fprintf('     Ahorro: $%.0f/ano sin inversion adicional.\n', ahorro_anual);
fprintf('  2. CORTO PLAZO: Renegociar tarifa con P4 (actualmente\n');
fprintf('     inactiva). Activarla para absorber picos de demanda.\n');
fprintf('  3. P6 EN MELO: Evaluar solo si la demanda crece\n');
fprintf('     sostenidamente mas del 15%% anual.\n\n');

%% ============================================================
%% BLOQUE: VISUALIZACION
%% ============================================================

fprintf('--- Visualizaciones ---\n');

figure('Name','Clase 13 --- Mini-caso 2 TransUY S.A.',...
    'NumberTitle','off','Position',[30 30 1350 820]);

%% Subplot 1: Comparacion de planes
subplot(2,3,1);
datos_bar = [xp, x_opt];
bh = bar(datos_bar);
bh(1).FaceColor = [0.5 0.5 0.5];
bh(2).FaceColor = [0 0.5 0.2];
hold on;
for p=1:n, yline(cap(p),'r--','LineWidth',1); end
set(gca,'XTickLabel',{'P1','P2','P3','P4','P5'});
ylabel('Toneladas'); title('Plan base vs plan optimo');
legend({'Base','Optimo','Cap. max'},'Location','northeast'); grid on;

%% Subplot 2: Costo en funcion de t
subplot(2,3,2);
t_rng = linspace(t_lower-20, t_upper+20, 200);
costo_t = zeros(size(t_rng));
fact_t  = false(size(t_rng));
for k_t = 1:length(t_rng)
    xt = xp + t_rng(k_t)*n1;
    fact_t(k_t) = all(xt >= -1e-6) && all(xt <= cap+1e-6);
    costo_t(k_t) = c' * max(xt,0);
end
costo_t_plot = costo_t; costo_t_plot(~fact_t) = NaN;
plot(t_rng, costo_t_plot, 'b-', 'LineWidth', 2);
hold on;
plot(t_opt, costo_opt, 'r*', 'MarkerSize', 14, 'LineWidth', 2);
xline(t_lower,'g--','t_{min}','LabelVerticalAlignment','top');
xline(t_upper,'g--','t_{max}','LabelVerticalAlignment','top');
xlabel('Parametro t'); ylabel('Costo (USD/sem)');
title('Costo vs parametro del lazo');
legend({'C(t)','Optimo'},'Location','best'); grid on;

%% Subplot 3: Utilizacion de capacidad
subplot(2,3,3);
uso_opt = x_opt ./ cap * 100;
bh3 = barh(uso_opt, 'FaceColor','flat');
bh3.CData = [0 0.4 0.8; 0 0.4 0.8; 0 0.4 0.8; 0.5 0.5 0.5; 0 0.4 0.8];
set(gca,'YTickLabel',{'P1','P2','P3','P4','P5'});
xlabel('% de capacidad utilizada');
title('Utilizacion de capacidad (plan optimo)');
xline(100,'r--','LineWidth',2);
xline(80,'orange--','LineWidth',1);
xlim([0 110]); grid on;
for p=1:n
    text(uso_opt(p)+1, p, sprintf('%.1f%%',uso_opt(p)),...
        'VerticalAlignment','middle','FontWeight','bold','FontSize',8);
end

%% Subplot 4: Entrega vs demanda
subplot(2,3,4);
entrega_base = A * xp;
entrega_opt2 = A * x_opt;
bar([entrega_base, entrega_opt2, b]);
set(gca,'XTickLabel',{'D1','D2','D3','D4'});
ylabel('Toneladas');
title('Entrega vs demanda por CD');
legend({'Base','Optimo','Demanda'},'Location','best'); grid on;

%% Subplot 5: Sensibilidad por escenario
subplot(2,3,5);
escenarios = {'Base','Opt. act.','Dem. +10%','Dem. -15%'};
costos_esc = [costo_base, costo_opt, c'*x_opt_alto, costo_bajo];
bh5 = bar(costos_esc,'FaceColor','flat');
bh5.CData = [0.5 0.5 0.5; 0 0.5 0.2; 0.8 0.2 0.1; 0.2 0.6 0.8];
set(gca,'XTickLabel',escenarios,'XTickLabelRotation',15);
ylabel('Costo (USD/sem)'); title('Costo por escenario');
grid on;
for k_e=1:4
    text(k_e, costos_esc(k_e)+20, sprintf('$%.0f',costos_esc(k_e)),...
        'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end

%% Subplot 6: Resumen ejecutivo (texto)
subplot(2,3,6);
axis off;
ypos = 0.95;
dy = 0.12;
items = {
    sprintf('Red actual: %dx%d, gdl=%d', m, n, k);
    sprintf('Costo base: $%.0f/sem', costo_base);
    sprintf('Costo optimo: $%.0f/sem', costo_opt);
    sprintf('Ahorro anual: $%.0f', ahorro_anual);
    sprintf('P1 cuello de botella: %.0f%%', x_opt(1)/cap(1)*100);
    'P4 inactiva en plan optimo';
    'Rec: implementar plan optimo';
    'Rev. P6 si demanda +15%';
};
colores_txt = {azulLog,azulLog,verdeLog,verdeLog,naranja,[0.5 0 0.5],[0 0.4 0],[0 0.4 0]};
for k_t=1:length(items)
    text(0.05, ypos-(k_t-1)*dy, items{k_t},...
        'FontSize',9,'FontWeight','bold','Color',colores_txt{k_t},...
        'Units','normalized');
end
title('Resumen ejecutivo');

sgtitle('MATEMATICAS 2 --- Clase 13: Mini-caso 2 TransUY S.A.',...
    'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% PREGUNTAS PARA EL INFORME
%% ============================================================

fprintf('============================================\n');
fprintf('PREGUNTAS PARA EL INFORME (Mini-caso 2)\n');
fprintf('============================================\n\n');

fprintf('1. ¿Cuantos GDL tiene la red actual? ¿Que significa\n');
fprintf('   para la planificacion operativa?\n');
fprintf('   Respuesta: k=%d gdl => %s\n\n', k,...
    ternStr(k==0,'Plan unico, sin margen de maniobra.',...
    sprintf('%d lazo(s) cerrado(s) para optimizar.',k)));

fprintf('2. ¿Que planta queda inactiva en el plan optimo?\n');
fprintf('   ¿Por que? ¿Conviene mantenerla?\n');
[~, inactivas] = find(x_opt < 1e-3);
if ~isempty(inactivas)
    fprintf('   Respuesta: %s (despacho=0). Mantener como\n', plantas{inactivas(1)});
    fprintf('   respaldo para temporada alta.\n\n');
else
    fprintf('   Respuesta: ninguna planta inactiva.\n\n');
end

fprintf('3. ¿Cual es el ahorro anual del plan optimo\n');
fprintf('   respecto al plan base?\n');
fprintf('   Respuesta: $%.0f/ano\n\n', ahorro_anual);

fprintf('4. ¿Con demanda +10%%, la red puede operar sin\n');
fprintf('   incorporar P6?\n');
fprintf('   Respuesta: %s\n\n', ternStr(~excede_cap,...
    'SI, todas las plantas dentro de capacidad.',...
    'NO, alguna planta supera su capacidad.'));

fprintf('5. ¿Conviene incorporar P6 con horizonte de 5 anos?\n');
if exist('payback6','var')
    fprintf('   Payback: %.1f anos => %s\n\n', payback6,...
        ternStr(payback6<=5,'CONVIENE','NO CONVIENE en 5 anos'));
else
    fprintf('   Ver resultado del analisis de P6 arriba.\n\n');
end

fprintf('============================================\n');
fprintf('Fin del script clase13_datos.m\n');
fprintf('Preparar el informe para entrega en Clase 14.\n');
fprintf('============================================\n');

%% --- Funciones auxiliares ------------------------------------
function s = yesNo(v)
    if v; s = 'SI'; else; s = 'NO'; end
end

function v = ternVal(cond_v, a, b_val)
    if cond_v; v = a; else; v = b_val; end
end

function s = ternStr(v, a, b_val)
    if v; s = a; else; s = b_val; end
end
