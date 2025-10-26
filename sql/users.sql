CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON tecmis.* TO 'admin'@'localhost' WITH GRANT OPTION;


CREATE USER 'dean'@'localhost' IDENTIFIED BY 'dean123';
GRANT ALL PRIVILEGES ON tecmis.* TO 'dean'@'localhost';


CREATE USER 'techofficer'@'localhost' IDENTIFIED BY 'tech123';
GRANT SELECT, INSERT, UPDATE ON tecmis.attendance TO 'techofficer'@'localhost';
GRANT SELECT ON tecmis.attendance_combined_theory_practical TO 'techofficer'@'localhost';
GRANT SELECT ON tecmis.attendance_detail_by_course TO 'techofficer'@'localhost';
GRANT SELECT ON tecmis.attendance_summary TO 'techofficer'@'localhost';
GRANT SELECT ON tecmis.attendance_summary_by_course TO 'techofficer'@'localhost';
GRANT SELECT ON tecmis.attendance_summary_by_student TO 'techofficer'@'localhost';
GRANT SELECT ON tecmis.attendance_summary_pivot TO 'techofficer'@'localhost';



CREATE USER 'student'@'localhost' IDENTIFIED BY 'student123';

GRANT SELECT ON tecmis.attendance_summary TO 'student'@'localhost';
GRANT SELECT ON tecmis.attendance_summary_by_student TO 'student'@'localhost';
GRANT SELECT ON tecmis.attendance_combined_theory_practical TO 'student'@'localhost';
GRANT SELECT ON tecmis.attendance_detail_by_course TO 'student'@'localhost';
GRANT SELECT ON tecmis.attendance_summary_by_course TO 'student'@'localhost';
GRANT SELECT ON tecmis.attendance_summary_pivot TO 'student'@'localhost';

GRANT SELECT ON tecmis.student_final_grades_student_version TO 'student'@'localhost';
GRANT SELECT ON tecmis.student_grades_pivot_view_student_version TO 'student'@'localhost';
GRANT SELECT ON tecmis.student_gpa TO 'student'@'localhost';
