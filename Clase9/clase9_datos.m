%% ============================================================
%%  MATEMATICAS 2 --- CLASE 9
%%  Script MATLAB: Sistemas Homogeneos y Espacio Nulo
%%  Archivo: clase9_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 9\n');
fprintf(' Sistemas Homogeneos y Espacio Nulo\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: SISTEMA HOMOGENEO --- EJEMPLO PRINCIPAL
%% ============================================================

fprintf('--- BLOQUE 1: Sistema homogeneo A*x = 0 ---\n\n');

A = [1 2 1; 2 4 3; 1 2 0];
fprintf('Matriz A:\n'); disp(A);
fprintf('rang(A) = %d,  n = %d\n', rank(A), size(A,2));
fprintf('dim(Nul(A)) = n - rang = %d\n\n', size(A,2)-rank(A));

%% Metodo 1: RREF de A (no de [A|0], son equivalentes)
fprintf('=== RREF de A ===\n');
[R, piv] = rref(A);
disp(R);
n = size(A,2);
vars_libres  = setdiff(1:n, piv);
vars_basicas = piv;
fprintf('Columnas pivote (variables basicas): x%s\n', mat2str(vars_basicas));
fprintf('Variables libres: x%s\n\n', mat2str(vars_libres));

%% Construir base del Nul(A) manualmente desde RREF
%% Para x2=1 (libre): x1 = -R(1,2)*1 = -2; x3 = -R(2,2)*1 = 0
fprintf('=== Construccion manual de la base de Nul(A) ===\n');
n1 = zeros(n,1);
n1(vars_libres(1)) = 1;
for k = 1:length(vars_basicas)
    n1(vars_basicas(k)) = -R(k, vars_libres(1));
end
fprintf('Vector base n1 (x2=1): [%.4f  %.4f  %.4f]\n', n1');

%% Verificacion: A*n1 debe ser 0
fprintf('Verificacion A*n1: [%.2e  %.2e  %.2e]\n', (A*n1)');
fprintf('||A*n1|| = %.2e\n\n', norm(A*n1));

%% Metodo 2: null(A) de MATLAB
fprintf('=== null(A) de MATLAB (base ortonormal) ===\n');
N_ort = null(A);
fprintf('Columnas de null(A):\n'); disp(N_ort);
fprintf('||A*null(A)|| = %.2e\n', norm(A*N_ort));
fprintf('dim(Nul(A)) = %d\n\n', size(N_ort,2));

%% Metodo 3: null(A,'r') --- base racional
N_rat = null(A,'r');
fprintf('=== null(A,r) --- base racional ===\n');
disp(N_rat);
fprintf('Coincide con n1 manual: %s\n\n', yesNo(norm(N_rat - n1) < 1e-10));

%% ============================================================
%% BLOQUE 2: SISTEMA CON MULTIPLES LAZOS CERRADOS
%% ============================================================

fprintf('--- BLOQUE 2: Sistema con 2 variables libres ---\n\n');

A2 = [1 0 2 1; 0 1 1 -1; 1 1 3 0];
fprintf('Matriz A2:\n'); disp(A2);
fprintf('rang(A2) = %d,  n = %d\n', rank(A2), size(A2,2));
fprintf('dim(Nul(A2)) = %d (2 lazos cerrados independientes)\n\n', ...
    size(A2,2)-rank(A2));

[R2, piv2] = rref(A2);
fprintf('RREF de A2:\n'); disp(R2);

n2 = size(A2,2);
libres2 = setdiff(1:n2, piv2);
fprintf('Variables libres: x%s\n\n', mat2str(libres2));

%% Construir los dos vectores base
N2 = zeros(n2, 2);
for col = 1:2
    N2(libres2(col), col) = 1;
    for k = 1:rank(A2)
        N2(piv2(k), col) = -R2(k, libres2(col));
    end
end
fprintf('Vector base n1 (x3=1, x4=0): [%s]\n', num2str(N2(:,1)','%.4f '));
fprintf('Vector base n2 (x3=0, x4=1): [%s]\n', num2str(N2(:,2)','%.4f '));

%% Verificacion
fprintf('\nVerificacion:\n');
fprintf('||A2*n1|| = %.2e\n', norm(A2*N2(:,1)));
fprintf('||A2*n2|| = %.2e\n', norm(A2*N2(:,2)));

%% Son linealmente independientes?
fprintf('n1 y n2 son linealmente independientes: %s\n\n', ...
    yesNo(rank([N2(:,1), N2(:,2)]) == 2));

%% ============================================================
%% BLOQUE 3: SOLUCION GENERAL DE A*x=b USANDO ESPACIO NULO
%% ============================================================

fprintf('--- BLOQUE 3: Sol. general A*x=b con Nul(A) ---\n\n');

b2 = [3; 1; 4];
fprintf('Sistema A2*x = b2, b2 = [%s]\n', num2str(b2','%.0f '));

%% Solucion particular (vars. libres = 0)
[R2b, piv2b] = rref([A2, b2]);
xp = zeros(n2, 1);
for k = 1:rank(A2)
    xp(piv2b(k)) = R2b(k, end);
end
fprintf('\nSolucion particular xp (x3=0, x4=0):\n');
fprintf('  xp = [%.4f  %.4f  %.4f  %.4f]\n', xp');
fprintf('  A2*xp - b2 = [%.2e  %.2e  %.2e]\n', (A2*xp-b2)');
fprintf('  ||A2*xp-b2|| = %.2e\n\n', norm(A2*xp-b2));

%% Verificar con A2\b2
xp_ml = A2 \ b2;
fprintf('Solucion con A2\\b2: [%s]\n', num2str(xp_ml','%.4f '));
fprintf('||A2*(A2\\b2)-b2|| = %.2e\n\n', norm(A2*xp_ml-b2));

%% Familia de soluciones
fprintf('Solucion general:\n');
fprintf('  x = xp + s*n1 + t*n2, s,t en R\n\n');

%% Verificar algunos elementos de la familia
fprintf('Verificacion de la familia (deben tener residuo ~0):\n');
params = [0 0; 1 0; 0 1; 2 -1; -1 3];
for k = 1:size(params,1)
    s = params(k,1); t = params(k,2);
    x_fam = xp + s*N2(:,1) + t*N2(:,2);
    res = norm(A2*x_fam - b2);
    fprintf('  s=%2d, t=%2d: x=[%s] | res=%.2e\n',...
        s, t, num2str(x_fam','%6.2f'), res);
end
fprintf('\n');

%% ============================================================
%% BLOQUE 4: OPTIMIZACION SOBRE LAZOS CERRADOS
%% ============================================================

fprintf('--- BLOQUE 4: Optimizacion mediante lazos ---\n\n');

%% Costos por planta/ruta
c2 = [8; 12; 15; 10];  % USD/ton
fprintf('Vector de costos c = [%s] USD/ton\n', num2str(c2','%.0f '));

%% Costo de la solucion particular
costo_xp = c2' * xp;
fprintf('Costo solucion particular xp: $%.2f\n', costo_xp);

%% Efecto de cada lazo sobre el costo
dc1 = c2' * N2(:,1);
dc2 = c2' * N2(:,2);
fprintf('Efecto lazo n1 en el costo: c^T*n1 = %.2f USD por unidad de s\n', dc1);
fprintf('Efecto lazo n2 en el costo: c^T*n2 = %.2f USD por unidad de t\n\n', dc2);

if dc1 < 0
    fprintf('El lazo n1 REDUCE el costo. Conviene aumentar s.\n');
elseif dc1 > 0
    fprintf('El lazo n1 AUMENTA el costo. Conviene disminuir s.\n');
else
    fprintf('El lazo n1 NO afecta el costo.\n');
end
if dc2 < 0
    fprintf('El lazo n2 REDUCE el costo. Conviene aumentar t.\n');
elseif dc2 > 0
    fprintf('El lazo n2 AUMENTA el costo. Conviene disminuir t.\n');
else
    fprintf('El lazo n2 NO afecta el costo.\n');
end
fprintf('\n');

%% Restricciones de no negatividad y region factible
fprintf('Restricciones de no negatividad (x = xp + s*n1 + t*n2 >= 0):\n');
for k = 1:n2
    if abs(N2(k,1)) > 1e-12 || abs(N2(k,2)) > 1e-12
        fprintf('  x%d = %.4f + s*(%.4f) + t*(%.4f) >= 0\n',...
            k, xp(k), N2(k,1), N2(k,2));
    end
end
fprintf('\n(Ver Bloque 7 para analisis grafico de la region factible)\n\n');

%% ============================================================
%% BLOQUE 5: PROPIEDADES DEL ESPACIO NULO
%% ============================================================

fprintf('--- BLOQUE 5: Propiedades algebraicas ---\n\n');

%% Cierre bajo suma
u = N2(:,1); v = N2(:,2);
fprintf('u = n1, v = n2 (ambos en Nul(A2))\n');
fprintf('||A2*(u+v)|| = %.2e (debe ser ~0)\n', norm(A2*(u+v)));
fprintf('||A2*(3u-2v)|| = %.2e (debe ser ~0)\n', norm(A2*(3*u-2*v)));

%% Cierre bajo escalar
fprintf('||A2*(5*u)|| = %.2e (debe ser ~0)\n\n', norm(A2*(5*u)));

%% Ortogonalidad nulo-espacio fila
fprintf('Ortogonalidad Nul(A2) _|_ Fila(A2):\n');
for i = 1:2
    for j = 1:size(A2,1)
        dp = dot(N2(:,i), A2(j,:)');
        fprintf('  n%d . fila%d(A2) = %.6f\n', i, j, dp);
    end
end
fprintf('\n');

%% Teorema rango-nulidad
fprintf('Teorema rango-nulidad:\n');
fprintf('  rang(A2) + dim(Nul(A2)) = %d + %d = %d = n\n\n',...
    rank(A2), size(A2,2)-rank(A2), size(A2,2));

%% ============================================================
%% BLOQUE 6: EJEMPLOS DE DISTINTAS DIMENSIONES DEL NULO
%% ============================================================

fprintf('--- BLOQUE 6: Espacio nulo de diversas matrices ---\n\n');

matrices_ej = {
    eye(3),                'Identidad 3x3',        '0 (solo sol trivial)';
    zeros(3),              'Nula 3x3',              '3 (todo R^3)';
    [1 2 3; 2 4 6],        'Rango 1 (2x3)',         '2';
    [1 0;0 1;1 1],         'Full col rank (3x2)',   '0';
    [1 2 3;4 5 6;7 8 9],   'Rango 2 (3x3)',         '1';
};

fprintf('%-25s | rang | n | dim(Nul)\n','Matriz');
fprintf('%s\n', repmat('-',1,50));
for k = 1:size(matrices_ej,1)
    Ak = matrices_ej{k,1};
    rk = rank(Ak); nk = size(Ak,2);
    fprintf('%-25s | %4d | %d | %d (esp: %s)\n',...
        matrices_ej{k,2}, rk, nk, nk-rk, matrices_ej{k,3});
end
fprintf('\n');

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 9 --- Sistemas Homogeneos y Lazos Cerrados',...
       'NumberTitle','off','Position',[30 30 1350 800]);

%% Subplot 1: Espacio nulo en R^3 (cuando dim=1)
subplot(2,3,1);
A_vis = [1 1 1];  % plano x1+x2+x3=0 es el Nul(A_vis)
N_vis = null(A_vis);
t_range = linspace(-2,2,20);
% Generar puntos del plano nulo: combinaciones de los dos vectores de Nul
[S,T] = meshgrid(t_range, t_range);
P1 = N_vis(1,1)*S + N_vis(1,2)*T;
P2 = N_vis(2,1)*S + N_vis(2,2)*T;
P3 = N_vis(3,1)*S + N_vis(3,2)*T;
surf(P1,P2,P3,'FaceAlpha',0.3,'FaceColor',[0 0.5 0.8],'EdgeColor','none');
hold on;
% Graficar los vectores base
quiver3(0,0,0,N_vis(1,1),N_vis(2,1),N_vis(3,1),'r','LineWidth',2,'MaxHeadSize',0.5);
quiver3(0,0,0,N_vis(1,2),N_vis(2,2),N_vis(3,2),'g','LineWidth',2,'MaxHeadSize',0.5);
xlabel('x1'); ylabel('x2'); zlabel('x3');
title('Nul(A) para A=[1 1 1]: plano en R^3');
grid on; axis equal;

%% Subplot 2: Estructura de la solucion A*x=b
subplot(2,3,2);
% Mostrar solucion particular y el espacio nulo
t_fam = linspace(-3,3,100);
x_fam = zeros(3,length(t_fam));
for k=1:length(t_fam), x_fam(:,k) = xp(1:3) + t_fam(k)*n1; end
plot3(x_fam(1,:),x_fam(2,:),x_fam(3,:),'b-','LineWidth',2,'DisplayName','xp + t*n1');
hold on;
plot3(xp(1),xp(2),xp(3),'ro','MarkerSize',10,'LineWidth',2,'DisplayName','xp (particular)');
plot3(0,0,0,'gs','MarkerSize',10,'LineWidth',2,'DisplayName','origen');
xlabel('x1'); ylabel('x2'); zlabel('x3');
title('Sol. general = xp + Nul(A)');
legend('Location','best'); grid on;

%% Subplot 3: Verificacion de la familia (residuos)
subplot(2,3,3);
s_test = -2:0.5:2; t_test = -2:0.5:2;
residuos_fam = zeros(length(s_test), length(t_test));
for i=1:length(s_test)
    for j=1:length(t_test)
        x_ij = xp + s_test(i)*N2(:,1) + t_test(j)*N2(:,2);
        residuos_fam(i,j) = log10(norm(A2*x_ij - b2) + 1e-16);
    end
end
imagesc(t_test, s_test, residuos_fam);
colorbar; xlabel('t'); ylabel('s');
title('log10 residuo de la familia (debe ser <-10)');
colormap(gca,'cool');

%% Subplot 4: Efecto de lazos en el costo
subplot(2,3,4);
s_range2 = linspace(-2, 2, 50);
t_fixed  = [0, 0.5, 1, -0.5];
hold on;
for t_val = t_fixed
    costos_s = zeros(size(s_range2));
    for k=1:length(s_range2)
        x_k = xp + s_range2(k)*N2(:,1) + t_val*N2(:,2);
        if all(x_k >= -1e-10)
            costos_s(k) = c2' * max(x_k, 0);
        else
            costos_s(k) = NaN;
        end
    end
    plot(s_range2, costos_s, 'LineWidth', 1.5,...
         'DisplayName', sprintf('t=%.1f', t_val));
end
xlabel('s (parametro del lazo n1)');
ylabel('Costo total (USD)');
title('Costo como funcion del parametro s');
legend('Location','best'); grid on;

%% Subplot 5: Dimension del espacio nulo vs rango
subplot(2,3,5);
n_total = 6;
rangos  = 0:n_total;
nulos   = n_total - rangos;
bar([rangos; nulos]','stacked');
xlabel('Rango de A'); ylabel('Dimension');
title(sprintf('Rango + dim(Nul) = n = %d', n_total));
legend({'Rango (vars. basicas)','Nul (vars. libres)'},'Location','best');
xticks(1:n_total+1); xticklabels(0:n_total); grid on;

%% Subplot 6: Diagrama de lazo cerrado
subplot(2,3,6);
axis off; title('Lazo cerrado logistico');
% Dibujar una red simple con lazo
pos = struct();
pos.P1 = [0.2, 0.7]; pos.P2 = [0.2, 0.3];
pos.D1 = [0.7, 0.8]; pos.D2 = [0.7, 0.5]; pos.D3 = [0.7, 0.2];
% Flujos normales
annotation('arrow',[0.35 0.55],[0.82 0.84],'Color',[0.2 0.5 0.9]);
annotation('arrow',[0.35 0.55],[0.78 0.62],'Color',[0.2 0.5 0.9]);
annotation('arrow',[0.35 0.55],[0.42 0.58],'Color',[0 0.6 0.3]);
annotation('arrow',[0.35 0.55],[0.38 0.28],'Color',[0 0.6 0.3]);
% Lazo cerrado
annotation('doublearrow',[0.28 0.28],[0.42 0.68],'Color',[0.8 0.1 0.1],...
    'LineWidth',2);
% Etiquetas
text(0.15,0.72,'P1','FontWeight','bold','Color',[0.2 0.5 0.9],...
    'Units','normalized','FontSize',10);
text(0.15,0.32,'P2','FontWeight','bold','Color',[0 0.6 0.3],...
    'Units','normalized','FontSize',10);
text(0.75,0.84,'D1','FontWeight','bold','Color',[0.5 0.5 0.5],...
    'Units','normalized','FontSize',10);
text(0.75,0.55,'D2','FontWeight','bold','Color',[0.5 0.5 0.5],...
    'Units','normalized','FontSize',10);
text(0.75,0.25,'D3','FontWeight','bold','Color',[0.5 0.5 0.5],...
    'Units','normalized','FontSize',10);
text(0.17,0.53,sprintf('-2t/+t'),'Color',[0.8 0.1 0.1],...
    'Units','normalized','FontSize',9,'Rotation',90);
text(0.35,0.90,'Flujos normales','Color',[0.4 0.4 0.4],...
    'Units','normalized','FontSize',8,'FontStyle','italic');
text(0.05,0.50,'Lazo cerrado','Color',[0.8 0.1 0.1],...
    'Units','normalized','FontSize',8,'Rotation',90);

sgtitle('MATEMATICAS 2 --- Clase 9: Sistemas Homogeneos y Lazos',...
        'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 9)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cuantos lazos cerrados independientes tiene la red\n');
fprintf('   representada por A2? ¿Y la red de A (3x3 del Bloque 1)?\n');
fprintf('   Respuesta: A2 tiene %d lazo(s); A tiene %d lazo(s).\n\n',...
    size(A2,2)-rank(A2), size(A,2)-rank(A));

fprintf('2. Verifica que u+v esta en Nul(A2) siendo u=n1 y v=n2.\n');
fprintf('   ||A2*(u+v)|| = %.2e (debe ser ~0)\n\n', norm(A2*(N2(:,1)+N2(:,2))));

fprintf('3. Para el lazo n1 de A2, ¿reduce o aumenta el costo\n');
fprintf('   si los costos son c=[8;12;15;10]?\n');
fprintf('   c^T*n1 = %.2f => %s el costo por unidad de s.\n\n',...
    dc1, ternStr(dc1<0,'REDUCE','AUMENTA'));

fprintf('4. ¿Cuantas soluciones tiene el sistema homogeneo\n');
fprintf('   A=[1 0; 0 1; 0 0]*x = 0?\n');
A_q4 = [1 0; 0 1; 0 0];
fprintf('   rang(A_q4)=%d, n=2 => dim(Nul)=%d => %s\n\n',...
    rank(A_q4), 2-rank(A_q4), ternStr(2-rank(A_q4)==0,'Solo trivial','Infinitas'));

fprintf('5. Calcula null([1 2; 2 4]) en MATLAB.\n');
A_q5 = [1 2; 2 4];
N_q5 = null(A_q5);
fprintf('   Resultado: [%.4f; %.4f]\n', N_q5');
fprintf('   Interpretacion: el espacio nulo tiene dimension %d.\n\n', size(N_q5,2));
fprintf('==========================================\n');
fprintf('Fin del script clase9_datos.m\n');
fprintf('==========================================\n');

%% --- Funciones auxiliares ------------------------------------
function s = yesNo(v)
    if v; s = 'SI'; else; s = 'NO'; end
end

function s = ternStr(v, a, b)
    if v; s = a; else; s = b; end
end
