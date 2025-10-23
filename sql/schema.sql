

CREATE DATABASE tecmis;
USE tecmis;
CREATE TABLE department (
    dep_id CHAR(7) PRIMARY KEY,
    dep_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) UNIQUE
);
CREATE TABLE user (
    id CHAR(12) PRIMARY KEY,
    f_name VARCHAR(50) NOT NULL,
    l_name VARCHAR(50) NOT NULL,
    type VARCHAR(30) NOT NULL,
    nic VARCHAR(15) UNIQUE,
    email VARCHAR(100) UNIQUE,
    contact_no VARCHAR(15)
);
CREATE TABLE lecturer (
    lec_id CHAR(12) PRIMARY KEY,
    designation VARCHAR(50),
    department_id CHAR(7),
    FOREIGN KEY (lec_id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (department_id) REFERENCES department(dep_id) ON DELETE
    SET NULL ON UPDATE CASCADE
);
CREATE TABLE lecturer_degree (
    lec_id CHAR(12),
    degree VARCHAR(100),
    PRIMARY KEY (lec_id, degree),
    FOREIGN KEY (lec_id) REFERENCES lecturer(lec_id) ON DELETE CASCADE ON UPDATE CASCADE
);





CREATE TABLE technical_officer (
    id CHAR(12) PRIMARY KEY,
    hash_pwd VARCHAR(255) NOT NULL,
    FOREIGN KEY (id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE admin (
    id CHAR(12) PRIMARY KEY,
    hash_pwd VARCHAR(255) NOT NULL,
    FOREIGN KEY (id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE dean (
    id CHAR(12) PRIMARY KEY,
    appoint_date DATE NOT NULL,
    office_room VARCHAR(255) NOT NULL,
    FOREIGN KEY (id) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE student (
    reg_no CHAR(12) PRIMARY KEY,
    year INT,
    dob DATE,
    gender ENUM('F', 'M'),
    status ENUM('Proper', 'Repeat') DEFAULT 'Proper',
    department_id CHAR(7),
    lec_id CHAR(12),
    FOREIGN KEY (department_id) REFERENCES department(dep_id) ON DELETE
    SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (lec_id) REFERENCES lecturer(lec_id) ON DELETE
    SET NULL ON UPDATE CASCADE,
        FOREIGN KEY (reg_no) REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE
);




CREATE TABLE medical (
    ref_no CHAR(6) PRIMARY KEY,
    status ENUM('Approved', 'Pending', 'Rejected') DEFAULT 'Pending',
    reason TEXT,
    reg_no CHAR(12),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (reg_no) REFERENCES student(reg_no) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE exam_type (
    type_id CHAR(4) PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE course_unit (
    course_code CHAR(7) PRIMARY KEY,
    credits INT,
    title VARCHAR(100),
    type ENUM('Theory', 'Practical', 'Both'),
    department_id CHAR(7),
    FOREIGN KEY (department_id) REFERENCES department(dep_id) ON DELETE
    SET NULL ON UPDATE CASCADE
);
CREATE TABLE student_course (
    reg_no CHAR(12),
    course_code CHAR(7),
    PRIMARY KEY (reg_no, course_code),
    FOREIGN KEY (reg_no) REFERENCES student(reg_no) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code) REFERENCES course_unit(course_code) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE lecturer_course (
    lec_id CHAR(12),
    course_code CHAR(7),
    no_of_hours INT,
    PRIMARY KEY (lec_id, course_code),
    FOREIGN KEY (lec_id) REFERENCES lecturer(lec_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code) REFERENCES course_unit(course_code) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Marks (
    Mark_id CHAR(12) PRIMARY KEY,
    Is_medical BOOLEAN DEFAULT FALSE,
    Assessment DECIMAL(5, 2),
    Mid_theory DECIMAL(5, 2),
    Mid_practical DECIMAL(5, 2),
    Final_theory DECIMAL(5, 2),
    Final_practical DECIMAL(5, 2),
    Quiz_01 DECIMAL(5, 2),
    Quiz_02 DECIMAL(5, 2),
    Quiz_03 DECIMAL(5, 2),
    Reg_no CHAR(12),
    Ref_no CHAR(12),
    Course_code CHAR(12),
    FOREIGN KEY (Reg_no) REFERENCES Student(Reg_no) ON DELETE CASCADE,
    FOREIGN KEY (Ref_no) REFERENCES Medical(Ref_no) ON DELETE
    SET NULL,
        FOREIGN KEY (Course_code) REFERENCES Course_Unit(Course_code) ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id CHAR(12) PRIMARY KEY,
    week_no INT,
    status ENUM('Present', 'Absent', 'Medical'),
    reg_no CHAR(12),
    course_code CHAR(7),
    ref_no CHAR(6),
    FOREIGN KEY (reg_no) REFERENCES student(reg_no) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code) REFERENCES course_unit(course_code) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ref_no) REFERENCES medical(ref_no) ON DELETE
    SET NULL ON UPDATE CASCADE
);
CREATE TABLE student_guardian (
    reg_no CHAR(12) NOT NULL,
    guardian_id CHAR(12) NOT NULL,
    name VARCHAR(100) DEFAULT NULL,
    contact_no VARCHAR(15) DEFAULT NULL,
    relationship VARCHAR(50) DEFAULT NULL,
    occupation VARCHAR(100) DEFAULT NULL,
    PRIMARY KEY (reg_no, guardian_id),
    CONSTRAINT student_guardian_ibfk_1 FOREIGN KEY (reg_no) REFERENCES student (reg_no) ON DELETE CASCADE ON UPDATE CASCADE
);
