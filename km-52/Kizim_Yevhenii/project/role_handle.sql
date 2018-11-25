CREATE OR REPLACE PACKAGE role_handle AS
    TYPE roles_tbl IS
        TABLE OF role%rowtype;
    system_roles_deletion EXCEPTION;
    PROCEDURE add_role (
        rolename_ role.rolename%TYPE
    );

    PROCEDURE delete_role (
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
        rolename_ role.rolename%TYPE
    ) IS
    BEGIN
        INSERT INTO role VALUES ( rolename_ );

    END add_role;

    PROCEDURE delete_role (
        rolename_ role.rolename%TYPE
    ) IS
    BEGIN
        IF NOT ( rolename_ = 'user' AND rolename_ = 'superuser' ) THEN
            DELETE role
            WHERE
                rolename = rolename_;

        ELSE
            RAISE system_roles_deletion;
        END IF;
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