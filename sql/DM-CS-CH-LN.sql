delete from dm_cs_ch_ln.local_names_name_of_locality_pos_name;
delete from dm_cs_ch_ln.local_names_name_of_locality;

delete from dm_cs_ch_ln.local_names_place_name_pos_name;
delete from dm_cs_ch_ln.local_names_place_name;

delete from dm_cs_ch_ln.local_names_local_geographical_name_pos_name;
delete from dm_cs_ch_ln.local_names_local_geographical_name;

delete from dm_cs_ch_ln.local_names_local_name_revision;

with nf as
(
	insert into 
		dm_cs_ch_ln.local_names_local_name_revision (t_id, revision_id, description, 
		state_of, perimeter)
	select 
		t_id, identifikator as revision_id, beschreibung as description, gueltigereintrag as state_of, 
		ST_SnapToGrid(ST_Force3D(perimeter), 0.00001) as perimeter
	from 
		dm01_tmp.nomenklatur_nknachfuehrung
	returning *
),
local_geo_name as
(
	insert into
		dm_cs_ch_ln.local_names_local_geographical_name (t_id, aname, 
		r_geographical_name_local_name_revision, geometry)
	select 
		flurn.t_id, flurn.aname, flurn.entstehung as r_geographical_name_local_name_revision, 
		ST_SnapToGrid(ST_Force3D(flurn.geometrie), 0.00001) as geometry
	from
		nf,
		dm01_tmp.nomenklatur_flurname as flurn
	where
		nf.t_id = flurn.entstehung
	returning *
),
local_geo_name_pos as
(
	insert into 
		dm_cs_ch_ln.local_names_local_geographical_name_pos_name (t_id, ori, hali, vali,
		r_local_geographical_name, pos)
	select 
		t_id, ori, hali, vali, flurnamepos_von as r_local_geographical_name, ST_Force3D(pos) as pos
	from 
		dm01_tmp.nomenklatur_flurnamepos
	returning *
),
place_name as 
(
	insert into 
		dm_cs_ch_ln.local_names_place_name (t_id, aname, 
		r_place_name_revision, geometry)
	select 
		ort.t_id, ort.aname, ort.entstehung as r_place_name_revision, 
		ST_SnapToGrid(ST_Force3D(ort.geometrie), 0.00001) as geometry
	from
		nf,
		dm01_tmp.nomenklatur_ortsname as ort
	where
		nf.t_id = ort.entstehung
	returning *
),
place_name_pos as
(
	insert into 
		dm_cs_ch_ln.local_names_place_name_pos_name (t_id, ori, hali, vali,
		r_place_name, pos)
	select 
		t_id, ori, hali, vali, ortsnamepos_von as r_place_name, ST_Force3D(pos) as pos
	from 
		dm01_tmp.nomenklatur_ortsnamepos
	returning *
),
name_of_locality as 
(
	insert into 
		dm_cs_ch_ln.local_names_name_of_locality (t_id, aname, 
		r_name_of_locality_revision, geometry)
	select 
		gel.t_id, gel.aname, gel.entstehung as r_name_of_locality_revision, 
		ST_Force3D(gelpos.pos) as geometry
	from
		nf,
		dm01_tmp.nomenklatur_ortsname as gel,
		dm01_tmp.nomenklatur_gelaendenamepos as gelpos
	where
		nf.t_id = gel.entstehung
	and
		gelpos.gelaendenamepos_von = gel.t_id
	returning *
),
name_of_locality_pos as
(
	insert into 
		dm_cs_ch_ln.local_names_name_of_locality_pos_name (t_id, ori, hali, vali,
		r_name_of_locality, pos)
	select 
		t_id, ori, hali, vali, gelaendenamepos_von as r_name_of_locality, ST_Force3D(pos) as pos
	from 
		dm01_tmp.nomenklatur_gelaendenamepos
	returning *
)
select 
	*
from
	name_of_locality_pos;




