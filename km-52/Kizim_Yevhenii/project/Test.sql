declare
urec users%rowtype;
pid_ post.pid%type;
aid_ answer.aid%type;
begin
    -- User registration \ Add user --
--    user_handle.add_user('+380971234589', 'user', 'Test Lucas', 'sold@disney.com');
--    -- Get User \ Login
--    urec := user_handle.get_user('+380971234589');
--    dbms_output.put_line('Name: ' || urec.NAME);
--    -- Edit User --
--    user_handle.edit_user('+380971234589', 'moderator', 'Test Lucas', 'sold@disney.com');
--    -- Delete User --
--    user_handle.delete_user('+380971234589');
--    -- Write Post --
--    pid_ := post_handle.add_post('+380673221487', 'New Post Title', 'Super long text of new post by Snoop Dogg', 'Education plan');
--    -- Add tag to post --
--    post_handle.add_tag_to_post(pid_, 'Working conditions');
--    -- Add tag --
--    tag_handle.add_tag('Sad mood');
--    tag_handle.add_tag('Good mood');
--    -- Delete tags --
--    tag_handle.delete_tag('Sad mood');
--    
--    -- Add category --
--    category_handle.add_category('New Category');
--    category_handle.add_category('Old Category');
--    -- Delete Category --
--    category_handle.delete_category('Old Category');
--    -- Add Answer --
--    -- creating post to make answer for
--    pid_ := post_handle.add_post('+380673221487', 'New Post Title', 'Super long text of new post by Snoop Dogg', 'Education plan');
--    -- creating answer
--    aid_ := answer_handle.add_answer('+380673221487', pid_, 'New answer', 'New answer text');
--    
--    -- Delete answer --
--    answer_handle.delete_answer(aid_);
    
    -- Edit answer --
    -- Creating answer to edit
    aid_ := answer_handle.add_answer('+380674568969', 1, 'TestTest', 'New answer text');
    answer_handle.edit_answer(aid_, 'Super Test Two', 'Super New answer text');
    
    -- Edit post --
--    post_handle.edit_post(pid_, 'Super New Post Title', 'Super long text of new post by Snoop Dogg', 'Education plan');
--    
--    -- Delete post -- 
--    -- creating post to delete
--    pid_ := post_handle.add_post('+380673221487', 'Post to delete', 'Super long text of new post by Snoop Dogg', 'Education plan');
--    post_handle.delete_post(pid_);

end;
-- end --
-- Manage Users -- 
-- Outputs users -- 
select * from TABLE(user_handle.get_user_by_name('S'));

-- Manage Tags --
select * from TABLE(tag_handle.get_all_tags);

-- Manage Categories --
select * from TABLE(category_handle.get_all_categories);
    
-- Filter post --
select * from TABLE(post_handle.get_post_by_title('on'));
-- answers --
select * from TABLE(answer_handle.get_answer_by_title('re'));

    
-- new part --
-- end --