-- launch partially --
declare
temp users%rowtype;
begin
    temp := user_handle.get_user_by_email('bob.marley@abc.com');
    dbms_output.put_line(temp.phone);
end;
-- end --

-- new part --
select * from TABLE(user_handle.get_user_by_name('S'));
-- end --