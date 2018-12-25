-- RUN THIS SCRIPT AFTER TAG_HANDLE --
CREATE SEQUENCE post_ids START WITH 5 INCREMENT BY 1 CACHE 2;

CREATE OR REPLACE PACKAGE post_handle IS
    TYPE single_tag IS RECORD (
        title tag.title%TYPE
    );
    TYPE post_tag_table IS
        TABLE OF single_tag;
    TYPE post_tbl IS
        TABLE OF post%rowtype;
   
    FUNCTION add_post (
        status       OUT          VARCHAR2,
        user_id_     post.user_id%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE
    ) RETURN post.pid%TYPE;

    PROCEDURE edit_post (
        status       OUT          VARCHAR2,
        pid_         post.pid%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    category.categorytitle%TYPE
    );

--    PROCEDURE delete_post (
--        status   OUT      VARCHAR2,
--        pid_     post.pid%TYPE
--    );

    PROCEDURE publicate (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE
    );

    PROCEDURE hide_post (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE
    );

    PROCEDURE add_tag_to_post (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE,
        tag_     tag.title%TYPE
    );

    PROCEDURE delete_tag_from_post (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE,
        tag_     tag.title%TYPE
    );

    FUNCTION get_post (
        pid_ post.pid%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION filter_posts (
        user_id_     post.user_id%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE,
        status_      post.published%TYPE
    ) RETURN post_tbl
        PIPELINED;

    FUNCTION get_post_tags (
        pid_ post.pid%TYPE
    ) RETURN post_tag_table
        PIPELINED;

END post_handle;
/

CREATE OR REPLACE PACKAGE BODY post_handle AS

    FUNCTION add_post (
        status       OUT          VARCHAR2,
        user_id_     post.user_id%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE
    ) RETURN post.pid%TYPE IS
        new_id   post.pid%TYPE;
    BEGIN
        new_id := post_ids.nextval;
        INSERT INTO post (
            pid,
            user_id,
            posttitle,
            posttext,
            published,
            postcreatedtime,
            categorytitle
        ) VALUES (
            new_id,
            user_id_,
            posttitle_,
            posttext_,
            NULL,
            current_timestamp,
            category_
        );

        status := 'ok';
        RETURN new_id;
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'post already exists';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'POST_TEXT_CHECK') != 0 THEN
                status := 'Text allows only alphanumeric symbols and .,!?<>\/-';
            ELSIF instr(sqlerrm, 'POST_TITLE_CHECK') != 0 THEN
                status := 'Title allows only alphabethic symbols and ,!.-';
            ELSIF instr(sqlerrm, 'POST_UNIQUE') != 0 THEN
                status := 'Similar post already exists.';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;
    END add_post;

    PROCEDURE edit_post (
        status       OUT          VARCHAR2,
        pid_         post.pid%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    category.categorytitle%TYPE
    ) IS
    BEGIN
        UPDATE post
        SET
            posttitle = posttitle_,
            posttext = posttext_,
            categorytitle = category_
        WHERE
            post.pid = pid_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'POST_TEXT_CHECK') != 0 THEN
                status := 'Text allows only alphanumeric symbols and .,!?<>\/-';
            ELSIF instr(sqlerrm, 'POST_TITLE_CHECK') != 0 THEN
                status := 'Title allows only alphabethic symbols and ,!.-';
            ELSIF instr(sqlerrm, 'POST_UNIQUE') != 0 THEN
                status := 'Similar post already exists.';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;
    END edit_post;

--    PROCEDURE delete_post (
--        status   OUT      VARCHAR2,
--        pid_     post.pid%TYPE
--    ) IS
--    BEGIN
--        DELETE FROM post
--        WHERE
--            post.pid = pid_;
--
--        status := 'ok';
--    EXCEPTION
--        WHEN OTHERS THEN
--            status := 'Uknown error while deletion. Please contact support.';
--    END delete_post;

    PROCEDURE publicate (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE
    ) IS
    BEGIN
        UPDATE post
        SET
            published = current_timestamp
        where pid=pid_;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while publicating. Please contact support.';
    END publicate;

    PROCEDURE hide_post (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE
    ) IS
    BEGIN
        UPDATE post
        SET
            published = NULL
        where pid=pid_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while hiding post. Please contact support.';
    END hide_post;

    PROCEDURE add_tag_to_post (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE,
        tag_     tag.title%TYPE
    ) IS
    BEGIN
        INSERT INTO post_has_tags (
            pid,
            title
        ) VALUES (
            pid_,
            tag_
        );

        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'post already has this tag';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'PK_POST_HAS_TAGS') != 0 THEN
                status := 'post already has this tag';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;
    END add_tag_to_post;

    PROCEDURE delete_tag_from_post (
        status   OUT      VARCHAR2,
        pid_     post.pid%TYPE,
        tag_     tag.title%TYPE
    ) IS
    BEGIN
        DELETE FROM post_has_tags
        WHERE
            pid = pid_
            AND title = tag_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error. Please contact support.';
    END delete_tag_from_post;

    FUNCTION get_post (
        pid_ post.pid%TYPE
    ) RETURN SYS_REFCURSOR IS
        prec   SYS_REFCURSOR;
    BEGIN
        OPEN prec FOR SELECT
                          *
                      FROM
                          post
                      WHERE
                          post.pid = pid_;

        RETURN prec;
    END get_post;

    FUNCTION filter_posts (
        user_id_     post.user_id%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE,
        status_      post.published%TYPE
    ) RETURN post_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE postcursor IS REF CURSOR;
        pcur       postcursor;
        prec       post%rowtype;
    BEGIN
        IF user_id_ IS NULL AND posttitle_ IS NULL AND posttext_ IS NULL AND category_ IS NULL AND status_ IS NULL THEN
            exec_str := 'SELECT * FROM post WHERE published IS NOT NULL';
        ELSE
            exec_str := 'SELECT * FROM post WHERE ';
            IF user_id_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'post.user_id='''
                            || user_id_
                            || ''' AND ';
            END IF;

            IF posttitle_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(post.posttitle, '''
                            || posttitle_
                            || ''') > 0 AND ';
            END IF;

            IF posttext_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(post.POSTTEXT, '''
                            || posttext_
                            || ''') > 0 AND ';
            END IF;

            IF category_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'post.categorytitle='''
                            || category_
                            || ''' AND ';
            END IF;

            IF status_ IS NULL THEN
                exec_str := exec_str
                            || 'post.published IS NULL'
                            || status_
                            || ' AND ';
            END IF;

            exec_str := exec_str || '0=0';
        END IF;

        exec_str := exec_str || ' ORDER BY POSTCREATEDTIME DESC';
        OPEN pcur FOR exec_str;

        LOOP
            FETCH pcur INTO prec;
            EXIT WHEN pcur%notfound;
            PIPE ROW ( prec );
        END LOOP;

    END filter_posts;

    FUNCTION get_post_tags (
        pid_ post.pid%TYPE
    ) RETURN post_tag_table
        PIPELINED
    IS
        CURSOR tcur IS
        SELECT
            title
        FROM
            post_has_tags
        WHERE
            pid = pid_;

    BEGIN
        FOR trec IN tcur LOOP
            PIPE ROW ( trec );
        END LOOP;
    END get_post_tags;

END post_handle;
/