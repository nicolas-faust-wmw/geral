alter system set processes = 300 scope = spfile;
alter system set sessions = 500 scope = spfile;
alter system set parallel_degree_policy = 'AUTO' scope = spfile;
ALTER SYSTEM SET parallel_threads_per_cpu = 4;

SELECT COUNT(*)
  FROM v$session;

SELECT RESOURCE_NAME, CURRENT_UTILIZATION, MAX_UTILIZATION, LIMIT_VALUE
FROM V$RESOURCE_LIMIT
WHERE RESOURCE_NAME IN ( 'sessions', 'processes', 'parallel_threads_per_cpu');


select
    resource_name,
    current_utilization, limit_value 
from v$resource_limit ;

SELECT name, value 
FROM v$parameter
where name like '%parallel%';


CREATE INDEX "IDX_SYNC_ITEMTABELAPRECO" ON "TBLVPITEMTABELAPRECO" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_DESCQUANTIDADE" ON "TBLVPDESCQUANTIDADE" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_DESCPROMOCIONAL" ON "TBLVPDESCPROMOCIONAL" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_PRODUTOTABPRECO" ON "TBLVPPRODUTOTABPRECO" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_FOTOPRODUTO" ON "TBLVPFOTOPRODUTO" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_PEDIDOERP" ON "TBLVPPEDIDOERP" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_PEDIDOERPDIF" ON "TBLVPPEDIDOERPDIF" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;

CREATE INDEX "IDX_SYNC_ITEMPEDIDOERPDIF" ON "TBLVPITEMPEDIDOERPDIF" ("CDUSUARIO", "NUCARIMBO") 
TABLESPACE "WMW_HOM2_INDEX" ;


SELECT   
	'alter table '||t.owner||'.'||t.table_name||' move lob ('||column_name|| ') store as (tablespace TBS_LOB);' CMD
FROM dba_lobs l, dba_tables t
WHERE 
	l.owner = t.owner
AND l.table_name = t.table_name
AND l.SEGMENT_NAME IN(
		SELECT segment_name
		FROM dba_segments
		WHERE 
			segment_type = 'LOBSEGMENT'
		AND OWNER = 'SCOTT'
		AND tablespace_name = 'TBS_DATA'
	)
AND l.owner = 'SCOTT'
ORDER BY t.owner, t.table_name;


SELECT 'alter index '||owner||'.'||index_name||' rebuild tablespace TBS_INDX;' CMD
FROM dba_indexes
WHERE index_type <> 'LOB' 
AND owner = 'SCOTT';


SELECT 'alter table '||owner||'.'||table_name||' move tablespace USERS;' CMD
FROM dba_tables
WHERE owner = 'SCOTT';


select 
	a.file_id,
	a.file_name,
	ceil((nvl(hwm,1)*8192)/1024) smallest,
	ceil(blocks*8192/1024) currsize,
	ceil(blocks*8192/1024) - ceil((nvl(hwm,1)*8192)/1024) savings
from dba_data_files a, (
	select 
		file_id, 
		max(block_id+blocks-1) hwm
	from dba_extents 
	where owner='TESTE'
	group by file_id
) b 
where a.file_id = b.file_id;


select sesion.sid, sesion.serial#,
sql_text, sesion.username, 'ALTER SYSTEM KILL SESSION '''||sesion.sid||','||sesion.serial#||''';'
from v$sqltext sqltext, v$session sesion
where sesion.sql_hash_value = sqltext.hash_value
and sesion.sql_address = sqltext.address
and sesion.username is not null
and sesion.username in('RDAMASIOWVWEBHOM2','RDAMASIOWVWEBPRD', 'RDAMASIOWVWEBC5')
and sesion.status = 'ACTIVE'
order by sesion.sid DESC, sqltext.piece;



SELECT DISTINCT 
    owner, 
    --segment_name,
    segment_type, 
    tablespace_name
FROM dba_segments S
WHERE owner LIKE 'RDAMASIO%'
ORDER BY owner, SEGMENT_TYPE, TABLESPACE_NAME;



select 
	a.file_id,
	a.file_name,
	ceil((nvl(hwm,1)*8192)/1024) smallest,
	ceil(blocks*8192/1024) currsize,
	ceil(blocks*8192/1024) - ceil((nvl(hwm,1)*8192)/1024) savings,
    'ALTER DATABASE DATAFILE '||A.FILE_ID||' RESIZE '||ceil(((nvl(hwm,1)*8192)/1024)*1.1)||'k;' cmd
from dba_data_files a, (
	select 
		file_id, 
		max(block_id+blocks-1) hwm
	from dba_extents 
	where owner LIKE 'RDAMASIO%'
	group by file_id
) b 
where a.file_id = b.file_id
and ceil(((nvl(hwm,1)*8192)/1024)*1.1) < ceil(blocks*8192/1024)
order by ceil(blocks*8192/1024) - ceil((nvl(hwm,1)*8192)/1024) desc;


EXEC DBMS_STATS.GATHER_SYSTEM_STATS('');
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('start');
EXEC DBMS_STATS.GATHER_SYSTEM_STATS('interval', 1800);

EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVAPPC5', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVAPPPRD', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVAPPHOM', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVAPPHOM2', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVWEBC5', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVWEBPRD', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVWEBHOM', estimate_percent => 25, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVWEBHOM2', estimate_percent => 25, cascade => TRUE);


SELECT DISTINCT OWNER, TABLESPACE_NAME, 'ALTER INDEX ' || OWNER || '.'|| index_name ||' REBUILD;' 
FROM ALL_INDEXES 
WHERE OWNER LIKE 'RDAMASIO%'
UNION 
SELECT DISTINCT OWNER, TABLESPACE_NAME, 'ALTER TABLE ' || OWNER || '.'|| TABLE_NAME ||' DISABLE ROW MOVEMENT;' 
FROM ALL_TABLES 
WHERE OWNER LIKE 'RDAMASIO%'
UNION 
SELECT DISTINCT OWNER, TABLESPACE_NAME, 'ALTER TABLE ' || OWNER || '.'|| TABLE_NAME ||' SHRINK SPACE CASCADE;' 
FROM ALL_TABLES 
WHERE OWNER LIKE 'RDAMASIO%'
UNION 
SELECT DISTINCT OWNER, TABLESPACE_NAME, 'ALTER TABLE ' || OWNER || '.'|| TABLE_NAME ||' MOVE;' 
FROM ALL_TABLES 
WHERE OWNER LIKE 'RDAMASIO%'
UNION 
SELECT DISTINCT OWNER, TABLESPACE_NAME, 'ALTER TABLESPACE ' || TABLESPACE_NAME ||' COALESCE;' 
FROM DBA_SEGMENTS
WHERE OWNER LIKE 'RDAMASIO%';



EXEC DBMS_STATS.GATHER_SYSTEM_STATS();
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVAPPC5PRD', estimate_percent => 10, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVWEBC5PRD', estimate_percent => 10, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVAPPPRD', estimate_percent => 10, cascade => TRUE);
EXEC DBMS_STATS.gather_schema_stats('RDAMASIOWVWEBPRD', estimate_percent => 10, cascade => TRUE);



select sesion.sid, sesion.serial#,
sql_text, sesion.username, 'ALTER SYSTEM KILL SESSION '''||sesion.sid||','||sesion.serial#||''';'
from v$sqltext sqltext, v$session sesion
where sesion.sql_hash_value = sqltext.hash_value
and sesion.sql_address = sqltext.address
and sesion.username is not null
and sesion.username in('RDAMASIOWVWEBC5PRD')
and sesion.status = 'ACTIVE'
order by sesion.sid DESC, sqltext.piece;



select 
    'ALTER SYSTEM KILL SESSION '''||sesion.sid||','||sesion.serial#||''';'
from v$session sesion 
where module='DBMS_SCHEDULER';

select * from DBA_TABLESPACES;

show PARAMETERS;

select * from V$PARAMETER;

alter system set processes = 150 scope = SPFILE;
alter system set sessions = 300 scope = spfile;
alter system set transactions = 330 scope = spfile;  

select COUNT(*) from v$session WHERE status = 'ACTIVE';


SELECT * FROM DBA_DIRECTORIES;


SELECT 
    'Blocking Session   	  : ' || do_loop.session_id,
    'Object Type        	  : ' || do_loop.object_type,
    'Sessions being blocked   : ' || l.sid
FROM v$lock L, (
    SELECT 
        session_id,
        a.object_id,
        xidsqn,
        oracle_username,
        b.owner owner,
        b.object_name object_name,
        b.object_type object_type
    FROM v$locked_object a, dba_objects b
    WHERE xidsqn != 0 
    AND b.object_id = a.object_id
) do_loop
WHERE 
	l.id2 = do_loop.xidsqn 
AND l.sid != do_loop.session_id;






