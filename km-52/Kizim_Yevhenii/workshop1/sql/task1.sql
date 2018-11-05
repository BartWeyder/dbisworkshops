declare
    cursor role_cur is select ROLENAME from role;
    role_rec role_cur%rowtype;

begin
    if NOT role_cur%ISOPEN THEN
        OPEN role_cur;
    end if;
    fetch role_cur into role_rec;
    -- inserting first
    insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
    values('+380672555555', role_rec.ROLENAME, 'Bobby', 'smth@xyz.com', CURRENT_TIMESTAMP);
    -- inserting second
    insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
    values('+380672555555', role_rec.ROLENAME, 'Robin', 'robin@xyz.com', CURRENT_TIMESTAMP);
end;