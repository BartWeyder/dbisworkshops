CREATE SEQUENCE answer_ids START WITH 5 INCREMENT BY 1 CACHE 2;

CREATE OR REPLACE PACKAGE answer_handle AS
    TYPE answer_tbl IS
        TABLE OF answer%rowtype;
    FUNCTION add_answer (
        status         OUT            VARCHAR2,
        user_id_       answer.user_id%TYPE,
        pid_           answer.pid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer.aid%TYPE;

    PROCEDURE edit_answer (
        status         OUT            VARCHAR2,
        aid_           answer.aid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    );

    PROCEDURE delete_answer (
        status   OUT      VARCHAR2,
        aid_     answer.aid%TYPE
    );

    FUNCTION get_answer (
        aid_ answer.aid%TYPE
    ) RETURN SYS_REFCURSOR;

    FUNCTION filter_answers (
        answertitle_   answer.answertitle%TYPE,
        user_id_       answer.user_id%TYPE,
        pid_           answer.pid%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer_tbl
        PIPELINED;

END answer_handle;
/

CREATE OR REPLACE PACKAGE BODY answer_handle AS

    FUNCTION add_answer (
        status         OUT            VARCHAR2,
        user_id_       answer.user_id%TYPE,
        pid_           answer.pid%TYPE,
        answertitle_   answer.answertitle%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer.aid%TYPE IS
        aid_   answer.aid%TYPE;
    BEGIN
        aid_ := answer_ids.nextval;
        INSERT INTO answer (
            aid,
            user_id,
            pid,
            answertitle,
            answertext,
            answercreatedtime
        ) VALUES (
            aid_,
            user_id_,
            pid_,
            answertitle_,
            answertext_,
            current_timestamp
        );

        UPDATE post
        SET
            published = current_timestamp
        WHERE
            pid = pid_;

        status := 'ok';
        RETURN aid_;

    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'answer already exists';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'ANSWER_TEXT_CHECK') != 0 THEN
                status := 'Text allows only alphanumeric symbols and .,!?<>\/-';
            ELSIF instr(sqlerrm, 'ANSWER_TITLE_CHECK') != 0 THEN
                status := 'Title allows only alphabethic symbols and ,!.-';
            ELSIF instr(sqlerrm, 'PID_UNIQUE') != 0 THEN
                status := 'Answer for this post already exists, edit or delete old one.';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;

    END add_answer;

    PROCEDURE edit_answer (
        status         OUT            VARCHAR2,
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

        status := 'ok';
    EXCEPTION
        WHEN dup_val_on_index THEN
            status := 'answer already exists';
        WHEN OTHERS THEN
            IF instr(sqlerrm, 'ANSWER_TEXT_CHECK') != 0 THEN
                status := 'Text allows only alphanumeric symbols and .,!?<>\/-';
            ELSIF instr(sqlerrm, 'ANSWER_TITLE_CHECK') != 0 THEN
                status := 'Title allows only alphabethic symbols and ,!.-';
            ELSE
                status := 'Uknown error. Please contact support.';
            END IF;
    END edit_answer;

    PROCEDURE delete_answer (
        status   OUT      VARCHAR2,
        aid_     answer.aid%TYPE
    ) IS
    BEGIN
        DELETE FROM answer
        WHERE
            answer.aid = aid_;

        status := 'ok';
    EXCEPTION
        WHEN OTHERS THEN
            status := 'Uknown error. Please contact support.';
    END delete_answer;

    FUNCTION get_answer (
        aid_ answer.aid%TYPE
    ) RETURN SYS_REFCURSOR IS
        arec   SYS_REFCURSOR;
    BEGIN
        OPEN arec FOR SELECT
                          *
                      FROM
                          answer
                      WHERE
                          answer.aid = aid_;

        RETURN arec;
    END get_answer;

    FUNCTION filter_answers (
        answertitle_   answer.answertitle%TYPE,
        user_id_       answer.user_id%TYPE,
        pid_           answer.pid%TYPE,
        answertext_    answer.answertext%TYPE
    ) RETURN answer_tbl
        PIPELINED
    IS
        exec_str   VARCHAR2(500);
        TYPE answercursor IS REF CURSOR;
        acur       answercursor;
        arec       answer%rowtype;
    BEGIN
        IF answertitle_ IS NULL AND user_id_ IS NULL AND pid_ IS NULL AND answertext_ IS NULL THEN
            exec_str := 'SELECT * FROM answer';
        ELSE
            exec_str := 'SELECT * FROM answer WHERE ';
            IF answertitle_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'instr(answer.answertitle, '''
                            || answertitle_
                            || ''') > 0 AND ';
            END IF;

            IF user_id_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'answer.user_id='''
                            || user_id_
                            || ''' AND ';
            END IF;

            IF pid_ IS NOT NULL THEN
                exec_str := exec_str
                            || 'answer.pid='''
                            || pid_
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

        exec_str := exec_str || ' ORDER BY answer.ANSWERCREATEDTIME';
        OPEN acur FOR exec_str;

        LOOP
            FETCH acur INTO arec;
            EXIT WHEN acur%notfound;
            PIPE ROW ( arec );
        END LOOP;

    END filter_answers;

END answer_handle;
/