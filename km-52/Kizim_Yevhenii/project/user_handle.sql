-- add user
CREATE OR REPLACE PACKAGE user_handle AS
    TYPE users_tbl IS
        TABLE OF users%rowtype;

    PROCEDURE add_user (
        phone_      IN          users.phone%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        email_      IN          users.email%TYPE
    );

    PROCEDURE edit_user (
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        email_      IN          users.email%TYPE
    );

    PROCEDURE delete_user (
        phone_   IN       users.phone%TYPE
    );
    
    FUNCTION get_all_users RETURN users_tbl PIPELINED;

    FUNCTION get_user (
        phone_   IN       users.phone%TYPE
    ) RETURN users%rowtype;

    FUNCTION get_user_by_email (
        email_ users.email%TYPE
    ) RETURN users%rowtype;

    FUNCTION get_user_by_name (
        name_ users.name%TYPE
    ) RETURN users_tbl
        PIPELINED;

    FUNCTION get_user_by_rolename (
        rolename_ users.rolename%TYPE
    ) RETURN users_tbl
        PIPELINED;

END user_handle;
/

CREATE OR REPLACE PACKAGE BODY user_handle AS

    PROCEDURE add_user (
        phone_      IN          users.phone%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        email_      IN          users.email%TYPE
    ) IS
    BEGIN
        INSERT INTO users (
            phone,
            rolename,
            name,
            email,
            usercreatedtime
        ) VALUES (
            phone_,
            rolename_,
            name_,
            email_,
            current_timestamp
        );

    END add_user;

    PROCEDURE edit_user (
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        email_      IN          users.email%TYPE
    ) IS
    BEGIN
        UPDATE users
        SET
            rolename = rolename_,
            name = name_,
            email = email_
        WHERE
            phone = phone_;

    END edit_user;

    PROCEDURE delete_user (
        phone_   IN       users.phone%TYPE
    ) IS
    BEGIN
        DELETE FROM users
        WHERE
            phone = phone_;

    END;
    
    FUNCTION get_all_users RETURN users_tbl PIPELINED
    IS
        CURSOR ucur IS
        SELECT
            *
        FROM
            users;

        urec   ucur%rowtype;
    begin
        FOR urec IN ucur LOOP
            PIPE ROW ( urec );
        END LOOP;
    end get_all_users;

    FUNCTION get_user (
        phone_   IN       users.phone%TYPE
    ) RETURN users%rowtype IS
        urec   users%rowtype;
    BEGIN
        SELECT
            *
        INTO urec
        FROM
            users
        WHERE
            phone = phone_;

        RETURN urec;
    END get_user;

    FUNCTION get_user_by_email (
        email_ users.email%TYPE
    ) RETURN users%rowtype IS
        urec   users%rowtype;
    BEGIN
        SELECT
            *
        INTO urec
        FROM
            users
        WHERE
            users.email = email_;

        RETURN urec;
    END get_user_by_email;

    FUNCTION get_user_by_name (
        name_ users.name%TYPE
    ) RETURN users_tbl
        PIPELINED
    IS

        CURSOR ucur IS
        SELECT
            *
        FROM
            users
        WHERE
            instr(users.name, name_) > 0;

        urec   ucur%rowtype;
    BEGIN
        FOR urec IN ucur LOOP
            PIPE ROW ( urec );
        END LOOP;
    END get_user_by_name;

    FUNCTION get_user_by_rolename (
        rolename_ users.rolename%TYPE
    ) RETURN users_tbl
        PIPELINED
    IS
        CURSOR ucur IS
        SELECT
            *
        FROM
            users
        WHERE
            users.rolename = rolename_;

        urec   ucur%rowtype;
    BEGIN
        FOR urec IN ucur LOOP
            PIPE ROW ( urec );
        END LOOP;
    END get_user_by_rolename;

END user_handle;