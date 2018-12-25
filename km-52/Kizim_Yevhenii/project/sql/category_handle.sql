CREATE OR REPLACE PACKAGE category_handle AS

    TYPE category_tbl IS
        TABLE OF category%rowtype;
    PROCEDURE add_category (
        status           OUT              VARCHAR2,
        categorytitle_   category.categorytitle%TYPE
    );

    PROCEDURE delete_category (
        status           OUT              VARCHAR2,
        categorytitle_   category.categorytitle%TYPE
    );

    FUNCTION get_category (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION filter_categories (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN category_tbl
        PIPELINED;

END category_handle;
/

CREATE OR REPLACE PACKAGE BODY category_handle AS

    PROCEDURE add_category (
        status           OUT              VARCHAR2,
        categorytitle_   category.categorytitle%TYPE
    ) IS
    BEGIN
        INSERT INTO category ( categorytitle ) VALUES ( categorytitle_ );

        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'Category already exists';
        WHEN OTHERS THEN
            status := 'Uknown error. Please contact support.';
    END add_category;

    PROCEDURE delete_category (
        status           OUT              VARCHAR2,
        categorytitle_   category.categorytitle%TYPE
    ) IS
    BEGIN
        IF categorytitle_ = 'Other' THEN
            status := 'You are trying to delete system category.';
        ELSE
            DELETE FROM category
            WHERE
                category.categorytitle = categorytitle_;

            status := 'ok';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error while deletion. Please contact support.';
    END delete_category;

    FUNCTION get_category (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN SYS_REFCURSOR IS
        crec   SYS_REFCURSOR;
    BEGIN
        OPEN crec FOR SELECT
                          *
                      FROM
                          category
                      WHERE
                          category.categorytitle = categorytitle_;

        RETURN crec;
    END get_category;

    FUNCTION filter_categories (
        categorytitle_ category.categorytitle%TYPE
    ) RETURN category_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(200);
        TYPE catcursor IS REF CURSOR;
        ccur       catcursor;
        crec       category%rowtype;
    BEGIN
        IF categorytitle_ IS NULL THEN
            exec_str := 'SELECT * FROM category';
        ELSE
            exec_str := 'SELECT * FROM category WHERE instr(category.categorytitle, '''
                        || categorytitle_
                        || ''') > 0';
        END IF;

        exec_str := exec_str || ' ORDER BY CATEGORYTITLE ASC';
        OPEN ccur FOR exec_str;

        LOOP
            FETCH ccur INTO crec;
            EXIT WHEN ccur%notfound;
            PIPE ROW ( crec );
        END LOOP;

    END filter_categories;

END category_handle;
/