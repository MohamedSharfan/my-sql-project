🎓 TECMIS – Faculty of Technology

📌 Project Overview

This project is a Database Management System (DBMS) practicum built using MySQL.
It is designed for the Faculty of Technology to manage key academic activities such as:

Student details

Student marks

Student attendance

Result management

The system also implements different MySQL user roles with specific privileges (Admin, Dean, Lecturer, Student, Technical Officer) to ensure proper access control.

⚙️ Features

👨‍🎓 Student Management – Add, update, delete, and view student details.

📝 Marks Management – Store and manage student marks for different courses.

📅 Attendance Tracking – Record and retrieve student attendance.

📊 Result Management – Generate results based on stored marks.

🔐 Role-Based Access Control – Different user privileges for Admin, Dean, Lecturer, Student, and Technical Officer.

👥 MySQL User Accounts & Privileges
User	Privileges
Admin	ALL PRIVILEGES + GRANT OPTION on all tables
Dean	ALL PRIVILEGES (without GRANT)
Lecturer	SELECT, INSERT, UPDATE (no DELETE)
Student	SELECT only
Technical Officer	INSERT, UPDATE (attendance & marks related tables)
🛠️ Technologies Used

Database: MySQL

Language: MySQL

Concepts:

DDLC (Database Development Life Cycle)
