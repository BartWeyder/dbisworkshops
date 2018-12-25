-- add user
CREATE OR REPLACE PACKAGE user_handle AS
    TYPE users_tbl IS
        TABLE OF users%rowtype;
    PROCEDURE add_user (
        status      OUT         VARCHAR2,
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        hash_       IN          VARCHAR2
    );

    PROCEDURE edit_user (
        status      OUT         VARCHAR2,
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE
    );

    PROCEDURE delete_user (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE
    );

    PROCEDURE update_hash (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE,
        hash_      IN         VARCHAR2
    );

    PROCEDURE block_user (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE
    );

    PROCEDURE unblock_user (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE
    );

    FUNCTION get_user (
        user_id_   IN         users.user_id%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION filter_users (
        rolename_   users.rolename%TYPE,
        name_       users.name%TYPE,
        hash_       VARCHAR2
    ) RETURN users_tbl
        PIPELINED;

    FUNCTION get_hash (
        id_ users.user_id%TYPE
    ) RETURN VARCHAR2;

END user_handle;
/

CREATE OR REPLACE PACKAGE BODY user_handle AS

    PROCEDURE add_user (
        status      OUT         VARCHAR2,
        user_id_    IN          users.user_id%TYPE,
        rolename_   IN          users.rolename%TYPE,
        name_       IN          users.name%TYPE,
        hash_       IN          VARCHAR2
    ) IS
        counter    INTEGER := 0;
        blocked_   DATE := NULL;
        deleted_   DATE := NULL;
    BEGIN
        SELECT
            COUNT(*)
        INTO counter
        FROM
            users
        WHERE
            user_id = user_id_;

        IF counter = 0 THEN
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

            status := 'ok';
        ELSE
            SELECT
                blocked
            INTO blocked_
            FROM
                users
            WHERE
                user_id = user_id_;

            IF blocked_ IS NULL THEN
                SELECT
                    deleted
                INTO deleted_
                FROM
                    users
                WHERE
                    user_id = user_id_;

                IF deleted_ IS NOT NULL THEN
                    UPDATE users
                    SET
                        deleted = NULL;

                    status := 'ok';
                END IF;

            ELSE
                status := 'User has been blocked.';
            END IF;

        END IF;

    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'user already exists';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'NAME_CHECK') != 0 THEN
                status := 'Name allows only alpha symbols';
            ELSIF instr(sqlerrm, 'PK_USER') != 0 THEN
                status := 'user already exists';
            ELSE
                status := ( sqlcode
                            || ' '
                            || sqlerrm );
            END IF;
    END add_user;

    PROCEDURE edit_user (
        status      OUT         VARCHAR2,
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

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'NAME_CHECK') != 0 THEN
                status := 'Name allows only alpha symbols';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;
    END edit_user;

    PROCEDURE delete_user (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE
    ) IS
    BEGIN
        UPDATE users
        SET
            deleted = current_timestamp
        WHERE
            user_id = user_id_;

        UPDATE post
        SET
            published = NULL
        WHERE
            user_id = user_id_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while user deletion. Please contact support.';
    END delete_user;

    PROCEDURE update_hash (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE,
        hash_      IN         VARCHAR2
    ) IS
    BEGIN
        UPDATE users
        SET
            user_hash = hash_
        WHERE
            user_id = user_id_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while user updating credentials. Please contact support.';
    END update_hash;

    PROCEDURE block_user (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE
    ) IS
    BEGIN
        UPDATE users
        SET
            blocked = current_timestamp
        WHERE
            user_id = user_id_;

        UPDATE post
        SET
            published = NULL
        WHERE
            user_id = user_id_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while user blocking. Please contact support.';
    END block_user;

    PROCEDURE unblock_user (
        status     OUT        VARCHAR2,
        user_id_   IN         users.user_id%TYPE
    ) IS
    BEGIN
        UPDATE users
        SET
            blocked = NULL
        WHERE
            user_id = user_id_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while user unblocking. Please contact support.';
    END unblock_user;

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
        hash_       VARCHAR2/*,
        deleted_    users.deleted%TYPE,
        blocked_    users.blocked%TYPE*/
    ) RETURN users_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE userscursor IS REF CURSOR;
        ucur       userscursor;
        urec       users%rowtype;
    BEGIN
        IF rolename_ IS NULL AND name_ IS NULL AND hash_ IS NULL /*AND deleted_ IS NULL AND blocked_ IS NULL*/ THEN
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

        exec_str := exec_str || ' ORDER BY USERCREATEDTIME DESC';
        OPEN ucur FOR exec_str;

        LOOP
            FETCH ucur INTO urec;
            EXIT WHEN ucur%notfound;
            PIPE ROW ( urec );
        END LOOP;

    END filter_users;

    FUNCTION get_hash (
        id_ users.user_id%TYPE
    ) RETURN VARCHAR2 IS
        hash_   VARCHAR2(64);
    BEGIN
        SELECT
            user_hash
        INTO hash_
        FROM
            users
        WHERE
            user_id = id_;

        RETURN hash_;
    END get_hash;

END user_handle;