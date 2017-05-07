delete from dm_cs_ch_gd.ground_displcmnts_ground_displacement;

insert into 
    dm_cs_ch_gd.ground_displcmnts_ground_displacement
    (t_id, aname, id, state_of, geometry)
select 
    t_id, aname as aname, identifikator as id,
    gueltigereintrag as state_of, 
    ST_SnapToGrid(ST_Force3D(geometrie), 0.00001) as geometry
from 
    dm01_tmp.rutschgebiete_rutschung;

