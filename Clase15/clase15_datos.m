%% ============================================================
%%  MATEMATICAS 2 --- CLASE 15
%%  Script MATLAB: Producto Escalar, Similitud y Costo Ponderado
%%  Archivo: clase15_datos.m
%%
%%  INSTRUCCIONES:
%%  Ejecutar bloque a bloque con Ctrl+Enter, o F5 para todo.
%%  REQUERIMIENTOS: MATLAB R2018b o superior.
%% ============================================================

clc; clear; close all;
fprintf('==========================================\n');
fprintf(' MATEMATICAS 2 --- Clase 15\n');
fprintf(' Producto Escalar, Similitud, Costo\n');
fprintf('==========================================\n\n');

%% ============================================================
%% BLOQUE 1: PRODUCTO ESCALAR --- CALCULO Y PROPIEDADES
%% ============================================================

fprintf('--- BLOQUE 1: Producto escalar ---\n\n');

%% Vectores de demanda y costos
dA = [300; 250; 200; 150];
dB = [600; 500; 400; 300];   % = 2*dA
dC = [100; 300; 200; 400];
c  = [10; 8; 12; 9];         % costos USD/ton
x  = [400; 350; 200; 150];   % plan de despacho

%% Tres formas de calcular el producto escalar
pe_1 = dot(c, x);
pe_2 = c' * x;
pe_3 = sum(c .* x);
fprintf('Costo total c^T * x:\n');
fprintf('  dot(c,x)   = $%.2f\n', pe_1);
fprintf('  c^T * x    = $%.2f\n', pe_2);
fprintf('  sum(c.*x)  = $%.2f\n', pe_3);
fprintf('  Son iguales: %s\n\n', mat2str(pe_1==pe_2 && pe_2==pe_3));

%% Verificar v.v = ||v||^2
vv = dot(dA, dA);
norm2_sq = norm(dA, 2)^2;
fprintf('Verificacion: dA.dA = ||dA||^2\n');
fprintf('  dot(dA,dA) = %.4f\n', vv);
fprintf('  norm(dA)^2 = %.4f\n', norm2_sq);
fprintf('  Son iguales: %s\n\n', mat2str(abs(vv-norm2_sq)<1e-10));

%% Propiedades
u = dA; v = dC; w = [50;100;75;25]; k = 2.5;
fprintf('Propiedades del producto escalar:\n');
fprintf('  Conmutativa: u.v=%.0f, v.u=%.0f => %s\n',...
    dot(u,v), dot(v,u), mat2str(dot(u,v)==dot(v,u)));
fprintf('  Bilineal: (u+w).v = %.0f = u.v+w.v = %.0f => %s\n',...
    dot(u+w,v), dot(u,v)+dot(w,v),...
    mat2str(abs(dot(u+w,v)-(dot(u,v)+dot(w,v)))<1e-10));
fprintf('  Escalar: (k*u).v = %.0f = k*(u.v) = %.0f => %s\n\n',...
    dot(k*u,v), k*dot(u,v), mat2str(abs(dot(k*u,v)-k*dot(u,v))<1e-10));

%% Desigualdad de Cauchy-Schwarz
fprintf('Desigualdad de Cauchy-Schwarz: |u.v| <= ||u||*||v||\n');
fprintf('  |dA.dC| = %.2f\n', abs(dot(dA,dC)));
fprintf('  ||dA||*||dC|| = %.2f\n', norm(dA)*norm(dC));
fprintf('  Se cumple: %s\n\n', mat2str(abs(dot(dA,dC)) <= norm(dA)*norm(dC)+1e-10));

%% ============================================================
%% BLOQUE 2: COSENO DE SIMILITUD
%% ============================================================

fprintf('--- BLOQUE 2: Coseno de similitud ---\n\n');

CDs = {'D1','D2','D3','D4'};

%% Calcular cosenos
cos_AB = dot(dA,dB) / (norm(dA)*norm(dB));
cos_AC = dot(dA,dC) / (norm(dA)*norm(dC));
cos_BC = dot(dB,dC) / (norm(dB)*norm(dC));

fprintf('Cosenos de similitud:\n');
fprintf('  cos(dA,dB) = %.6f', cos_AB);
if abs(cos_AB-1) < 1e-6
    fprintf(' => IDENTICOS (dB = k*dA)\n');
elseif cos_AB > 0.9
    fprintf(' => MUY SIMILARES\n');
else
    fprintf(' => MODERADAMENTE SIMILARES\n');
end

fprintf('  cos(dA,dC) = %.6f', cos_AC);
if cos_AC > 0.9
    fprintf(' => SIMILARES\n');
elseif cos_AC > 0.5
    fprintf(' => ALGO SIMILARES\n');
else
    fprintf(' => POCO SIMILARES\n');
end

fprintf('  cos(dB,dC) = %.6f\n\n', cos_BC);

%% Angulo entre vectores
theta_AC = acosd(cos_AC);
fprintf('Angulo entre dA y dC: %.2f grados\n\n', theta_AC);

%% Matriz de cosenos entre 4 semanas
D_sem = [300 320 280 310;
         250 230 270 260;
         200 210 190 205;
         180 170 200 185];
nsem = 4;
C_cos = zeros(nsem);
for i=1:nsem
    for j=1:nsem
        C_cos(i,j) = dot(D_sem(:,i),D_sem(:,j)) / ...
                     (norm(D_sem(:,i))*norm(D_sem(:,j)));
    end
end
fprintf('Matriz de cosenos de similitud (4 semanas):\n');
fprintf('       S1      S2      S3      S4\n');
for i=1:nsem
    fprintf('S%d | ', i);
    for j=1:nsem, fprintf('%7.4f ', C_cos(i,j)); end
    fprintf('\n');
end

%% Par mas similar y mas distinto (en coseno)
C_upper = triu(C_cos,1);
C_upper(C_upper==0) = -Inf;
[max_c, idx_max] = max(C_upper(:));
[r1,c1] = ind2sub([nsem,nsem], idx_max);
C_upper2 = triu(C_cos,1);
C_upper2(C_upper2==0) = Inf;
[min_c, idx_min] = min(C_upper2(:));
[r2,c2] = ind2sub([nsem,nsem], idx_min);
fprintf('\nMas similares (coseno): S%d - S%d (%.4f)\n', r1,c1,max_c);
fprintf('Menos similares (coseno): S%d - S%d (%.4f)\n\n', r2,c2,min_c);

%% ============================================================
%% BLOQUE 3: ORTOGONALIDAD
%% ============================================================

fprintf('--- BLOQUE 3: Ortogonalidad ---\n\n');

%% Turnos dia/noche: ortogonales
d_dia   = [100; 0; 200; 0];
d_noche = [0; 150; 0; 250];
pe_dn   = dot(d_dia, d_noche);

fprintf('Demanda dia:   [%s]\n', num2str(d_dia','%.0f '));
fprintf('Demanda noche: [%s]\n', num2str(d_noche','%.0f '));
fprintf('Producto escalar dia.noche = %.4f\n', pe_dn);
fprintf('Son ORTOGONALES: %s\n\n', mat2str(abs(pe_dn)<1e-10));

%% Pitagoras generalizado
d_total = d_dia + d_noche;
lhs = norm(d_total)^2;
rhs = norm(d_dia)^2 + norm(d_noche)^2;
fprintf('Pitagoras: ||d_total||^2 = ||d_dia||^2 + ||d_noche||^2\n');
fprintf('  LHS = %.4f\n', lhs);
fprintf('  RHS = %.4f\n', rhs);
fprintf('  Iguales: %s\n\n', mat2str(abs(lhs-rhs)<1e-10));

%% Verificar ortogonalidad entre varios vectores
fprintf('Test de ortogonalidad (pares):\n');
vectores = {d_dia,'d_dia'; d_noche,'d_noche'; dA,'dA'; [1;-1;0;0],'v_dif'};
for i=1:size(vectores,1)
    for j=i+1:size(vectores,1)
        pe_ij = dot(vectores{i,1}, vectores{j,1});
        ort = abs(pe_ij) < 1e-6;
        fprintf('  %s . %s = %8.2f => ortogonales: %s\n',...
            vectores{i,2}, vectores{j,2}, pe_ij, mat2str(ort));
    end
end
fprintf('\n');

%% ============================================================
%% BLOQUE 4: COSTO PONDERADO Y PRECIO MEDIO
%% ============================================================

fprintf('--- BLOQUE 4: Costo ponderado y precio medio ---\n\n');

%% Inventario de 5 SKUs
skus = {'SKU-A','SKU-B','SKU-C','SKU-D','SKU-E'};
precios = [15; 22;  8; 35; 12];   % USD/unid
stocks  = [200;150;400; 80;300];  % unidades

%% Valor total = producto escalar
valor_total = dot(precios, stocks);
total_unid  = sum(stocks);
precio_medio = valor_total / total_unid;

fprintf('Inventario:\n');
fprintf('%-8s | Precio | Stock | Valor\n','SKU');
fprintf('%s\n', repmat('-',1,40));
for k=1:5
    fprintf('%-8s | %6.2f | %5.0f | $%7.2f\n',...
        skus{k}, precios(k), stocks(k), precios(k)*stocks(k));
end
fprintf('%s\n', repmat('-',1,40));
fprintf('%-8s | %6.2f | %5.0f | $%7.2f\n',...
    'TOTAL', precio_medio, total_unid, valor_total);

fprintf('\nValor total = p^T * q = $%.2f\n', valor_total);
fprintf('Precio medio ponderado = $%.4f/unidad\n\n', precio_medio);

%% Impacto de aumento de precios
delta_p = [0; 0; 0; 5; 0];  % SKU-D sube $5
delta_V = dot(delta_p, stocks);
fprintf('Si SKU-D sube $5/unid:\n');
fprintf('  Delta V = delta_p^T * q = $%.2f\n', delta_V);
fprintf('  Nuevo valor total = $%.2f\n\n', valor_total + delta_V);

%% Precio medio de flota de camiones
tipos = {'Camion pequeño','Camion mediano','Camion grande','Semirremolque'};
p_camiones = [80000; 120000; 95000; 140000];
q_camiones = [10; 5; 8; 3];
V_flota = dot(p_camiones, q_camiones);
pm_flota = V_flota / sum(q_camiones);
fprintf('Flota de camiones:\n');
fprintf('  Valor total: $%,.0f\n', V_flota);
fprintf('  Precio medio: $%,.0f por camion\n\n', pm_flota);

%% ============================================================
%% BLOQUE 5: PROYECCION ORTOGONAL
%% ============================================================

fprintf('--- BLOQUE 5: Proyeccion ortogonal ---\n\n');

d = [400; 300; 200; 100];

%% Proyeccion sobre vector uniforme (extrae el promedio)
n_dim = length(d);
b_uni = ones(n_dim,1) / sqrt(n_dim);  % vector uniforme unitario
comp_escalar = dot(d, b_uni);
proj_media   = comp_escalar * b_uni;
variacion    = d - proj_media;

fprintf('d = [%s]\n', num2str(d','%.0f '));
fprintf('Componente escalar sobre b_uniforme = %.4f\n', comp_escalar);
fprintf('Proyeccion (media):   [%s]\n', num2str(proj_media','%.4f '));
fprintf('Variacion (residuo):  [%s]\n', num2str(variacion','%.4f '));
fprintf('Verificacion ortogonal: %.2e\n', dot(proj_media, variacion));
fprintf('Media aritmetica de d = %.4f (comparar)\n\n', mean(d));

%% Nota: el componente escalar / sqrt(n) = media aritmetica
fprintf('Comp. escalar / sqrt(n) = %.4f = mean(d)? %s\n\n',...
    comp_escalar/sqrt(n_dim), mat2str(abs(comp_escalar/sqrt(n_dim)-mean(d))<1e-10));

%% Proyeccion sobre primer CD (extrae la demanda de D1)
e1 = [1;0;0;0];
proj_D1  = dot(d,e1)/dot(e1,e1) * e1;
resid_D1 = d - proj_D1;
fprintf('Proyeccion sobre e1 (solo D1):\n');
fprintf('  proj = [%s]\n', num2str(proj_D1','%.0f '));
fprintf('  resid = [%s]\n', num2str(resid_D1','%.0f '));
fprintf('  Ortogonal: %.2e\n\n', dot(proj_D1, resid_D1));

%% Proyeccion sobre dA (extrae componente en direccion de dA)
proj_dA  = dot(d,dA)/dot(dA,dA) * dA;
resid_dA = d - proj_dA;
fprintf('Proyeccion de d sobre dA:\n');
fprintf('  proj = [%s]\n', num2str(proj_dA','%.4f '));
fprintf('  resid = [%s]\n', num2str(resid_dA','%.4f '));
fprintf('  Ortogonal: %.2e\n\n', dot(proj_dA, resid_dA));

%% ============================================================
%% BLOQUE 6: CORRELACION DE PEARSON Y PRODUCTO ESCALAR
%% ============================================================

fprintf('--- BLOQUE 6: Correlacion = coseno (datos centrados) ---\n\n');

%% Datos de ventas vs temperatura
ventas = [100;120;140;130;160;180;200;190;170;150];
temp   = [15; 18; 22; 20; 25; 28; 30; 29; 26; 23];

%% Centrar los datos
vc = ventas - mean(ventas);
tc = temp   - mean(temp);

%% Correlacion = coseno de similitud de los datos centrados
cos_vt  = dot(vc,tc) / (norm(vc)*norm(tc));
r_matlab = corr(ventas, temp);

fprintf('Ventas vs Temperatura:\n');
fprintf('  cos(vc, tc) = %.6f\n', cos_vt);
fprintf('  corr(v,t)   = %.6f\n', r_matlab);
fprintf('  Son iguales: %s\n\n', mat2str(abs(cos_vt - r_matlab) < 1e-10));

%% Coeficiente de regresion = proyeccion de vc sobre tc
beta_hat = dot(vc,tc) / dot(tc,tc);
fprintf('Coeficiente de regresion (pendiente):\n');
fprintf('  beta = (vc.tc) / (tc.tc) = %.4f ventas/grado C\n', beta_hat);
fprintf('  Comparar con polyfit: %.4f\n\n', polyfit(temp,ventas,1));

%% ============================================================
%% BLOQUE 7: VISUALIZACION
%% ============================================================

fprintf('--- BLOQUE 7: Visualizaciones ---\n');

figure('Name','Clase 15 --- Producto Escalar y Similitud',...
    'NumberTitle','off','Position',[30 30 1350 800]);

%% Subplot 1: Producto escalar como costo
subplot(2,3,1);
bar_vals = precios .* stocks;
bh1 = bar(bar_vals,'FaceColor','flat');
bh1.CData = repmat([0 0.32 0.58],5,1);
set(gca,'XTickLabel',skus,'XTickLabelRotation',20);
ylabel('Valor ($)'); title('Valor por SKU (precio x stock)');
grid on;
yline(valor_total/5,'r--','LineWidth',1.5,'DisplayName','Media');
for k=1:5
    text(k,bar_vals(k)+50,sprintf('$%.0f',bar_vals(k)),...
        'HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
end

%% Subplot 2: Cosenos de similitud (heatmap)
subplot(2,3,2);
imagesc(C_cos,[-1 1]); colorbar; colormap(gca,'rdbu');
set(gca,'XTick',1:4,'XTickLabel',{'S1','S2','S3','S4'});
set(gca,'YTick',1:4,'YTickLabel',{'S1','S2','S3','S4'});
title('Cosenos de similitud (semanas)');
for i=1:4; for j=1:4
    text(j,i,sprintf('%.3f',C_cos(i,j)),'HorizontalAlignment','center',...
        'FontSize',8,'FontWeight','bold',...
        'Color',ternStr(C_cos(i,j)>0,'black','white'));
end; end

%% Subplot 3: Vectores ortogonales (dia/noche)
subplot(2,3,3);
bar([d_dia,d_noche,d_total]);
set(gca,'XTickLabel',{'D1','D2','D3','D4'});
ylabel('Toneladas');
title('Dia + Noche = Total (vectores ortogonales)');
legend({'Dia','Noche','Total'},'Location','best'); grid on;

%% Subplot 4: Proyeccion y residuo
subplot(2,3,4);
bar([d, proj_media, variacion]);
set(gca,'XTickLabel',{'D1','D2','D3','D4'});
ylabel('Toneladas');
title('Descomposicion: media + variacion');
legend({'d original','Componente media','Variacion'},'Location','best'); grid on;

%% Subplot 5: Correlacion ventas-temperatura
subplot(2,3,5);
scatter(temp, ventas, 80,'b','filled');
hold on;
t_fit = min(temp):max(temp);
y_fit = beta_hat*(t_fit-mean(temp)) + mean(ventas);
plot(t_fit, y_fit,'r-','LineWidth',2);
xlabel('Temperatura (C)'); ylabel('Ventas');
title(sprintf('Ventas vs Temp. (r=%.3f)', r_matlab));
legend({'Datos','Regresion'},'Location','best'); grid on;

%% Subplot 6: Angulos entre vectores de demanda
subplot(2,3,6);
thetas = [0, acosd(cos_AB), acosd(cos_AC), acosd(cos_BC)];
labels = {'dA-dA','dA-dB','dA-dC','dB-dC'};
bar(thetas,'FaceColor',[0.49 0 0.49]);
set(gca,'XTickLabel',labels,'XTickLabelRotation',15);
ylabel('Angulo (grados)'); title('Angulos entre vectores de demanda');
grid on;
for k=1:4
    text(k,thetas(k)+0.5,sprintf('%.1f',thetas(k)),...
        'HorizontalAlignment','center','FontWeight','bold');
end

sgtitle('MATEMATICAS 2 --- Clase 15: Producto Escalar y Similitud',...
    'FontSize',13,'FontWeight','bold');
fprintf('Figura generada exitosamente.\n\n');

%% ============================================================
%% BLOQUE 8: PREGUNTAS PARA LA TAREA
%% ============================================================

fprintf('==========================================\n');
fprintf('PREGUNTAS PARA RESPONDER (Tarea Clase 15)\n');
fprintf('==========================================\n\n');

fprintf('1. ¿Cual es el costo total del plan x=[%s]?\n', num2str(x','%.0f '));
fprintf('   Respuesta: c^T*x = $%.2f\n\n', dot(c,x));

fprintf('2. ¿Cual es el coseno de similitud entre dA y dB?\n');
fprintf('   Respuesta: %.6f. ¿Por que es exactamente 1?\n', cos_AB);
fprintf('   (dB = 2*dA, son paralelos)\n\n');

fprintf('3. ¿Son ortogonales d_dia y d_noche?\n');
fprintf('   d_dia . d_noche = %.4f => %s\n\n',...
    dot(d_dia,d_noche), mat2str(abs(dot(d_dia,d_noche))<1e-10));

fprintf('4. ¿Cuanto vale la proyeccion de d=[%s] sobre b_uniforme?\n',...
    num2str(d','%.0f '));
fprintf('   Respuesta: comp. escalar = %.4f, proj = [%s]\n\n',...
    comp_escalar, num2str(proj_media','%.2f '));

fprintf('5. ¿La correlacion de Pearson es igual al coseno\n');
fprintf('   de similitud de los datos centrados?\n');
fprintf('   Respuesta: %s (diferencia = %.2e)\n\n',...
    mat2str(abs(cos_vt-r_matlab)<1e-10), abs(cos_vt-r_matlab));
fprintf('==========================================\n');
fprintf('Fin del script clase15_datos.m\n');
fprintf('Prepararse para la Evaluacion Parcial 1.\n');
fprintf('==========================================\n');

%% --- Funciones auxiliares ---
function s = ternStr(v, a, b_val)
    if v; s=a; else; s=b_val; end
end
