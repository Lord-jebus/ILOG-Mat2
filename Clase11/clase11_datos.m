%% ============================================================
%%  MATEMATICAS 2 --- CLASE 11
%%  Script MATLAB: Determinante, Inversa y Estabilidad Numerica
%%  Archivo: clase11_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 11\n');
fprintf(' Determinante, Inversa y Condicionamiento\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: DETERMINANTE --- CALCULO Y PROPIEDADES
%% ============================================================

fprintf('--- BLOQUE 1: Determinante ---\n\n');

%% Matrices de ejemplo logistico
A_2x2 = [0.6  0.4;
          0.4  0.6];

A_3x3 = [0.5  0.3  0.2;
          0.3  0.5  0.2;
          0.2  0.2  0.6];

A_sing = [0.5  0.5;
          0.5  0.5];   % singular: dos filas iguales

%% Determinantes
fprintf('det(A_2x2) = %.6f\n', det(A_2x2));
fprintf('det(A_3x3) = %.6f\n', det(A_3x3));
fprintf('det(A_sing) = %.6f\n\n', det(A_sing));

%% Clasificacion
matrices_d = {A_2x2,'A_2x2'; A_3x3,'A_3x3'; A_sing,'A_sing'};
for k = 1:3
    Ak = matrices_d{k,1};
    dk = det(Ak);
    if abs(dk) > 1e-10
        tipo = 'INVERTIBLE';
    else
        tipo = 'SINGULAR (no invertible)';
    end
    fprintf('%s: det=%.6f => %s\n', matrices_d{k,2}, dk, tipo);
end
fprintf('\n');

%% Propiedades del determinante
fprintf('=== Propiedades ===\n');
B = [1 0; 2 1];
fprintf('det(A_2x2)=%.4f, det(B)=%.4f\n', det(A_2x2), det(B));
fprintf('det(A_2x2 * B) = %.4f (debe = %.4f)\n',...
    det(A_2x2*B), det(A_2x2)*det(B));
fprintf('det(A_2x2^T) = %.4f (debe = det(A_2x2))\n\n', det(A_2x2'));

%% Determinante manual 2x2
a = A_2x2(1,1); b = A_2x2(1,2);
c = A_2x2(2,1); d = A_2x2(2,2);
det_manual = a*d - b*c;
fprintf('Calculo manual: a*d - b*c = %.2f*%.2f - %.2f*%.2f = %.4f\n',...
    a, d, b, c, det_manual);
fprintf('Coincide con det(A): %s\n\n', yesNo(abs(det_manual-det(A_2x2))<1e-10));

%% ============================================================
%% BLOQUE 2: INVERSA --- CALCULO Y VERIFICACION
%% ============================================================

fprintf('--- BLOQUE 2: Inversa de matrices ---\n\n');

%% Inversa 2x2 por formula
d2 = det(A_2x2);
A_inv_2x2_manual = (1/d2) * [A_2x2(2,2), -A_2x2(1,2);
                              -A_2x2(2,1),  A_2x2(1,1)];
fprintf('Inversa de A_2x2 (formula manual):\n'); disp(A_inv_2x2_manual);

%% Comparar con inv() de MATLAB
A_inv_2x2_ml = inv(A_2x2);
fprintf('Inversa de A_2x2 (inv MATLAB):\n'); disp(A_inv_2x2_ml);
fprintf('Diferencia ||manual - MATLAB||: %.2e\n\n',...
    norm(A_inv_2x2_manual - A_inv_2x2_ml,'fro'));

%% Verificacion A * A^-1 = I
residuo_inv2 = norm(A_2x2 * A_inv_2x2_ml - eye(2), 'fro');
fprintf('||A_2x2 * A_2x2^-1 - I||_F = %.2e\n\n', residuo_inv2);

%% Inversa 3x3 con Gauss-Jordan
fprintf('=== Inversa 3x3 via Gauss-Jordan ===\n');
n3 = size(A_3x3,1);
[R3, ~] = rref([A_3x3, eye(n3)]);
A_inv_3x3_rref = R3(:, n3+1:end);

fprintf('Inversa de A_3x3 (Gauss-Jordan):\n'); disp(A_inv_3x3_rref);

A_inv_3x3_ml = inv(A_3x3);
fprintf('Inversa de A_3x3 (inv MATLAB):\n'); disp(A_inv_3x3_ml);
fprintf('Diferencia: %.2e\n', norm(A_inv_3x3_rref - A_inv_3x3_ml,'fro'));
fprintf('||A_3x3 * A_3x3^-1 - I||_F = %.2e\n\n',...
    norm(A_3x3*A_inv_3x3_ml - eye(3),'fro'));

%% Intentar inversa de matriz singular
fprintf('=== Intento de inversa de matriz singular ===\n');
try
    A_inv_sing = inv(A_sing);
    fprintf('inv(A_sing):\n'); disp(A_inv_sing);
    fprintf('Advertencia: los elementos pueden ser Inf o muy grandes.\n');
catch ME
    fprintf('Error: %s\n', ME.message);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 3: NUMERO DE CONDICION
%% ============================================================

fprintf('--- BLOQUE 3: Numero de condicion ---\n\n');

%% Condicion de distintas matrices
matrices_c = {
    eye(3),                          'I (identidad)';
    A_2x2,                           'A_2x2 logistica';
    A_3x3,                           'A_3x3 logistica';
    [1 1; 1 1.0001],                 'Casi singular 2x2';
    diag([1, 1e-6, 1]),              'Diagonal mal cond.';
};

fprintf('%-30s | cond (norma 2) | Estado\n','Matriz');
fprintf('%s\n', repmat('-',1,65));
for k = 1:size(matrices_c,1)
    Ak   = matrices_c{k,1};
    desc = matrices_c{k,2};
    ck   = cond(Ak);
    if ck < 100
        estado = 'CONFIABLE';
    elseif ck < 1e4
        estado = 'Aceptable';
    elseif ck < 1e8
        estado = 'DUDOSO';
    else
        estado = 'PELIGROSO';
    end
    fprintf('%-30s | %14.4f | %s\n', desc, ck, estado);
end
fprintf('\n');

%% Relacion entre det y cond (no directa)
fprintf('Relacion det vs cond:\n');
fprintf('  det(I3) = %.0f,  cond(I3) = %.2f\n', det(eye(3)), cond(eye(3)));
fprintf('  det(10*I3) = %.0f,  cond(10*I3) = %.2f\n',...
    det(10*eye(3)), cond(10*eye(3)));
fprintf('  => escalar la matriz no cambia cond, pero si det\n\n');

%% Evolucion del condicionamiento al acercarse a singularidad
fprintf('Evolucion del cond al aproximarse a singularidad:\n');
fprintf('%-12s | det(A) | cond(A)\n','epsilon');
fprintf('%s\n', repmat('-',1,40));
for eps = [0.1, 0.01, 0.001, 1e-4, 1e-6, 0]
    A_e = [1 1; 1 1+eps];
    if eps == 0
        ck = Inf;
    else
        ck = cond(A_e);
    end
    fprintf('eps=%-8.0e | %6.4f | %8.2f\n', eps, det(A_e), ck);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 4: USOS DE LA INVERSA EN LOGISTICA
%% ============================================================

fprintf('--- BLOQUE 4: Usos practicos de A^-1 ---\n\n');

%% Planificacion rapida para multiples demandas
Ainv = A_inv_3x3_ml;
demandas = {[300;200;150],[350;180;200],[280;220;130]};
desc_dem  = {'Semana 1','Semana 2','Semana 3'};
c_tarifa  = [8;12;15];

fprintf('Planificacion via A^-1 (sin resolver nuevo sistema cada vez):\n');
fprintf('%-12s | %-10s %-10s %-10s | Costo ($)\n','Semana','P1','P2','P3');
fprintf('%s\n', repmat('-',1,65));
for k = 1:3
    bk = demandas{k};
    xk = Ainv * bk;
    ck = c_tarifa' * xk;
    fprintf('%-12s | %10.2f %10.2f %10.2f | %9.2f\n',...
        desc_dem{k}, xk(1), xk(2), xk(3), ck);
end
fprintf('\n');

%% Analisis de sensibilidad
fprintf('=== Analisis de sensibilidad ===\n');
b0  = [300;200;150];
x0  = Ainv * b0;
fprintf('Plan base: x = [%.2f  %.2f  %.2f]\n', x0');
fprintf('Costo base: $%.2f\n\n', c_tarifa'*x0);

perturbaciones = {[10;0;0],'CD1 +10t'; [0;10;0],'CD2 +10t'; [0;0;10],'CD3 +10t'};
fprintf('%-12s | dx1     dx2     dx3   | dCosto\n','Perturbacion');
fprintf('%s\n', repmat('-',1,58));
for k = 1:3
    db  = perturbaciones{k,1};
    dx  = Ainv * db;
    dck = c_tarifa' * dx;
    fprintf('%-12s | %7.4f %7.4f %7.4f | %7.2f\n',...
        perturbaciones{k,2}, dx(1), dx(2), dx(3), dck);
end
fprintf('\n');
fprintf('(Cada fila de A^-1 mide el impacto en cada planta de una unidad de demanda)\n\n');

%% ============================================================
%% BLOQUE 5: DIAGNOSTICO DE CONFIABILIDAD
%% ============================================================

fprintf('--- BLOQUE 5: Diagnostico de confiabilidad ---\n\n');

%% Escenario 1: Red bien condicionada
A_buena = A_3x3;
b_test  = [300;200;150];
x_buena = A_buena \ b_test;
perturb = 0.01;   % 1% de error en la demanda
db_rand = perturb * b_test .* (2*rand(3,1)-1);  % perturbacion aleatoria 1%
dx_buena = A_buena \ db_rand;

fprintf('=== Red BIEN condicionada (cond=%.1f) ===\n', cond(A_buena));
fprintf('Perturbacion de demanda (1%%): [%.2f  %.2f  %.2f]\n', db_rand');
fprintf('Cambio en el plan:           [%.2f  %.2f  %.2f]\n', dx_buena');
fprintf('Amplificacion relativa: %.1fx (cond=%d)\n\n',...
    norm(dx_buena)/norm(x_buena) / (norm(db_rand)/norm(b_test)),...
    round(cond(A_buena)));

%% Escenario 2: Red mal condicionada
A_mala = [0.5 0.501 0.2; 0.3 0.299 0.2; 0.2 0.2 0.6];
x_mala = A_mala \ b_test;
dx_mala = A_mala \ db_rand;

fprintf('=== Red MAL condicionada (cond=%.0f) ===\n', cond(A_mala));
fprintf('Perturbacion de demanda (1%%): [%.2f  %.2f  %.2f]\n', db_rand');
fprintf('Cambio en el plan:           [%.2f  %.2f  %.2f]\n', dx_mala');
fprintf('Amplificacion relativa: %.1fx\n\n',...
    norm(dx_mala)/norm(x_mala) / (norm(db_rand)/norm(b_test)));

%% Tabla de diagnostico
fprintf('=== Tabla de diagnostico de confiabilidad ===\n');
redes_diag = {
    A_3x3,              'Red logistica A (3x3)';
    A_2x2,              'Red logistica B (2x2)';
    A_mala,             'Red C (casi singular)';
    eye(3),             'Red ideal (I)';
    A_sing,             'Red singular';
};
fprintf('%-25s | det      | cond     | Estado\n','Red');
fprintf('%s\n', repmat('-',1,65));
for k = 1:size(redes_diag,1)
    Ak   = redes_diag{k,1};
    desc = redes_diag{k,2};
    dk   = det(Ak);
    if abs(dk) < 1e-10
        ck = Inf; estado = 'INVALIDA';
    else
        ck = cond(Ak);
        if ck < 10,    estado = 'CONFIABLE';
        elseif ck < 1e3, estado = 'Aceptable';
        else,            estado = 'DUDOSA'; end
    end
    fprintf('%-25s | %8.4f | %8.2f | %s\n', desc, dk, ck, estado);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 6: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 6: Visualizaciones ---\n');

figure('Name','Clase 11 --- Determinante, Inversa y Condicion',...
       'NumberTitle','off','Position',[30 30 1350 800]);

%% Subplot 1: Heatmap de A y A^-1
subplot(2,3,1);
imagesc([A_3x3; nan(1,3); A_inv_3x3_ml]);
colorbar; colormap(gca,'cool');
yticks([1 2 3 5 6 7]);
yticklabels({'A(1,:)','A(2,:)','A(3,:)','','A^{-1}(1,:)','A^{-1}(2,:)','A^{-1}(3,:)'});
title('A (filas 1-3) y A^{-1} (filas 5-7)');
xlabel('Columna');

%% Subplot 2: Verificacion A*A^-1 = I
subplot(2,3,2);
prod_check = A_3x3 * A_inv_3x3_ml;
imagesc(prod_check); colorbar; colormap(gca,'gray');
set(gca,'XTick',1:3,'YTick',1:3);
title('A * A^{-1} (debe ser identidad)');
for r=1:3; for c=1:3
    text(c,r,sprintf('%.4f',prod_check(r,c)),...
        'HorizontalAlignment','center','Color','white','FontWeight','bold','FontSize',8);
end; end

%% Subplot 3: Evolucion del condicionamiento
subplot(2,3,3);
eps_vals = logspace(-6,0,50);
cond_vals = arrayfun(@(e) cond([1 1; 1 1+e]), eps_vals);
semilogx(eps_vals, cond_vals,'b-','LineWidth',2);
xlabel('epsilon'); ylabel('cond(A)');
title('Condicionamiento vs. proximidad a singularidad');
grid on;
yline(100,'r--','Dudoso','LineWidth',1.5);
yline(10000,'r:','Peligroso','LineWidth',1.5);

%% Subplot 4: Amplificacion del error
subplot(2,3,4);
cond_redes = [cond(A_3x3), cond(A_2x2), cond(A_mala), cond(eye(3))];
bar(cond_redes,'FaceColor','flat');
set(gca,'XTickLabel',{'Red A','Red B','Red C','Ideal'});
ylabel('Numero de condicion'); title('Condicion de distintas redes');
set(gca,'YScale','log'); grid on;
for k=1:4
    text(k, cond_redes(k)*1.2, sprintf('%.1f',cond_redes(k)),...
        'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end

%% Subplot 5: Sensibilidad del plan
subplot(2,3,5);
perturbaciones_pct = linspace(0, 5, 50);  % 0% a 5% de error
dx_buena_norm = zeros(size(perturbaciones_pct));
dx_mala_norm  = zeros(size(perturbaciones_pct));
for k = 1:length(perturbaciones_pct)
    db_k = (perturbaciones_pct(k)/100) * b_test;
    dx_buena_norm(k) = norm(A_buena\db_k) / norm(A_buena\b_test) * 100;
    dx_mala_norm(k)  = norm(A_mala\db_k)  / norm(A_mala\b_test)  * 100;
end
plot(perturbaciones_pct, dx_buena_norm,'b-','LineWidth',2,'DisplayName','Red A (bien cond.)');
hold on;
plot(perturbaciones_pct, dx_mala_norm,'r--','LineWidth',2,'DisplayName','Red C (mal cond.)');
plot(perturbaciones_pct, perturbaciones_pct,'k:','LineWidth',1,'DisplayName','Sin amplificacion');
xlabel('Error en demanda (%)'); ylabel('Error en plan (%)');
title('Amplificacion del error segun condicionamiento');
legend('Location','northwest'); grid on;

%% Subplot 6: Planificacion via A^-1
subplot(2,3,6);
X_planif = Ainv * [demandas{1}, demandas{2}, demandas{3}];
bar(X_planif');
set(gca,'XTickLabel',desc_dem);
ylabel('Toneladas');
title('Plan via A^{-1}: rapida planificacion multi-semana');
legend({'P1','P2','P3'},'Location','best'); grid on;

sgtitle('MATEMATICAS 2 --- Clase 11: Det, Inversa y Condicion',...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 7: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 11)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cual es det(A_3x3) de la red logistica principal?\n');
fprintf('   Respuesta: det = %.6f\n\n', det(A_3x3));

fprintf('2. ¿Es A_3x3 invertible? ¿Como lo verificas?\n');
fprintf('   det != 0: %s => INVERTIBLE\n\n', yesNo(abs(det(A_3x3))>1e-10));

fprintf('3. Calcula cond(A_3x3). ¿Es el modelo confiable?\n');
fprintf('   cond(A_3x3) = %.4f => %s\n\n', cond(A_3x3),...
    clasificar_cond(cond(A_3x3)));

fprintf('4. Si la demanda de CD2 sube en 10 ton, ¿cuanto\n');
fprintf('   cambia el plan de cada planta?\n');
db4 = [0;10;0];
dx4 = A_inv_3x3_ml * db4;
fprintf('   dx = A^-1 * [0;10;0] = [%.4f  %.4f  %.4f]\n\n', dx4');

fprintf('5. ¿Cual es ||A_3x3 * A_3x3^-1 - I||_F?\n');
fprintf('   Respuesta: %.2e (debe ser ~0)\n\n',...
    norm(A_3x3*A_inv_3x3_ml - eye(3),'fro'));

fprintf('==========================================\n');
fprintf('Fin del script clase11_datos.m\n');
fprintf('==========================================\n');

%% --- Funciones auxiliares ------------------------------------
function s = yesNo(v)
    if v; s = 'SI'; else; s = 'NO'; end
end

function s = clasificar_cond(c)
    if c < 10
        s = 'CONFIABLE';
    elseif c < 1e3
        s = 'Aceptable';
    elseif c < 1e6
        s = 'DUDOSO';
    else
        s = 'PELIGROSO';
    end
end
