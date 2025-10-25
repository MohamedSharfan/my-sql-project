----Sharfan 
CREATE OR REPLACE VIEW attendance_summary_by_student AS
SELECT s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    a.course_code,
    cu.session_hour,
    a.session_type,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN 1
            WHEN a.status = 'Medical'
            AND m.status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS attended_sessions,
    (15 * cu.session_hour) AS total_hours,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN cu.session_hour
            WHEN a.status = 'Medical'
            AND m.status = 'Approved' THEN cu.session_hour
            ELSE 0
        END
    ) AS attended_hours,
    ROUND(
        SUM(
            CASE
                WHEN a.status = 'Present' THEN cu.session_hour
                WHEN a.status = 'Medical'
                AND m.status = 'Approved' THEN cu.session_hour
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
                    WHEN a.status = 'Medical'
                    AND m.status = 'Approved' THEN cu.session_hour
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
GROUP BY s.reg_no,
    a.course_code,
    a.session_type,
    student_name,
    cu.session_hour;









CREATE OR REPLACE VIEW attendance_summary_by_course AS
SELECT cu.course_code,
    cu.title,
    cu.session_hour,
    a.session_type,
    COUNT(DISTINCT a.reg_no) AS total_students,
    (15 * cu.session_hour) AS total_hours_per_student,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN cu.session_hour
            WHEN a.status = 'Medical'
            AND m.status = 'Approved' THEN cu.session_hour
            ELSE 0
        END
    ) AS total_attended_hours,
    ROUND(
        SUM(
            CASE
                WHEN a.status = 'Present' THEN cu.session_hour
                WHEN a.status = 'Medical'
                AND m.status = 'Approved' THEN cu.session_hour
                ELSE 0
            END
        ) / (COUNT(DISTINCT a.reg_no) * 15 * cu.session_hour) * 100,
        2
    ) AS average_attendance_percentage
FROM course_unit cu
    LEFT JOIN attendance a ON a.course_code = cu.course_code
    LEFT JOIN medical m ON a.ref_no = m.ref_no
GROUP BY cu.course_code,
    cu.title,
    cu.session_hour,
    a.session_type;







CREATE OR REPLACE VIEW attendance_summary_pivot AS
SELECT s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ENG1222'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS ENG1222_Theory,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1212'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1212_Theory,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1222'
                AND session_type = 'Practical' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1222_Practical,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1233'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1233_Theory,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1233'
                AND session_type = 'Practical' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1233_Practical,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1242'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1242_Theory,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1253'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1253_Theory,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'ICT1253'
                AND session_type = 'Practical' THEN attendance_percentage
            END
        ),
        2
    ) AS ICT1253_Practical,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'TCS1212'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS TCS1212_Theory,
    ROUND(
        MAX(
            CASE
                WHEN course_code = 'TMS1233'
                AND session_type = 'Theory' THEN attendance_percentage
            END
        ),
        2
    ) AS TMS1233_Theory
FROM (
        SELECT a.reg_no,
            a.course_code,
            a.session_type,
            SUM(
                CASE
                    WHEN a.status = 'Present'
                    OR (
                        a.status = 'Medical'
                        AND m.status = 'Approved'
                    ) THEN cu.session_hour
                    ELSE 0
                END
            ) AS attended_hours,
            15 * cu.session_hour AS total_hours,
            (
                SUM(
                    CASE
                        WHEN a.status = 'Present'
                        OR (
                            a.status = 'Medical'
                            AND m.status = 'Approved'
                        ) THEN cu.session_hour
                        ELSE 0
                    END
                ) / (15 * cu.session_hour) * 100
            ) AS attendance_percentage
        FROM attendance a
            JOIN course_unit cu ON a.course_code = cu.course_code
            LEFT JOIN medical m ON a.ref_no = m.ref_no
        GROUP BY a.reg_no,
            a.course_code,
            a.session_type,
            cu.session_hour
    ) AS t
    JOIN student s ON t.reg_no = s.reg_no
    JOIN user u ON u.id = s.reg_no
GROUP BY s.reg_no,
    student_name;




CREATE OR REPLACE VIEW attendance_combined_theory_practical AS
SELECT s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    cu.course_code,
    cu.title AS course_name,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN 1
            WHEN a.status = 'Medical'
            AND m.status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS total_attended_sessions,
    COUNT(*) AS total_sessions,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN cu.session_hour
            WHEN a.status = 'Medical'
            AND m.status = 'Approved' THEN cu.session_hour
            ELSE 0
        END
    ) AS attended_hours,
    (15 * cu.session_hour * 2) AS total_hours,
    ROUND(
        SUM(
            CASE
                WHEN a.status = 'Present' THEN cu.session_hour
                WHEN a.status = 'Medical'
                AND m.status = 'Approved' THEN cu.session_hour
                ELSE 0
            END
        ) / (15 * cu.session_hour * 2) * 100,
        2
    ) AS combined_attendance_percentage,
    CASE
        WHEN ROUND(
            SUM(
                CASE
                    WHEN a.status = 'Present' THEN cu.session_hour
                    WHEN a.status = 'Medical'
                    AND m.status = 'Approved' THEN cu.session_hour
                    ELSE 0
                END
            ) / (15 * cu.session_hour * 2) * 100,
            2
        ) >= 80 THEN 'Eligible'
        ELSE 'Not Eligible'
    END AS eligibility
FROM attendance a
    JOIN student s ON a.reg_no = s.reg_no
    JOIN user u ON u.id = s.reg_no
    JOIN course_unit cu ON a.course_code = cu.course_code
    LEFT JOIN medical m ON a.ref_no = m.ref_no
WHERE cu.type = 'Both'
GROUP BY s.reg_no,
    cu.course_code,
    student_name,
    cu.title;
CREATE OR REPLACE VIEW attendance_summary AS
SELECT 
    s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    a.course_code,
    cu.title AS course_name,
    a.session_type,
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
        WHEN SUM(
            CASE
                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                ELSE 0
            END
        ) > 0 THEN 'Yes'
        ELSE 'No'
    END AS has_medical,
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
GROUP BY 
    s.reg_no,
    a.course_code,
    a.session_type,
    student_name,
    cu.title
ORDER BY 
    a.course_code,
    s.reg_no;


CREATE OR REPLACE VIEW attendance_detail_by_course AS
SELECT a.course_code,
    cu.title AS course_name,
    a.session_type,
    s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    a.session_date,
    a.week_no,
    a.status,
    CASE
        WHEN m.status = 'Approved' THEN 'Yes'
        ELSE 'No'
    END AS has_approved_medical,
    (
        SELECT ROUND(
                SUM(
                    CASE
                        WHEN a2.status = 'Present' THEN cu.session_hour
                        WHEN a2.status = 'Medical'
                        AND m2.status = 'Approved' THEN cu.session_hour
                        ELSE 0
                    END
                ) / (15 * cu.session_hour) * 100,
                2
            )
        FROM attendance a2
            LEFT JOIN medical m2 ON a2.ref_no = m2.ref_no
        WHERE a2.reg_no = a.reg_no
            AND a2.course_code = a.course_code
            AND a2.session_type = a.session_type
    ) AS attendance_percentage,
    CASE
        WHEN (
            SELECT ROUND(
                    SUM(
                        CASE
                            WHEN a2.status = 'Present' THEN cu.session_hour
                            WHEN a2.status = 'Medical'
                            AND m2.status = 'Approved' THEN cu.session_hour
                            ELSE 0
                        END
                    ) / (15 * cu.session_hour) * 100,
                    2
                )
            FROM attendance a2
                LEFT JOIN medical m2 ON a2.ref_no = m2.ref_no
            WHERE a2.reg_no = a.reg_no
                AND a2.course_code = a.course_code
                AND a2.session_type = a.session_type
        ) >= 80 THEN 'Eligible'
        ELSE 'Not Eligible'
    END AS eligibility
FROM attendance a
    JOIN student s ON a.reg_no = s.reg_no
    JOIN user u ON u.id = s.reg_no
    JOIN course_unit cu ON a.course_code = cu.course_code
    LEFT JOIN medical m ON a.ref_no = m.ref_no
ORDER BY a.course_code,
    a.session_type,
    s.reg_no,
    a.week_no;


CREATE OR REPLACE VIEW Max_two_quizzes AS 
SELECT 
	reg_no,
	MAX(CASE WHEN course_code = 'ENG1222' THEN avg_max END) AS ENG1222,
    MAX(CASE WHEN course_code = 'ICT1212' THEN avg_max END) AS ICT1212,
    MAX(CASE WHEN course_code = 'ICT1222' THEN avg_max END) AS ICT1222,
    MAX(CASE WHEN course_code = 'ICT1233' THEN avg_max END) AS ICT1233,
    MAX(CASE WHEN course_code = 'ICT1242' THEN avg_max END) AS ICT1242,
    MAX(CASE WHEN course_code = 'ICT1253' THEN avg_max END) AS ICT1253,
    MAX(CASE WHEN course_code = 'TCS1212' THEN avg_max END) AS TCS1212,
    MAX(CASE WHEN course_code = 'TMS1233' THEN avg_max END) AS TMS1233 
	
FROM ( 
	SELECT 
		reg_no, 
		course_code, 
		ROUND( 
		    ((COALESCE(MAX(CASE WHEN type_id = 'QU01' THEN mark END), 0) + 
              COALESCE(MAX(CASE WHEN type_id = 'QU02' THEN mark END), 0) + 
              COALESCE(MAX(CASE WHEN type_id = 'QU03' THEN mark END), 0) 
			  - LEAST( 
				 COALESCE(MAX(CASE WHEN type_id = 'QU01' THEN mark END), 0), 
				 COALESCE(MAX(CASE WHEN type_id = 'QU02' THEN mark END), 0), 
				 COALESCE(MAX(CASE WHEN type_id = 'QU03' THEN mark END), 0) 
				 ) 
				 )/2 
				 ),2) AS avg_max 
	FROM marks 
	WHERE type_id IN('QU01','QU02','QU03') 
	GROUP BY reg_no, course_code 
	) AS avg_quiz 
	GROUP BY reg_no;  
	
	
CREATE OR REPLACE VIEW CA_Marks AS 
	SELECT 
	   m.reg_no, 
	   m.course_code, 
	   
	   CASE m.course_code 
			WHEN 'ENG1222' THEN a.ENG1222
			WHEN 'ICT1212' THEN a.ICT1212
			WHEN 'ICT1222' THEN a.ICT1222
			WHEN 'ICT1233' THEN a.ICT1233
			WHEN 'ICT1242' THEN a.ICT1242
			WHEN 'ICT1253' THEN a.ICT1253
			WHEN 'TCS1212' THEN a.TCS1212
			WHEN 'TMS1233' THEN a.TMS1233
	   END AS avg_quiz, 

	   MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) AS assesment,
	   MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) AS mid_theory, 
       MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) AS mid_practical, 
	
	   ROUND( 
	   CASE 
		   
        WHEN m.course_code= 'TCS1212' THEN 
	        (a.TCS1212  * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
            (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.10) 
			
        WHEN m.course_code= 'TMS1233' THEN 
            (a.TMS1233 * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.05) + 
            (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.25)
			
        WHEN m.course_code= 'ICT1212' THEN 
            (a.ICT1212 * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.30) 
			
        WHEN m.course_code= 'ICT1222' THEN  
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
            (MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) * 0.20) 
			
        WHEN m.course_code= 'ICT1233' THEN 
            (a.ICT1233 * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
            (MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) * 0.10)
			
        WHEN m.course_code= 'ICT1242' THEN 
            (a.ICT1242 * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.05) + 
            (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.25)
			
        WHEN m.course_code= 'ICT1253' THEN 
            (a.ICT1253 * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.10) + 
            (MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) * 0.20)
			
        WHEN m.course_code= 'ENG1222' THEN 
            (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
            (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.20)
    END,2) AS ca_marks
	
FROM marks m 
JOIN Max_two_quizzes a ON m.reg_no = a.reg_no 
WHERE m.type_id IN('ASST','MIDT','MIDP') 
GROUP BY m.reg_no, m.course_code;  


CREATE OR REPLACE VIEW  Whole_Batch_summary AS
SELECT
    reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    MAX(CASE WHEN course_code = 'ENG1222' THEN ca_marks END) AS ENG1222,
    MAX(CASE WHEN course_code = 'ICT1212' THEN ca_marks END) AS ICT1212,
    MAX(CASE WHEN course_code = 'ICT1222' THEN ca_marks END) AS ICT1222,
    MAX(CASE WHEN course_code = 'ICT1233' THEN ca_marks END) AS ICT1233,
    MAX(CASE WHEN course_code = 'ICT1242' THEN ca_marks END) AS ICT1242,
    MAX(CASE WHEN course_code = 'ICT1253' THEN ca_marks END) AS ICT1253,
    MAX(CASE WHEN course_code = 'TCS1212' THEN ca_marks END) AS TCS1212,
    MAX(CASE WHEN course_code = 'TMS1233' THEN ca_marks END) AS TMS1233
FROM CA_marks c
JOIN user u ON u.id = c.reg_no
GROUP BY reg_no
ORDER BY reg_no;                     


CREATE OR REPLACE VIEW CA_Eligibility AS
SELECT
    c.reg_no,
    MAX(CASE WHEN c.course_code = 'ENG1222' THEN c.eligibility END) AS ENG1222,
    MAX(CASE WHEN c.course_code = 'ICT1212' THEN c.eligibility END) AS ICT1212,
    MAX(CASE WHEN c.course_code = 'ICT1222' THEN c.eligibility END) AS ICT1222,
    MAX(CASE WHEN c.course_code = 'ICT1233' THEN c.eligibility END) AS ICT1233,
    MAX(CASE WHEN c.course_code = 'ICT1242' THEN c.eligibility END) AS ICT1242,
    MAX(CASE WHEN c.course_code = 'ICT1253' THEN c.eligibility END) AS ICT1253,
    MAX(CASE WHEN c.course_code = 'TCS1212' THEN c.eligibility END) AS TCS1212,
    MAX(CASE WHEN c.course_code = 'TMS1233' THEN c.eligibility END) AS TMS1233
FROM (
    SELECT
        m.reg_no,
        m.course_code,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM medical me
                JOIN course_exam_dates ce
                  ON ce.course_code = m.course_code
                WHERE me.reg_no = m.reg_no
                  AND me.status = 'Approved'
                  AND me.start_date <= ce.exam_date
                  AND me.end_date >= ce.exam_date
            ) THEN 'MC'
            WHEN m.ca_marks >= 16 THEN 'Eligible'
            ELSE 'Not Eligible'
        END AS eligibility
    FROM ca_marks m
) AS c
GROUP BY c.reg_no
ORDER BY c.reg_no;	







CREATE OR REPLACE VIEW student_final_grades AS
SELECT reg_no,
    student_name,
    course_code,
    course_name,
    total_marks,
    CASE
        WHEN has_mc = 1 THEN 'MC'
        WHEN total_marks >= 85 THEN 'A+'
        WHEN total_marks >= 75 THEN 'A'
        WHEN total_marks >= 70 THEN 'A-'
        WHEN total_marks >= 65 THEN 'B+'
        WHEN total_marks >= 60 THEN 'B'
        WHEN total_marks >= 55 THEN 'B-'
        WHEN total_marks >= 50 THEN 'C+'
        WHEN total_marks >= 45 THEN 'C'
        WHEN total_marks >= 40 THEN 'C-'
        WHEN total_marks >= 35 THEN 'D'
        ELSE 'E'
    END AS final_grade
FROM (
        SELECT s.reg_no,
            CONCAT(u.f_name, ' ', u.l_name) AS student_name,
            cu.course_code,
            cu.title AS course_name,
            (
                (
                    (
                        COALESCE(
                            MAX(
                                CASE
                                    WHEN n.type_id = 'QU01' THEN n.mark
                                END
                            ),
                            0
                        ) + COALESCE(
                            MAX(
                                CASE
                                    WHEN n.type_id = 'QU02' THEN n.mark
                                END
                            ),
                            0
                        ) + COALESCE(
                            MAX(
                                CASE
                                    WHEN n.type_id = 'QU03' THEN n.mark
                                END
                            ),
                            0
                        )
                    ) - LEAST(
                        COALESCE(
                            MAX(
                                CASE
                                    WHEN n.type_id = 'QU01' THEN n.mark
                                END
                            ),
                            0
                        ),
                        COALESCE(
                            MAX(
                                CASE
                                    WHEN n.type_id = 'QU02' THEN n.mark
                                END
                            ),
                            0
                        ),
                        COALESCE(
                            MAX(
                                CASE
                                    WHEN n.type_id = 'QU03' THEN n.mark
                                END
                            ),
                            0
                        )
                    )
                ) / 2 * 0.10 + COALESCE(
                    MAX(
                        CASE
                            WHEN n.type_id = 'ASST' THEN n.mark
                        END
                    ),
                    0
                ) * 0.10 + CASE
                    WHEN MAX(
                        CASE
                            WHEN n.type_id = 'MIDP' THEN n.mark
                        END
                    ) IS NOT NULL THEN COALESCE(
                        MAX(
                            CASE
                                WHEN n.type_id = 'MIDT' THEN n.mark
                            END
                        ),
                        0
                    ) * 0.10 + COALESCE(
                        MAX(
                            CASE
                                WHEN n.type_id = 'MIDP' THEN n.mark
                            END
                        ),
                        0
                    ) * 0.10
                    ELSE COALESCE(
                        MAX(
                            CASE
                                WHEN n.type_id = 'MIDT' THEN n.mark
                            END
                        ),
                        0
                    ) * 0.20
                END + CASE
                    WHEN MAX(
                        CASE
                            WHEN n.type_id = 'FINP' THEN n.mark
                        END
                    ) IS NOT NULL THEN COALESCE(
                        MAX(
                            CASE
                                WHEN n.type_id = 'FINT' THEN n.mark
                            END
                        ),
                        0
                    ) * 0.40 + COALESCE(
                        MAX(
                            CASE
                                WHEN n.type_id = 'FINP' THEN n.mark
                            END
                        ),
                        0
                    ) * 0.20
                    ELSE COALESCE(
                        MAX(
                            CASE
                                WHEN n.type_id = 'FINT' THEN n.mark
                            END
                        ),
                        0
                    ) * 0.60
                END
            ) AS total_marks,
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM exam_type e
                        JOIN medical md ON md.reg_no = s.reg_no
                    WHERE md.status = 'Approved'
                        AND e.exam_date BETWEEN md.start_date AND md.end_date
                        AND e.type_id IN ('MIDT', 'MIDP', 'FINT', 'FINP')
                ) THEN 1
                ELSE 0
            END AS has_mc
        FROM marks n
            JOIN student s ON n.reg_no = s.reg_no
            JOIN user u ON s.reg_no = u.id
            JOIN course_unit cu ON n.course_code = cu.course_code
        GROUP BY s.reg_no,
            cu.course_code
    ) AS sub;





CREATE OR REPLACE VIEW student_final_grades AS
WITH marks_pivot AS (
    SELECT
        reg_no,
        course_code,
        MAX(CASE WHEN type_id = 'QU01' THEN mark END) AS q1,
        MAX(CASE WHEN type_id = 'QU02' THEN mark END) AS q2,
        MAX(CASE WHEN type_id = 'QU03' THEN mark END) AS q3,
        MAX(CASE WHEN type_id = 'ASST' THEN mark END) AS asst,
        MAX(CASE WHEN type_id = 'MIDT' THEN mark END) AS midt,
        MAX(CASE WHEN type_id = 'MIDP' THEN mark END) AS midp,
        MAX(CASE WHEN type_id = 'FINT' THEN mark END) AS fint,
        MAX(CASE WHEN type_id = 'FINP' THEN mark END) AS finp
    FROM marks
    GROUP BY reg_no, course_code
),
attendance_calc AS (
    SELECT
        reg_no,
        course_code,
        ROUND((attended_hours / total_hours) * 100, 2) AS attendance_percentage
    FROM attendance_summary_by_student
),
total_scores AS (
    SELECT
        s.reg_no,
        cu.course_code,
        cu.type AS course_type,
        ROUND(
            CASE
                WHEN cu.type = 'Both' THEN
                    (( (COALESCE(m.q1,0) + COALESCE(m.q2,0) + COALESCE(m.q3,0)
                        - LEAST(COALESCE(m.q1,0), COALESCE(m.q2,0), COALESCE(m.q3,0)) ) / 2 ) * 0.10)
                    + COALESCE(m.asst,0) * 0.10
                    + COALESCE(m.midt,0) * 0.10
                    + COALESCE(m.midp,0) * 0.10
                    + COALESCE(m.fint,0) * 0.40
                    + COALESCE(m.finp,0) * 0.20
                WHEN cu.type = 'Theory' THEN
                    (( (COALESCE(m.q1,0) + COALESCE(m.q2,0) + COALESCE(m.q3,0)
                        - LEAST(COALESCE(m.q1,0), COALESCE(m.q2,0), COALESCE(m.q3,0)) ) / 2 ) * 0.10)
                    + COALESCE(m.asst,0) * 0.10
                    + COALESCE(m.midt,0) * 0.20
                    + COALESCE(m.fint,0) * 0.60
                WHEN cu.type = 'Practical' THEN
                    (( (COALESCE(m.q1,0) + COALESCE(m.q2,0) + COALESCE(m.q3,0)
                        - LEAST(COALESCE(m.q1,0), COALESCE(m.q2,0), COALESCE(m.q3,0)) ) / 2 ) * 0.10)
                    + COALESCE(m.asst,0) * 0.10
                    + COALESCE(m.midp,0) * 0.20
                    + COALESCE(m.finp,0) * 0.60
                ELSE 0
            END, 2
        ) AS total_score
    FROM student s
    JOIN student_course sc ON s.reg_no = sc.reg_no
    JOIN course_unit cu ON sc.course_code = cu.course_code
    LEFT JOIN marks_pivot m ON m.reg_no = s.reg_no AND m.course_code = cu.course_code
)
SELECT
    s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    cu.course_code,
    cu.title AS course_name,
    cu.type AS course_type,
    ts.total_score,
    CASE
        WHEN s.status = 'Suspended' THEN 'WH'
        WHEN EXISTS (
            SELECT 1
            FROM medical m
            JOIN course_exam_dates ced ON ced.course_code = cu.course_code
            WHERE m.reg_no = s.reg_no
              AND m.status = 'Approved'
              AND m.start_date <= ced.exam_date
              AND m.end_date >= ced.exam_date
        ) THEN 'MC'
        WHEN COALESCE(att.attendance_percentage, 100) < 80 THEN 'E'
        WHEN ts.total_score >= 85 THEN 'A+'
        WHEN ts.total_score >= 75 THEN 'A'
        WHEN ts.total_score >= 70 THEN 'A-'
        WHEN ts.total_score >= 65 THEN 'B+'
        WHEN ts.total_score >= 60 THEN 'B'
        WHEN ts.total_score >= 55 THEN 'B-'
        WHEN ts.total_score >= 50 THEN 'C+'
        WHEN ts.total_score >= 45 THEN 'C'
        WHEN ts.total_score >= 40 THEN 'C-'
        ELSE 'E'
    END AS final_grade
FROM student s
JOIN user u ON s.reg_no = u.id
JOIN student_course sc ON s.reg_no = sc.reg_no
JOIN course_unit cu ON sc.course_code = cu.course_code
LEFT JOIN total_scores ts ON ts.reg_no = s.reg_no AND ts.course_code = cu.course_code
LEFT JOIN attendance_calc att ON att.reg_no = s.reg_no AND att.course_code = cu.course_code;



 
CREATE OR REPLACE VIEW end_exam_status AS
SELECT 
    s.reg_no AS reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    c.course_code AS course_code,
    c.title AS course_name,
    c.type AS course_type,
    MAX(CASE WHEN f.type_id = 'FINT' THEN f.mark END) AS FINT,
    MAX(CASE WHEN f.type_id = 'FINP' THEN f.mark END) AS FINP,
    CASE 
        WHEN c.type = 'Theory' AND MAX(CASE WHEN f.type_id = 'FINT' THEN f.mark END) >= 35 THEN 'PASS'
        WHEN c.type = 'Practical' AND MAX(CASE WHEN f.type_id = 'FINP' THEN f.mark END) >= 35 THEN 'PASS'
        WHEN c.type = 'Both' AND MAX(CASE WHEN f.type_id = 'FINT' THEN f.mark END) >= 35 
            AND MAX(CASE WHEN f.type_id = 'FINP' THEN f.mark END) >= 35 THEN 'PASS'
        ELSE 'FAIL'
    END AS end_exam_status
FROM student s
JOIN user u ON s.reg_no = u.id
JOIN marks f ON s.reg_no = f.reg_no
JOIN course_unit c ON f.course_code = c.course_code
GROUP BY s.reg_no, u.f_name, u.l_name, c.course_code, c.title, c.type;




CREATE VIEW student_final_grades_student_version AS
SELECT sf.reg_no,
       CONCAT(u.f_name, ' ', u.l_name) AS student_name,
       sf.course_code,
       sf.course_name,
       sf.final_grade
FROM student_final_grades sf
JOIN user u ON sf.reg_no = u.id
ORDER BY sf.reg_no;

#below is only to run after above 

CREATE VIEW student_grades_pivot_view_student_version AS
SELECT 
    reg_no,
    student_name,
    MAX(CASE WHEN course_code = 'ENG1222' THEN final_grade END) AS ENG1222,
    MAX(CASE WHEN course_code = 'ICT1222' THEN final_grade END) AS ICT1222,
    MAX(CASE WHEN course_code = 'ICT1242' THEN final_grade END) AS ICT1242,
    MAX(CASE WHEN course_code = 'ICT1233' THEN final_grade END) AS ICT1233,
    MAX(CASE WHEN course_code = 'ICT1212' THEN final_grade END) AS ICT1212,
    MAX(CASE WHEN course_code = 'TCS1212' THEN final_grade END) AS TCS1212,
    MAX(CASE WHEN course_code = 'ICT1253' THEN final_grade END) AS ICT1253,
    MAX(CASE WHEN course_code = 'TMS1233' THEN final_grade END) AS TMS1233
FROM student_final_grades_student_version
GROUP BY reg_no, student_name
ORDER BY reg_no;


CREATE VIEW batch_summary_of_courses AS
SELECT 
    sf.course_code,
    cu.title AS course_name,
    COUNT(*) AS total_students,
    SUM(CASE WHEN sf.final_grade = 'A+' THEN 1 ELSE 0 END) AS `A+`,
    SUM(CASE WHEN sf.final_grade = 'A'  THEN 1 ELSE 0 END) AS `A`,
    SUM(CASE WHEN sf.final_grade = 'A-' THEN 1 ELSE 0 END) AS `A-`,
    SUM(CASE WHEN sf.final_grade = 'B+' THEN 1 ELSE 0 END) AS `B+`,
    SUM(CASE WHEN sf.final_grade = 'B'  THEN 1 ELSE 0 END) AS `B`,
    SUM(CASE WHEN sf.final_grade = 'B-' THEN 1 ELSE 0 END) AS `B-`,
    SUM(CASE WHEN sf.final_grade = 'C+' THEN 1 ELSE 0 END) AS `C+`,
    SUM(CASE WHEN sf.final_grade = 'C'  THEN 1 ELSE 0 END) AS `C`,
    SUM(CASE WHEN sf.final_grade = 'E'  THEN 1 ELSE 0 END) AS `E`,
    SUM(CASE WHEN sf.final_grade = 'MC' THEN 1 ELSE 0 END) AS `MC`,
    SUM(CASE WHEN sf.final_grade = 'WH' THEN 1 ELSE 0 END) AS `WH`,
    ROUND(
        (SUM(CASE WHEN sf.final_grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C') THEN 1 ELSE 0 END) / COUNT(*) * 100),
        2
    ) AS `passed percentage`
FROM student_final_grades sf
JOIN course_unit cu ON sf.course_code = cu.course_code
GROUP BY sf.course_code, cu.title
ORDER BY sf.course_code;
