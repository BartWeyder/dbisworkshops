CREATE OR REPLACE PACKAGE tag_handle AS
    TYPE tag_tbl IS
        TABLE OF tag%rowtype;
    PROCEDURE add_tag (
        title_ tag.title%TYPE
    );

    PROCEDURE delete_tag (
        title_ tag.title%TYPE
    );

    FUNCTION get_tag (
        title_ tag.title%TYPE
    ) RETURN tag%rowtype;

    FUNCTION filter_tags (
        title_ tag.title%TYPE
    ) RETURN tag_tbl
        PIPELINED;

END tag_handle;
/

CREATE OR REPLACE PACKAGE BODY tag_handle AS

    PROCEDURE add_tag (
        title_ tag.title%TYPE
    ) IS
    BEGIN
        INSERT INTO tag ( title ) VALUES ( title_ );

    END add_tag;

    PROCEDURE delete_tag (
        title_ tag.title%TYPE
    ) IS
    BEGIN
        DELETE FROM tag
        WHERE
            tag.title = title_;

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
        title_ tag.title%TYPE
    ) RETURN tag_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE tagcursor IS REF CURSOR;
        tcur       tagcursor;
        trec       tag%rowtype;
    BEGIN
        IF title_ IS NULL THEN
            exec_str := 'SELECT * FROM tag';
        ELSE
            exec_str := 'SELECT * FROM tag WHERE instr(tag.title, '''
                        || title_
                        || ''') > 0';
        END IF;

        OPEN tcur FOR exec_str;

        LOOP
            FETCH tcur INTO trec;
            EXIT WHEN tcur%notfound;
            PIPE ROW ( trec );
        END LOOP;
    END filter_tags;

END tag_handle;
/