
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

DELIMITER //

CREATE PROCEDURE Highest_CA_Per_Course()
BEGIN
    SELECT 
        c.course_code,
        c.reg_no,
        c.ca_marks
    FROM CA_marks c
    JOIN (
        SELECT course_code, MAX(ca_marks) AS highest_ca
        FROM CA_marks
        GROUP BY course_code
    ) h
      ON c.course_code = h.course_code
     AND c.ca_marks = h.highest_ca
    ORDER BY c.course_code;
END //

DELIMITER ;    


DELIMITER //

CREATE PROCEDURE Whole_Batch_Ca_Summary()
BEGIN
    SELECT 
        c.course_code,
        COUNT(*) AS total_students,
        ROUND(AVG(c.ca_marks),2) AS avg_ca,
        ROUND(MAX(c.ca_marks),2) AS highest_ca,
        ROUND(MIN(c.ca_marks),2) AS lowest_ca,
        SUM(CASE WHEN e.eligibility = 'Eligible' THEN 1 ELSE 0 END) AS eligible_students,
        SUM(CASE WHEN e.eligibility = 'Not Eligible' THEN 1 ELSE 0 END) AS not_eligible_students,
        SUM(CASE WHEN e.eligibility = 'MC' THEN 1 ELSE 0 END) AS mc_students
    FROM CA_marks c
    JOIN CA_eligibility e
      ON c.reg_no = e.reg_no
     AND c.course_code = e.course_code
    GROUP BY c.course_code
    ORDER BY c.course_code;
END //

DELIMITER ; 


DELIMITER // 


DELIMITER //

CREATE PROCEDURE Get_Individual_CA(IN s_reg CHAR(12), IN s_course CHAR(7))
BEGIN

  SELECT 
    reg_no,
    course_code,
    ca_marks,
    IF(ca_marks >= 16, 'Eligible', 'Not Eligible') AS eligibility
  FROM CA_marks
  WHERE reg_no = s_reg AND course_code = s_course;
  
END //

DELIMITER ; 


CREATE PROCEDURE Individual_CA_Summary(IN s_reg_no CHAR(12))
    
BEGIN
    SELECT 
        c.reg_no,
        c.course_code,
        c.ca_marks,
        c.Best_two_quizzes,
        e.eligibility
    FROM CA_marks c
    JOIN CA_eligibility e
      ON c.reg_no = e.reg_no
     AND c.course_code = e.course_code
    WHERE c.reg_no = s_reg_no
    ORDER BY c.course_code;
END //

DELIMITER ;




