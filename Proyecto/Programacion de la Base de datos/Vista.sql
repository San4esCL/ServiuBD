CREATE OR REPLACE VIEW VISTA_PROCESO AS
SELECT
    p.run_postulante,
    po.nombres_postulante||' '||po.p_apellido_postulante as nombre,
    p.edad,
    p.puntaje_edad,
    p.cargas_fam,
    p.puntaje_cargas,
    p.e_civil,
    p.puntaje_ecivil,
    p.pueblo_indigena,
    p.puntaje_indigena,
    p.monto_ahorro,
    p.puntaje_ahorro,
    p.titulo,
    p.puntaje_titulo,
    case
    when r.id_region in (1,2,15,16) then r.nombre_region
    end as "Zona extrema",
    case
    when r.id_region = 15 then TRUNC(p.puntaje_total/2) 
    when r.id_region = 16 then TRUNC(p.puntaje_total/2.3)
    when r.id_region = 2 then TRUNC(p.puntaje_total/1.3)
    when r.id_region = 1 then TRUNC(p.puntaje_total/1.5)
    end AS "Puntaje zona extrema",
    p.puntaje_total,
    vi.tipo_vivienda,
    ub.valor_vivienda,
    it.subsidio_obtenido
    
FROM PROCESO P JOIN postulante PO
ON p.run_postulante = po.rut_postulante join ficha_postulacion fp
on fp.id_ficha = p.id_ficha join vivienda vi
on fp.rol_sii = vi.rol_sii join region r
on vi.id_region = r.id_region join ubicacion_preferencia ub
on ub.id_ficha = fp.id_ficha join informe_tecnico it
on it.id_informe = vi.id_informe
where p.puntaje_total> (select avg(puntaje_total) from proceso);