CREATE SEQUENCE answer_ids START WITH 5 INCREMENT BY 1 CACHE 2;

CREATE OR REPLACE PACKAGE answer_handle AS
    TYPE answer_tbl IS
        TABLE OF answer%rowtype;
    FUNCTION add_answer (
        phone_         answer.phone%TYPE,
        pid_           answer.pid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer.aid%TYPE;

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

    FUNCTION filter_answers (
        answertitle_   answer.answertitle%TYPE,
        phone_         answer.phone%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer_tbl
        PIPELINED;

END answer_handle;
/

CREATE OR REPLACE PACKAGE BODY answer_handle AS

    FUNCTION add_answer (
        phone_         answer.phone%TYPE,
        pid_           answer.pid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer.aid%TYPE IS
        aid_   answer.aid%TYPE;
    BEGIN
        aid_ := answer_ids.nextval;
        INSERT INTO answer (
            aid,
            phone,
            pid,
            answertitle,
            answertext,
            answercreatedtime
        ) VALUES (
            aid_,
            phone_,
            pid_,
            answertitle_,
            answertext_,
            current_timestamp
        );

        UPDATE post
        SET
            published = 1
        WHERE
            pid = pid_;

        RETURN aid_;
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

        RETURN arec;
    END get_answer;

    FUNCTION filter_answers (
        answertitle_   answer.answertitle%TYPE,
        phone_         answer.phone%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE answercursor IS REF CURSOR;
        acur       answercursor;
        arec       answer%rowtype;
    BEGIN
        IF answertitle_ IS NULL AND phone_ IS NULL AND answertext_ IS NULL THEN
            exec_str := 'SELECT * FROM answer';
        ELSE
            exec_str := 'SELECT * FROM answer WHERE ';
            IF answertitle_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(answer.answertitle, '''
                            || answertitle_
                            || ''') > 0 AND ';
            END IF;

            IF phone_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'answer.PHONE='''
                            || phone_
                            || ''' AND ';
            END IF;

            IF answertext_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(answer.ANSWERTEXT, '''
                            || answertext_
                            || ''') > 0 AND ';
            END IF;

            exec_str := exec_str || '0=0';
        END IF;

        OPEN acur FOR exec_str;

        LOOP
            FETCH acur INTO arec;
            EXIT WHEN acur%notfound;
            PIPE ROW ( arec );
        END LOOP;

    END filter_answers;

END answer_handle;
/