%% ============================================================
%%  MATEMATICAS 2 --- CLASE 7
%%  Script MATLAB: Mini-caso 1 --- Sistema de Distribucion Logistica
%%  Archivo: clase7_datos.m
%%
%%  EMPRESA: LogiSur S.A. (caso ficticio)
%%  4 plantas de produccion --> 5 centros de distribucion
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==============================================\n');
fprintf(' MATEMATICAS 2 --- Clase 7\n');
fprintf(' Mini-caso 1: Distribucion Logistica LogiSur\n');
fprintf('==============================================\n\n');

%% ============================================================
%% DATOS DEL CASO --- LogiSur S.A.
%% ============================================================

%% Nombres
plantas = {'P1 Montevideo','P2 Salto','P3 Rivera','P4 Paysandu'};
CDs     = {'D1 Maldonado','D2 Tacuarembo','D3 Colonia',...
           'D4 Artigas','D5 Melo'};

%% Matriz de coeficientes A (5x4)
%% a_ij = fraccion del despacho de planta j que llega a CD i
A = [0.50  0.00  0.00  0.30;   % D1 Maldonado
     0.00  0.40  0.30  0.00;   % D2 Tacuarembo
     0.20  0.00  0.00  0.10;   % D3 Colonia
     0.00  0.35  0.00  0.40;   % D4 Artigas
     0.00  0.00  0.50  0.00];  % D5 Melo

%% Vector de demanda semanal (ton/semana)
b_base = [320; 280; 130; 255; 150];

%% Capacidades maximas por planta (ton/semana)
cap_max = [600; 500; 400; 550];

%% Tarifas de despacho por planta (USD/ton)
c_tarifa = [8; 12; 15; 10];

%% Escenarios de demanda
b_alto = 1.20 * b_base;   % +20%
b_bajo = 0.85 * b_base;   % -15%

fprintf('Datos cargados correctamente.\n');
fprintf('Dimensiones: A(%dx%d), b(%dx1), cap(%dx1)\n\n',...
    size(A,1), size(A,2), length(b_base), length(cap_max));

%% ============================================================
%% BLOQUE 1: VERIFICACION DEL MODELO CON A*v0
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 1: Verificacion del modelo (A*v0)\n');
fprintf('==========================================\n\n');

%% Vector de prueba: capacidades maximas
v0 = cap_max;
flujo_v0 = A * v0;

fprintf('Vector de prueba v0 (capacidades maximas, ton):\n');
for k=1:4, fprintf('  %s: %d ton\n', plantas{k}, v0(k)); end

fprintf('\nFlujo A*v0 vs Demanda base:\n');
fprintf('%-16s | A*v0 | Demanda | Diferencia | Estado\n','CD');
fprintf('%s\n', repmat('-',1,65));
for k=1:5
    dif = flujo_v0(k) - b_base(k);
    estado = 'OK (exceso)';
    if dif < 0, estado = '!!! DEFICIT !!!'; end
    fprintf('%-16s | %4.0f | %7.0f | %+10.1f | %s\n',...
        CDs{k}, flujo_v0(k), b_base(k), dif, estado);
end

fprintf('\nConclusin: ');
if all(flujo_v0 >= b_base)
    fprintf('La demanda base es alcanzable con capacidades maximas.\n');
    fprintf('El sistema A*x=b es compatible.\n\n');
else
    fprintf('ATENCION: hay CDs en deficit. Revisar la red.\n\n');
end

%% ============================================================
%% BLOQUE 2: RESOLUCION DEL SISTEMA BASE
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 2: Resolucion A*x = b (base)\n');
fprintf('==========================================\n\n');

%% Verificar compatibilidad
rA  = rank(A);
rAb = rank([A, b_base]);
n   = size(A, 2);
fprintf('rang(A) = %d\n', rA);
fprintf('rang([A|b]) = %d\n', rAb);
fprintf('n (incognitas) = %d\n\n', n);

if rA < rAb
    fprintf('Sistema INCOMPATIBLE. No hay solucion.\n');
    return;
elseif rA < n
    fprintf('Sistema con INFINITAS SOLUCIONES (%d variables libres).\n\n', n-rA);
else
    fprintf('Sistema con SOLUCION UNICA.\n\n');
end

%% Resolver
x_base = A \ b_base;
residuo_base = norm(A * x_base - b_base);

fprintf('Plan de despacho optimo (Escenario Base):\n');
fprintf('%-18s | Despacho (ton) | Capacidad | Holgura\n','Planta');
fprintf('%s\n', repmat('-',1,60));
for k=1:4
    holgura = cap_max(k) - x_base(k);
    fprintf('%-18s | %14.2f | %9d | %7.1f\n',...
        plantas{k}, x_base(k), cap_max(k), holgura);
end
fprintf('\nResiduo ||A*x - b|| = %.2e\n', residuo_base);

%% Costo
costo_base = c_tarifa' * x_base;
fprintf('Costo total plan base: $%.2f/semana\n\n', costo_base);

%% RREF para informacion estructural
[R_base, pivots_base] = rref([A, b_base]);
fprintf('RREF del sistema base:\n');
for i=1:5
    fprintf('  |');
    for j=1:4, fprintf(' %8.4f', R_base(i,j)); end
    fprintf(' | %8.4f |\n', R_base(i,5));
end
vars_libres = setdiff(1:n, pivots_base(pivots_base<=n));
if isempty(vars_libres)
    fprintf('\nConfirma: solucion UNICA (todas las columnas tienen pivote).\n\n');
else
    fprintf('\nVariables libres: x%s\n\n', mat2str(vars_libres));
end

%% ============================================================
%% BLOQUE 3: ANALISIS DE VIABILIDAD
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 3: Analisis de viabilidad\n');
fprintf('==========================================\n\n');

exceso  = max(0, x_base - cap_max);
deficit = max(0, -x_base);  % despachos negativos

fprintf('Resumen de viabilidad (Escenario Base):\n');
problema = false;
for k=1:4
    if exceso(k) > 0
        fprintf('  !!! %s SUPERA capacidad en %.2f ton\n', plantas{k}, exceso(k));
        problema = true;
    elseif deficit(k) > 0
        fprintf('  !!! %s tiene despacho negativo: %.2f ton\n', plantas{k}, x_base(k));
        problema = true;
    else
        fprintf('  OK  %s: %.2f ton (%.0f%% de cap.)\n',...
            plantas{k}, x_base(k), x_base(k)/cap_max(k)*100);
    end
end

if ~problema
    fprintf('\nPlan BASE es VIABLE operativamente.\n\n');
else
    fprintf('\nPlan BASE tiene problemas de viabilidad.\n\n');
end

%% Verificar entregas a cada CD
fprintf('Verificacion de entregas a CDs:\n');
entrega = A * x_base;
for k=1:5
    pct = entrega(k)/b_base(k)*100;
    fprintf('  %s: %.1f/%.1f ton (%.1f%%)\n',...
        CDs{k}, entrega(k), b_base(k), pct);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 4: SIMULACION DE ESCENARIOS
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 4: Simulacion de escenarios\n');
fprintf('==========================================\n\n');

B_esc = [b_base, b_alto, b_bajo];
esc_nombres = {'Base (100%)','Alto (+20%)','Bajo (-15%)'};
X_esc = A \ B_esc;

fprintf('Planes de despacho por escenario (ton/semana):\n');
fprintf('%-18s | %-12s | %-12s | %-12s\n','Planta',esc_nombres{:});
fprintf('%s\n', repmat('-',1,62));
for k=1:4
    fprintf('%-18s | %12.2f | %12.2f | %12.2f\n',...
        plantas{k}, X_esc(k,1), X_esc(k,2), X_esc(k,3));
end
fprintf('%s\n', repmat('-',1,62));

%% Viabilidad y costos por escenario
fprintf('\nResumen de viabilidad y costos:\n');
fprintf('%-14s | Viable | Costo (USD/sem) | Problema\n','Escenario');
fprintf('%s\n', repmat('-',1,65));
for k=1:3
    xk = X_esc(:,k);
    viable = all(xk <= cap_max) && all(xk >= 0);
    costo_k = c_tarifa' * xk;
    problema_str = '';
    if ~viable
        idx = find(xk > cap_max);
        if ~isempty(idx)
            problema_str = sprintf('%s supera cap.', plantas{idx(1)});
        end
        idx2 = find(xk < 0);
        if ~isempty(idx2)
            problema_str = [problema_str, sprintf(' x%d<0', idx2(1))];
        end
    end
    fprintf('%-14s | %-6s | %15.2f | %s\n',...
        esc_nombres{k}, yesNo(viable), costo_k, problema_str);
end
fprintf('\n');

%% Detalle del escenario alto (el problematico)
fprintf('Detalle Escenario Alto:\n');
for k=1:4
    exceso_k = max(0, X_esc(k,2)-cap_max(k));
    if exceso_k > 0
        fprintf('  %s: necesita %.2f t, cap.max=%d t => exceso=%.2f t\n',...
            plantas{k}, X_esc(k,2), cap_max(k), exceso_k);
    else
        fprintf('  %s: %.2f t dentro de capacidad\n', plantas{k}, X_esc(k,2));
    end
end
fprintf('\n');

%% ============================================================
%% BLOQUE 5: ANALISIS DE COSTOS
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 5: Analisis de costos\n');
fprintf('==========================================\n\n');

fprintf('Costo por planta por escenario (USD/semana):\n');
fprintf('%-18s | %-12s | %-12s\n','Planta','Base','Bajo');
fprintf('%s\n', repmat('-',1,50));
for k=1:4
    cb = c_tarifa(k)*X_esc(k,1);
    clow = c_tarifa(k)*X_esc(k,3);
    fprintf('%-18s | %12.2f | %12.2f\n', plantas{k}, cb, clow);
end
fprintf('%s\n', repmat('-',1,50));
fprintf('%-18s | %12.2f | %12.2f\n','TOTAL',...
    c_tarifa'*X_esc(:,1), c_tarifa'*X_esc(:,3));
fprintf('\n');

%% Ahorro en escenario bajo
ahorro = c_tarifa'*X_esc(:,1) - c_tarifa'*X_esc(:,3);
fprintf('Ahorro escenario bajo vs base: $%.2f/semana\n', ahorro);
fprintf('Ahorro anual estimado: $%.0f (52 semanas)\n\n', ahorro*52);

%% Planta mas costosa
[~, imax_c] = max(c_tarifa .* X_esc(:,1));
fprintf('Planta mas costosa en escenario base: %s\n', plantas{imax_c});
fprintf('Accion sugerida: renegociar tarifa o reducir fraccion de carga.\n\n');

%% Analisis: si tarifa de P3 sube a 20 USD/ton
c_nuevo = c_tarifa; c_nuevo(3) = 20;
costo_nuevo = c_nuevo' * x_base;
fprintf('Si tarifa P3 sube de 15 a 20 USD/ton:\n');
fprintf('  Costo total nuevo: $%.2f/semana (+$%.2f)\n\n',...
    costo_nuevo, costo_nuevo - costo_base);

%% ============================================================
%% BLOQUE 6: DECISION FINAL Y RECOMENDACIONES
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 6: Decision final\n');
fprintf('==========================================\n\n');

fprintf('PLAN RECOMENDADO: Escenario Base\n');
fprintf('%s\n', repmat('=',1,45));
for k=1:4
    fprintf('  %s: %.2f ton/semana (%.0f%% cap., $%.0f/sem)\n',...
        plantas{k}, x_base(k), x_base(k)/cap_max(k)*100,...
        c_tarifa(k)*x_base(k));
end
fprintf('  COSTO TOTAL: $%.2f/semana\n\n', costo_base);

fprintf('RIESGOS IDENTIFICADOS:\n');
fprintf('  1. Si demanda sube >14%%, P1 (Mvd) alcanza su limite.\n');
fprintf('     Accion: negociar +50 ton capacidad en P4 (Paysandu)\n');
fprintf('     o renegociar fraccion de D1 desde P4.\n\n');
fprintf('  2. P3 (Rivera) tiene la tarifa mas alta ($15/ton).\n');
fprintf('     Accion: evaluar si se puede transferir parte de su\n');
fprintf('     carga a P2 (Salto, $12/ton) ajustando la red.\n\n');

fprintf('ACCIONES PREVENTIVAS:\n');
fprintf('  - Monitorear demanda de D2 (Tacuarembo): mayor sensibilidad.\n');
fprintf('  - Reservar 50 ton de capacidad en P1 para picos.\n');
fprintf('  - Revisar coeficientes de A con datos reales mensualmente.\n\n');

%% ============================================================
%% BLOQUE 7: SISTEMA SIMPLIFICADO 3x3 (para alumnos con dificultades)
%% ============================================================

fprintf('==========================================\n');
fprintf('BLOQUE 7: Version simplificada 3x3\n');
fprintf('==========================================\n\n');

%% Red simplificada: P1, P2, P3 --> D1, D2, D3
A_s = A(1:3, 1:3);
b_s = b_base(1:3);
cap_s = cap_max(1:3);
c_s   = c_tarifa(1:3);

fprintf('Sistema simplificado 3x3:\n');
fprintf('A_s =\n'); disp(A_s);
fprintf('b_s = '); disp(b_s');

x_s = A_s \ b_s;
fprintf('Solucion x_s = [%.2f, %.2f, %.2f] ton\n', x_s');
fprintf('Residuo: %.2e\n', norm(A_s*x_s - b_s));
fprintf('Costo: $%.2f/semana\n', c_s'*x_s);

%% Gauss-Jordan manual del sistema 3x3
fprintf('\nRREF del sistema 3x3:\n');
[R_s, piv_s] = rref([A_s, b_s]);
for i=1:3
    fprintf('  |');
    for j=1:3, fprintf(' %8.4f', R_s(i,j)); end
    fprintf(' | %8.4f |\n', R_s(i,4));
end
fprintf('Pivotes: columnas %s => Solucion unica\n\n', mat2str(piv_s));

%% ============================================================
%% BLOQUE 8: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 8: Visualizaciones ---\n');

figure('Name','Clase 7 --- Mini-caso 1 LogiSur','NumberTitle','off',...
       'Position',[30 30 1350 800]);

%% Subplot 1: Plan de despacho base
subplot(2,3,1);
bar(x_base,'FaceColor',[0 0.32 0.58]);
hold on;
bar_cap = bar(cap_max,'FaceColor','none','EdgeColor','r','LineWidth',2);
set(gca,'XTickLabel',{'P1','P2','P3','P4'});
ylabel('Toneladas');
title('Plan de despacho vs Capacidad');
legend({'Despacho','Cap. maxima'},'Location','northeast');
grid on;
for k=1:4
    text(k, x_base(k)+5, sprintf('%.0f t',x_base(k)),...
        'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end

%% Subplot 2: Verificacion de entregas
subplot(2,3,2);
entrega_plot = A * x_base;
x_idx = 1:5;
bar(x_idx, [entrega_plot, b_base]);
set(gca,'XTickLabel',{'D1','D2','D3','D4','D5'});
ylabel('Toneladas'); title('Entrega vs Demanda por CD');
legend({'Entregado (Ax)','Demanda (b)'},'Location','best');
grid on;

%% Subplot 3: Comparacion de escenarios
subplot(2,3,3);
bar_esc = X_esc';
bh = bar(1:3, bar_esc);
colores_p = {[0 0.32 0.58],[0 0.51 0.31],[0.86 0.37 0.07],[0.49 0 0.49]};
for k=1:4, bh(k).FaceColor = colores_p{k}; end
set(gca,'XTickLabel',{'Base','Alto +20%','Bajo -15%'});
ylabel('Toneladas'); title('Plan por escenario');
legend(plantas,'Location','northeast','FontSize',7);
hold on;
for k=1:4
    yline(cap_max(k),'--','Color',colores_p{k},'LineWidth',1,...
        'HandleVisibility','off');
end
grid on;

%% Subplot 4: Costos por escenario
subplot(2,3,4);
costos_esc = zeros(1,3);
for k=1:3, costos_esc(k) = c_tarifa' * X_esc(:,k); end
bar_c = bar(1:3, costos_esc, 'FaceColor','flat');
bar_c.CData = [0.2 0.6 0.9; 0.9 0.3 0.1; 0.2 0.8 0.3];
set(gca,'XTickLabel',{'Base','Alto +20%','Bajo -15%'});
ylabel('USD/semana'); title('Costo total por escenario');
grid on;
for k=1:3
    text(k, costos_esc(k)+100, sprintf('$%.0f',costos_esc(k)),...
        'HorizontalAlignment','center','FontWeight','bold','FontSize',9);
end

%% Subplot 5: Porcentaje de uso de capacidad
subplot(2,3,5);
uso_pct = x_base ./ cap_max * 100;
barh(uso_pct,'FaceColor',[0 0.51 0.31]);
set(gca,'YTickLabel',{'P1','P2','P3','P4'});
xlabel('% de capacidad utilizada');
title('Utilizacion de capacidad (base)');
xline(100,'r--','LineWidth',2,'DisplayName','Limite');
xline(80,'orange--','LineWidth',1.5,'DisplayName','Alerta 80%');
xlim([0 120]); grid on;
for k=1:4
    text(uso_pct(k)+1, k, sprintf('%.1f%%',uso_pct(k)),...
        'VerticalAlignment','middle','FontWeight','bold','FontSize',9);
end

%% Subplot 6: Desglose de costo por planta
subplot(2,3,6);
costo_planta = c_tarifa .* x_base;
pie(costo_planta, plantas);
title(sprintf('Desglose costo base ($%.0f total)',costo_base));
colormap(gca,'cool');

sgtitle('MATEMATICAS 2 --- Clase 7: Mini-caso 1 LogiSur S.A.',...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 9: PREGUNTAS PARA EL INFORME
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA EL INFORME (Mini-caso 1)\n');
fprintf('==========================================\n\n');
fprintf('1. Define A, x y b. ¿Por que A es 5x4 y no cuadrada?\n');
fprintf('   ¿Como afecta esto a la unicidad de la solucion?\n\n');
fprintf('2. ¿Que representa cada columna de A en logistica?\n');
fprintf('   ¿Y cada fila?\n\n');
fprintf('3. Calcula rang(A) y rang([A|b]). ¿Que concluyes?\n');
fprintf('   rang(A) = %d,  rang([A|b]) = %d\n\n', rA, rAb);
fprintf('4. ¿En que escenario de demanda el sistema es\n');
fprintf('   operativamente NO viable? ¿Por que?\n');
fprintf('   Respuesta: Escenario ALTO (+20%%): P1 supera capacidad.\n\n');
fprintf('5. Si la tarifa de P3 sube a $20/ton, ¿en cuanto\n');
fprintf('   aumenta el costo semanal total?\n');
fprintf('   Respuesta: +$%.2f/semana (de $%.2f a $%.2f)\n\n',...
    costo_nuevo-costo_base, costo_base, costo_nuevo);
fprintf('==========================================\n');
fprintf('Fin del script clase7_datos.m\n');
fprintf('Entregar informe antes de la Clase 8.\n');
fprintf('==========================================\n');

%% --- Funcion auxiliar ---
function s = yesNo(v)
    if v; s = 'VIABLE'; else; s = 'NO VIABLE'; end
end
