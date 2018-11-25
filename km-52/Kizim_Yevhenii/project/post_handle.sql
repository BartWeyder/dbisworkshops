-- RUN THIS SCRIPT AFTER TAG_HANDLE --
CREATE SEQUENCE post_ids START WITH 5 INCREMENT BY 1 CACHE 2;

CREATE OR REPLACE PACKAGE post_handle AS
    TYPE post_tbl IS
        TABLE OF post%rowtype;
    FUNCTION add_post (
        phone_       post.phone%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE
    ) RETURN post.pid%TYPE;

    PROCEDURE edit_post (
        pid_         post.pid%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    category.categorytitle%TYPE
    );

    PROCEDURE delete_post (
        pid_ post.pid%TYPE
    );

    PROCEDURE publicate_post (
        pid_ post.pid%TYPE
    );

    PROCEDURE hide_post (
        pid_ post.pid%TYPE
    );

    PROCEDURE add_tag_to_post (
        pid_   post.pid%TYPE,
        tag_   tag.title%TYPE
    );

    FUNCTION get_all_posts RETURN post_tbl
        PIPELINED;

    FUNCTION get_post (
        pid_ post.pid%TYPE
    ) RETURN post%rowtype;
        
    FUNCTION filter_posts(
        phone_ post.PHONE%TYPE,
        posttitle_ post.posttitle%TYPE,
        posttext_ post.POSTTEXT%TYPE,
        category_ post.categorytitle%TYPE
    ) RETURN post_tbl
        PIPELINED;

    FUNCTION get_post_tags (
        pid_ post.pid%TYPE
    ) RETURN tag_handle.tag_tbl
        PIPELINED;

END post_handle;
/

CREATE OR REPLACE PACKAGE BODY post_handle AS

    FUNCTION add_post (
        phone_       post.phone%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE
    ) RETURN post.pid%TYPE IS
        new_id   post.pid%TYPE;
    BEGIN
        new_id := post_ids.nextval;
        INSERT INTO post (
            pid,
            phone,
            posttitle,
            posttext,
            published,
            postcreatedtime,
            categorytitle
        ) VALUES (
            new_id,
            phone_,
            posttitle_,
            posttext_,
            0,
            current_timestamp,
            category_
        );

        RETURN new_id;
    END add_post;

    PROCEDURE edit_post (
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

    END edit_post;

    PROCEDURE delete_post (
        pid_ post.pid%TYPE
    ) IS
    BEGIN
        DELETE FROM post
        WHERE
            post.pid = pid_;

    END delete_post;

    PROCEDURE publicate_post (
        pid_ post.pid%TYPE
    ) IS
    BEGIN
        UPDATE post
        SET
            published = 1
        WHERE
            post.pid = pid_;

    END publicate_post;

    PROCEDURE hide_post (
        pid_ post.pid%TYPE
    ) IS
    BEGIN
        UPDATE post
        SET
            published = 0
        WHERE
            post.pid = pid_;

    END hide_post;

    PROCEDURE add_tag_to_post (
        pid_   post.pid%TYPE,
        tag_   tag.title%TYPE
    ) IS
    BEGIN
        INSERT INTO post_has_tags (
            pid,
            title
        ) VALUES (
            pid_,
            tag_
        );

    END add_tag_to_post;

    FUNCTION get_all_posts RETURN post_tbl
        PIPELINED
    IS
        CURSOR pcur IS
        SELECT
            *
        FROM
            post;

    BEGIN
        FOR prec IN pcur LOOP
            PIPE ROW ( prec );
        END LOOP;
    END get_all_posts;

    FUNCTION get_post (
        pid_ post.pid%TYPE
    ) RETURN post%rowtype IS
        prec   post%rowtype;
    BEGIN
        SELECT
            *
        INTO prec
        FROM
            post
        WHERE
            post.pid = pid_;

        RETURN prec;
    END get_post;
    
    FUNCTION filter_posts(
        phone_ post.PHONE%TYPE,
        posttitle_ post.posttitle%TYPE,
        posttext_ post.POSTTEXT%TYPE,
        category_ post.categorytitle%TYPE
    ) RETURN post_tbl
        PIPELINED
    IS
        exec_str varchar2(500);
        TYPE PostCursor IS REF CURSOR;
        pcur PostCursor;
        prec post%rowtype;
    BEGIN
        IF phone_ IS NULL AND posttitle_ IS NULL AND posttext_ IS NULL AND category_ IS NULL THEN
            exec_str := 'SELECT * FROM post';
        ELSE 
            exec_str := exec_str || 'SELECT * FROM post WHERE ';
            IF phone_ IS NOT NULL THEN
                exec_str := exec_str || 'post.PHONE=''' || phone_ || ''' AND ';
            END IF;
            IF posttitle_ IS NOT NULL THEN 
                exec_str := exec_str || 'instr(post.posttitle, ''' || posttitle_ || ''') > 0 AND ';
            END IF;
            IF posttext_ IS NOT NULL THEN 
                exec_str := exec_str || 'instr(post.POSTTEXT, ''' || posttext_ || ''') > 0 AND ';
            END IF;
            IF category_ IS NOT NULL THEN 
                exec_str := exec_str || 'post.categorytitle=''' || category_ || ''' AND ';
            END IF;
            exec_str := exec_str || '0=0';
        END IF;
        
        OPEN pcur FOR exec_str;

        LOOP
            FETCH pcur INTO prec;
            EXIT WHEN pcur%notfound;
            PIPE ROW ( prec );
        END LOOP;
        
    END filter_posts;

    FUNCTION get_post_tags (
        pid_ post.pid%TYPE
    ) RETURN tag_handle.tag_tbl
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