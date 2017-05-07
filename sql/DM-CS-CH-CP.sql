delete from dm_cs_ch_cp.control_points_control_point;
delete from dm_cs_ch_cp.control_points_control_point_revision;

with lfp as
(
    select 
        t_id, 'PCP1' as category, nummer, geometrie, hoehegeom, punktzeichen, entstehung
    from 
        ch_252000.fixpunktekatgrie1_lfp1
        
    union all    
    
    select 
        t_id, 'PCP2' as category, nummer, geometrie, hoehegeom, punktzeichen, entstehung
    from 
        ch_252000.fixpunktekatgrie2_lfp2
        
    union all
    
    select 
        t_id, 'PCP3' as category, nummer, geometrie, hoehegeom, punktzeichen, entstehung
    from 
        ch_252000.fixpunktekatgrie3_lfp3
),
-- TODO: CASE WHEN gueltigereintrag IS NULL
nf as (
	insert into 
		dm_cs_ch_cp.control_points_control_point_revision (t_id, description, state_of, perimeter)
		
    select 
        t_id, beschreibung as description, gueltigereintrag as state_of, ST_Force3D(perimeter) as perimeter
    from 
        ch_252000.fixpunktekatgrie1_lfp1nachfuehrung
        
    union all
    
    select 
        t_id, beschreibung as description, gueltigereintrag as state_of, ST_Force3D(perimeter) as perimeter
    from 
        ch_252000.fixpunktekatgrie2_lfp2nachfuehrung
        
    union all
    
    select 
        t_id, beschreibung as description, gueltigereintrag as state_of, ST_Force3D(perimeter) as perimeter
    from 
        ch_252000.fixpunktekatgrie3_lfp3nachfuehrung
    returning *
),
lfp_ng as
(
	insert into 
   		dm_cs_ch_cp.control_points_control_point (t_id, category, anumber,
    	geometry, mark, r_control_point_revision)
    select 
        lfp.t_id, lfp.category, lfp.nummer as anumber, 
        case 
            when hoehegeom is null then ST_SetSRID(ST_MakePoint(ST_X(geometrie), ST_Y(geometrie), 0), 2056)
            else ST_SetSRID(ST_MakePoint(ST_X(geometrie), ST_Y(geometrie), hoehegeom), 2056)
        end as geometry,
        case 
            when punktzeichen = 'Stein' then 'boundary_marker'
            when punktzeichen = 'Bolzen' then 'bolt'
            when punktzeichen = 'Rohr' then 'tube'
            when punktzeichen = 'Kreuz' then 'cross'
            else 'other'
        end as mark,
        nf.t_id as r_control_point_revision
    from
        lfp,
        nf  
    where
        lfp.entstehung = nf.t_id
    returning *
)
select
	*
from
	lfp_ng;
