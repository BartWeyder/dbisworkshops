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
    ) RETURN roles_tbl
        PIPELINED;

    FUNCTION get_all_roles RETURN roles_tbl
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
    ) RETURN roles_tbl
        PIPELINED
    IS
        CURSOR rcur IS
        SELECT
            *
        FROM
            role
        WHERE
            instr(role.rolename, rolename_) > 0;

    BEGIN
        FOR rrec IN rcur LOOP
            PIPE ROW ( rrec );
        END LOOP;
    END get_role;

    FUNCTION get_all_roles RETURN roles_tbl
        PIPELINED
    IS
        CURSOR rcur IS
        SELECT
            *
        FROM
            role;

    BEGIN
        FOR rrec IN rcur LOOP
            PIPE ROW ( rrec );
        END LOOP;
    END get_all_roles;

END role_handle;
/