select PUBLISHED as "IS PUBLISHED?" from post
where pid = 1;

update post 
set published = 0
where pid = 1;

select PUBLISHED as "IS PUBLISHED?" from post
where pid = 1;