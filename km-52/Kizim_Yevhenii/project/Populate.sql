-- tag 
insert into tag(TITLE) values('Math Analysis');
insert into tag(TITLE) values('Working hours');
insert into tag(TITLE) values('Heavy load');
insert into tag(TITLE) values('Working conditions');

-- CATEGORY
insert into CATEGORY(CATEGORYTITLE) values('Education process');
insert into CATEGORY(CATEGORYTITLE) values('Education stuff');
insert into CATEGORY(CATEGORYTITLE) values('Education plan');
insert into CATEGORY(CATEGORYTITLE) values('Other');

--role
insert into ROLE(ROLENAME) values('user');

insert into ROLE(ROLENAME) values('superuser');

insert into ROLE(ROLENAME) values('moderator');

insert into ROLE(ROLENAME) values('anonym');

--user
insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
values('+380674568969', 'user', 'Bob Marley', 'bob.marley@abc.com', '06-nov-2018');

insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
values('+380673221487', 'moderator', 'Snoop Dogg', '420@abc.com', '20-apr-2018');

insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
values('+380671597536', 'moderator', 'Sergei Kopychko', 'kpi@evm.com', '03-nov-2018');

insert into "USER"(PHONE, ROLENAME, NAME, EMAIL, USERCREATEDTIME)
values('+380671337859', 'user', 'Alla Stolovaja', 'kotleta.po@kievski.com', '01-nov-2018');


--post
insert into post(PID, PHONE, POSTTITLE, POSTTEXT, PUBLISHED, POSTCREATEDTIME, CATEGORYTITLE)
values(1, '+380674568969', 'No reggae on radio KPI', 'Please add some reggae to playlist. <br \> I cant listen current anymore.', 0, 
    '07-nov-2018', 'Other');

insert into post(PID, PHONE, POSTTITLE, POSTTEXT, PUBLISHED, POSTCREATEDTIME, CATEGORYTITLE)
values(2, '+380671337859', 'Please dont close our canteen', 'I will raise strike against you if you close my canteen. So dont!', 0, 
    '01-nov-2018', 'Other');

insert into post(PID, PHONE, POSTTITLE, POSTTEXT, PUBLISHED, POSTCREATEDTIME, CATEGORYTITLE)
values(3, '+380671597536', 
    'More working hours for OS', 'I need more working hours for my subject. It is imposible to tell all material to students.', 
    1, '04-nov-2018', 'Education plan');

insert into post(PID, PHONE, POSTTITLE, POSTTEXT, PUBLISHED, POSTCREATEDTIME, CATEGORYTITLE)
values(4, '+380671597536', 'Upgrade EVM', 'I need upgrade for my EVM to make my work more efficient.', 0, 
    '07-nov-2018', 'Education process');

--post has tags
insert into post_has_tags values(1, 'Working conditions');

insert into post_has_tags values(2, 'Working conditions');

insert into post_has_tags values(3, 'Working conditions');

insert into post_has_tags values(3, 'Working hours');

--answer
insert into answer(AID, PHONE, PID, ANSWERTITLE, ANSWERTEXT, ANSWERCREATEDTIME)
values (1, '+380673221487', 1, 'There will be only Snoop beats', 'Sorry, but we will play only good old old-school rap', '07-nov-2018');

insert into answer(AID, PHONE, PID, ANSWERTITLE, ANSWERTEXT, ANSWERCREATEDTIME)
values (2, '+380673221487', 2, 'Ey-yo, we cant do anything', 'Sorry, but we cant do anything. It is Zgurovskii and mafia.', '02-nov-2018');

insert into answer(AID, PHONE, PID, ANSWERTITLE, ANSWERTEXT, ANSWERCREATEDTIME)
values (3, '+380673221487', 3, 'Let kids have some free time', 'Sorry, students are overloaded, so leave them alone!', '07-nov-2018');

insert into answer(AID, PHONE, PID, ANSWERTITLE, ANSWERTEXT, ANSWERCREATEDTIME)
values (4, '+380673221487', 4, 'We are waiting for new models rolling out', 'We are waiting for release of new Mac Pro, so please be patient and wait few months',
    '07-nov-2018');

