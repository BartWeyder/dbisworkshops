CREATE OR REPLACE PACKAGE role_handle AS
    TYPE roles_tbl IS
        TABLE OF role%rowtype;
    system_roles_deletion EXCEPTION;
    PROCEDURE add_role (
        status         OUT varchar2,
        rolename_ role.rolename%TYPE
    );

    PROCEDURE delete_role (
        status         OUT varchar2,
        rolename_ role.rolename%TYPE
    );

    FUNCTION get_role (
        rolename_ role.rolename%TYPE
    ) RETURN role%rowtype;

    FUNCTION filter_roles (
        rolename_ role.rolename%TYPE
    ) RETURN roles_tbl
        PIPELINED;

END role_handle;
/

CREATE OR REPLACE PACKAGE BODY role_handle AS

    PROCEDURE add_role (
        status         OUT varchar2,
        rolename_ role.rolename%TYPE
    ) IS
    BEGIN
        INSERT INTO role VALUES ( rolename_ );
        status := 'ok';
        
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Role already exists';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'ROLE_NAME_CHECK') != 0 THEN
                status := 'Role name allows only alphanumeric values.';
            ELSIF instr(sqlerrm, 'PK_ROLE') != 0 THEN
                status := 'Role already exists';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;
    END add_role;

    PROCEDURE delete_role (
        status         OUT varchar2,
        rolename_ role.rolename%TYPE
    ) IS
    BEGIN
        IF NOT ( rolename_ = 'user' AND rolename_ = 'superuser' ) THEN
            DELETE role
            WHERE
                rolename = rolename_;
            status := 'ok';

        ELSE
            status := 'System role deletion is denied.';
        END IF;
        
            
        
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while role deletion. Please contact support.';
            
    END delete_role;

    FUNCTION get_role (
        rolename_ role.rolename%TYPE
    ) RETURN role%rowtype IS
        rrec   role%rowtype;
    BEGIN
        SELECT
            *
        INTO rrec
        FROM
            role
        WHERE
            role.rolename = rolename_;

        RETURN rrec;
    END get_role;

    FUNCTION filter_roles (
        rolename_ role.rolename%TYPE
    ) RETURN roles_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE rolecursor IS REF CURSOR;
        rcur       rolecursor;
        rrec       role%rowtype;
    BEGIN
        IF rolename_ IS NULL THEN
            exec_str := 'SELECT * FROM role';
        ELSE
            exec_str := 'SELECT * FROM role WHERE instr(role.rolename, '''
                        || rolename_
                        || ''') > 0';
        END IF;

        OPEN rcur FOR exec_str;

        LOOP
            FETCH rcur INTO rrec;
            EXIT WHEN rcur%notfound;
            PIPE ROW ( rrec );
        END LOOP;

    END filter_roles;

END role_handle;
/