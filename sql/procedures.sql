

DELIMITER //

CREATE PROCEDURE GetAttendanceByCourse(IN p_course_code CHAR(7))
BEGIN
    SELECT *
    FROM attendance_summary_by_course
    WHERE course_code = p_course_code;
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE GetAttendanceByStudent(IN p_reg_no VARCHAR(12))
BEGIN
    SELECT *
    FROM attendance_summary_by_student
    WHERE reg_no = p_reg_no;
END //


DELIMITER ;

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

DELIMITER ;

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


DELIMITER ;


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
           CAST(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       ELSE 0
                   END
               ) AS UNSIGNED
           ) AS attended_hours,
           CAST(
               (15 * CASE
                        WHEN cu.type = 'Both' THEN cu.session_hour / 2
                        ELSE cu.session_hour
                    END) AS UNSIGNED
           ) AS total_hours,
           ROUND(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       ELSE 0
                   END
               ) / (15 * CASE
                            WHEN cu.type = 'Both' THEN cu.session_hour / 2
                            ELSE cu.session_hour
                        END) * 100,
               2
           ) AS attendance_percentage,
           CASE
               WHEN ROUND(
                        SUM(
                            CASE
                                WHEN a.status = 'Present' THEN CASE
                                    WHEN cu.type = 'Both' THEN cu.session_hour / 2
                                    ELSE cu.session_hour
                                END
                                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN CASE
                                    WHEN cu.type = 'Both' THEN cu.session_hour / 2
                                    ELSE cu.session_hour
                                END
                                ELSE 0
                            END
                        ) / (15 * CASE
                                     WHEN cu.type = 'Both' THEN cu.session_hour / 2
                                     ELSE cu.session_hour
                                 END) * 100,
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
             cu.session_hour,
             cu.type;
END //

DELIMITER ;

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
           CAST(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       ELSE 0
                   END
               ) AS UNSIGNED
           ) AS attended_hours,
           CAST(
               (15 * CASE
                        WHEN cu.type = 'Both' THEN cu.session_hour / 2
                        ELSE cu.session_hour
                    END) AS UNSIGNED
           ) AS total_hours,
           ROUND(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN CASE
                           WHEN cu.type = 'Both' THEN cu.session_hour / 2
                           ELSE cu.session_hour
                       END
                       ELSE 0
                   END
               ) / (15 * CASE
                            WHEN cu.type = 'Both' THEN cu.session_hour / 2
                            ELSE cu.session_hour
                        END) * 100,
               2
           ) AS attendance_percentage,
           CASE
               WHEN ROUND(
                        SUM(
                            CASE
                                WHEN a.status = 'Present' THEN CASE
                                    WHEN cu.type = 'Both' THEN cu.session_hour / 2
                                    ELSE cu.session_hour
                                END
                                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN CASE
                                    WHEN cu.type = 'Both' THEN cu.session_hour / 2
                                    ELSE cu.session_hour
                                END
                                ELSE 0
                            END
                        ) / (15 * CASE
                                     WHEN cu.type = 'Both' THEN cu.session_hour / 2
                                     ELSE cu.session_hour
                                 END) * 100,
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
             cu.session_hour,
             cu.type;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAttendanceCombined(
    IN p_reg_no CHAR(12),
    IN p_course_code CHAR(7)
)
BEGIN
    SELECT s.reg_no,
           CONCAT(u.f_name, ' ', u.l_name) AS student_name,
           cu.course_code,
           cu.title AS course_name,
           SUM(
               CASE
                   WHEN a.status = 'Present' THEN 1
                   WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                   ELSE 0
               END
           ) AS total_attended_sessions,
           COUNT(*) AS total_sessions,
           CAST(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN cu.session_hour / 2
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour / 2
                       ELSE 0
                   END
               ) AS UNSIGNED
           ) AS attended_hours,
           CAST((15 * cu.session_hour) AS UNSIGNED) AS total_hours,
           ROUND(
               SUM(
                   CASE
                       WHEN a.status = 'Present' THEN cu.session_hour / 2
                       WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour / 2
                       ELSE 0
                   END
               ) / (15 * cu.session_hour) * 100,
               2
           ) AS combined_attendance_percentage,
           CASE
               WHEN ROUND(
                        SUM(
                            CASE
                                WHEN a.status = 'Present' THEN cu.session_hour / 2
                                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour / 2
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
      AND cu.type = 'Both'
    GROUP BY s.reg_no,
             cu.course_code,
             student_name,
             cu.title,
             cu.session_hour;
END //


DELIMITER ;

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
<<<<<<< HEAD
=======
=======





>>>>>>> 7fdad4172b784caeaa7e822ac7e5b65601e26a54


DELIMITER //

<<<<<<< HEAD
CREATE PROCEDURE Individual_CA(IN s_reg_no CHAR(12),IN s_course CHAR(7))
    
 
BEGIN
    SELECT 
        m.reg_no,
        m.course_code,
        MAX(CASE WHEN m.type_id='QU01' THEN m.mark END) AS QU01,
        MAX(CASE WHEN m.type_id='QU02' THEN m.mark END) AS QU02,
        MAX(CASE WHEN m.type_id='QU03' THEN m.mark END) AS QU03,
        MAX(CASE WHEN m.type_id='ASST' THEN m.mark END) AS ASST,
        MAX(CASE WHEN m.type_id='MIDT' THEN m.mark END) AS MIDT,
        MAX(CASE WHEN m.type_id='MIDP' THEN m.mark END) AS MIDP,
        c.ca_marks
    FROM marks m
    JOIN CA_Marks c ON m.reg_no = c.reg_no AND m.course_code = c.course_code
    WHERE m.reg_no = s_reg_no
      AND m.course_code = s_course
      AND m.type_id IN ('QU01','QU02','QU03','ASST','MIDT','MIDP')
    GROUP BY m.reg_no, m.course_code;
=======
CREATE PROCEDURE get_student_summary(IN input_reg_no VARCHAR(12))
BEGIN
     IF EXISTS (SELECT 1 FROM student_final_grades WHERE reg_no = input_reg_no) THEN
        
         SELECT
            course_code,
            course_name,
            final_grade
        FROM student_final_grades
        WHERE reg_no = input_reg_no
        ORDER BY course_code;

    ELSE
        SELECT 'Student not found' AS message;
    END IF;
>>>>>>> 7fdad4172b784caeaa7e822ac7e5b65601e26a54
END //

DELIMITER ;


<<<<<<< HEAD
DELIMITER //

CREATE PROCEDURE Ca_By_RegNo(IN s_reg_no CHAR(12))
BEGIN
    SELECT
        m.course_code,
        MAX(CASE WHEN m.type_id='QU01' THEN m.mark END) AS QU01,
        MAX(CASE WHEN m.type_id='QU02' THEN m.mark END) AS QU02,
        MAX(CASE WHEN m.type_id='QU03' THEN m.mark END) AS QU03,
        MAX(CASE WHEN m.type_id='ASST' THEN m.mark END) AS ASST,
        MAX(CASE WHEN m.type_id='MIDT' THEN m.mark END) AS MIDT,
        MAX(CASE WHEN m.type_id='MIDP' THEN m.mark END) AS MIDP,
        
      
        c.ca_marks AS total_ca
        
    FROM marks m
    JOIN CA_Marks c
      ON m.reg_no = c.reg_no
     AND m.course_code = c.course_code
     
    WHERE m.reg_no = s_reg_no
      AND m.type_id IN ('QU01','QU02','QU03','ASST','MIDT','MIDP')
      
    GROUP BY m.course_code
    ORDER BY m.course_code;
=======




--adhikari


DELIMITER //

CREATE PROCEDURE StudentGPAWithGuardians(
    IN student_reg_no CHAR(12)
)
BEGIN
    WITH course_grades AS (
        SELECT 
            sc.reg_no,
            sc.course_code,
            cu.credits,
            cu.title,
            
            COALESCE(
                (COALESCE(m_asst.mark, 0) * 0.1 +  
                COALESCE(m_midt.mark, 0) * 0.2 +   
                COALESCE(m_midp.mark, 0) * 0.15 +  
                COALESCE(m_fint.mark, 0) * 0.3 +   
                COALESCE(m_finp.mark, 0) * 0.2 +   
                COALESCE(m_quiz1.mark, 0) * 0.025 + 
                COALESCE(m_quiz2.mark, 0) * 0.025 + 
                COALESCE(m_quiz3.mark, 0) * 0.025   
                ), 0
            ) AS total_marks,
            
            CASE 
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 85 THEN 4.00  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 80 THEN 4.00  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 75 THEN 3.70  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 70 THEN 3.30  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 65 THEN 3.00  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 60 THEN 2.70  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 55 THEN 2.30  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 50 THEN 2.00  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 45 THEN 1.70  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 40 THEN 1.30  
                WHEN COALESCE(
                    (COALESCE(m_asst.mark, 0) * 0.1 +
                    COALESCE(m_midt.mark, 0) * 0.2 +
                    COALESCE(m_midp.mark, 0) * 0.15 +
                    COALESCE(m_fint.mark, 0) * 0.3 +
                    COALESCE(m_finp.mark, 0) * 0.2 +
                    COALESCE(m_quiz1.mark, 0) * 0.025 +
                    COALESCE(m_quiz2.mark, 0) * 0.025 +
                    COALESCE(m_quiz3.mark, 0) * 0.025
                    ), 0) >= 35 THEN 1.00  
                ELSE 0.00  
            END AS grade_point
        FROM student_course sc
        JOIN course_unit cu ON sc.course_code = cu.course_code
        
        LEFT JOIN marks m_asst ON sc.reg_no = m_asst.reg_no AND sc.course_code = m_asst.course_code AND m_asst.type_id = 'ASST'
        LEFT JOIN marks m_midt ON sc.reg_no = m_midt.reg_no AND sc.course_code = m_midt.course_code AND m_midt.type_id = 'MIDT'
        LEFT JOIN marks m_midp ON sc.reg_no = m_midp.reg_no AND sc.course_code = m_midp.course_code AND m_midp.type_id = 'MIDP'
        LEFT JOIN marks m_fint ON sc.reg_no = m_fint.reg_no AND sc.course_code = m_fint.course_code AND m_fint.type_id = 'FINT'
        LEFT JOIN marks m_finp ON sc.reg_no = m_finp.reg_no AND sc.course_code = m_finp.course_code AND m_finp.type_id = 'FINP'
        LEFT JOIN marks m_quiz1 ON sc.reg_no = m_quiz1.reg_no AND sc.course_code = m_quiz1.course_code AND m_quiz1.type_id = 'QU01'
        LEFT JOIN marks m_quiz2 ON sc.reg_no = m_quiz2.reg_no AND sc.course_code = m_quiz2.course_code AND m_quiz2.type_id = 'QU02'
        LEFT JOIN marks m_quiz3 ON sc.reg_no = m_quiz3.reg_no AND sc.course_code = m_quiz3.course_code AND m_quiz3.type_id = 'QU03'
        WHERE sc.reg_no = student_reg_no
    ),
    semester_calculations AS (
        SELECT 
            cg.reg_no,
            s.year AS academic_year,
            CASE 
                WHEN MONTH(NOW()) BETWEEN 1 AND 6 THEN 2  
                ELSE 1  
            END AS semester,
            SUM(cg.grade_point * cg.credits) AS total_grade_points,
            SUM(cg.credits) AS total_credits,
            CASE 
                WHEN SUM(cg.credits) > 0 THEN SUM(cg.grade_point * cg.credits) / SUM(cg.credits)
                ELSE 0
            END AS sgpa
        FROM course_grades cg
        JOIN student s ON cg.reg_no = s.reg_no
        WHERE cg.reg_no = student_reg_no
        GROUP BY cg.reg_no, s.year, 
            CASE 
                WHEN MONTH(NOW()) BETWEEN 1 AND 6 THEN 2
                ELSE 1
            END
    ),
    cumulative_calculations AS (
        SELECT 
            reg_no,
            SUM(total_grade_points) AS cumulative_grade_points,
            SUM(total_credits) AS cumulative_credits,
            CASE 
                WHEN SUM(total_credits) > 0 THEN SUM(total_grade_points) / SUM(total_credits)
                ELSE 0
            END AS cgpa
        FROM semester_calculations
        WHERE reg_no = student_reg_no
        GROUP BY reg_no
    ),
    guardian_info AS (
        SELECT 
            reg_no,
            GROUP_CONCAT(CONCAT(name, ' (', relationship, ')') SEPARATOR ', ') AS guardian_names,
            GROUP_CONCAT(contact_no SEPARATOR ', ') AS guardian_contacts,
            GROUP_CONCAT(relationship SEPARATOR ', ') AS guardian_relationships
        FROM student_guardian
        WHERE reg_no = student_reg_no
        GROUP BY reg_no
    )
    SELECT 
        s.reg_no,
        u.f_name,
        u.l_name,
        s.year AS current_year,
        sc.semester,
        sc.sgpa,
        cc.cgpa,
        COALESCE(gi.guardian_names, 'No guardian registered') AS guardian_names,
        COALESCE(gi.guardian_contacts, 'No contact information') AS guardian_contacts,
        COALESCE(gi.guardian_relationships, 'No relationship specified') AS guardian_relationships
    FROM student s
    JOIN user u ON s.reg_no = u.id
    JOIN semester_calculations sc ON s.reg_no = sc.reg_no
    JOIN cumulative_calculations cc ON s.reg_no = cc.reg_no
    LEFT JOIN guardian_info gi ON s.reg_no = gi.reg_no
    WHERE s.reg_no = student_reg_no;
>>>>>>> 7fdad4172b784caeaa7e822ac7e5b65601e26a54
END //

DELIMITER ;

<<<<<<< HEAD
=======




>>>>>>> 7fdad4172b784caeaa7e822ac7e5b65601e26a54

