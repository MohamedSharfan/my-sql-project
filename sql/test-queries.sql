
-- PROCEDURES

-- sharfan
CALL GetAttendanceByCourse('ICT1222');
CALL GetAttendanceByStudent('TG/2023/1786');
CALL GetAttendanceByStudentAndCourse('TG/2023/1786','ICT1222');
CALL GetAttendanceCombined('TG/2023/1786','ICT1253');
CALL GetAttendancePracticalOnly('TG/2023/1786','ICT1253');
CALL GetAttendanceTheoryOnly('TG/2023/1786','ICT1253');
CALL GetCourseAttendanceDetails('ICT1253');

--razim
CALL get_course_summary('ICT1222');
CALL get_student_summary('TG/2023/1786');


--rishma 
CALL Ca_By_RegNo('TG/2023/1787'); 
CALL Individual_CA('TG/2023/1787','ICT1233');

--adhikari
CALL StudentGPAWithGuardians('TG/2023/1780');


-- VIEWS

SELECT * FROM attendance_combined_theory_practical;
SELECT * FROM attendance_detail_by_course;
SELECT * FROM attendance_summary;
SELECT * FROM attendance_summary_by_course;
SELECT * FROM attendance_summary_by_student;
SELECT * FROM attendance_summary_pivot;
SELECT * FROM batch_summary_of_courses;
SELECT * FROM ca_eligibility;
SELECT * FROM ca_marks;
SELECT * FROM end_exam_status;
SELECT * FROM end_exam_status_pivot;
SELECT * FROM max_two_quizzes;
SELECT * FROM student_final_grades;
SELECT * FROM student_final_grades_student_version;
SELECT * FROM student_gpa;
SELECT * FROM student_grades_pivot_view_student_version;
SELECT * FROM whole_batch_summary;
SELECT * FROM whole_batch_summary_of_ca;

