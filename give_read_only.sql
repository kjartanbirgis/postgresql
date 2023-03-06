create role give_read_only;

CREATE OR REPLACE FUNCTION public.give_read_only(
	)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
    SET search_path=pg_temp
AS $BODY$
declare 
rec record;
begin
for rec in select distinct table_schema from information_schema.tables order by table_schema
	Loop
		execute 'grant usage on schema ' || quote_ident(rec.table_schema) || ' to read_only_db';
		execute 'grant select on all sequences in schema ' || quote_ident(rec.table_schema) || ' to read_only_db';
		
	end loop;
	
for rec in select table_schema,table_name from information_schema.tables where table_type in ('BASE TABLE','VIEW')
Loop
	execute 'grant select on '|| quote_ident(rec.table_schema)||'.'||quote_ident(rec.table_name) || ' to read_only_db';
end loop;	

for rec in select schemaname,matviewname from pg_catalog.pg_matviews

Loop
	execute 'grant select on '|| quote_ident(rec.schemaname) ||'.' ||quote_ident(rec.matviewname)||' to read_only_db';
end loop;	
end;
$BODY$;
