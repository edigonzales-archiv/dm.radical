delete from dm_cs_ch_tb.territorl_bndries_municipal_boundary_proj;

delete from dm_cs_ch_tb.territorl_bndries_municipal_boundary;
delete from dm_cs_ch_tb.territorl_bndries_municipality;

delete from dm_cs_ch_tb.territorl_bndries_boundary_terr_point;
delete from dm_cs_ch_tb.territorl_bndries_municipal_boundary_revision;

with nf as 
(
    insert into
        dm_cs_ch_tb.territorl_bndries_municipal_boundary_revision
        (t_id, description, perimeter, state_of, revision_id, validity)
    select 
        t_id, beschreibung as description, ST_Force3D(perimeter) as perimeter,
        gueltigereintrag as state_of, identifikator as revision_id, 
        case 
            when gueltigkeit = 'gueltig' then 'valid'
            else 'planned'
        end as validity
    from
        dm01_tmp.gemeindegrenzen_gemnachfuehrung
    returning *
),
btp as (
    insert into 
        dm_cs_ch_tb.territorl_bndries_boundary_terr_point (t_id, anumber, 
        mark, r_municipal_boundary_revision, geometry, territorial_point)
    select 
        t_id, identifikator as anumber,
        case 
            when punktzeichen = 'Stein' then 'boundary_marker'
            when punktzeichen = 'Kunststoffzeichen' then 'artificial_boundary_marker'
            when punktzeichen = 'Bolzen' then 'bolt'
            when punktzeichen = 'Rohr' then 'tube'
            when punktzeichen = 'Pfahl' then 'stake'
            when punktzeichen = 'Kreuz' then 'cross'
            when punktzeichen = 'unversichert' then 'not_materialized'
            when punktzeichen = 'weitere' then 'other'
            when punktzeichen = 'undefiniert' then 'undefined'
            else 'undefined'
        end as mark,
        entstehung as r_municipal_boundary_revision, ST_Force3D(geometrie) as geometry,
        case 
            when hoheitsgrenzstein = 'nein' then false
            else true
        end as territorial_point
    from 
        dm01_tmp.gemeindegrenzen_hoheitsgrenzpunkt
    returning *
),
municipality as (
    insert into 
        dm_cs_ch_tb.territorl_bndries_municipality (t_id, aname, fosnr)
    select 
        t_id, aname as aname, bfsnr as fosnr
    from 
        dm01_tmp.gemeindegrenzen_gemeinde 
    returning *
        
),
boundary as 
(
    insert into 
        dm_cs_ch_tb.territorl_bndries_municipal_boundary (t_id, geometry,
        r_municipal_boundary_revision, r_municipality)
    select
        gre.t_id, ST_SnapToGrid(ST_Force3D(gre.geometrie), 0.00001) as geometry,
        gre.entstehung as r_municipal_boundary_revision,
        gre.gemeindegrenze_von as r_municipality
    from
        dm01_tmp.gemeindegrenzen_gemeindegrenze as gre,
        dm01_tmp.gemeindegrenzen_gemeinde gem
    where gem.t_id = gre.gemeindegrenze_von
    returning *
),
boundary_proj as
(
    insert into 
        dm_cs_ch_tb.territorl_bndries_municipal_boundary_proj
        (t_id, r_municipal_boundary_revision, geometry)
    select 
        t_id, entstehung as r_municipal_boundary_revision, 
        ST_SnapToGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from 
        dm01_tmp.gemeindegrenzen_projgemeindegrenze
    returning *
)
select 
    *
from
    boundary_proj
    