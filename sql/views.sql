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
