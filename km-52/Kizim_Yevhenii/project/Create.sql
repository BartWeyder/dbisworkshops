/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     01-Nov-18 23:48:24                           */
/*==============================================================*/
ALTER TABLE answer DROP CONSTRAINT fk_answer_post_has__post;

ALTER TABLE answer DROP CONSTRAINT fk_answer_user_has__user;

ALTER TABLE post DROP CONSTRAINT fk_post_post_has__category;

ALTER TABLE post DROP CONSTRAINT fk_post_user_has__user;

ALTER TABLE post_has_tags DROP CONSTRAINT fk_post_has_post_has__post;

ALTER TABLE post_has_tags DROP CONSTRAINT fk_post_has_post_has__tag;

ALTER TABLE users DROP CONSTRAINT fk_user_user_has__role;

DROP INDEX post_has_answer_fk;

DROP INDEX user_has_answers_fk;

DROP TABLE answer CASCADE CONSTRAINTS;

DROP TABLE category CASCADE CONSTRAINTS;

DROP INDEX post_has_category_fk;

DROP INDEX user_has_posts_fk;

DROP TABLE post CASCADE CONSTRAINTS;

DROP INDEX post_has_tags_fk;

DROP INDEX post_has_tags2_fk;

DROP TABLE post_has_tags CASCADE CONSTRAINTS;

DROP TABLE role CASCADE CONSTRAINTS;

DROP TABLE tag CASCADE CONSTRAINTS;

DROP INDEX user_has_role_fk;

DROP TABLE users CASCADE CONSTRAINTS;

/*==============================================================*/
/* Table: ANSWER                                                */
/*==============================================================*/

CREATE TABLE answer (
    aid                 INTEGER NOT NULL,
    user_id             INTEGER NOT NULL,
    pid                 INTEGER NOT NULL,
    answertitle         VARCHAR2(256),
    answertext          VARCHAR2(2000) NOT NULL,
    answercreatedtime   DATE NOT NULL,
    CONSTRAINT pk_answer PRIMARY KEY ( aid )
);

/*==============================================================*/
/* Index: USER_HAS_ANSWERS_FK                                   */
/*==============================================================*/
--create index USER_HAS_ANSWERS_FK on ANSWER (
--   PHONE ASC
--);
--
--/*==============================================================*/
--/* Index: POST_HAS_ANSWER_FK                                    */
--/*==============================================================*/
--create index POST_HAS_ANSWER_FK on ANSWER (
--   PID ASC
--);

/*==============================================================*/
/* Table: CATEGORY                                              */
/*==============================================================*/

CREATE TABLE category (
    categorytitle   VARCHAR(40) NOT NULL,
    CONSTRAINT pk_category PRIMARY KEY ( categorytitle )
);

/*==============================================================*/
/* Table: POST                                                  */
/*==============================================================*/

CREATE TABLE post (
    pid               INTEGER NOT NULL,
    user_id           INTEGER NOT NULL,
    posttitle         VARCHAR2(256) NOT NULL,
    posttext          VARCHAR2(2000) NOT NULL,
    published         SMALLINT NOT NULL,
    postcreatedtime   DATE NOT NULL,
    categorytitle     VARCHAR(40) NOT NULL,
    CONSTRAINT pk_post PRIMARY KEY ( pid )
);

/*==============================================================*/
/* Index: USER_HAS_POSTS_FK                                     */
/*==============================================================*/
--create index USER_HAS_POSTS_FK on POST (
--   PHONE ASC
--);
--
--/*==============================================================*/
--/* Index: POST_HAS_CATEGORY_FK                                  */
--/*==============================================================*/
--create index POST_HAS_CATEGORY_FK on POST (
--   CATEGORYTITLE ASC
--);

/*==============================================================*/
/* Table: POST_HAS_TAGS                                         */
/*==============================================================*/

CREATE TABLE post_has_tags (
    pid     INTEGER NOT NULL,
    title   VARCHAR(40) NOT NULL,
    CONSTRAINT pk_post_has_tags PRIMARY KEY ( pid,
                                              title )
);

/*==============================================================*/
/* Index: POST_HAS_TAGS2_FK                                     */
/*==============================================================*/
--create index POST_HAS_TAGS2_FK on POST_HAS_TAGS (
--   TITLE ASC
--);
--
--/*==============================================================*/
--/* Index: POST_HAS_TAGS_FK                                      */
--/*==============================================================*/
--create index POST_HAS_TAGS_FK on POST_HAS_TAGS (
--   PID ASC
--);

/*==============================================================*/
/* Table: ROLE                                                  */
/*==============================================================*/

CREATE TABLE role (
    rolename   VARCHAR(20) NOT NULL,
    CONSTRAINT pk_role PRIMARY KEY ( rolename )
);

/*==============================================================*/
/* Table: TAG                                                   */
/*==============================================================*/

CREATE TABLE tag (
    title   VARCHAR(40) NOT NULL,
    CONSTRAINT pk_tag PRIMARY KEY ( title )
);

/*==============================================================*/
/* Table: USERS                                                */
/*==============================================================*/

CREATE TABLE users (
    user_id           INTEGER NOT NULL,
    rolename          VARCHAR(20) NOT NULL,
    name              VARCHAR2(100) NOT NULL,
    user_hash         RAW(64),
    usercreatedtime   DATE NOT NULL,
    CONSTRAINT pk_user PRIMARY KEY ( user_id )
);

/*==============================================================*/
/* Index: USER_HAS_ROLE_FK                                      */
/*==============================================================*/
--create index USER_HAS_ROLE_FK on USERS (
--   ROLENAME ASC
--);

ALTER TABLE answer
    ADD CONSTRAINT fk_answer_post_has__post FOREIGN KEY ( pid )
        REFERENCES post ( pid );

ALTER TABLE answer
    ADD CONSTRAINT fk_answer_user_has__user FOREIGN KEY ( user_id )
        REFERENCES users ( user_id );

ALTER TABLE post
    ADD CONSTRAINT fk_post_post_has__category FOREIGN KEY ( categorytitle )
        REFERENCES category ( categorytitle );

ALTER TABLE post
    ADD CONSTRAINT fk_post_user_has__user FOREIGN KEY ( user_id )
        REFERENCES users ( user_id );

ALTER TABLE post_has_tags
    ADD CONSTRAINT fk_post_has_post_has__post FOREIGN KEY ( pid )
        REFERENCES post ( pid );

ALTER TABLE post_has_tags
    ADD CONSTRAINT fk_post_has_post_has__tag FOREIGN KEY ( title )
        REFERENCES tag ( title );

ALTER TABLE users
    ADD CONSTRAINT fk_user_user_has__role FOREIGN KEY ( rolename )
        REFERENCES role ( rolename );

ALTER TABLE answer
    ADD CONSTRAINT answer_title_check CHECK ( REGEXP_LIKE ( answertitle,
                                                            '^[A-z ,!.-]{0,526}$' ) );

ALTER TABLE answer
    ADD CONSTRAINT answer_text_check CHECK ( REGEXP_LIKE ( answertext,
                                                           '^[A-Za-z0-9 ;—–.,!?+<>\/-]{5,2000}$' ) );

ALTER TABLE category
    ADD CONSTRAINT category_name_check CHECK ( REGEXP_LIKE ( categorytitle,
                                                             '^[A-z -]{1,40}$' ) );

ALTER TABLE post
    ADD CONSTRAINT post_title_check CHECK ( REGEXP_LIKE ( posttitle,
                                                          '^[A-z ,!.-]{5,526}$' ) );

ALTER TABLE post
    ADD CONSTRAINT post_text_check CHECK ( REGEXP_LIKE ( posttext,
                                                         '^[A-Za-z0-9 ;—–.,!?+<>\/-]{5,2000}$' ) );

ALTER TABLE role
    ADD CONSTRAINT role_name_check CHECK ( REGEXP_LIKE ( rolename,
                                                         '^[A-Za-z]{1,20}$' ) );

ALTER TABLE tag
    ADD CONSTRAINT title_check CHECK ( REGEXP_LIKE ( title,
                                                     '^[A-Za-z -]{1,20}$' ) );

ALTER TABLE users
    ADD CONSTRAINT name_check CHECK ( REGEXP_LIKE ( name,
                                                    '^[A-Za-z -]{5,100}$' ) );