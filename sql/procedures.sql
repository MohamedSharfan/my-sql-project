DELIMITER // 

CREATE PROCEDURE GetAttendanceByCourse(IN p_course_code CHAR(7)) 
BEGIN
    SELECT *
    FROM attendance_summary_by_course
    WHERE course_code = p_course_code;
END // 

DELIMITER // 




CREATE PROCEDURE GetAttendanceByStudent(IN p_reg_no VARCHAR(12)) 
BEGIN
    SELECT *
    FROM attendance_summary_by_student
    WHERE reg_no = p_reg_no;
END // 

DELIMITER // 

CREATE PROCEDURE GetStudentReport(IN p_reg_no CHAR(12)) 
BEGIN
    SELECT course_name,
           course_code,
           final_grade
    FROM student_final_grades
    WHERE reg_no = p_reg_no
    ORDER BY course_code;
END // 

DELIMITER // 

CREATE PROCEDURE GetAttendanceByStudentAndCourse(
    IN p_reg_no CHAR(12),
    IN p_course_code CHAR(7)
) 
BEGIN
    SELECT s.reg_no,
           CONCAT(u.f_name, ' ', u.l_name) AS student_name,
           a.course_code,
           cu.title AS course_name,
           a.session_type,
           a.session_date,
           a.week_no,
           a.status,
           ROUND(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN cu.session_hour
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                       ELSE 0
                   END
               ) OVER (PARTITION BY a.session_type) / (15 * cu.session_hour) * 100,
               2
           ) AS attendance_percentage,
           CASE
               WHEN ROUND(
                        SUM(
                            CASE
                                WHEN a.status = 'Present' THEN cu.session_hour
                                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                                ELSE 0
                            END
                        ) OVER (PARTITION BY a.session_type) / (15 * cu.session_hour) * 100,
                        2
                    ) >= 80 THEN 'Eligible'
               ELSE 'Not Eligible'
           END AS eligibility
    FROM attendance a
    JOIN student s ON a.reg_no = s.reg_no
    JOIN user u ON u.id = s.reg_no
    JOIN course_unit cu ON a.course_code = cu.course_code
    LEFT JOIN medical m ON a.ref_no = m.ref_no
    WHERE a.reg_no = p_reg_no
      AND a.course_code = p_course_code
    ORDER BY a.session_type,
             a.week_no;
END // 

DELIMITER // 

CREATE PROCEDURE GetAttendanceTheoryOnly(
    IN p_reg_no CHAR(12),
    IN p_course_code CHAR(7)
) 
BEGIN
    SELECT s.reg_no,
           CONCAT(u.f_name, ' ', u.l_name) AS student_name,
           a.course_code,
           cu.title AS course_name,
           a.session_type,
           SUM(
               CASE
                   WHEN a.status = 'Present' THEN 1
                   WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                   ELSE 0
               END
           ) AS attended_sessions,
           COUNT(*) AS total_sessions,
           SUM(
               CASE
                   WHEN a.status = 'Present' THEN cu.session_hour
                   WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                   ELSE 0
               END
           ) AS attended_hours,
           (15 * cu.session_hour) AS total_hours,
           ROUND(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN cu.session_hour
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                       ELSE 0
                   END
               ) / (15 * cu.session_hour) * 100,
               2
           ) AS attendance_percentage,
           CASE
               WHEN ROUND(
                        SUM(
                            CASE
                                WHEN a.status = 'Present' THEN cu.session_hour
                                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                                ELSE 0
                            END
                        ) / (15 * cu.session_hour) * 100,
                        2
                    ) >= 80 THEN 'Eligible'
               ELSE 'Not Eligible'
           END AS eligibility
    FROM attendance a
    JOIN student s ON a.reg_no = s.reg_no
    JOIN user u ON u.id = s.reg_no
    JOIN course_unit cu ON a.course_code = cu.course_code
    LEFT JOIN medical m ON a.ref_no = m.ref_no
    WHERE a.reg_no = p_reg_no
      AND a.course_code = p_course_code
      AND a.session_type = 'Theory'
    GROUP BY s.reg_no,
             a.course_code,
             a.session_type,
             student_name,
             cu.title,
             cu.session_hour;
END // 

DELIMITER // 

CREATE PROCEDURE GetAttendancePracticalOnly(
    IN p_reg_no CHAR(12),
    IN p_course_code CHAR(7)
) 
BEGIN
    SELECT s.reg_no,
           CONCAT(u.f_name, ' ', u.l_name) AS student_name,
           a.course_code,
           cu.title AS course_name,
           a.session_type,
           SUM(
               CASE
                   WHEN a.status = 'Present' THEN 1
                   WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                   ELSE 0
               END
           ) AS attended_sessions,
           COUNT(*) AS total_sessions,
           SUM(
               CASE
                   WHEN a.status = 'Present' THEN cu.session_hour
                   WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                   ELSE 0
               END
           ) AS attended_hours,
           (15 * cu.session_hour) AS total_hours,
           ROUND(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN cu.session_hour
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                       ELSE 0
                   END
               ) / (15 * cu.session_hour) * 100,
               2
           ) AS attendance_percentage,
           CASE
               WHEN ROUND(
                        SUM(
                            CASE
                                WHEN a.status = 'Present' THEN cu.session_hour
                                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                                ELSE 0
                            END
                        ) / (15 * cu.session_hour) * 100,
                        2
                    ) >= 80 THEN 'Eligible'
               ELSE 'Not Eligible'
           END AS eligibility
    FROM attendance a
    JOIN student s ON a.reg_no = s.reg_no
    JOIN user u ON u.id = s.reg_no
    JOIN course_unit cu ON a.course_code = cu.course_code
    LEFT JOIN medical m ON a.ref_no = m.ref_no
    WHERE a.reg_no = p_reg_no
      AND a.course_code = p_course_code
      AND a.session_type = 'Practical'
    GROUP BY s.reg_no,
             a.course_code,
             a.session_type,
             student_name,
             cu.title,
             cu.session_hour;
END // 

DELIMITER // 

CREATE PROCEDURE GetAttendanceCombined(
    IN p_reg_no CHAR(12),
    IN p_course_code CHAR(7)
) 
BEGIN
    SELECT *
    FROM attendance_combined_theory_practical
    WHERE reg_no = p_reg_no
      AND course_code = p_course_code;
END // 

DELIMITER // 

CREATE PROCEDURE GetCourseAttendanceDetails(IN p_course_code CHAR(7)) 
BEGIN
    SELECT *
    FROM attendance_detail_by_course
    WHERE course_code = p_course_code
    ORDER BY session_type,
             reg_no,
             week_no;
END // 

DELIMITER ;




DROP PROCEDURE IF EXISTS get_course_summary;

DELIMITER //

CREATE PROCEDURE get_course_summary(IN input_course_code VARCHAR(7))
BEGIN
     IF EXISTS (SELECT 1 FROM batch_summary_of_courses WHERE course_code = input_course_code) THEN
        SELECT 
            course_code,
            course_name,
            total_students,
            `A+`,
            `A`,
            `A-`,
            `B+`,
            `B`,
            `B-`,
            `C+`,
            `C`,
            `E`,
            `MC`,
            `WH`,
            `passed percentage`
        FROM batch_summary_of_courses
        WHERE course_code = input_course_code;
    ELSE
        SELECT 'Course not found' AS message;
    END IF;
END //

DELIMITER ;
