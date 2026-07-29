%% ============================================================
%%  MATEMATICAS 2 --- CLASE 12
%%  Script MATLAB: Grados de Libertad e Interpretacion Aplicada
%%  Archivo: clase12_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 12\n');
fprintf(' Grados de Libertad e Interpretacion\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: GRADOS DE LIBERTAD --- CALCULO Y CLASIFICACION
%% ============================================================

fprintf('--- BLOQUE 1: Grados de libertad ---\n\n');

%% Redes de ejemplo con distintos GDL
redes = {
    [0.5 0.3 0.2; 0.3 0.5 0.2; 0.2 0.2 0.6],   '3x3 rango 3 (0 gdl)';
    [0.5 0.3 0.2 0.0; 0.3 0.5 0.0 0.4; 0.2 0.2 0.8 0.6], '3x4 rango 3 (1 gdl)';
    [0.5 0.3 0.2 0.0 0.1; 0.3 0.5 0.0 0.4 0.2; 0.2 0.2 0.8 0.6 0.7], '3x5 rango 3 (2 gdl)';
    [0.5 0.3; 0.4 0.5; 0.1 0.2],                 '3x2 rango 2 (0 gdl, fat)';
};

fprintf('%-35s | n | r | gdl | Nul\n','Red');
fprintf('%s\n', repmat('-',1,60));
for k = 1:size(redes,1)
    Ak = redes{k,1}; desc = redes{k,2};
    n = size(Ak,2); r = rank(Ak); gdl = n - r;
    N = null(Ak,'r');
    fprintf('%-35s | %d | %d | %3d | dim=%d\n', desc, n, r, gdl, size(N,2));
end
fprintf('\n');

%% ============================================================
%% BLOQUE 2: OPTIMIZACION CON 1 GDL
%% ============================================================

fprintf('--- BLOQUE 2: Optimizacion con 1 GDL ---\n\n');

%% Red con 4 plantas, 3 CDs, rango 3 => 1 GDL
A1 = [0.5  0.2  0.3  0.0;
      0.3  0.6  0.0  0.4;
      0.2  0.2  0.7  0.6];

b1 = [200; 300; 100];
c1 = [8; 6; 12; 9];
cap1 = [800; 600; 500; 700];

fprintf('Red: %dx%d, rang=%d, gdl=%d\n', size(A1,1), size(A1,2), rank(A1), size(A1,2)-rank(A1));

%% Verificar compatibilidad
rA1  = rank(A1); rAb1 = rank([A1 b1]);
fprintf('Compatibilidad: rang(A)=%d, rang([A|b])=%d => %s\n\n',...
    rA1, rAb1, yesNo(rA1==rAb1));

%% Lazo cerrado
N1 = null(A1,'r');
fprintf('Lazo cerrado n1 = [%s]\n', num2str(N1','%.4f '));
fprintf('Verificacion ||A*n1|| = %.2e\n\n', norm(A1*N1));

%% Solucion particular
[R1, piv1] = rref([A1, b1]);
n1_vars = size(A1,2);
xp1 = zeros(n1_vars,1);
xp1(piv1(piv1<=n1_vars)) = R1(1:rA1, end);
fprintf('Solucion particular xp = [%s]\n', num2str(xp1','%.2f '));
fprintf('Verificacion ||A*xp-b|| = %.2e\n', norm(A1*xp1-b1));
fprintf('xp >= 0: %s\n', yesNo(all(xp1>=-1e-6)));
fprintf('Costo base: $%.2f\n\n', c1'*xp1);

%% Efecto del lazo sobre el costo
delta1 = c1' * N1;
fprintf('delta = c^T * n1 = %.4f\n', delta1);
if delta1 < 0
    fprintf('El lazo REDUCE el costo en $%.4f por unidad de t.\n', abs(delta1));
    fprintf('Conviene MAXIMIZAR t.\n\n');
else
    fprintf('El lazo AUMENTA el costo. Conviene MINIMIZAR t.\n\n');
end

%% Restricciones de factibilidad: xp + t*n1 >= 0
fprintf('Restricciones de factibilidad (xp + t*n1 >= 0):\n');
t_limites = zeros(n1_vars, 2); t_limites(:,:) = [-Inf, Inf];
for i = 1:n1_vars
    ni = N1(i);
    if abs(ni) > 1e-10
        t_lim = -xp1(i) / ni;
        if ni > 0
            t_limites(i,1) = t_lim;  % t >= t_lim
        else
            t_limites(i,2) = t_lim;  % t <= t_lim
        end
        fprintf('  x%d: %.2f + %.4f*t >= 0 => t %s %.4f\n',...
            i, xp1(i), ni, ternStr(ni>0,'>=','<='), t_lim);
    end
end

t_min = max(t_limites(:,1));
t_max = min(t_limites(:,2));
if isinf(t_min), t_min = 0; end
fprintf('\nRango factible: [%.4f, %.4f]\n', t_min, t_max);

%% Optimo
if delta1 < 0
    t_opt1 = t_max;
else
    t_opt1 = t_min;
end
x_opt1 = xp1 + t_opt1 * N1;
costo_opt1 = c1' * x_opt1;
costo_base1 = c1' * xp1;
fprintf('\n=== PLAN OPTIMO (t*=%.4f) ===\n', t_opt1);
for p = 1:n1_vars
    fprintf('  P%d: %.2f ton\n', p, x_opt1(p));
end
fprintf('Costo optimo: $%.2f\n', costo_opt1);
fprintf('Ahorro vs base: $%.2f (%.1f%%)\n\n',...
    costo_base1-costo_opt1, (costo_base1-costo_opt1)/costo_base1*100);

%% ============================================================
%% BLOQUE 3: PROTOCOLO COMPLETO CON 2 GDL
%% ============================================================

fprintf('--- BLOQUE 3: Red con 2 GDL ---\n\n');

%% Red 3x5, rango 3, 2 GDL
A2 = [0.4  0.2  0.3  0.1  0.0;
      0.3  0.5  0.0  0.2  0.4;
      0.3  0.3  0.7  0.7  0.6];

b2 = [240; 270; 240];
c2 = [10; 8; 14; 9; 7];
cap2 = [800; 600; 500; 700; 600];

[m2, n2] = size(A2);
r2 = rank(A2); k2 = n2 - r2;
fprintf('Red: %dx%d, rang=%d, gdl=%d\n', m2, n2, r2, k2);
fprintf('Compatibilidad: %s\n', yesNo(r2==rank([A2 b2])));

%% Lazos cerrados
N2 = null(A2,'r');
fprintf('\nBase de Nul(A):\n');
for j = 1:k2
    fprintf('  n%d = [%s]\n', j, num2str(N2(:,j)','%.4f '));
end

%% Solucion particular
[R2, piv2] = rref([A2, b2]);
xp2 = zeros(n2,1);
xp2(piv2(piv2<=n2)) = R2(1:r2, end);
fprintf('\nSol. particular xp = [%s]\n', num2str(xp2','%.2f '));
fprintf('Viable (xp>=0): %s\n', yesNo(all(xp2>=-1e-6)));
costo_base2 = c2' * xp2;
fprintf('Costo base: $%.2f\n\n', costo_base2);

%% Efecto de cada lazo
dc2 = c2' * N2;
fprintf('Efecto de lazos sobre costo:\n');
for j = 1:k2
    fprintf('  delta%d = c^T*n%d = %.4f => lazo %s costo\n',...
        j, j, dc2(j), ternStr(dc2(j)<0,'REDUCE','AUMENTA'));
end

%% Optimizacion en malla de (s,t)
fprintf('\nOptimizacion en malla de (s,t):\n');
s_range = linspace(0, 200, 50);
t_range = linspace(-100, 300, 50);
[S,T] = meshgrid(s_range, t_range);
C_mat = zeros(size(S));
fact  = false(size(S));
for i=1:numel(S)
    xk = xp2 + S(i)*N2(:,1) + T(i)*N2(:,2);
    fact(i) = all(xk >= -1e-6) && all(xk <= cap2+1e-6);
    C_mat(i) = c2' * max(xk,0);
end
C_mat(~fact) = NaN;

[C_min2, idx] = min(C_mat(:));
[i_opt, j_opt] = ind2sub(size(C_mat), idx);
s_opt = S(i_opt, j_opt); t_opt = T(i_opt, j_opt);
x_opt2 = xp2 + s_opt*N2(:,1) + t_opt*N2(:,2);
fprintf('  Optimo aproximado: s=%.1f, t=%.1f\n', s_opt, t_opt);
fprintf('  Plan optimo: [%s]\n', num2str(max(x_opt2,0)','%.1f '));
fprintf('  Costo optimo: $%.2f\n', C_min2);
fprintf('  Ahorro: $%.2f (%.1f%%)\n\n',...
    costo_base2-C_min2, (costo_base2-C_min2)/costo_base2*100);

%% ============================================================
%% BLOQUE 4: PROTOCOLO COMPLETO --- FUNCION analizar_red
%% ============================================================

fprintf('--- BLOQUE 4: Protocolo completo (funcion analizar_red) ---\n\n');

%% Aplicar protocolo a la red de 1 GDL
fprintf('>>> Aplicando protocolo a la red de 1 GDL:\n\n');
resultado1 = analizar_red(A1, b1, c1, cap1);

fprintf('\n>>> Aplicando protocolo a la red de 2 GDL:\n\n');
resultado2 = analizar_red(A2, b2, c2, cap2);

%% ============================================================
%% BLOQUE 5: DECISION DE EXPANSION DE RED
%% ============================================================

fprintf('\n--- BLOQUE 5: Decision de expansion ---\n\n');

%% Comparar redes con distinto numero de GDL
A_base = A1(:,1:3);  % 3x3, 0 gdl
b_base = b1; c_base = c1(1:3); cap_base = cap1(1:3);

% Expandir agregando plantas
A_1gdl = A1;           c_1gdl = c1; cap_1gdl = cap1;
A_2gdl = A2;           c_2gdl = c2; cap_2gdl = cap2;

costos = zeros(1,3);

%% Costo 0 GDL (solucion unica)
xp0 = A_base \ b_base;
if all(xp0 >= -1e-6)
    costos(1) = c_base' * xp0;
else
    costos(1) = Inf;
end

%% Costo 1 GDL (optimo calculado antes)
costos(2) = costo_opt1;

%% Costo 2 GDL (optimo calculado antes)
costos(3) = C_min2;

fprintf('Comparacion de redes por GDL:\n');
fprintf('%-15s | GDL | Costo opt. | Ahorro vs 0 GDL | Costo infra/sem\n','Red');
fprintf('%s\n', repmat('-',1,72));

costos_infra = [0, 200000/52, 380000/52];  % costo semanal de infraestructura
for k = 0:2
    ahorro = costos(1) - costos(k+1);
    costo_neto = costos_infra(k+1) - ahorro;
    fprintf('Red %d GDL       | %3d | $%9.0f | $%15.0f | $%14.0f\n',...
        k, k, costos(k+1), ahorro, costos_infra(k+1));
end

fprintf('\nAnalisis de recuperacion de inversion:\n');
inversiones = [0, 200000, 380000];
for k = 1:2
    ahorro_sem = costos(1) - costos(k+1);
    ahorro_anual = ahorro_sem * 52;
    if ahorro_anual > 0
        payback = inversiones(k+1) / ahorro_anual;
        fprintf('  %d GDL: inversion=$%,d, ahorro anual=$%.0f, payback=%.1f años\n',...
            k, inversiones(k+1), ahorro_anual, payback);
    end
end
fprintf('\n');

%% ============================================================
%% BLOQUE 6: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 6: Visualizaciones ---\n');

figure('Name','Clase 12 --- Grados de Libertad','NumberTitle','off',...
    'Position',[30 30 1350 800]);

%% Subplot 1: GDL de distintas redes
subplot(2,3,1);
gdl_redes = [0 1 2 3 4];
bar(gdl_redes,'FaceColor',[0 0.32 0.58]);
xlabel('Red'); ylabel('Grados de libertad');
title('GDL de distintas configuraciones de red');
set(gca,'XTickLabel',{'0 (r=n)','1','2','3','4'});
grid on;
for k=1:5
    text(k,gdl_redes(k)+0.05,num2str(gdl_redes(k)),...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 2: Costo en funcion de t (1 GDL)
subplot(2,3,2);
t_plot = linspace(t_min, t_max, 100);
costo_t = zeros(size(t_plot));
for k=1:length(t_plot)
    xt = xp1 + t_plot(k)*N1;
    costo_t(k) = c1' * xt;
end
plot(t_plot, costo_t,'b-','LineWidth',2);
hold on;
plot(t_opt1, costo_opt1,'r*','MarkerSize',14,'LineWidth',2,'DisplayName','Optimo');
xline(t_min,'g--','t_{min}'); xline(t_max,'g--','t_{max}');
xlabel('Parametro t'); ylabel('Costo (USD)');
title('Costo vs parametro t (1 GDL)');
legend({'Costo C(t)','Optimo'},'Location','best'); grid on;

%% Subplot 3: Region factible y costo en 2D (2 GDL)
subplot(2,3,3);
contourf(S, T, C_mat, 20); colorbar;
hold on;
plot(s_opt, t_opt,'r*','MarkerSize',14,'LineWidth',2,'DisplayName','Optimo');
xlabel('s (lazo n1)'); ylabel('t (lazo n2)');
title('Region factible y costo C(s,t) — 2 GDL');
legend({'Optimo'},'Location','best'); grid on;

%% Subplot 4: Comparacion plan base vs optimo (1 GDL)
subplot(2,3,4);
bar([xp1, x_opt1]);
set(gca,'XTickLabel',{'P1','P2','P3','P4'});
ylabel('Toneladas'); title('Plan base vs optimo (1 GDL)');
legend({'Base','Optimo'},'Location','best'); grid on;
hold on;
for p=1:4, yline(cap1(p),'r:','LineWidth',1); end

%% Subplot 5: Ahorro acumulado por GDL adicional
subplot(2,3,5);
gdl_vals = 0:2;
ahorro_vals = max(0, costos(1) - costos);
bar(gdl_vals, ahorro_vals,'FaceColor',[0 0.51 0.31]);
xlabel('Grados de libertad'); ylabel('Ahorro vs 0 GDL (USD/sem)');
title('Ahorro semanal por GDL adicional');
grid on;
for k=1:3
    text(gdl_vals(k), ahorro_vals(k)+5,...
        sprintf('$%.0f',ahorro_vals(k)),...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 6: Payback de la inversion
subplot(2,3,6);
payback_vals = [0, inversiones(2)/(max(0,costos(1)-costos(2))*52+1),...
                   inversiones(3)/(max(0,costos(1)-costos(3))*52+1)];
bar(0:2, payback_vals,'FaceColor',[0.49 0 0.49]);
xlabel('GDL adicionales'); ylabel('Años de recuperacion');
title('Payback de la inversion en GDL');
yline(5,'r--','5 anos'); yline(10,'r:','10 anos'); grid on;
for k=2:3
    if payback_vals(k) > 0 && payback_vals(k) < 50
        text(k-1, payback_vals(k)+0.2, sprintf('%.1f a',payback_vals(k)),...
            'HorizontalAlignment','center','FontWeight','bold','FontSize',9);
    end
end

sgtitle('MATEMATICAS 2 --- Clase 12: Grados de Libertad',...
    'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 7: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 12)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cuantos GDL tiene la red de 1 GDL (A1)?\n');
fprintf('   Respuesta: n=%d, r=%d => gdl=%d\n\n', size(A1,2), rank(A1), size(A1,2)-rank(A1));

fprintf('2. ¿Cuanto ahorra el plan optimo vs la solucion\n');
fprintf('   particular en la red de 1 GDL?\n');
fprintf('   Respuesta: $%.2f/semana (%.1f%%)\n\n',...
    costo_base1-costo_opt1, (costo_base1-costo_opt1)/costo_base1*100);

fprintf('3. ¿Por que el optimo con 1 GDL siempre esta\n');
fprintf('   en el extremo del intervalo factible?\n');
fprintf('   Respuesta: el costo C(t) = C0 + delta*t es LINEAL\n');
fprintf('   en t, por lo que su minimo sobre un intervalo\n');
fprintf('   siempre esta en un extremo.\n\n');

fprintf('4. Para la red de 2 GDL, ¿ambos lazos reducen el costo?\n');
fprintf('   delta1=%.4f => %s; delta2=%.4f => %s\n\n',...
    dc2(1), ternStr(dc2(1)<0,'SI','NO'),...
    dc2(2), ternStr(dc2(2)<0,'SI','NO'));

fprintf('5. ¿Conviene invertir $200.000 para agregar 1 GDL\n');
fprintf('   si el horizonte de decision es 5 anos?\n');
ahorro_anual_1 = (costos(1)-costos(2))*52;
payback_1 = 200000/ahorro_anual_1;
fprintf('   Ahorro anual: $%.0f. Payback: %.1f anos.\n', ahorro_anual_1, payback_1);
fprintf('   Respuesta: %s (payback %s 5 anos)\n\n',...
    ternStr(payback_1<=5,'SI CONVIENE','NO CONVIENE'),...
    ternStr(payback_1<=5,'<=','>'));
fprintf('==========================================\n');
fprintf('Fin del script clase12_datos.m\n');
fprintf('==========================================\n');

%% ============================================================
%%  FUNCIONES AUXILIARES
%% ============================================================

function resultado = analizar_red(A, b, c, cap)
    [m, n] = size(A);
    r = rank(A); k = n - r;
    resultado = struct('A',A,'b',b,'c',c,'r',r,'gdl',k);

    fprintf('Dimension: %dx%d | rang=%d | gdl=%d\n', m, n, r, k);

    %% Compatibilidad
    rAb = rank([A b]);
    if r < rAb
        fprintf('INCOMPATIBLE.\n'); return;
    end

    %% Lazos
    N = null(A,'r');
    resultado.N = N;

    %% Solucion particular
    [R, piv] = rref([A b]);
    xp = zeros(n,1);
    xp(piv(piv<=n)) = R(1:r, end);
    resultado.xp = xp;
    fprintf('Sol. particular viable: %s | Costo base: $%.2f\n',...
        yesNo(all(xp>=-1e-6)), c'*xp);

    %% Lazos y su efecto
    dc = c' * N;
    resultado.dc = dc;
    fprintf('Efecto lazos (c^T*N): [%s]\n', num2str(dc,'%.3f '));

    %% Optimizacion 1 GDL
    if k == 1
        n1 = N(:,1); delta = dc(1);
        t_limites = arrayfun(@(i) ternVal(n1(i)>1e-10,...
            -xp(i)/n1(i), inf), 1:n);
        t_limites_neg = arrayfun(@(i) ternVal(n1(i)<-1e-10,...
            -xp(i)/n1(i), -inf), 1:n);
        t_min_v = max([0; t_limites_neg']);
        t_max_v = min([inf; t_limites']);
        if delta < 0, t_opt = t_max_v; else, t_opt = t_min_v; end
        x_opt = xp + t_opt * n1;
        resultado.x_opt = x_opt;
        fprintf('Optimo (t*=%.2f): costo=$%.2f, ahorro=$%.2f\n',...
            t_opt, c'*x_opt, c'*xp - c'*x_opt);
    end
end

function v = ternVal(cond_v, a, b)
    if cond_v; v=a; else; v=b; end
end

function s = ternStr(v, a, b)
    if v; s=a; else; s=b; end
end

function s = yesNo(v)
    if v; s='SI'; else; s='NO'; end
end
