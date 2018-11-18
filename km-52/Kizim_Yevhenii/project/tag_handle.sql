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

    FUNCTION get_tags (
        title_ tag.title%TYPE
    ) RETURN tag_tbl
        PIPELINED;

    FUNCTION get_all_tags RETURN tag_tbl
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

    FUNCTION get_tags (
        title_ tag.title%TYPE
    ) RETURN tag_tbl
        PIPELINED
    IS
        CURSOR tcur IS
        SELECT
            title
        FROM
            tag
        WHERE
            instr(tag.title, title_) > 0;

    BEGIN
        FOR trec IN tcur LOOP
            PIPE ROW ( trec );
        END LOOP;
    END get_tags;

    FUNCTION get_all_tags RETURN tag_tbl
        PIPELINED
    IS
        CURSOR tcur IS
        SELECT
            title
        FROM
            tag;

    BEGIN
        FOR trec IN tcur LOOP
            PIPE ROW ( trec );
        END LOOP;
    END get_all_tags;

END tag_handle;
/