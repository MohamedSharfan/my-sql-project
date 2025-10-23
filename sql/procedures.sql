
DELIMITER //

CREATE PROCEDURE get_attendance_by_course(IN p_course_code CHAR(7))
BEGIN
    SELECT *
    FROM attendance_summary_by_course
    WHERE course_code = p_course_code
    ORDER BY student_name;
END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE get_attendence_student(
    IN p_reg_no CHAR(12)
)
BEGIN
    SELECT * FROM attendance_summary_by_student 
    WHERE reg_no = p_reg_no;
END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE get_attendence_student_with_courseid_and_tg(
    IN p_reg_no CHAR(12),
    IN p_course_code CHAR(7)
)
BEGIN
    SELECT * FROM attendance_summary_by_student 
    WHERE reg_no = p_reg_no
        AND course_code = p_course_code;
END //

DELIMITER ;
