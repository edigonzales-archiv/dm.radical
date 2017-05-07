delete from dm_cs_ch_os.ownership_mineral_right_proj;
delete from dm_cs_ch_os.ownership_distinct_permanent_right_proj;
delete from dm_cs_ch_os.ownership_real_estate_proj;
delete from dm_cs_ch_os.ownership_property_proj_pos;
delete from dm_cs_ch_os.ownership_property_proj;

delete from dm_cs_ch_os.ownership_mineral_right;
delete from dm_cs_ch_os.ownership_distinct_permanent_right;
delete from dm_cs_ch_os.ownership_real_estate;
delete from dm_cs_ch_os.ownership_property_pos;
delete from dm_cs_ch_os.ownership_property;

delete from dm_cs_ch_os.ownership_boundary_point;
delete from dm_cs_ch_os.ownership_property_revision;

with nf as 
(
    insert into 
        dm_cs_ch_os.ownership_property_revision (t_id, revision_id, 
        description, state_of, perimeter)
    select 
        t_id, identifikator as revision_id, beschreibung as description, 
        gueltigereintrag as state_of, perimeter as perimeter
    from 
        dm01_tmp.liegenschaften_lsnachfuehrung
    returning *
),
bp as 
(
    insert into
        dm_cs_ch_os.ownership_boundary_point (t_id, anumber, mark, 
        r_property_revision, geometry)
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
        entstehung as r_property_revision, ST_Force3D(geometrie) as geometry
    from
        dm01_tmp.liegenschaften_grenzpunkt
    returning *
),
property as 
(
    insert into
        dm_cs_ch_os.ownership_property (t_id, anumber, egris_egrid, validity, 
        completeness, total_area, r_property_revision)
    select 
        t_id, nummer as anumber, 
        case 
            when egris_egrid is null then substring(md5(random()::text) from 1 for 14)
            else egris_egrid
        end as egris_egrid,
        case 
            when gueltigkeit = 'rechtskraeftig' then 'in_effect'
            else 'disputed'
        end as validity,
        case 
            when vollstaendigkeit = 'Vollstaendig' then 'complete'
            else 'incomplete'
        end as completeness,
        gesamteflaechenmass as total_area,
        entstehung as r_property_revision
    from
        dm01_tmp.liegenschaften_grundstueck
    returning *
),
property_pos as
(
    insert into 
        dm_cs_ch_os.ownership_property_pos (t_id, ori, hali, vali, pos, r_property)
    select 
        t_id, ori, hali, vali, ST_Force3D(pos), grundstueckpos_von as r_property
    from 
        dm01_tmp.liegenschaften_grundstueckpos
    returning *
),
real_estate as 
(
    insert into 
        dm_cs_ch_os.ownership_real_estate (t_id, number_property_part,
        area, r_property, geometry)
    select 
        t_id, nummerteilgrundstueck as number_property_part, 
        flaechenmass as area, liegenschaft_von as r_property,
        ST_SnaptoGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from 
        dm01_tmp.liegenschaften_liegenschaft
    returning *
),
dpr as 
(
    insert into 
        dm_cs_ch_os.ownership_distinct_permanent_right (t_id, number_property_part,
        area, atype, r_property, geometry)
        
    select 
        sr.t_id, sr.nummerteilgrundstueck as number_property_part,
        sr.flaechenmass as area,
        case 
            when g.art = 'SelbstRecht.Baurecht' then 'building_right'
            when g.art = 'SelbstRecht.Quellenrecht' then 'right_to_spring_water'
            when g.art = 'SelbstRecht.Konzession' then 'concession'
        end as atype, sr.selbstrecht_von as r_property, 
        ST_SnaptoGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from
        dm01_tmp.liegenschaften_selbstrecht as sr,
        dm01_tmp.liegenschaften_grundstueck as g 
    where 
        sr.selbstrecht_von = g.t_id
    returning *
),
mineral_right as 
(
    insert into 
        dm_cs_ch_os.ownership_mineral_right (t_id, number_property_part,
        area, r_property, geometry)
    select
        t_id, nummerteilgrundstueck as number_property_part, 
        flaechenmass as area, bergwerk_von as r_property,
        ST_SnaptoGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from
        dm01_tmp.liegenschaften_bergwerk 
    returning *
),
property_proj as 
(
    insert into
        dm_cs_ch_os.ownership_property_proj (t_id, anumber, egris_egrid, validity, 
        completeness, total_area, r_property_revision)
    select 
        t_id, nummer as anumber, 
        case 
            when egris_egrid is null then substring(md5(random()::text) from 1 for 14)
            else egris_egrid
        end as egris_egrid,
        case 
            when gueltigkeit = 'rechtskraeftig' then 'in_effect'
            else 'disputed'
        end as validity,
        case 
            when vollstaendigkeit = 'Vollstaendig' then 'complete'
            else 'incomplete'
        end as completeness,
        gesamteflaechenmass as total_area,
        entstehung as r_property_revision
    from
        dm01_tmp.liegenschaften_projgrundstueck
    returning *
),
property_proj_pos as
(
    insert into 
        dm_cs_ch_os.ownership_property_proj_pos (t_id, ori, hali, vali, pos, r_property_proj)
    select 
        t_id, ori, hali, vali, ST_Force3D(pos), projgrundstueckpos_von as r_property_proj
    from 
        dm01_tmp.liegenschaften_projgrundstueckpos
    returning *
),
real_estate_proj as 
(
    insert into 
        dm_cs_ch_os.ownership_real_estate_proj (t_id, number_property_part,
        area, r_property_proj, geometry)
    select 
        t_id, nummerteilgrundstueck as number_property_part, 
        flaechenmass as area, projliegenschaft_von as r_property_proj,
        ST_SnaptoGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from 
        dm01_tmp.liegenschaften_projliegenschaft
    returning *
),
dpr_proj as 
(
    insert into 
        dm_cs_ch_os.ownership_distinct_permanent_right_proj (t_id, number_property_part,
        area, atype, r_property_proj, geometry)
        
    select 
        sr.t_id, sr.nummerteilgrundstueck as number_property_part,
        sr.flaechenmass as area,
        case 
            when g.art = 'SelbstRecht.Baurecht' then 'building_right'
            when g.art = 'SelbstRecht.Quellenrecht' then 'right_to_spring_water'
            when g.art = 'SelbstRecht.Konzession' then 'concession'
        end as atype, sr.projselbstrecht_von as r_property_proj, 
        ST_SnaptoGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from
        dm01_tmp.liegenschaften_projselbstrecht as sr,
        dm01_tmp.liegenschaften_projgrundstueck as g 
    where 
        sr.projselbstrecht_von = g.t_id
    returning *
),
mineral_right_proj as 
(
    insert into 
        dm_cs_ch_os.ownership_mineral_right_proj (t_id, number_property_part,
        area, r_property_proj, geometry)
    select
        t_id, nummerteilgrundstueck as number_property_part, 
        flaechenmass as area, projbergwerk_von as r_property_proj,
        ST_SnaptoGrid(ST_Force3D(geometrie), 0.00001) as geometry
    from
        dm01_tmp.liegenschaften_projbergwerk 
    returning *
)
select 
    *
from  
    mineral_right_proj
    
    
