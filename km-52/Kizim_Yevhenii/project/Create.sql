/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     01-Nov-18 23:48:24                           */
/*==============================================================*/


alter table ANSWER
   drop constraint FK_ANSWER_POST_HAS__POST;

alter table ANSWER
   drop constraint FK_ANSWER_USER_HAS__USER;

alter table POST
   drop constraint FK_POST_POST_HAS__CATEGORY;

alter table POST
   drop constraint FK_POST_USER_HAS__USER;

alter table POST_HAS_TAGS
   drop constraint FK_POST_HAS_POST_HAS__POST;

alter table POST_HAS_TAGS
   drop constraint FK_POST_HAS_POST_HAS__TAG;

alter table "USER"
   drop constraint FK_USER_USER_HAS__ROLE;

drop index POST_HAS_ANSWER_FK;

drop index USER_HAS_ANSWERS_FK;

drop table ANSWER cascade constraints;

drop table CATEGORY cascade constraints;

drop index POST_HAS_CATEGORY_FK;

drop index USER_HAS_POSTS_FK;

drop table POST cascade constraints;

drop index POST_HAS_TAGS_FK;

drop index POST_HAS_TAGS2_FK;

drop table POST_HAS_TAGS cascade constraints;

drop table ROLE cascade constraints;

drop table TAG cascade constraints;

drop index USER_HAS_ROLE_FK;

drop table "USER" cascade constraints;

/*==============================================================*/
/* Table: ANSWER                                                */
/*==============================================================*/
create table ANSWER 
(
   AID                  INTEGER              not null,
   PHONE                VARCHAR2(30)         not null,
   PID                  INTEGER              not null,
   ANSWERTITLE          VARCHAR2(256)        not null,
   ANSWERTEXT           VARCHAR2(2000)       not null,
   ANSWERCREATEDTIME    DATE                 not null,
   constraint PK_ANSWER primary key (AID)
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
create table CATEGORY 
(
   CATEGORYTITLE        VARCHAR(40)             not null,
   constraint PK_CATEGORY primary key (CATEGORYTITLE)
);

/*==============================================================*/
/* Table: POST                                                  */
/*==============================================================*/
create table POST 
(
   PID                  INTEGER              not null,
   PHONE                VARCHAR2(30)         not null,
   POSTTITLE            VARCHAR2(256)        not null,
   POSTTEXT             VARCHAR2(2000)       not null,
   PUBLISHED            SMALLINT             not null,
   POSTCREATEDTIME      DATE                 not null,
   CATEGORYTITLE        VARCHAR(40)             not null,
   constraint PK_POST primary key (PID)
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
create table POST_HAS_TAGS 
(
   PID                  INTEGER              not null,
   TITLE                VARCHAR(40)             not null,
   constraint PK_POST_HAS_TAGS primary key (PID, TITLE)
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
create table ROLE 
(
   ROLENAME             VARCHAR(20)             not null,
   constraint PK_ROLE primary key (ROLENAME)
);

/*==============================================================*/
/* Table: TAG                                                   */
/*==============================================================*/
create table TAG 
(
   TITLE                VARCHAR(40)             not null,
   constraint PK_TAG primary key (TITLE)
);

/*==============================================================*/
/* Table: "USER"                                                */
/*==============================================================*/
create table "USER" 
(
   PHONE                VARCHAR2(30)         not null,
   ROLENAME             VARCHAR(20)             not null,
   NAME                 VARCHAR2(100)        not null,
   EMAIL                VARCHAR2(60)         not null UNIQUE,
   USERCREATEDTIME      DATE                 not null,
   constraint PK_USER primary key (PHONE)
);

/*==============================================================*/
/* Index: USER_HAS_ROLE_FK                                      */
/*==============================================================*/
--create index USER_HAS_ROLE_FK on "USER" (
--   ROLENAME ASC
--);

alter table ANSWER
   add constraint FK_ANSWER_POST_HAS__POST foreign key (PID)
      references POST (PID);

alter table ANSWER
   add constraint FK_ANSWER_USER_HAS__USER foreign key (PHONE)
      references "USER" (PHONE);

alter table POST
   add constraint FK_POST_POST_HAS__CATEGORY foreign key (CATEGORYTITLE)
      references CATEGORY (CATEGORYTITLE);

alter table POST
   add constraint FK_POST_USER_HAS__USER foreign key (PHONE)
      references "USER" (PHONE);

alter table POST_HAS_TAGS
   add constraint FK_POST_HAS_POST_HAS__POST foreign key (PID)
      references POST (PID);

alter table POST_HAS_TAGS
   add constraint FK_POST_HAS_POST_HAS__TAG foreign key (TITLE)
      references TAG (TITLE);

alter table "USER"
   add constraint FK_USER_USER_HAS__ROLE foreign key (ROLENAME)
      references ROLE (ROLENAME);

alter table answer 
    add constraint ANSWER_TITLE_CHECK check(REGEXP_LIKE(ANSWERTITLE, '^[A-z ,!.-]{0,526}$'));

alter table answer 
    add constraint ANSWER_TEXT_CHECK check(REGEXP_LIKE(ANSWERTEXT, '^[A-Za-z0-9 ;—–.,!?+<>\/-]{5,2000}$'));
    
alter table CATEGORY 
    add constraint CATEGORY_NAME_CHECK check(REGEXP_LIKE(CATEGORYTITLE, '^[A-z -]{1,40}$'));
    
alter table post 
    add constraint POST_TITLE_CHECK check(REGEXP_LIKE(POSTTITLE, '^[A-z ,!.-]{5,526}$'));

alter table post 
    add constraint POST_TEXT_CHECK check(REGEXP_LIKE(POSTTEXT, '^[A-Za-z0-9 ;—–.,!?+<>\/-]{5,2000}$'));
    
alter table role  
    add constraint ROLE_NAME_CHECK check(REGEXP_LIKE(ROLENAME, '^[A-Za-z]{1,20}$'));

alter table TAG  
    add constraint TITLE_CHECK check(REGEXP_LIKE(TITLE, '^[A-Za-z -]{1,20}$'));
    
alter table "USER"
    add constraint PHONE_CHECK check(REGEXP_LIKE(PHONE, '^(\+[0-9]{1,3}|0)[0-9]{3}( ){0,1}[0-9]{7,8}$'));

alter table "USER"
    add constraint NAME_CHECK check(REGEXP_LIKE(NAME, '^[A-Za-z -]{5,100}$'));

alter table "USER"
    add constraint EMAIL_CHECK check(REGEXP_LIKE(EMAIL, '^([A-Z|a-z|0-9](\.|_){0,1})+[A-Z|a-z|0-9]\@([A-Z|a-z|0-9])+((\.){0,1}[A-Z|a-z|0-9]){2}\.[a-z]{2,3}$'));
    
CREATE TRIGGER answer_deletion before delete
on answer
for each row
begin
    update post 
    set published = 0
    where pid = :OLD.pid;
end;