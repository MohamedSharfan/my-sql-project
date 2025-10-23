

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

INSERT INTO Department (dep_id, dep_name, contact_email)
VALUES (
        'DEP001',
        'Information and Communication Technology',
        'ictdept@tec.lk'
    ),
    (
        'DEP002',
        'Engineering Technology',
        'engdept@tec.lk'
    ),
    (
        'DEP003',
        'Bio Systems Technology',
        'bstdept@tec.lk'
    ),
    (
        'DEP004',
        'Multi disciplinary',
        'multidis@tec.lk'
    );
INSERT INTO User (id, f_name, l_name, type, nic, email, contact_no)
VALUES (
        'Ad_001',
        'Ravindra',
        'Perera',
        'Admin',
        '842536789012',
        'ravindra.perera.admin@tec.lk',
        '0771234567'
    ),
    (
        'De_001',
        'Manoj',
        'Silva',
        'Dean',
        '801234567890',
        'manoj.silva.dean@tec.lk',
        '0712345678'
    ),
    (
        'Lec_003',
        'Nishantha',
        'Fernando',
        'Lecturer',
        '861112233445',
        'nishantha.fernando.lec@tec.lk',
        '0778765432'
    ),
    (
        'Lec_004',
        'Chamila',
        'Wijesinghe',
        'Lecturer',
        '881223344556',
        'chamila.wijesinghe.lec@tec.lk',
        '0759876543'
    ),
    (
        'Lec_005',
        'Kavindu',
        'Jayasinghe',
        'Lecturer',
        '890987654321',
        'kavindu.jayasinghe.lec@tec.lk',
        '0787654321'
    ),
    (
        'Lec_006',
        'Tharindu',
        'Perera',
        'Lecturer',
        '870112345678',
        'tharindu.perera.lec@tec.lk',
        '0712345678'
    ),
    (
        'Lec_007',
        'Dilani',
        'Senanayake',
        'Lecturer',
        '860223456789',
        'dilani.senanayake.lec@tec.lk',
        '0723456789'
    ),
    (
        'Lec_008',
        'Roshan',
        'Kumarasinghe',
        'Lecturer',
        '880334567890',
        'roshan.kumarasinghe.lec@tec.lk',
        '0734567890'
    ),
    (
        'Lec_009',
        'Nadeesha',
        'De Silva',
        'Lecturer',
        '890445678901',
        'nadeesha.desilva.lec@tec.lk',
        '0745678901'
    ),
    (
        'Lec_010',
        'Ravindu',
        'Fernando',
        'Lecturer',
        '900556789012',
        'ravindu.fernando.lec@tec.lk',
        '0756789012'
    ),
    (
        'Lec_011',
        'Sanduni',
        'Gunawardena',
        'Lecturer',
        '910667890123',
        'sanduni.gunawardena.lec@tec.lk',
        '0767890123'
    ),
    (
        'Lec_012',
        'Chamika',
        'Jayawardena',
        'Lecturer',
        '920778901234',
        'chamika.jayawardena.lec@tec.lk',
        '0778901234'
    ),
    (
        'Lec_013',
        'Kasun',
        'Rajapaksha',
        'Lecturer',
        '930889012345',
        'kasun.rajapaksha.lec@tec.lk',
        '0789012345'
    ),
    (
        'Lec_014',
        'Pavithra',
        'Amarasuriya',
        'Lecturer',
        '940990123456',
        'pavithra.amarasuriya.lec@tec.lk',
        '0790123456'
    ),
    (
        'Lec_015',
        'Arjun',
        'Sharma',
        'Lecturer',
        '950112345678',
        'arjun.sharma.lec@tec.lk',
        '0712345678'
    ),
    (
        'Lec_016',
        'Priya',
        'Reddy',
        'Lecturer',
        '960223456789',
        'priya.reddy.lec@tec.lk',
        '0723456789'
    ),
    (
        'TO_001',
        'Sanduni',
        'Abeysekara',
        'Technical Officer',
        '905678912345',
        'sanduni.abeysekara.to@tec.lk',
        '0765432198'
    ),
    (
        'TO_002',
        'Tharindu',
        'Gunawardena',
        'Technical Officer',
        '915123456789',
        'tharindu.gunawardena.to@tec.lk',
        '0723456789'
    ),
    (
        'TO_003',
        'Ameer',
        'Faisal',
        'Technical Officer',
        '925678901234',
        'ameer.faisal.to@tec.lk',
        '0709876543'
    ),
    (
        'TO_004',
        'Nazeera',
        'Hassan',
        'Technical Officer',
        '935789012345',
        'nazeera.hassan.to@tec.lk',
        '0718765432'
    ),
    (
        'TO_005',
        'Fathima',
        'Rizwan',
        'Technical Officer',
        '945890123456',
        'fathima.rizwan.to@tec.lk',
        '0727654321'
    ),
    (
        'TG/2023/1780',
        'Isuru',
        'Perera',
        'Student',
        '200345678901',
        'isuru.perera1780@tec.lk',
        '0777894561'
    ),
    (
        'TG/2023/1781',
        'Dilini',
        'Fernando',
        'Student',
        '200347891234',
        'dilini.fernando1781@tec.lk',
        '0719632584'
    ),
    (
        'TG/2023/1782',
        'Rashmi',
        'Wijeratne',
        'Student',
        '200358974123',
        'rashmi.wijeratne1782@tec.lk',
        '0757418529'
    ),
    (
        'TG/2023/1783',
        'Thivanka',
        'Rajapaksha',
        'Student',
        '200361234567',
        'thivanka.rajapaksha1783@tec.lk',
        '0789513574'
    ),
    (
        'TG/2023/1784',
        'Nadeesha',
        'Senanayake',
        'Student',
        '200378965432',
        'nadeesha.senanayake1784@tec.lk',
        '0748529631'
    ),
    (
        'TG/2023/1785',
        'Kavindi',
        'Perera',
        'Student',
        '200389012346',
        'kavindi.perera1785@tec.lk',
        '0771234567'
    ),
    (
        'TG/2023/1786',
        'Roshan',
        'Fernando',
        'Student',
        '200390123457',
        'roshan.fernando1786@tec.lk',
        '0712345678'
    ),
    (
        'TG/2023/1787',
        'Chamika',
        'Kumarasinghe',
        'Student',
        '200301234568',
        'chamika.kumarasinghe1787@tec.lk',
        '0753456789'
    ),
    (
        'TG/2023/1788',
        'Sanduni',
        'De Silva',
        'Student',
        '200312345679',
        'sanduni.desilva1788@tec.lk',
        '0784567890'
    ),
    (
        'TG/2023/1789',
        'Ravindu',
        'Jayasinghe',
        'Student',
        '200323456780',
        'ravindu.jayasinghe1789@tec.lk',
        '0745678901'
    ),
    (
        'TG/2023/1790',
        'Tharindu',
        'Gunawardena',
        'Student',
        '200334567891',
        'tharindu.gunawardena1790@tec.lk',
        '0726789012'
    ),
    (
        'TG/2023/1791',
        'Dilani',
        'Amarasuriya',
        'Student',
        '200345678912',
        'dilani.amarasuriya1791@tec.lk',
        '0737890123'
    ),
    (
        'TG/2023/1792',
        'Kasun',
        'Rajapaksha',
        'Student',
        '200356789123',
        'kasun.rajapaksha1792@tec.lk',
        '0768901234'
    ),
    (
        'TG/2023/1793',
        'Pavithra',
        'Senarath',
        'Student',
        '200367891234',
        'pavithra.senarath1793@tec.lk',
        '0779012345'
    ),
    (
        'TG/2023/1794',
        'Isuru',
        'Jayawardena',
        'Student',
        '200378901235',
        'isuru.jayawardena1794@tec.lk',
        '0710123456'
    ),
    (
        'TG/2023/1795',
        'Nisansala',
        'Perera',
        'Student',
        '200389012347',
        'nisansala.perera1795@tec.lk',
        '0721234567'
    ),
    (
        'TG/2023/1796',
        'Himasha',
        'Fernando',
        'Student',
        '200390123458',
        'himasha.fernando1796@tec.lk',
        '0732345678'
    ),
    (
        'TG/2023/1797',
        'Ravindu',
        'Wijesinghe',
        'Student',
        '200301234569',
        'ravindu.wijesinghe1797@tec.lk',
        '0743456789'
    ),
    (
        'TG/2023/1798',
        'Tharushi',
        'Senanayake',
        'Student',
        '200312345670',
        'tharushi.senanayake1798@tec.lk',
        '0754567890'
    ),
    (
        'TG/2023/1799',
        'Kasun',
        'De Silva',
        'Student',
        '200323456781',
        'kasun.desilva1799@tec.lk',
        '0765678901'
    ),
    (
        'TG/2023/1800',
        'Pavithra',
        'Jayasinghe',
        'Student',
        '200334567892',
        'pavithra.jayasinghe1800@tec.lk',
        '0776789012'
    );
INSERT INTO Lecturer (lec_id, designation, department_id)
VALUES ('Lec_003', 'Lecturer', 'DEP001'),
    ('Lec_004', 'Lecturer', 'DEP001'),
    ('Lec_005', 'Lecturer', 'DEP003'),
    ('Lec_006', 'Lecturer', 'DEP001'),
    ('Lec_007', 'Lecturer', 'DEP002'),
    ('Lec_008', 'Lecturer', 'DEP003'),
    ('Lec_009', 'Lecturer', 'DEP001'),
    ('Lec_010', 'Lecturer', 'DEP001'),
    ('Lec_011', 'Lecturer', 'DEP003'),
    ('Lec_012', 'Lecturer', 'DEP001'),
    ('Lec_013', 'Lecturer', 'DEP002'),
    ('Lec_014', 'Lecturer', 'DEP001'),
    ('Lec_015', 'Lecturer', 'DEP004'),
    ('Lec_016', 'Lecturer', 'DEP004'); 

INSERT INTO Lecturer_Degree (lec_id, degree)
VALUES ('Lec_003', 'BSc in IT'),
    ('Lec_003', 'MSc in Computer Science'),
    ('Lec_004', 'BEng in Mechanical Engineering'),
    ('Lec_004', 'MEng in Electrical Engineering'),
    ('Lec_005', 'BSc in Bio System Technology'),
    ('Lec_006', 'BSc in IT'),
    ('Lec_006', 'PhD in Computer Science'),
    ('Lec_007', 'BEng in Civil Engineering'),
    ('Lec_008', 'BSc in Bioinformatics'),
    ('Lec_008', 'MSc in Bio System Technology'),
    ('Lec_009', 'BSc in Software Engineering'),
    ('Lec_010', 'BEng in Electrical Engineering'),
    ('Lec_011', 'BSc in Biotechnology'),
    ('Lec_012', 'BSc in IT'),
    ('Lec_013', 'BEng in Mechanical Engineering'),
    ('Lec_014', 'BSc in Bio System Technology'),
    ('Lec_014', 'MSc in Bio System Technology'),
    ('Lec_015', 'Bachelour of English literature'),
    ('Lec_016', 'BSc in Management');

