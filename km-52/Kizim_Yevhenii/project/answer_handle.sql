CREATE SEQUENCE answer_ids START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE answer_handle AS
    TYPE answer_tbl IS
        TABLE OF answer%rowtype;
    PROCEDURE add_answer (
        phone_         answer.phone%TYPE,
        pid_           answer.pid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    );

    PROCEDURE edit_answer (
        aid_           answer.aid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    );

    PROCEDURE delete_answer (
        aid_ answer.aid%TYPE
    );

    FUNCTION get_answer (
        aid_ answer.aid%TYPE
    ) RETURN answer%rowtype;

    FUNCTION get_answer_by_title (
        answertitle_ answer.answertitle%TYPE
    ) RETURN answer_tbl
        PIPELINED;

    FUNCTION get_all_answers RETURN answer_tbl
        PIPELINED;

    FUNCTION get_answers_by_author (
        phone_ answer.phone%TYPE
    ) RETURN answer_tbl
        PIPELINED;

END answer_handle;
/

CREATE OR REPLACE PACKAGE BODY answer_handle AS

    PROCEDURE add_answer (
        phone_         answer.phone%TYPE,
        pid_           answer.pid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    ) IS
    BEGIN
        INSERT INTO answer (
            aid,
            phone,
            pid,
            answertitle,
            answertext,
            answercreatedtime
        ) VALUES (
            answer_ids.NEXTVAL,
            phone_,
            pid_,
            answertitle_,
            answertext_,
            current_timestamp
        );

    END add_answer;

    PROCEDURE edit_answer (
        aid_           answer.aid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    ) IS
    BEGIN
        UPDATE answer
        SET
            answer.answertitle = answertitle_,
            answer.answertext = answertext_
        WHERE
            answer.aid = aid_;

    END edit_answer;

    PROCEDURE delete_answer (
        aid_ answer.aid%TYPE
    ) IS
    BEGIN
        DELETE FROM answer
        WHERE
            answer.aid = aid_;

    END delete_answer;

    FUNCTION get_answer (
        aid_ answer.aid%TYPE
    ) RETURN answer%rowtype IS
        arec   answer%rowtype;
    BEGIN
        SELECT
            *
        INTO arec
        FROM
            answer
        WHERE
            answer.aid = aid_;

    END get_answer;

    FUNCTION get_answer_by_title (
        answertitle_ answer.answertitle%TYPE
    ) RETURN answer_tbl
        PIPELINED
    IS
        CURSOR acur IS
        SELECT
            *
        FROM
            answer
        WHERE
            instr(answer.answertitle, answertitle_) > 0;

    BEGIN
        FOR arec IN acur LOOP
            PIPE ROW ( arec );
        END LOOP;
    END get_answer_by_title;

    FUNCTION get_all_answers RETURN answer_tbl
        PIPELINED
    IS
        CURSOR acur IS
        SELECT
            *
        FROM
            answer;

    BEGIN
        FOR arec IN acur LOOP
            PIPE ROW ( arec );
        END LOOP;
    END get_all_answers;

    FUNCTION get_answers_by_author (
        phone_ answer.phone%TYPE
    ) RETURN answer_tbl
        PIPELINED
    IS
        CURSOR acur IS
        SELECT
            *
        FROM
            answer
        WHERE
            answer.phone = phone_;

    BEGIN
        FOR arec IN acur LOOP
            PIPE ROW ( arec );
        END LOOP;
    END get_answers_by_author;

END answer_handle;
/