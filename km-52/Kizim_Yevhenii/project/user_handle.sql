-- add user
CREATE OR REPLACE PACKAGE user_handle AS
    TYPE users_tbl IS
        TABLE OF users%rowtype;
    PROCEDURE add_user (
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        hash_ IN varchar2
    );

    PROCEDURE edit_user (
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE
    );

    PROCEDURE delete_user (
        user_id_   IN         users.user_id%TYPE
    );
    
    PROCEDURE update_hash (
        user_id_   IN         users.user_id%TYPE,
        hash_ IN varchar2
    );

    FUNCTION get_user (
        user_id_   IN         users.user_id%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION filter_users (
        rolename_   users.rolename%TYPE,
        name_       users.name%TYPE,
        hash_       varchar2
    ) RETURN users_tbl
        PIPELINED;
        
    FUNCTION get_hash (
        id_ users.user_id%type
    ) RETURN varchar2;
    
    
END user_handle;
/

CREATE OR REPLACE PACKAGE BODY user_handle AS

    PROCEDURE add_user (
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        hash_       IN          varchar2
    ) IS
    BEGIN
        INSERT INTO users (
            user_id,
            rolename,
            name,
            user_hash,
            usercreatedtime
        ) VALUES (
            user_id_,
            rolename_,
            name_,
            hextoraw(hash_),
            current_timestamp
        );

    END add_user;

    PROCEDURE edit_user (
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE
    ) IS
    BEGIN
        UPDATE users
        SET
            rolename = rolename_,
            name = name_
        WHERE
            user_id = user_id_;

    END edit_user;

    PROCEDURE delete_user (
        user_id_   IN         users.user_id%TYPE
    ) IS
    BEGIN
        DELETE FROM users
        WHERE
            user_id = user_id_;

    END delete_user;
    
    PROCEDURE update_hash (
        user_id_   IN         users.user_id%TYPE,
        hash_ IN varchar2
    ) IS
    BEGIN
        UPDATE USERS
        SET user_hash=hash_
        WHERE user_id = user_id_;
    
    END update_hash;

    FUNCTION get_user (
        user_id_   IN         users.user_id%TYPE
    ) RETURN SYS_REFCURSOR IS
        user_row   SYS_REFCURSOR;
    BEGIN
        OPEN user_row FOR SELECT
                              *
                          FROM
                              users
                          WHERE
                              user_id = user_id_;

        RETURN user_row;
    END get_user;

    FUNCTION filter_users (
        rolename_   users.rolename%TYPE,
        name_       users.name%TYPE,
        hash_       varchar2
    ) RETURN users_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE userscursor IS REF CURSOR;
        ucur       userscursor;
        urec       users%rowtype;
    BEGIN
        IF rolename_ IS NULL AND name_ IS NULL AND hash_ IS NULL THEN
            exec_str := 'SELECT * FROM users';
        ELSE
            exec_str := 'SELECT * FROM users WHERE ';
            IF rolename_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'users.ROLENAME='''
                            || rolename_
                            || ''' AND ';
            END IF;

            IF name_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(users.name, '''
                            || name_
                            || ''') > 0 AND ';
            END IF;
            
            IF hash_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'user_hash=UPPER('''
                            || hash_
                            || ''') AND ';
            END IF;

            exec_str := exec_str || '0=0';
        END IF;

        OPEN ucur FOR exec_str;

        LOOP
            FETCH ucur INTO urec;
            EXIT WHEN ucur%notfound;
            PIPE ROW ( urec );
        END LOOP;

    END filter_users;
    
    FUNCTION get_hash (
        id_ users.user_id%type
    ) RETURN varchar2
    IS
        hash_ varchar2(64);
    BEGIN
        select user_hash into hash_ from users
        where user_id = id_;
        RETURN hash_;
    END get_hash;

END user_handle;