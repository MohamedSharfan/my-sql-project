CREATE OR REPLACE VIEW attendance_summary_by_student AS
SELECT
    s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    a.course_code,
 
    SUM(
        CASE
            WHEN a.status = 'Present' THEN 1
            WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS attended_classes,

    
    ROUND(
        SUM(
            CASE
                WHEN a.status = 'Present' THEN 1
                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                ELSE 0
            END
        ) / COUNT(a.week_no) * 100,
        2
    ) AS attendance_percentage,

    CASE
        WHEN ROUND(
            SUM(
                CASE
                    WHEN a.status = 'Present' THEN 1
                    WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                    ELSE 0
                END
            ) / COUNT(a.week_no) * 100,
            2
        ) >= 80 THEN 'Eligible'
        ELSE 'Not Eligible'
    END AS eligibility
FROM attendance a
JOIN student s ON a.reg_no = s.reg_no
JOIN user u ON s.reg_no = u.id
LEFT JOIN medical m ON a.ref_no = m.ref_no

GROUP BY s.reg_no, a.course_code, student_name;




CREATE OR REPLACE VIEW attendance_summary_by_course AS
SELECT
    a.course_code,
    s.reg_no,
    CONCAT(u.f_name, ' ', u.l_name) AS student_name,
    COUNT(a.week_no) AS total_classes,
    SUM(
        CASE
            WHEN a.status = 'Present' THEN 1
            WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS attended_classes,
    ROUND(
        SUM(
            CASE
                WHEN a.status = 'Present' THEN 1
                WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                ELSE 0
            END
        ) / COUNT(a.week_no) * 100, 2
    ) AS attendance_percentage,
    CASE
        WHEN ROUND(
            SUM(
                CASE
                    WHEN a.status = 'Present' THEN 1
                    WHEN a.status = 'Medical' AND m.status = 'Approved' THEN 1
                    ELSE 0
                END
            ) / COUNT(a.week_no) * 100, 2
        ) >= 80 THEN 'Eligible'
        ELSE 'Not Eligible'
    END AS eligibility
FROM attendance a
JOIN student s ON a.reg_no = s.reg_no
JOIN user u ON s.reg_no = u.id
LEFT JOIN medical m ON a.ref_no = m.ref_no
GROUP BY a.course_code, s.reg_no;










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
