"""Genera las figuras de la Clase 14 (Laboratorio de sintonizacion en motor DC).
Respuestas: SIMULACION con el modelo de motor de _comun/motor.py (zona muerta 15 %, w(100 %) = 330 RPM,
tau = 0,12 s, 50 Hz). PI difuso: tabla 5x3 (+-5 %/paso), De en +-10 RPM/paso, particion de e triangular.
Ejecutar:  python generar_imagenes.py
"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '_comun'))
from fz import *
import motor as M
setout(HERE)
fmt = lambda v, d=1: f'{v:.{d}f}'.replace('.', ',')

# 1. Ruta ---------------------------------------------------------------------------------
fig, ax = canvas(6, 6.2)
items = [('Cl. 13: difuso PD y PI', 'ok'), ('Cl. 14: sintonización (lab)', 'hoy'), ('Cl. 15: PID híbrido', 'pend'),
         ('Cl. 16: benchmarking', 'pend'), ('U4: robótica', 'pend')]
for i, (t, st) in enumerate(items):
    y = 5.6 - i * 1.2; c = {'ok': VER, 'hoy': NAR, 'pend': GRIS}[st]
    box(ax, 3, y, 5.4, 0.8, {'ok': '✔ ', 'hoy': 'Hoy: ', 'pend': '○ '}[st] + t, color=c, fs=12.5,
        tc=GRIS if st == 'pend' else NEGRO, bold=st == 'hoy', lw=3 if st == 'hoy' else 1.8)
    if i < 4: arrow(ax, (3, y - 0.42), (3, y - 0.78), color=GRIS, lw=2)
save(fig, 'c14_ruta')

# 2. Metodologia iterativa ------------------------------------------------------------------
fig, ax = canvas(13, 5.0)
P = dict(color=AZUL, fs=11.5)
box(ax, 1.4, 3.6, 2.4, 1.2, '1. Ejecutar\ncontrolador\n(30 s)', **P)
box(ax, 4.6, 3.6, 2.4, 1.2, '2. Calcular\nIAE y $M_p$', **P)
box(ax, 8.0, 3.6, 2.6, 1.3, '¿Mejoró\nrespecto a la\niteración previa?', color=NAR, fs=11, r=0.5)
box(ax, 11.6, 3.6, 2.2, 1.0, '3a. Mantener\nel cambio', color=VER, fs=11.5)
box(ax, 11.6, 1.6, 2.2, 1.0, '3b. Revertir\nel cambio', color=ROJO, fs=11.5)
box(ax, 8.0, 1.6, 2.6, 1.3, '¿Mejora > 3 % en\nalguna de las 3\núltimas iter.?', color=NAR, fs=11, r=0.5)
box(ax, 4.6, 1.6, 2.4, 1.2, '4. Elegir otra\ncelda (una sola)', **P)
box(ax, 8.0, 0.2, 2.6, 0.6, 'No → PARAR (óptimo local)', color=GRIS, fs=10.5)
arrow(ax, (2.6, 3.6), (3.4, 3.6), lw=2); arrow(ax, (5.8, 3.6), (6.7, 3.6), lw=2)
arrow(ax, (9.3, 3.6), (10.5, 3.6), lw=2, text='Sí', toff=(0, 0.2))
poly_arrow(ax, [(8.0, 2.95), (8.0, 2.8), (11.0, 2.8), (11.6, 2.1)], lw=1.5); ax.text(9.0, 2.9, 'No', fontsize=11)
arrow(ax, (11.6, 3.1), (9.3, 1.9), lw=1.5); arrow(ax, (10.5, 1.6), (9.3, 1.6), lw=1.5)
arrow(ax, (6.7, 1.6), (5.8, 1.6), lw=2, text='Sí', toff=(0, 0.2)); arrow(ax, (8.0, 0.95), (8.0, 0.5), lw=1.5)
poly_arrow(ax, [(3.4, 1.6), (1.4, 1.6), (1.4, 3.0)], lw=2)
ax.set_ylim(-0.2, 4.6)
save(fig, 'c14_metodologia')

# 3. Comparativa de los tres controladores ----------------------------------------------------
L = lambda t: 60.0 if 3.0 <= t < 4.5 else 0.0
fig, axs = plt.subplots(2, 1, figsize=(12, 6.2), sharex=True, gridspec_kw=dict(height_ratios=[2.2, 1]))
cases = [('T-S orden 0 (sin pre-alim.)', M.ts0, False, AZUL, '-'), ('T-S orden 1 + pre-alimentación', M.ts1, True, NAR, '--'),
         ('PI difuso (5×3)', M.make_fpi(10.0, 1.0), False, VER, '-')]
for lab, c, ff, col, ls in cases:
    t, w, u = M.sim(c, load=L, ff=ff, tf=6.0)
    iae = float(np.sum(np.abs(150 - w)) * 0.02)
    axs[0].plot(t, w, color=col, ls=ls, lw=2.4, label=f'{lab}: IAE ≈ {iae:.0f} RPM·s')
    axs[1].plot(t, u, color=col, ls=ls, lw=1.8)
    print(lab, round(iae), round(w[140], 1), round(w[150:225].min(), 1), round(w[-1], 1))
axs[0].axhline(150, color=NEGRO, ls='--', lw=1.2); axs[0].axvspan(3, 4.5, color=GRIS, alpha=.12)
axs[0].text(3.75, 168, 'carga', ha='center', color=GRIS, fontsize=10)
axs[0].set_ylim(-60, 180); axs[0].set_yticks([0, 50, 100, 150]); axs[0].set_ylabel('ω (RPM)')
axs[0].legend(loc='lower right', fontsize=9.5)
axs[0].set_title('Simulación: escalón a 150 RPM y carga entre 3 y 4,5 s', fontsize=12)
axs[1].set_ylabel('u (%)'); axs[1].set_xlabel('Tiempo (s)'); axs[1].set_ylim(-5, 105); axs[1].set_xlim(0, 6)
fig.tight_layout()
save(fig, 'c14_comparativa')

# 4. Convergencia del IAE (ilustrativa) ----------------------------------------------------------
it = np.arange(7); iae = np.array([100, 85, 72, 65, 60, 58, 57])
fig, ax = plt.subplots(figsize=(6.4, 4.6))
ax.plot(it, iae, 'o-', color=AZUL, lw=2.6, ms=8, label='IAE por iteración')
ax.axhline(57, color=VER, ls='--', lw=1.6); ax.text(6.2, 50, 'óptimo local', color=VER, ha='right', fontsize=10.5)
ax.plot([1, 2], [85, 72], '^', color=NAR, ms=12, label='mejoras > 10 %')
ax.set_xlabel('Iteración'); ax.set_ylabel('IAE (RPM·s)'); ax.set_ylim(0, 115); ax.set_xticks(it)
ax.legend(loc='upper right'); ax.set_title('Convergencia típica del IAE (ilustrativo)', fontsize=12)
save(fig, 'c14_convergencia_iae')
print('Listo.')
