CREATE OR REPLACE PACKAGE tag_handle AS
    TYPE tag_tbl IS
        TABLE OF tag%rowtype;
    PROCEDURE add_tag (
        status         OUT varchar2,
        title_ tag.title%TYPE
    );

    PROCEDURE delete_tag (
        status         OUT varchar2,
        title_ tag.title%TYPE
    );

    FUNCTION get_tag (
        title_ tag.title%TYPE
    ) RETURN tag%rowtype;

    FUNCTION filter_tags (
        title_ tag.title%TYPE,
        deleted_ tag.deleted%TYPE
    ) RETURN tag_tbl
        PIPELINED;

END tag_handle;
/

CREATE OR REPLACE PACKAGE BODY tag_handle AS

    PROCEDURE add_tag (
        status         OUT varchar2,
        title_ tag.title%TYPE
    ) IS
        counter INTEGER;
    BEGIN
        select count(*) into counter from tag where title=title_;
        IF counter > 0 then
            update tag 
                set deleted=NULL
                where title=title_;
        ELSE
            INSERT INTO tag ( title ) VALUES ( title_ );
        END IF;
        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Tag already exists';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'TITLE_CHECK') != 0 THEN
                status := 'Tag name allows only alphanumeric values.';
            ELSIF instr(sqlerrm, 'PK_TAG') != 0 THEN
                status := 'Tag already exists';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;

    END add_tag;

    PROCEDURE delete_tag (
        status         OUT varchar2,
        title_ tag.title%TYPE
    ) IS
    BEGIN
        UPDATE tag
            SET deleted = current_timestamp
            where title_=title;
        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while tag deletion. Please contact support.';

    END delete_tag;

    FUNCTION get_tag (
        title_ tag.title%TYPE
    ) RETURN tag%rowtype IS
        trec   tag%rowtype;
    BEGIN
        SELECT
            *
        INTO trec
        FROM
            tag
        WHERE
            tag.title = title_;

        RETURN trec;
    END get_tag;

    FUNCTION filter_tags (
        title_ tag.title%TYPE,
        deleted_ tag.deleted%TYPE
    ) RETURN tag_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE tagcursor IS REF CURSOR;
        tcur       tagcursor;
        trec       tag%rowtype;
    BEGIN
        IF title_ IS NULL AND deleted_ IS NULL THEN
            exec_str := 'SELECT * FROM tag WHERE deleted IS NULL';
        ELSE
            exec_str := 'SELECT * FROM tag WHERE';
            IF title_ IS NOT NULL THEN
                exec_str := exec_str || ' instr(tag.title, '''
                        || title_
                        || ''') > 0 AND ';
            END IF;
            IF deleted_ IS NULL THEN
                exec_str := exec_str || 'deleted IS NULL';
            END IF;
        END IF;
        
        exec_str := exec_str || ' ORDER BY TITLE ASC';

        OPEN tcur FOR exec_str;

        LOOP
            FETCH tcur INTO trec;
            EXIT WHEN tcur%notfound;
            PIPE ROW ( trec );
        END LOOP;
    END filter_tags;

END tag_handle;
/