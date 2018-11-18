CREATE SEQUENCE post_ids START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE post_handle AS
    TYPE post_tbl IS
        TABLE OF post%rowtype;
    PROCEDURE add_post (
        phone_       post.phone%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE
    );

    PROCEDURE edit_post (
        pid_         post.pid%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    category.categorytitle%TYPE
    );

    PROCEDURE delete_post (
        pid_ post.pid%TYPE
    );
    
    PROCEDURE publicate_post(pid_ post.pid%TYPE);
    
    PROCEDURE hide_post(pid_ post.pid%TYPE);

    FUNCTION get_all_posts RETURN post_tbl
        PIPELINED;

    FUNCTION get_post (
        pid_ post.pid%TYPE
    ) RETURN post%rowtype;

    FUNCTION get_post_by_title (
        posttitle_ post.posttitle%TYPE
    ) RETURN post_tbl
        PIPELINED;

    FUNCTION get_post_by_category (
        category_ post.categorytitle%TYPE
    ) RETURN post_tbl
        PIPELINED;

END post_handle;
/
CREATE OR REPLACE PACKAGE BODY post_handle AS

    PROCEDURE add_post (
        phone_       post.phone%TYPE,
        posttitle_   post.posttitle%TYPE,
        posttext_    post.posttext%TYPE,
        category_    post.categorytitle%TYPE
    ) IS
    BEGIN
        INSERT INTO post (
            pid,
            phone,
            posttitle,
            posttext,
            published,
            postcreatedtime,
            categorytitle
        ) VALUES (
            post_ids.NEXTVAL,
            phone_,
            posttitle_,
            posttext_,
            0,
            current_timestamp,
            category_
        );

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
    )
    IS
    BEGIN 
        delete from POST
         where POST.PID = pid_;
    END delete_post;
    
    PROCEDURE publicate_post(pid_ post.pid%TYPE)
    IS
    BEGIN
        update post
           set PUBLISHED=1
         where post.pid = pid_;
    END publicate_post;

    PROCEDURE hide_post(pid_ post.pid%TYPE)
    IS
    begin
      update POST
         set PUBLISHED=0
       where post.pid = pid_;
    end hide_post;
    
    FUNCTION get_all_posts RETURN post_tbl
        PIPELINED
    IS
        CURSOR pcur IS 
            SELECT * FROM post;
    BEGIN
        FOR prec IN pcur loop
          PIPE ROW(prec);
        end loop;
    END get_all_posts;
    
    FUNCTION get_post (
        pid_ post.pid%TYPE
    ) RETURN post%rowtype
    IS
        prec post%rowtype;
    BEGIN
        select *
          into prec
          from post
         where post.pid = pid_;
         Return prec;
    END get_post;

    FUNCTION get_post_by_title (
        posttitle_ post.posttitle%TYPE
    ) RETURN post_tbl
        PIPELINED
    IS 
        CURSOR pcur IS select *
          from POST
         where instr(POST.posttitle, posttitle_) > 0;
    begin
      for prec in pcur loop
        pipe row(prec);
      end loop;
    end get_post_by_title;

    FUNCTION get_post_by_category (
        category_ post.categorytitle%TYPE
    ) RETURN post_tbl
        PIPELINED
    is 
        CURSOR pcur IS select *
          from post
         where post.categorytitle = category_;
    begin
      for prec in pcur loop
        pipe row(prec);
      end loop;
    end get_post_by_category;

END post_handle;
/