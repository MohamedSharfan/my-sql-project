----Sharfan 


CREATE OR REPLACE VIEW attendance_summary_by_student AS
SELECT
    s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    a.course_code,
    cu.session_hour,
    a.session_type,

    SUM(
        CASE
            WHEN a.status = 'Present' THEN 1
            WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS attended_sessions,

    SUM(
        CASE
            WHEN a.status = 'Present' THEN cu.session_hour
            WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
            ELSE 0
        END
    ) AS attended_hours,

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

GROUP BY s.reg_no, a.course_code, a.session_type, student_name, cu.session_hour;



CREATE OR REPLACE VIEW attendance_summary_by_course AS
SELECT
    cu.course_code,
    cu.title,
    cu.session_hour,
    a.session_type,
    COUNT(DISTINCT a.reg_no) AS total_students,
    (15 * cu.session_hour) AS total_hours_per_student,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN cu.session_hour
            WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
            ELSE 0
        END
    ) AS total_attended_hours,
    ROUND(
        SUM(
            CASE
                WHEN a.status = 'Present' THEN cu.session_hour
                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN cu.session_hour
                ELSE 0
            END
        ) / (COUNT(DISTINCT a.reg_no) * 15 * cu.session_hour) * 100,
        2
    ) AS average_attendance_percentage

FROM course_unit cu
LEFT JOIN attendance a ON a.course_code = cu.course_code
LEFT JOIN medical m ON a.ref_no = m.ref_no

GROUP BY cu.course_code, cu.title, cu.session_hour, a.session_type;






CREATE OR REPLACE VIEW Best_two_quizzes AS 
SELECT 
    reg_no,
    course_code, 

    
    (
        COALESCE(MAX(CASE WHEN type_id = 'QU01' THEN mark END), 0) +
        COALESCE(MAX(CASE WHEN type_id = 'QU02' THEN mark END), 0) +
        COALESCE(MAX(CASE WHEN type_id = 'QU03' THEN mark END), 0)
        -
        LEAST(
            COALESCE(MAX(CASE WHEN type_id = 'QU01' THEN mark END), 0),
            COALESCE(MAX(CASE WHEN type_id = 'QU02' THEN mark END), 0),
            COALESCE(MAX(CASE WHEN type_id = 'QU03' THEN mark END), 0)
        )
    ) AS max_two_quizzes, 
    
    
    (
        (
            COALESCE(MAX(CASE WHEN type_id = 'QU01' THEN mark END), 0) +
            COALESCE(MAX(CASE WHEN type_id = 'QU02' THEN mark END), 0) +
            COALESCE(MAX(CASE WHEN type_id = 'QU03' THEN mark END), 0)
            -
            LEAST(
                COALESCE(MAX(CASE WHEN type_id = 'QU01' THEN mark END), 0),
                COALESCE(MAX(CASE WHEN type_id = 'QU02' THEN mark END), 0),
                COALESCE(MAX(CASE WHEN type_id = 'QU03' THEN mark END), 0)
            )
        ) / 2
    ) AS avg_max

FROM marks 
WHERE type_id IN ('QU01','QU02','QU03') 
GROUP BY reg_no, course_code;

CREATE OR REPLACE VIEW CA_marks AS 
SELECT 
	m.reg_no, 
	m.course_code,
	b.avg_max, 
	
	MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) AS assesment,
	MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) AS mid_theory, 
	MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) AS mid_practical,
	MAX(CASE WHEN m.type_id= 'FINT' THEN m.mark END) AS final_theory, 
	MAX(CASE WHEN m.type_id= 'FINP' THEN m.mark END) AS final_practical, 
	
	CASE 
		  WHEN m.course_code= 'TCS1212' THEN 
			 (b.avg_max * 0.10)+ 
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
			 (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.10)  
			 
		  WHEN m.course_code= 'TMS1233' THEN 
			 (b.avg_max * 0.10)+ 
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.05) + 
			 (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.25) 
		  
		  WHEN m.course_code= 'ICT1212' THEN 
			 (b.avg_max * 0.10)+ 
			 (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.30)  
			 
		  WHEN m.course_code= 'ICT1222' THEN  
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
			 (MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) * 0.20) 
						 
		   WHEN m.course_code= 'ICT1233' THEN 
			 (b.avg_max * 0.10)+ 
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
			 (MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) * 0.10) 
						 
		   WHEN m.course_code= 'ICT1242' THEN 
			 (b.avg_max * 0.10)+ 
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.05) + 
			 (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.25) 
						 
		   WHEN m.course_code= 'ICT1253' THEN 
			 (b.avg_max * 0.10)+ 
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.10) + 
			 (MAX(CASE WHEN m.type_id= 'MIDP' THEN m.mark END) * 0.20) 
						 
		   WHEN m.course_code= 'ENG1222' THEN 
			 (MAX(CASE WHEN m.type_id= 'ASST' THEN m.mark END) * 0.20) + 
			 (MAX(CASE WHEN m.type_id= 'MIDT' THEN m.mark END) * 0.20) 
						 
	   
    END AS ca_marks	 
	
FROM marks m 
   JOIN Best_two_quizzes b 	
   ON m.reg_no=b.reg_no  AND  m.course_code=b.course_code 
WHERE m.type_id IN('ASST','MIDT','MIDP','FINT','FINP') 
GROUP BY m.reg_no,m.course_code; 
	

CREATE OR REPLACE VIEW CA_eligibility AS
SELECT
    c.reg_no,
	CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    c.course_code,
	
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM medical md
            JOIN exam_type e 
            ON e.type_id IN ('MIDT','MIDP')
            WHERE md.reg_no = c.reg_no
              AND md.status = 'Approved'
              AND e.exam_date BETWEEN md.start_date AND md.end_date
        ) THEN 'MC'
        WHEN c.ca_marks >= 16 THEN 'Eligible'
        ELSE 'Not Eligible'
    END AS eligibility 
FROM CA_marks c
JOIN user u 
ON u.id=c.reg_no;









CREATE OR REPLACE VIEW student_final_grades AS
SELECT
    reg_no,
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
    SELECT
        s.reg_no,
        CONCAT(u.f_name, ' ', u.l_name) AS student_name,
        cu.course_code,
        cu.title AS course_name,

        
        (
            ((COALESCE(MAX(CASE WHEN n.type_id='QU01' THEN n.mark END),0) +
              COALESCE(MAX(CASE WHEN n.type_id='QU02' THEN n.mark END),0) +
              COALESCE(MAX(CASE WHEN n.type_id='QU03' THEN n.mark END),0))
             - LEAST(
                 COALESCE(MAX(CASE WHEN n.type_id='QU01' THEN n.mark END),0),
                 COALESCE(MAX(CASE WHEN n.type_id='QU02' THEN n.mark END),0),
                 COALESCE(MAX(CASE WHEN n.type_id='QU03' THEN n.mark END),0)
               )
            ) / 2 * 0.10
            + COALESCE(MAX(CASE WHEN n.type_id='ASST' THEN n.mark END),0) * 0.10
            + CASE 
                WHEN MAX(CASE WHEN n.type_id='MIDP' THEN n.mark END) IS NOT NULL
                THEN COALESCE(MAX(CASE WHEN n.type_id='MIDT' THEN n.mark END),0)*0.10 +
                     COALESCE(MAX(CASE WHEN n.type_id='MIDP' THEN n.mark END),0)*0.10
                ELSE COALESCE(MAX(CASE WHEN n.type_id='MIDT' THEN n.mark END),0)*0.20
              END
            + CASE
                WHEN MAX(CASE WHEN n.type_id='FINP' THEN n.mark END) IS NOT NULL
                THEN COALESCE(MAX(CASE WHEN n.type_id='FINT' THEN n.mark END),0)*0.40 +
                     COALESCE(MAX(CASE WHEN n.type_id='FINP' THEN n.mark END),0)*0.20
                ELSE COALESCE(MAX(CASE WHEN n.type_id='FINT' THEN n.mark END),0)*0.60
              END
        ) AS total_marks,

        
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM exam_type e
                JOIN medical md ON md.reg_no = s.reg_no
                WHERE md.status='Approved'
                  AND e.exam_date BETWEEN md.start_date AND md.end_date
                  AND e.type_id IN ('MIDT','MIDP','FINT','FINP')
            ) THEN 1 ELSE 0
        END AS has_mc

    FROM marks n
    JOIN student s ON n.reg_no = s.reg_no
    JOIN user u ON s.reg_no = u.id
    JOIN course_unit cu ON n.course_code = cu.course_code
    GROUP BY s.reg_no, cu.course_code
) AS sub;








