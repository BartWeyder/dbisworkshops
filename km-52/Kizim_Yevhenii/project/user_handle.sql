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
        phone_      IN          users.phone%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        email_      IN          users.email%TYPE
    );

    PROCEDURE delete_user (
        phone_   IN       users.phone%TYPE
    );

    FUNCTION get_user (
        phone_   IN       users.phone%TYPE
    ) RETURN users%rowtype;

    FUNCTION get_user_by_email (
        email_ users.email%TYPE
    ) RETURN users%rowtype;

    FUNCTION filter_users (
        rolename_   users.rolename%TYPE,
        name_       users.name%TYPE,
        email_      users.email%TYPE
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
        phone_      IN          users.phone%TYPE,
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

    FUNCTION filter_users (
        rolename_   users.rolename%TYPE,
        name_       users.name%TYPE,
        email_      users.email%TYPE
    ) RETURN users_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE userscursor IS REF CURSOR;
        ucur       userscursor;
        urec       users%rowtype;
    BEGIN
        IF rolename_ IS NULL AND name_ IS NULL AND email_ IS NULL THEN
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

            IF email_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(users.email, '''
                            || email_
                            || ''') > 0 AND ';
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

END user_handle;