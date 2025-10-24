
DELIMITER //

CREATE PROCEDURE GetAttendanceByCourse(
    IN p_course_code CHAR(7)
)
BEGIN
    SELECT *
    FROM attendance_summary_by_course
    WHERE course_code = p_course_code;
END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetAttendanceByStudent(
    IN p_reg_no VARCHAR(12)
)
BEGIN
    SELECT *
    FROM attendance_summary_by_student
    WHERE reg_no = p_reg_no;
END //

DELIMITER ;




DELIMITER //

CREATE OR REPLACE PROCEDURE GetStudentReport(IN p_reg_no CHAR(12))
BEGIN
    SELECT course_name, course_code, final_grade
    FROM student_final_grades
    WHERE reg_no = p_reg_no
    ORDER BY course_code;
END;
//

DELIMITER ;
