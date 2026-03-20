-- ============================================================
-- Alta masiva de entregables — División Automotriz
-- Key User  : Ninfa Isabel
-- Fuente    : Division Automotriz.xlsx
-- Generado  : 2026-03-17
--
-- Mapeo de estatus:
--   "En curso"      → En progreso
--   "Completado"    → Completado
--   "Sin iniciar"   → Borrador  (si avance = 0)
--                  → En progreso (si avance > 0, tiene trabajo hecho)
--   "Aplazado"      → En revisión
-- ============================================================

DO $$
DECLARE
  v_div  INT;
  v_ku   INT;
  v_resp INT;
BEGIN
  SELECT id INTO v_div  FROM divisiones   WHERE nombre ILIKE '%Automotriz%'  LIMIT 1;
  SELECT id INTO v_ku   FROM key_users    WHERE nombre ILIKE '%Ninfa%'        LIMIT 1;
  SELECT id INTO v_resp FROM responsables WHERE nombre ILIKE '%Eduardo%Aguayo%' LIMIT 1;

  IF v_div  IS NULL THEN RAISE EXCEPTION 'División Automotriz no encontrada en la tabla divisiones'; END IF;
  IF v_ku   IS NULL THEN RAISE EXCEPTION 'Key User Ninfa no encontrado en la tabla key_users'; END IF;
  IF v_resp IS NULL THEN RAISE EXCEPTION 'Responsable Eduardo Aguayo no encontrado en la tabla responsables'; END IF;

  INSERT INTO entregables
    (folio, nombre, descripcion,
     fecha_inicio, fecha_fin_desarrollo, fecha_entrega,
     porcentaje_avance, estatus,
     responsable_id, division_id, key_user_id,
     horas_desarrollo, frd_aplica, necesita_devops)
  VALUES

  -- 1 ── En curso · 25%
  ( 'AUT-001',
    'BI Orquestador',
    'Área: Gestión de pagos. Información provenga de Dynamics directo '
    '(eliminaciones, reprogramaciones, etc). Programaciones incluyan el UUID factura. '
    'Liga de descarga del comprobante de pago.',
    '2026-02-24', '2026-03-24', '2026-03-24',
    25, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 2 ── En curso · 50%
  ( 'AUT-002',
    'Programaciones de pago que no viajan a Dynamics',
    'Área: Gestión de pagos.',
    '2026-02-24', '2026-03-31', '2026-03-31',
    50, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 3 ── En curso · 75%
  ( 'AUT-003',
    'Aplicaciones de pago que no viajan Dalton Soft',
    'Área: Gestión de pagos. Falta configuración de cuentas (Contabilidad). '
    'Pendiente: Reprogramaciones.',
    '2026-02-24', '2026-03-18', '2026-03-18',
    75, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 4 ── Completado · 100%
  ( 'AUT-004',
    'Errores en la cuenta de pago',
    'Área: Gestión de pagos. Se detectarán pagos programados desde una empresa, '
    'viajados a Dynamics y pagados desde otra. Se rechaza el pago para generar '
    'saldo a favor y realizar los movimientos administrativos.',
    '2026-02-24', '2026-03-06', '2026-03-06',
    100, 'Completado', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 5 ── Aplazado → En revisión · 75%
  ( 'AUT-005',
    'Error en la depuración de Movimientos',
    'Área: Validaciones. Al hacer la depuración de los saldos remanentes en '
    'subsidios se genera un error que mantiene el saldo vigente.',
    '2026-02-24', '2026-03-12', '2026-03-12',
    75, 'En revisión', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 6 ── Completado · 100%
  ( 'AUT-006',
    'Ajuste folio Dalton BI Movimientos Dalton Bancos',
    'Área: Validaciones. En Conciliación Aplicaciones se relaciona el mismo folio '
    'Dalton con diferentes ingresos, lo que impide realizar una conciliación completa.',
    '2026-02-24', '2026-03-06', '2026-03-06',
    100, 'Completado', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 7 ── Aplazado → En revisión · 75%
  ( 'AUT-007',
    'Error en comprobantes (principalmente CIE, SIT y HSBC)',
    'Área: Gestión de pagos. Distintos diarios no reciben o asocian un comprobante '
    'de pago, principalmente con HSBC.',
    '2026-02-24', '2026-03-17', '2026-03-17',
    75, 'En revisión', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 8 ── Sin iniciar + 50% → En progreso; sin fecha (en espera revisión permisos)
  ( 'AUT-008',
    'Bloquear edición de diarios importados desde DSFOT',
    'Área: Gestión de pagos. Algunos campos están bloqueados, sin embargo se detectó '
    'que es posible eliminar líneas causando discrepancias en contabilidad. '
    'Se revisan facultades de los perfiles "Encargado CXP" y "Tesorero". '
    'Fecha de vencimiento pendiente: en espera de revisión de permisos de usuarios.',
    '2026-02-24', NULL, NULL,
    50, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 9 ── Sin iniciar + 25% → En progreso
  ( 'AUT-009',
    'Falla en los envíos de comprobantes por correo (Dynamics)',
    'Área: Gestión de pagos. Intermitencia en los envíos de correo. Pendiente: '
    'agregar UUID de la factura en el detalle, agregar grupo de Tesoreros para '
    'recibir todos los comprobantes.',
    '2026-02-24', '2026-03-27', '2026-03-27',
    25, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 10 ── Sin iniciar · 0% → Borrador
  ( 'AUT-010',
    'Validar UUID Dalton Soft-Dynamics',
    'Área: Gestión de pagos. Validar que Dalton Soft envíe el UUID de factura '
    'para comparar con OC y no permitir el mismo registro.',
    '2026-02-24', '2026-03-24', '2026-03-24',
    0, 'Borrador', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 11 ── Sin iniciar · 0% → Borrador
  ( 'AUT-011',
    'H2H Banorte - Scotiabank',
    'Área: Validaciones. En proceso de contratación.',
    '2026-02-24', '2026-04-25', '2026-04-25',
    0, 'Borrador', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 12 ── Aplazado → En revisión · 0%
  ( 'AUT-012',
    'Aplicaciones Automáticas WebSet (Excelencia)',
    'Área: Validaciones. Se detectarán aplicaciones de pago automáticas generadas '
    'desde WebSet.',
    '2026-02-24', '2026-03-17', '2026-03-17',
    0, 'En revisión', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 13 ── En curso · 25%
  ( 'AUT-013',
    'Pagos rechazados en Dynamics que generan comprobante de otro proveedor',
    'Área: Gestión de pagos. Dynamics registra como pagado un diario con rechazo '
    'y genera un comprobante que corresponde a otro proveedor.',
    '2026-03-11', '2026-03-18', '2026-03-18',
    25, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 ),

  -- 14 ── En curso · 25% · sin fecha de vencimiento
  ( 'AUT-014',
    'Alta de las nuevas cuentas de Dimofi en Dalton Bancos',
    'Área: Validaciones. Solicitar archivos MT40 para hacer aplicaciones en '
    'Dalton Bancos de la nueva operación de Dimofi Autos.',
    '2026-03-11', NULL, NULL,
    25, 'En progreso', v_resp, v_div, v_ku, 0, 0, 0 );

  RAISE NOTICE '✓ 14 entregables de División Automotriz insertados correctamente.';
END $$;
