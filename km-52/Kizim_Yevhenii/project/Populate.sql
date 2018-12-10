-- tag 
INSERT INTO tag ( title ) VALUES ( 'Math Analysis' );

INSERT INTO tag ( title ) VALUES ( 'Working hours' );

INSERT INTO tag ( title ) VALUES ( 'Heavy load' );

INSERT INTO tag ( title ) VALUES ( 'Working conditions' );

-- CATEGORY

INSERT INTO category ( categorytitle ) VALUES ( 'Education process' );

INSERT INTO category ( categorytitle ) VALUES ( 'Education stuff' );

INSERT INTO category ( categorytitle ) VALUES ( 'Education plan' );

INSERT INTO category ( categorytitle ) VALUES ( 'Other' );

--role

INSERT INTO role ( rolename ) VALUES ( 'user' );

INSERT INTO role ( rolename ) VALUES ( 'superuser' );

INSERT INTO role ( rolename ) VALUES ( 'moderator' );

INSERT INTO role ( rolename ) VALUES ( 'anonym' );

--user

INSERT INTO users (
    user_id,
    rolename,
    name,
    usercreatedtime
) VALUES (
    380674568969,
    'user',
    'Bob Marley',
    '06-nov-2018'
);

INSERT INTO users (
    user_id,
    rolename,
    name,
    usercreatedtime
) VALUES (
    380673221487,
    'moderator',
    'Snoop Dogg',
    '20-apr-2018'
);

INSERT INTO users (
    user_id,
    rolename,
    name,
    usercreatedtime
) VALUES (
    380671597536,
    'moderator',
    'Sergei Kopychko',
    '03-nov-2018'
);

INSERT INTO users (
    user_id,
    rolename,
    name,
    usercreatedtime
) VALUES (
    380671337859,
    'user',
    'Alla Stolovaja',
    '01-nov-2018'
);

--post

INSERT INTO post (
    pid,
    user_id,
    posttitle,
    posttext,
    published,
    postcreatedtime,
    categorytitle
) VALUES (
    1,
    380674568969,
    'No reggae on radio KPI',
    'Please add some reggae to playlist. <br \> I cant listen current anymore.',
    0,
    '07-nov-2018',
    'Other'
);

INSERT INTO post (
    pid,
    user_id,
    posttitle,
    posttext,
    published,
    postcreatedtime,
    categorytitle
) VALUES (
    2,
    380671337859,
    'Please dont close our canteen',
    'I will raise strike against you if you close my canteen. So dont!',
    0,
    '01-nov-2018',
    'Other'
);

INSERT INTO post (
    pid,
    user_id,
    posttitle,
    posttext,
    published,
    postcreatedtime,
    categorytitle
) VALUES (
    3,
    380671597536,
    'More working hours for OS',
    'I need more working hours for my subject. It is imposible to tell all material to students.',
    1,
    '04-nov-2018',
    'Education plan'
);

INSERT INTO post (
    pid,
    user_id,
    posttitle,
    posttext,
    published,
    postcreatedtime,
    categorytitle
) VALUES (
    4,
    380671597536,
    'Upgrade EVM',
    'I need upgrade for my EVM to make my work more efficient.',
    0,
    '07-nov-2018',
    'Education process'
);

--post has tags

INSERT INTO post_has_tags VALUES (
    1,
    'Working conditions'
);

INSERT INTO post_has_tags VALUES (
    2,
    'Working conditions'
);

INSERT INTO post_has_tags VALUES (
    3,
    'Working conditions'
);

INSERT INTO post_has_tags VALUES (
    3,
    'Working hours'
);

--answer

INSERT INTO answer (
    aid,
    user_id,
    pid,
    answertitle,
    answertext,
    answercreatedtime
) VALUES (
    1,
    380673221487,
    1,
    'There will be only Snoop beats',
    'Sorry, but we will play only good old old-school rap',
    '07-nov-2018'
);

INSERT INTO answer (
    aid,
    user_id,
    pid,
    answertitle,
    answertext,
    answercreatedtime
) VALUES (
    2,
    380673221487,
    2,
    'Ey-yo, we cant do anything',
    'Sorry, but we cant do anything. It is Zgurovskii and mafia.',
    '02-nov-2018'
);

INSERT INTO answer (
    aid,
    user_id,
    pid,
    answertitle,
    answertext,
    answercreatedtime
) VALUES (
    3,
    380673221487,
    3,
    'Let kids have some free time',
    'Sorry, students are overloaded, so leave them alone!',
    '07-nov-2018'
);

INSERT INTO answer (
    aid,
    user_id,
    pid,
    answertitle,
    answertext,
    answercreatedtime
) VALUES (
    4,
    380673221487,
    4,
    'We are waiting for new models rolling out',
    'We are waiting for release of new Mac Pro, so please be patient and wait few months',
    '07-nov-2018'
);