%% ============================================================
%%  MATEMATICAS 2 --- CLASE 6
%%  Script MATLAB: Gauss-Jordan y RREF
%%  Archivo: clase6_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar seccion a seccion con Ctrl+Enter
%%  o el script completo con F5.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 6\n');
fprintf(' Metodo de Gauss-Jordan y RREF\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: GAUSS-JORDAN VIA rref --- SISTEMA 3x3
%% ============================================================

fprintf('--- BLOQUE 1: Gauss-Jordan sistema 3x3 ---\n\n');

A3 = [2 4 2; 1 3 4; 3 7 2];
b3 = [12; 11; 17];

fprintf('Sistema:\n');
fprintf('A =\n'); disp(A3);
fprintf('b = '); disp(b3');

Aug3 = [A3, b3];

%% Paso a paso: fase adelante (Gauss)
fprintf('=== FASE ADELANTE (Gauss) ===\n');
Aug_fe = gauss_adelante(A3, b3);
fprintf('Forma escalonada (FE):\n');
imprime_aug(Aug_fe, 3);

%% Paso a paso: normalizacion
fprintf('=== NORMALIZACION (pivotes a 1) ===\n');
Aug_norm = Aug_fe;
for i = 1:3
    pivote_i = Aug_norm(i, i);
    if abs(pivote_i) > 1e-12
        Aug_norm(i,:) = Aug_norm(i,:) / pivote_i;
    end
end
imprime_aug(Aug_norm, 3);

%% Paso a paso: fase hacia atras
fprintf('=== FASE HACIA ATRAS ===\n');
Aug_rref = Aug_norm;
% Pivote col 3: eliminar en filas 1 y 2
for i = 1:2
    Aug_rref(i,:) = Aug_rref(i,:) - Aug_rref(i,3)*Aug_rref(3,:);
end
fprintf('Despues de eliminar col 3 hacia arriba:\n');
imprime_aug(Aug_rref, 3);
% Pivote col 2: eliminar en fila 1
Aug_rref(1,:) = Aug_rref(1,:) - Aug_rref(1,2)*Aug_rref(2,:);
fprintf('RREF final:\n');
imprime_aug(Aug_rref, 3);

%% Leer solucion directamente
x_gj = Aug_rref(:, end);
fprintf('Solucion leida de la ultima columna de la RREF:\n');
fprintf('  x1 = %.4f ton (Planta 1)\n', x_gj(1));
fprintf('  x2 = %.4f ton (Planta 2)\n', x_gj(2));
fprintf('  x3 = %.4f ton (Planta 3)\n', x_gj(3));
fprintf('Residuo: %.2e\n\n', norm(A3*x_gj - b3));

%% Verificar con rref de MATLAB
[R_matlab, pivots_matlab] = rref(Aug3);
fprintf('Verificacion con rref MATLAB:\n');
imprime_aug(R_matlab, 3);
fprintf('Diferencia max con resultado manual: %.2e\n\n', ...
    max(abs(Aug_rref(:) - R_matlab(:))));

%% ============================================================
%% BLOQUE 2: RREF CON VARIABLES LIBRES
%% ============================================================

fprintf('--- BLOQUE 2: RREF con variables libres ---\n\n');

A_lib = [1 2 0 1;
         2 4 1 3;
         0 0 1 1];
b_lib = [5; 11; 1];

Aug_lib = [A_lib, b_lib];
[R_lib, piv_lib] = rref(Aug_lib);

fprintf('Matriz aumentada original:\n');
imprime_aug(Aug_lib, 4);
fprintf('RREF:\n');
imprime_aug(R_lib, 4);

n_vars = size(A_lib, 2);
rA = rank(A_lib);
vars_libres = setdiff(1:n_vars, piv_lib(piv_lib <= n_vars));
vars_basicas = piv_lib(piv_lib <= n_vars);

fprintf('Columnas de pivote: %s\n', mat2str(vars_basicas));
fprintf('Variables basicas:  x%s\n', mat2str(vars_basicas));
fprintf('Variables libres:   x%s\n', mat2str(vars_libres));
fprintf('Grados de libertad: %d\n\n', n_vars - rA);

fprintf('Solucion general (s=x2, t=x4):\n');
fprintf('  x1 = 5 - 2s - t\n');
fprintf('  x2 = s  (libre)\n');
fprintf('  x3 = 1 - t\n');
fprintf('  x4 = t  (libre)\n\n');

%% Verificar para varios valores de (s,t)
fprintf('Verificacion para distintos (s,t):\n');
fprintf('%-8s %-8s | x=[x1 x2 x3 x4]      | Residuo\n','s','t');
fprintf('%s\n',repmat('-',1,55));
for s = [0, 1, 2]
    for t = [0, 0.5, 1]
        xv = [5-2*s-t; s; 1-t; t];
        res = norm(A_lib*xv - b_lib);
        fprintf('s=%-5g t=%-5g | [%-5.1f %-5.1f %-5.1f %-5.1f] | %.2e\n', ...
            s, t, xv', res);
    end
end
fprintf('\n');

%% ============================================================
%% BLOQUE 3: COMPARACION FE vs RREF
%% ============================================================

fprintf('--- BLOQUE 3: Comparacion FE vs RREF ---\n\n');

sistemas = {
    [1 2 1; 2 5 4; 1 3 4], [4; 9; 7],   '3x3 sol. unica';
    [1 2 0 1; 2 4 1 3; 0 0 1 1], [5; 11; 1], '3x4 var. libre';
    [1 2; 3 6], [5; 15], '2x2 infinitas';
    [1 2; 3 6], [5; 16], '2x2 incompatible';
};

fprintf('%-20s | FE pivotes | RREF | Tipo\n','Sistema');
fprintf('%s\n',repmat('-',1,65));
for k = 1:size(sistemas,1)
    Ak = sistemas{k,1}; bk = sistemas{k,2}; desc = sistemas{k,3};
    rA = rank(Ak); rAb = rank([Ak bk]); nv = size(Ak,2);
    [Rk,pv] = rref([Ak,bk]);
    if rA < rAb
        tipo = 'INCOMPATIBLE';
    elseif rA == nv
        tipo = 'UNICA';
    else
        tipo = sprintf('INFINITAS (%d libre)', nv-rA);
    end
    fprintf('%-20s | %10s | RREF | %s\n', desc, mat2str(pv(pv<=nv)), tipo);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 4: CASO LOGISTICO --- BALANCE DE RED 4x4
%% ============================================================

fprintf('--- BLOQUE 4: Caso logistico 4x4 ---\n\n');

plantas = {'P1 Mvd','P2 Salto','P3 Rivera','P4 Tacuarembo'};
CDs_4   = {'CD Norte','CD Sur','CD Este','CD Oeste'};

A4 = [1 1 0 1;
      1 2 1 0;
      0 1 2 1;
      1 0 1 2];
b4 = [5; 6; 7; 6];

fprintf('Red de distribucion 4x4:\n');
fprintf('A =\n'); disp(A4);
fprintf('b (demanda) = '); disp(b4');

[R4, piv4] = rref([A4, b4]);
fprintf('RREF del sistema:\n');
imprime_aug(R4, 4);

n4 = size(A4,2);
rA4 = rank(A4);
libres4 = setdiff(1:n4, piv4(piv4<=n4));

if rank(A4) < rank([A4 b4])
    fprintf('Sistema: INCOMPATIBLE\n\n');
elseif isempty(libres4)
    x4 = R4(:, end);
    fprintf('Sistema: SOLUCION UNICA\n');
    fprintf('Plan de despacho:\n');
    for k=1:4, fprintf('  %s: %.4f ton\n', plantas{k}, x4(k)); end
    fprintf('Residuo: %.2e\n\n', norm(A4*x4 - b4));
else
    fprintf('Sistema: INFINITAS SOLUCIONES\n');
    fprintf('Variables libres: x%s\n', mat2str(libres4));

    %% Optimizacion: minimizar costo con c = (3,5,4,2)
    c4 = [3; 5; 4; 2];
    fprintf('\nOptimizacion de costo (c = [%s] USD/ton):\n', ...
        num2str(c4'));

    %% Generar solucion particular y vectores de la familia
    xp = R4(1:rA4, end);   % solucion particular (vars. libres = 0)
    fprintf('Solucion particular (vars. libres = 0):\n');
    disp(xp')
end
fprintf('\n');

%% ============================================================
%% BLOQUE 5: EFICIENCIA --- rref vs A\b vs inv
%% ============================================================

fprintf('--- BLOQUE 5: Comparacion de eficiencia ---\n\n');

n_vals = [10, 30, 50, 100, 200];
t_rref = zeros(size(n_vals));
t_back = zeros(size(n_vals));
t_inv  = zeros(size(n_vals));
reps   = 5;

fprintf('%-6s | %-14s | %-14s | %-14s\n','n','rref (ms)','A\\b (ms)','inv(A)*b (ms)');
fprintf('%s\n',repmat('-',1,58));

for k = 1:length(n_vals)
    n   = n_vals(k);
    Ak  = rand(n) + n*eye(n);
    bk  = rand(n,1);
    Abk = [Ak, bk];

    t1 = tic; for r=1:reps, rref(Abk);  end; t_rref(k)=toc(t1)/reps*1000;
    t2 = tic; for r=1:reps, Ak\bk;      end; t_back(k)=toc(t2)/reps*1000;
    t3 = tic; for r=1:reps, inv(Ak)*bk; end; t_inv(k) =toc(t3)/reps*1000;

    fprintf('%-6d | %-14.3f | %-14.3f | %-14.3f\n', ...
        n, t_rref(k), t_back(k), t_inv(k));
end
fprintf('\nConclusion: A\\b es el mas rapido; rref provee mas informacion estructural.\n\n');

%% ============================================================
%% BLOQUE 6: ANTICIPO DE INVERSA CON GAUSS-JORDAN
%% ============================================================

fprintf('--- BLOQUE 6: Anticipo Clase 11 --- Inversa con RREF ---\n\n');

A_inv = [2 1; 5 3];
I2    = eye(2);

[R_inv, ~] = rref([A_inv, I2]);
A_inv_calc  = R_inv(:, 3:4);

fprintf('Matriz A:\n'); disp(A_inv);
fprintf('rref([A | I2]):\n'); disp(R_inv);
fprintf('Inversa calculada (parte derecha):\n'); disp(A_inv_calc);
fprintf('Verificacion A * A^-1 (debe ser I):\n');
disp(A_inv * A_inv_calc);
fprintf('Diferencia con inv(A):\n');
disp(A_inv_calc - inv(A_inv));

%% Ejemplo 3x3
A_3 = [1 2 0; 0 1 1; 1 1 2];
I3  = eye(3);
[R3_inv, ~] = rref([A_3, I3]);
A3_inv = R3_inv(:, 4:6);
fprintf('\nInversa de A 3x3 calculada con rref:\n'); disp(A3_inv);
fprintf('Verificacion max(|A*A^-1 - I|) = %.2e\n\n', ...
    max(max(abs(A_3*A3_inv - I3))));

%% ============================================================
%% BLOQUE 7: GAUSS-JORDAN IMPLEMENTADO MANUALMENTE
%% ============================================================

fprintf('--- BLOQUE 7: Gauss-Jordan manual vs rref ---\n\n');

A_test = [3 1 2; 1 4 -1; 2 1 3];
b_test = [14; 8; 11];

[R_man, piv_man] = gauss_jordan_manual(A_test, b_test);
[R_ref, piv_ref] = rref([A_test, b_test]);

fprintf('GJ manual:\n'); imprime_aug(R_man, 3);
fprintf('rref MATLAB:\n'); imprime_aug(R_ref, 3);
fprintf('Diferencia maxima: %.2e\n', max(abs(R_man(:)-R_ref(:))));
fprintf('Pivotes GJ manual: %s\n', mat2str(piv_man));
fprintf('Pivotes rref:      %s\n\n', mat2str(piv_ref));

%% ============================================================
%% BLOQUE 8: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 8: Visualizaciones ---\n');

figure('Name','Clase 6 --- Gauss-Jordan y RREF','NumberTitle','off',...
       'Position',[50 50 1300 750]);

%% Subplot 1: FE vs RREF heatmap
subplot(2,3,1);
Aug_fe_plot = gauss_adelante(A3, b3);
imagesc([Aug_fe_plot; nan(1,4); Aug_rref], [-5 15]);
colormap(gca,'cool'); colorbar;
yticks([1 2 3 5 6 7]);
yticklabels({'F1','F2','F3','','F1','F2','F3'});
xlabel('Columna'); title('FE (filas 1-3) vs RREF (filas 5-7)');
grid on;

%% Subplot 2: Solucion del sistema 3x3
subplot(2,3,2);
bar(x_gj,'FaceColor',[0 0.32 0.58]);
set(gca,'XTickLabel',{'Planta 1','Planta 2','Planta 3'});
ylabel('Toneladas'); title('Solucion leida de la RREF');
grid on;
for k=1:3
    text(k, x_gj(k)+0.03, sprintf('%.2f',x_gj(k)), ...
        'HorizontalAlignment','center','FontWeight','bold');
end

%% Subplot 3: Region factible (variables libres)
subplot(2,3,3);
s_r = 0:0.05:2.5; t_r = 0:0.05:1;
[S,T] = meshgrid(s_r, t_r);
X1=5-2*S-T; X2=S; X3=1-T; X4=T;
fact = (X1>=0)&(X2>=0)&(X3>=0)&(X4>=0);
% Costo ilustrativo: c=(3,5,4,2)
Costo = 3*X1+5*X2+4*X3+2*X4;
Costo(~fact) = NaN;
contourf(S,T,Costo,15); colorbar;
hold on;
xlabel('s (x2)'); ylabel('t (x4)');
title('Region factible y costo C(s,t)');
grid on;

%% Subplot 4: Eficiencia comparada
subplot(2,3,4);
semilogy(n_vals, t_rref,'b-o','LineWidth',2,'DisplayName','rref');
hold on;
semilogy(n_vals, t_back,'r-s','LineWidth',2,'DisplayName','A\b');
semilogy(n_vals, t_inv, 'g-^','LineWidth',2,'DisplayName','inv(A)*b');
xlabel('Tamano n'); ylabel('Tiempo (ms, log)');
title('Eficiencia: rref vs A\b vs inv');
legend('Location','best'); grid on;

%% Subplot 5: Verificacion de la inversa
subplot(2,3,5);
prod_check = A_inv * A_inv_calc;
imagesc(prod_check);
colormap(gca,'gray'); colorbar;
set(gca,'XTick',1:2,'YTick',1:2);
title('A * A^{-1}: debe ser identidad');
for r=1:2, for c=1:2
    text(c,r,sprintf('%.4f',prod_check(r,c)),...
        'HorizontalAlignment','center','Color','white','FontWeight','bold');
end; end

%% Subplot 6: Clasificacion visual de sistemas
subplot(2,3,6);
etiquetas = {'Unico','Infinitas','Incomp.'};
colores_s  = {[0.2 0.7 0.3],[0.2 0.5 0.9],[0.9 0.2 0.2]};
y_pos = [0.85, 0.55, 0.25];
desc_s = {
    'rang(A)=rang([A|b])=n => Sol. UNICA';
    'rang(A)=rang([A|b])<n => INFINITAS';
    'rang(A)<rang([A|b])   => INCOMPATIBLE'
};
for k=1:3
    text(0.5, y_pos(k), desc_s{k}, 'HorizontalAlignment','center', ...
        'Color',colores_s{k},'FontSize',10,'FontWeight','bold',...
        'Units','normalized');
end
axis off; title('Clasificacion desde la RREF');

sgtitle('MATEMATICAS 2 --- Clase 6: Gauss-Jordan y RREF', ...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 9: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 6)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cuantas operaciones adicionales hace Gauss-Jordan\n');
fprintf('   sobre Gauss para un sistema 3x3? (cuenta los pasos\n');
fprintf('   de normalizacion y eliminacion hacia atras)\n');
fprintf('   Respuesta: 3 norm. + 3 elim. atras = 6 pasos extra\n\n');

fprintf('2. Para el sistema con variables libres (Bloque 2),\n');
fprintf('   ¿cuantas soluciones tiene con x1>=0, x3>=0?\n');
fprintf('   Calcula el rango de la region factible.\n');
fprintf('   Respuesta: infinitas (region 2D en espacio de s,t)\n\n');

fprintf('3. En el caso logistico 4x4 (Bloque 4),\n');
fprintf('   ¿el sistema tiene solucion unica o hay variables libres?\n');
fprintf('   Respuesta: rang(A)=%d, n=%d => ', rank(A4), size(A4,2));
if rank(A4)==size(A4,2)
    fprintf('Solucion UNICA\n\n');
else
    fprintf('%d variables libres\n\n', size(A4,2)-rank(A4));
end

fprintf('4. Verifica que A_inv * A_inv_calc = I2 en Bloque 6.\n');
fprintf('   Max(|A*A^-1 - I|) = %.2e\n\n', ...
    max(max(abs(A_inv*A_inv_calc - eye(2)))));

fprintf('5. ¿Que diferencia encuentras entre la RREF del sistema\n');
fprintf('   con sol. unica y el con variables libres?\n');
fprintf('   Respuesta: sol. unica -> RREF es [I|x*]; var. libre -> \n');
fprintf('   RREF tiene columnas sin pivote en la parte de A.\n\n');
fprintf('==========================================\n');
fprintf('Fin del script clase6_datos.m\n');
fprintf('==========================================\n');

%% ============================================================
%%  FUNCIONES AUXILIARES
%% ============================================================

function Aug_out = gauss_adelante(A, b)
    n   = length(b);
    Aug = [double(A), double(b)];
    for k = 1:n-1
        for i = k+1:n
            if abs(Aug(k,k)) < 1e-12, break; end
            m = Aug(i,k)/Aug(k,k);
            Aug(i,:) = Aug(i,:) - m*Aug(k,:);
        end
    end
    Aug_out = Aug;
end

function imprime_aug(Aug, n)
    [m,~] = size(Aug);
    for i = 1:m
        fprintf('  |');
        for j=1:n, fprintf(' %8.4f', Aug(i,j)); end
        fprintf(' | %8.4f |\n', Aug(i,n+1));
    end
    fprintf('\n');
end

function [R, pivots] = gauss_jordan_manual(A, b)
    m = size(A,1); n = size(A,2);
    Aug = [double(A), double(b)];
    pivots = []; r = 0;
    for j = 1:n
        k = 0;
        for i = r+1:m
            if abs(Aug(i,j)) > 1e-12, k=i; break; end
        end
        if k==0, continue; end
        r = r+1;
        if k~=r, Aug([r,k],:) = Aug([k,r],:); end
        Aug(r,:) = Aug(r,:)/Aug(r,j);
        pivots(end+1) = j; %#ok
        for i = 1:m
            if i~=r && abs(Aug(i,j))>1e-12
                Aug(i,:) = Aug(i,:) - Aug(i,j)*Aug(r,:);
            end
        end
    end
    R = Aug;
end
