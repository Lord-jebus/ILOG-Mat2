%% ============================================================
%%  MATEMATICAS 2 --- CLASE 8
%%  Script MATLAB: Rango de una Matriz y Clasificacion de Sistemas
%%  Archivo: clase8_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 8\n');
fprintf(' Rango de una Matriz y Clasificacion\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: CALCULO BASICO DEL RANGO
%% ============================================================

fprintf('--- BLOQUE 1: Calculo del rango ---\n\n');

%% Matrices de ejemplo
A1 = [1 2 3; 4 5 6; 7 8 9];      % Rango 2
A2 = [2 4 0 8; 1 2 1 5;
      3 6 1 13; 0 0 2 4];        % Rango 3 (del ejemplo de clase)
A3 = [1 0; 0 1; 1 1];            % Rango 2 (full column rank)
A4 = [2 4; 1 2];                  % Rango 1

matrices = {A1, A2, A3, A4};
nombres  = {'A1 (3x3)','A2 (4x4)','A3 (3x2)','A4 (2x2)'};

fprintf('%-12s | rang | min(m,n) | Full rank?\n','Matriz');
fprintf('%s\n', repmat('-',1,50));
for k = 1:4
    Ak = matrices{k};
    r  = rank(Ak);
    mn = min(size(Ak));
    fprintf('%-12s | %4d | %8d | %s\n', nombres{k}, r, mn, yesNo(r==mn));
end
fprintf('\n');

%% Calculo manual del rango por FE
fprintf('Calculo manual de rang(A1) via eliminacion Gaussiana:\n');
A1_fe = gauss_fe(A1);
fprintf('Forma escalonada de A1:\n'); disp(A1_fe);
filas_no_nulas = sum(any(abs(A1_fe) > 1e-10, 2));
fprintf('Filas no nulas: %d => rang(A1) = %d\n\n', filas_no_nulas, filas_no_nulas);

%% ============================================================
%% BLOQUE 2: TEOREMA DE ROUCHE-FROBENIUS
%% ============================================================

fprintf('--- BLOQUE 2: Clasificacion de sistemas ---\n\n');

%% Misma A, distintos b
A = [1 2 1; 2 4 3; 1 2 0];
b_casos = {
    [4; 9; 3],  'b1=(4,9,3)  : posiblemente compatible';
    [4; 9; 4],  'b2=(4,9,4)  : posiblemente incompatible';
    [2; 4; 1],  'b3=(2,4,1)  : verificar';
    [0; 0; 0],  'b4=(0,0,0)  : homogeneo (siempre compatible)';
};

fprintf('rang(A) = %d, n = %d\n\n', rank(A), size(A,2));
fprintf('%-40s | rA | rAb | Clasificacion\n','Sistema');
fprintf('%s\n', repmat('-',1,75));
for k = 1:4
    bk   = b_casos{k,1};
    desc = b_casos{k,2};
    rA   = rank(A);
    rAb  = rank([A, bk]);
    n    = size(A,2);
    tipo = clasificar_tipo(rA, rAb, n);
    fprintf('%-40s | %2d | %3d | %s\n', desc, rA, rAb, tipo);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 3: RANGO Y RUTAS REDUNDANTES
%% ============================================================

fprintf('--- BLOQUE 3: Rutas redundantes en red logistica ---\n\n');

%% Red con posible redundancia
A_red = [0.6  0.3  0.9;
         0.4  0.5  0.6;   % Col3 = Col1 + Col2 (0.9, 0.6, 0.0)? No exactamente
         0.0  0.2  0.0];

% Verificar: ¿col3 = c1*col1 + c2*col2?
% 0.9 = 0.6*c1 + 0.3*c2
% 0.6 = 0.4*c1 + 0.5*c2
% 0.0 = 0.0*c1 + 0.2*c2  => c2=0
% Entonces: 0.9 = 0.6*c1 => c1=1.5; 0.6=0.4*1.5=0.6 OK; 0.0=0 OK
% Col3 = 1.5*Col1 (¡Col3 es multiplo de Col1!)

fprintf('Matriz de red A_red:\n'); disp(A_red);
fprintf('rang(A_red) = %d (esperado < 3)\n', rank(A_red));

%% Encontrar columnas de pivote
[R_red, piv_red] = rref(A_red);
fprintf('Columnas de pivote (rutas esenciales): %s\n', mat2str(piv_red));
n_red = size(A_red,2);
dep_red = setdiff(1:n_red, piv_red);
fprintf('Columnas dependientes (rutas redundantes): %s\n\n', mat2str(dep_red));

%% Verificar relacion de dependencia
fprintf('Verificacion: Col3 = %.4f * Col1 ?\n', A_red(1,3)/A_red(1,1));
residuo_dep = A_red(:,3) - (A_red(1,3)/A_red(1,1))*A_red(:,1);
fprintf('Residuo (debe ser ~0): %.2e\n\n', norm(residuo_dep));

%% Red SIN redundancia
A_ok = [0.5  0.3  0.2;
        0.3  0.5  0.1;
        0.2  0.2  0.7];
fprintf('Red sin redundancia A_ok:\n'); disp(A_ok);
fprintf('rang(A_ok) = %d (igual a n=3: sin redundancia)\n\n', rank(A_ok));

%% ============================================================
%% BLOQUE 4: NUMERO DE VARIABLES LIBRES
%% ============================================================

fprintf('--- BLOQUE 4: Variables libres ---\n\n');

casos_vl = {
    [1 2 3 4; 0 1 2 3; 1 3 5 7; 2 3 5 7], [4;9;11;13], 'Sistema 4x4 rango 3';
    [2 4 0 8; 1 2 1 5; 3 6 1 13; 0 0 2 4],[8;5;13;4],  'Sistema 4x4 rango 3 (ej. clase)';
    [1 0 2 1; 0 1 -1 2; 1 1 1 3],          [3;1;4],     'Sistema 3x4 rango 2';
};

fprintf('%-35s | n | r | libres | Tipo\n','Sistema');
fprintf('%s\n', repmat('-',1,72));
for k = 1:3
    Ak = casos_vl{k,1}; bk = casos_vl{k,2}; desc = casos_vl{k,3};
    n = size(Ak,2); rA = rank(Ak); rAb = rank([Ak bk]);
    libres = n - rA;
    tipo   = clasificar_tipo(rA, rAb, n);
    fprintf('%-35s | %d | %d | %6d | %s\n', desc, n, rA, libres, tipo);
end
fprintf('\n');

%% Solucion general del caso 3
fprintf('Solucion general del Caso 3 (sistema 3x4 rango 2):\n');
A3_c = casos_vl{3,1}; b3_c = casos_vl{3,2};
[R3, piv3] = rref([A3_c, b3_c]);
fprintf('RREF:\n'); disp(R3);
vars_basicas = piv3(piv3 <= size(A3_c,2));
vars_libres  = setdiff(1:size(A3_c,2), vars_basicas);
fprintf('Variables basicas: x%s\n', mat2str(vars_basicas));
fprintf('Variables libres:  x%s\n\n', mat2str(vars_libres));

%% ============================================================
%% BLOQUE 5: ANALISIS DE UNA RED LOGISTICA COMPLETA
%% ============================================================

fprintf('--- BLOQUE 5: Analisis de red logistica ---\n\n');

%% Red del mini-caso 1 (Clase 7)
A_mc = [0.50 0.00 0.00 0.30;
        0.00 0.40 0.30 0.00;
        0.20 0.00 0.00 0.10;
        0.00 0.35 0.00 0.40;
        0.00 0.00 0.50 0.00];
b_mc = [320; 280; 130; 255; 150];

fprintf('=== Red del Mini-caso 1 (5x4) ===\n');
fprintf('rang(A) = %d\n', rank(A_mc));
fprintf('rang([A|b]) = %d\n', rank([A_mc, b_mc]));
fprintf('Tipo: %s\n\n', clasificar_tipo(rank(A_mc), rank([A_mc,b_mc]), size(A_mc,2)));

%% ¿Hay ecuaciones redundantes en el sistema?
fprintf('Analisis de ecuaciones (filas) independientes:\n');
fprintf('Rango de A = %d < m = %d\n', rank(A_mc), size(A_mc,1));
fprintf('=> Hay %d ecuacion(es) de balance redundante(s).\n\n', ...
    size(A_mc,1) - rank(A_mc));

%% Matrices de distintos tamanios: rango y variables libres
fprintf('Patron: n - rang(A) = variables libres\n');
fprintf('%-8s %-6s %-6s %-8s\n','m x n','rang','n','libres (si compat.)');
fprintf('%s\n', repmat('-',1,35));
casos_r = {A_mc, 'A_mc (5x4)';
           A3_c, 'A (3x4)';
           A_ok,  'A_ok (3x3)'};
for k = 1:3
    Ack = casos_r{k,1};
    nk  = size(Ack,2); rk = rank(Ack);
    fprintf('%-14s %4d    %2d    %4d\n', casos_r{k,2}, rk, nk, nk-rk);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 6: PROPIEDADES DEL RANGO
%% ============================================================

fprintf('--- BLOQUE 6: Propiedades del rango ---\n\n');

rng(42);
A_p = rand(4,3) + eye(4,3);
B_p = rand(3,5);

r_A  = rank(A_p);
r_AT = rank(A_p');
r_AB = rank(A_p * B_p);
r_kA = rank(3.7 * A_p);

fprintf('rang(A)   = %d\n', r_A);
fprintf('rang(A^T) = %d  (debe ser igual a rang(A))\n', r_AT);
fprintf('rang(A) == rang(A^T): %s\n\n', yesNo(r_A == r_AT));

fprintf('rang(AB) = %d\n', r_AB);
fprintf('min(rang(A),rang(B)) = %d\n', min(r_A, rank(B_p)));
fprintf('rang(AB) <= min: %s\n\n', yesNo(r_AB <= min(r_A, rank(B_p))));

fprintf('rang(3.7*A) = %d  (invariante bajo escalar no nulo)\n', r_kA);
fprintf('rang(kA) == rang(A): %s\n\n', yesNo(r_kA == r_A));

%% Rango de matrices especiales
fprintf('Rangos de matrices especiales:\n');
fprintf('  I4: %d\n', rank(eye(4)));
fprintf('  O4: %d\n', rank(zeros(4)));
u = [1;2;3]; v = [4;5;6];
fprintf('  u*v^T (rango 1): %d\n', rank(u*v'));
fprintf('  diag(1,0,3,0): %d\n', rank(diag([1 0 3 0])));

%% ============================================================
%% BLOQUE 7: DECISION --- UNICA VS MULTIPLES SOLUCIONES
%% ============================================================

fprintf('\n--- BLOQUE 7: Decision operativa ---\n\n');

%% Red A: solucion unica (rango maximo)
A_redA = [0.7 0.3; 0.3 0.7];
b_redA = [420; 280];
x_redA = A_redA \ b_redA;
costo_redA = [8;12]' * x_redA;

%% Red B: infinitas soluciones (rango deficiente)
A_redB = [1 2 0 1; 2 4 1 3; 0 0 1 1];
b_redB = [5; 11; 1];
c_redB = [3; 5; 4; 2];  % costos

[R_B, piv_B] = rref([A_redB, b_redB]);
n_B  = size(A_redB,2);
r_B  = rank(A_redB);
libres_B = setdiff(1:n_B, piv_B(piv_B<=n_B));
fprintf('Red A: rang=%d, n=2, variables libres=%d => UNICA\n', rank(A_redA), 0);
fprintf('  Plan: x1=%.2f, x2=%.2f ton\n', x_redA(1), x_redA(2));
fprintf('  Costo: $%.2f/semana\n\n', costo_redA);

fprintf('Red B: rang=%d, n=4, variables libres=%d => INFINITAS\n', r_B, n_B-r_B);
fprintf('  Variables libres: x%s\n', mat2str(libres_B));
fprintf('  Solucion general (s=x2, t=x4):\n');
fprintf('    x1 = 5 - 2s - t\n');
fprintf('    x3 = 1 - t\n\n');

%% Optimizar sobre la familia de soluciones de Red B
%% Costo = 3(5-2s-t) + 5s + 4(1-t) + 2t = 19 - s - 3t
%% Minimizar: maximizar s y t (con restricciones x_i >= 0)
%% x1>=0: 2s+t<=5; x3>=0: t<=1; s>=0; t>=0
fprintf('Funcion de costo Red B: C(s,t) = 19 - s - 3t\n');
fprintf('Para minimizar: maximizar s y t.\n');
fprintf('Region factible: s>=0, t>=0, t<=1, 2s+t<=5\n\n');

vertices = [0 0; 2.5 0; 2 1; 0 1];
fprintf('%-8s %-8s %-12s %-20s\n','s','t','Costo','Plan x');
fprintf('%s\n', repmat('-',1,55));
for k = 1:size(vertices,1)
    s = vertices(k,1); t = vertices(k,2);
    x_v = [5-2*s-t; s; 1-t; t];
    C_v = c_redB' * x_v;
    fprintf('%-8.1f %-8.1f %-12.1f [%.1f %.1f %.1f %.1f]\n',...
        s, t, C_v, x_v');
end
fprintf('\n=> Optimo: (s=2,t=1), Costo=$12/semana, x=[0,2,0,1]\n\n');

%% ============================================================
%% BLOQUE 8: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 8: Visualizaciones ---\n');

figure('Name','Clase 8 --- Rango y Clasificacion','NumberTitle','off',...
       'Position',[30 30 1350 800]);

%% Subplot 1: Rango de distintas matrices
subplot(2,3,1);
ms = [A1; nan(1,3); A2(1:3,:); nan(1,4); A3; nan(1,2); A4];
nombres_vis = {'A1 (r=2)','','A2 (r=3)','','A3 (r=2)','','A4 (r=1)'};
rangos_vis  = [rank(A1), rank(A2), rank(A3), rank(A4)];
bar(rangos_vis,'FaceColor',[0 0.32 0.58]);
set(gca,'XTickLabel',{'A1 3x3','A2 4x4','A3 3x2','A4 2x2'});
ylabel('Rango'); title('Rango de distintas matrices');
hold on;
plot(1:4, min([3 4 2 2],[3 4 2 2]),'r--','LineWidth',1.5,'DisplayName','min(m,n)');
legend('Location','best'); grid on;

%% Subplot 2: Clasificacion de sistemas (misma A, distintos b)
subplot(2,3,2);
rA_plot  = rank(A)*ones(1,4);
rAb_plot = arrayfun(@(k) rank([A, b_casos{k,1}]), 1:4);
bar_c = bar([rA_plot; rAb_plot]');
bar_c(1).FaceColor = [0 0.32 0.58];
bar_c(2).FaceColor = [0.86 0.37 0.07];
set(gca,'XTickLabel',{'b1','b2','b3','b4 (hom.)'});
ylabel('Rango'); title('rang(A) vs rang([A|b])');
legend({'rang(A)','rang([A|b])'},'Location','best');
grid on;

%% Subplot 3: Variables libres vs rango
subplot(2,3,3);
n_vals_vl = [3 4 5 6 4 4];
r_vals_vl = [3 4 5 6 3 2];
libres_vl  = n_vals_vl - r_vals_vl;
bar(libres_vl,'FaceColor',[0 0.51 0.31]);
xlabel('Caso'); ylabel('Variables libres (n - r)');
title('Variables libres por configuracion');
xticks(1:6);
xticklabels({'n=r=3','n=r=4','n=r=5','n=r=6','n=4,r=3','n=4,r=2'});
xtickangle(30); grid on;
for k=1:6
    text(k, libres_vl(k)+0.05, num2str(libres_vl(k)),...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 4: Patron de la red redundante
subplot(2,3,4);
imagesc(A_red); colorbar; colormap(gca,'cool');
title(sprintf('Red con ruta redundante (rang=%d)',rank(A_red)));
xlabel('Planta (columna)'); ylabel('CD (fila)');
set(gca,'XTick',1:3,'XTickLabel',{'P1','P2','P3 (redund.)'});
set(gca,'YTick',1:3,'YTickLabel',{'D1','D2','D3'});
for r=1:3; for c=1:3
    text(c,r,sprintf('%.1f',A_red(r,c)),'HorizontalAlignment','center',...
        'FontWeight','bold','Color','white');
end; end

%% Subplot 5: Region factible y costo de Red B
subplot(2,3,5);
s_r = 0:0.05:2.5; t_r = 0:0.05:1;
[S,T] = meshgrid(s_r, t_r);
X1=5-2*S-T; X2=S; X3=1-T; X4=T;
fact = (X1>=0)&(X2>=0)&(X3>=0)&(X4>=0);
Costo_B = 19 - S - 3*T;
Costo_B(~fact) = NaN;
contourf(S,T,Costo_B,15); colorbar;
hold on;
plot(2,1,'r*','MarkerSize',14,'LineWidth',2,'DisplayName','Optimo (12)');
xlabel('s (x2)'); ylabel('t (x4)');
title('Region factible y costo C(s,t) --- Red B');
legend('Location','best'); grid on;

%% Subplot 6: Rango del mini-caso vs escenarios
subplot(2,3,6);
b_escenarios = {b_mc, 1.2*b_mc, 0.85*b_mc, b_mc+[50;0;0;0;0]};
esc_desc = {'Base','Alto','Bajo','b mod.'};
r_esc    = arrayfun(@(k) rank([A_mc, b_escenarios{k}]), 1:4);
bar(r_esc,'FaceColor',[0.49 0 0.49]);
yline(rank(A_mc),'r--','LineWidth',2,'DisplayName','rang(A)=4');
set(gca,'XTickLabel',esc_desc);
ylabel('rang([A|b])');
title('Compatibilidad por escenario (Mini-caso 1)');
legend('Location','best'); grid on;
for k=1:4
    comp = yesNo(r_esc(k)==rank(A_mc));
    text(k, r_esc(k)+0.05, comp,'HorizontalAlignment','center',...
        'FontWeight','bold','FontSize',9,...
        'Color', [0 0.5 0]*strcmp(comp,'SI') + [0.8 0 0]*(1-strcmp(comp,'SI')));
end

sgtitle('MATEMATICAS 2 --- Clase 8: Rango y Clasificacion',...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 9: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 8)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cual es el rango de la matriz A1=[1 2 3; 4 5 6; 7 8 9]?\n');
fprintf('   Respuesta: rang(A1) = %d\n\n', rank(A1));

fprintf('2. Para A=[1 2 1; 2 4 3; 1 2 0] y b=[4;9;3],\n');
fprintf('   ¿cuantas variables libres tiene el sistema?\n');
fprintf('   Respuesta: n - rang(A) = %d - %d = %d variable(s) libre(s)\n\n',...
    size(A,2), rank(A), size(A,2)-rank(A));

fprintf('3. ¿La red con A_red (3x3) tiene rutas redundantes?\n');
fprintf('   Respuesta: rang(A_red)=%d < n=%d => %s\n\n',...
    rank(A_red), size(A_red,2), yesNo(rank(A_red)<size(A_red,2)));

fprintf('4. Para la Red B con variables libres (s,t),\n');
fprintf('   ¿en que vertice del dominio factible se minimiza el costo?\n');
fprintf('   Respuesta: (s=2, t=1) => Costo = $12/semana\n\n');

fprintf('5. En el Mini-caso 1, ¿hay ecuaciones redundantes en el sistema?\n');
fprintf('   Respuesta: rang(A)=%d < m=%d => %d ecuacion(es) redundante(s)\n\n',...
    rank(A_mc), size(A_mc,1), size(A_mc,1)-rank(A_mc));
fprintf('==========================================\n');
fprintf('Fin del script clase8_datos.m\n');
fprintf('==========================================\n');

%% ============================================================
%%  FUNCIONES AUXILIARES
%% ============================================================

function tipo = clasificar_tipo(rA, rAb, n)
    if rA < rAb
        tipo = 'INCOMPATIBLE';
    elseif rA == n
        tipo = 'SOLUCION UNICA';
    else
        tipo = sprintf('INFINITAS (%d libres)', n-rA);
    end
end

function Aug = gauss_fe(A)
    [m,n] = size(A);
    Aug   = double(A);
    r     = 0;
    for j = 1:n
        k = 0;
        for i = r+1:m
            if abs(Aug(i,j)) > 1e-12, k=i; break; end
        end
        if k==0, continue; end
        r = r+1;
        if k~=r, Aug([r,k],:) = Aug([k,r],:); end
        for i = r+1:m
            if abs(Aug(r,j)) > 1e-12
                Aug(i,:) = Aug(i,:) - (Aug(i,j)/Aug(r,j))*Aug(r,:);
            end
        end
    end
end

function s = yesNo(v)
    if v; s = 'SI'; else; s = 'NO'; end
end
