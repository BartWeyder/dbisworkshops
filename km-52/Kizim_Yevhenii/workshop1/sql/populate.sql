-- tag 
insert into tag(TITLE)
select dbms_random.string('A', 6)
from dual
connect by level <= 5;

-- CATEGORY
insert into CATEGORY(CATEGORYTITLE)
select dbms_random.string('A', 6)
from dual
connect by level <= 5;

--role
insert into ROLE(ROLENAME)
select dbms_random.string('A', 6)
from dual
connect by level <= 5;

declare 
    phone PLS_INTEGER;

    cursor role_ is select * from role;
    role_rec role_%rowtype;

    cursor us_cur is select phone from "USER";
    us_rec us_cur%rowtype;

    cursor cat_cur is select * from category;
    cat_rec cat_cur%rowtype;

    cursor post_cur is select pid from post;
    post_rec post_cur%rowtype;

    cursor tag_cur is select TITLE from tag;
    tag_rec tag_cur%rowtype;

    i number not null := 1;
begin
    --user
    FOR role_rec IN role_ LOOP
        phone := dbms_random.value(1000000, 9999999);
        insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
        values('+38067' || to_char(phone), role_rec.ROLENAME, dbms_random.string('A', 10), dbms_random.string('L', 6) || '@abc.com',
            CURRENT_TIMESTAMP);
    END LOOP;

    --post
    IF NOT us_cur%ISOPEN THEN 
        OPEN us_cur;
    END IF;
    FOR cat_rec in cat_cur LOOP
        fetch us_cur into us_rec;
        insert into post values(i, us_rec.PHONE, dbms_random.string('A', 15), dbms_random.string('A', 100), 
            1, CURRENT_TIMESTAMP, cat_rec.CATEGORYTITLE);
        i := i + 1;
    END LOOP; 
    close us_cur;
    
    -- post_has_tags
    i := 1;

    IF not post_cur%ISOPEN THEN
        OPEN post_cur; 
    END IF;
    FOR tag_rec in tag_cur LOOP
        fetch post_cur into post_rec;
        insert into post_has_tags values(post_rec.pid, tag_rec.title);
    END LOOP;

    close post_cur;

    -- answer
    IF NOT us_cur%ISOPEN THEN 
        OPEN us_cur;
    END IF;
    FOR post_rec in post_cur LOOP
        fetch us_cur into us_rec;
        insert into answer values(i, us_rec.PHONE, post_rec.pid, dbms_random.string('A', 15), dbms_random.string('A', 100), 
            CURRENT_TIMESTAMP);
        i := i + 1;
    END LOOP; 
end;
    
