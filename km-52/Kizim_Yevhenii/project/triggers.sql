-- USER DELETION --
CREATE TRIGGER user_deletion BEFORE
    DELETE ON users
    FOR EACH ROW
BEGIN
    DELETE answer
    WHERE
        user_id = :old.user_id;

    DELETE post
    WHERE
        user_id = :old.user_id;

END;

-- ANSWER DELETION -- 

CREATE TRIGGER answer_deletion BEFORE
    DELETE ON answer
    FOR EACH ROW
BEGIN
    UPDATE post
    SET
        published = 0
    WHERE
        pid = :old.pid;

END;

-- POST DELETION --

CREATE TRIGGER post_deletion BEFORE
    DELETE ON post
    FOR EACH ROW
BEGIN
    DELETE answer
    WHERE
        answer.pid = :old.pid;

    DELETE post_has_tags
    WHERE
        post_has_tags.pid = :old.pid;

END;

-- ROLE DELETION --

CREATE TRIGGER role_deletion BEFORE
    DELETE ON role
    FOR EACH ROW
BEGIN
    UPDATE users
    SET
        users.rolename = 'user'
    WHERE
        users.rolename = :old.rolename;

END;

-- TAG DELETION --

CREATE TRIGGER tag_deletion BEFORE
    DELETE ON tag
    FOR EACH ROW
BEGIN
    DELETE FROM post_has_tags
    WHERE
        post_has_tags.title = :old.title;

END;

-- CATEGORY DELETION --

CREATE TRIGGER category_deletion BEFORE
    DELETE ON category
    FOR EACH ROW
BEGIN
    UPDATE post
    SET
        post.categorytitle = 'Other'
    WHERE
        post.categorytitle = :old.categorytitle;

END;