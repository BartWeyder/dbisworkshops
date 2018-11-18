CREATE OR REPLACE PACKAGE category_handle AS
    system_category_deletion EXCEPTION;
    TYPE category_tbl IS
        TABLE OF category%rowtype;
    PROCEDURE add_category (
        categorytitle_ category.categorytitle%TYPE
    );

    PROCEDURE delete_category (
        categorytitle_ category.categorytitle%TYPE
    );

    FUNCTION get_category (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN category%rowtype;

    FUNCTION get_categories (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN category_tbl
        PIPELINED;

    FUNCTION get_all_categories RETURN category_tbl
        PIPELINED;

END category_handle;
/

CREATE OR REPLACE PACKAGE BODY category_handle AS

    PROCEDURE add_category (
        categorytitle_ category.categorytitle%TYPE
    ) IS
    BEGIN
        INSERT INTO category ( categorytitle ) VALUES ( categorytitle_ );

    END add_category;

    PROCEDURE delete_category (
        categorytitle_ category.categorytitle%TYPE
    ) IS
    BEGIN
        IF categorytitle_ = 'Other' THEN
            RAISE system_category_deletion;
        ELSE
            DELETE FROM category
            WHERE
                category.categorytitle = categorytitle_;

        END IF;
    END delete_category;

    FUNCTION get_category (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN category%rowtype IS
        crec   category%rowtype;
    BEGIN
        SELECT
            *
        INTO crec
        FROM
            category
        WHERE
            category.categorytitle = categorytitle_;

        RETURN crec;
    END get_category;

    FUNCTION get_categories (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN category_tbl
        PIPELINED
    IS
        CURSOR ccur IS
        SELECT
            categorytitle
        FROM
            category
        WHERE
            instr(category.categorytitle, categorytitle_) > 0;

    BEGIN
        FOR crec IN ccur LOOP
            PIPE ROW ( crec );
        END LOOP;
    END get_categories;

    FUNCTION get_all_categories RETURN category_tbl
        PIPELINED
    IS
        CURSOR ccur IS
        SELECT
            categorytitle
        FROM
            category;

    BEGIN
        FOR crec IN ccur LOOP
            PIPE ROW ( crec );
        END LOOP;
    END get_all_categories;

END category_handle;
/