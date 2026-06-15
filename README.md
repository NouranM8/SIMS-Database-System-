# 🏫 School Information Management System (SIMS)

A fully functional desktop-based School Information Management System developed using Python (Tkinter) and MySQL.  
The system provides a unified platform for managing students, teachers, academic structure, grades, attendance, and institutional communication with role-based access control.

---

## 📌 Project Overview

SIMS is designed to replace traditional manual school management processes with a centralized digital system.  
It supports the complete academic lifecycle from student enrollment to graduation, with automated GPA calculation, grade management, and reporting features.

The system is built with a clean separation between:
- UI Layer (app.py) → Handles Tkinter interface and navigation  
- Business Logic Layer (logic.py) → Handles database operations and system logic  
- Database Layer (MySQL) → Stores all academic and administrative data  

---

## 👥 User Roles

### 🧑‍💼 Administrator
- Full system access
- Manage students, teachers, classes, and academic years
- View dashboards and system analytics
- Trigger end-of-year promotion

### 👨‍🏫 Teacher
- Manage grades for assigned subjects
- Record student attendance
- View class-specific data only

### 🎓 Student
- View personal grades and attendance
- Access announcements
- Read-only access to academic performance

---

## ⚙️ Key Features

- 🔐 Secure authentication using SHA-256 password hashing
- 🧑‍🎓 Student, teacher, and class management system
- 📊 Component-based grading system (Quiz, Midterm, Final)
- 📈 Automatic GPA calculation and ranking system
- 📅 Attendance tracking with percentage calculation
- 📄 PDF report card generation using ReportLab
- 🧠 NLP-based Data Assistant (converts English questions into SQL queries)
- 📢 Announcement system for targeted communication
- 🎓 End-of-year promotion and graduation workflow
- 📦 Automated realistic data seeding for testing

---

## 🧠 Smart Data Assistant

The system includes a rule-based NLP engine that converts natural language questions into SQL queries.

Example:
> "How many students are failing in Grade 10?"

The assistant maps the query to predefined SQL templates and returns live database results instantly.

---

## 🗄️ Database Design

The system uses a relational MySQL database with the following core entities:

- Students
- Teachers
- Classes
- Subjects
- Enrollments
- Grades
- Grade Details
- Attendance
- Users
- Academic Years & Semesters
- Announcements

All relationships are enforced using foreign keys to ensure data integrity and consistency.

---

## 🧮 Grade Calculation System

- Quiz 1 → 10%
- Quiz 2 → 10%
- Midterm → 20%
- Final Exam → 60%

Total = 100%

### Letter Grades:
- A: 90–100
- B: 80–89
- C: 70–79
- D: 60–69
- F: < 60

✔ GPA is calculated on a 4.0 scale  
✔ Physical Education is excluded from GPA calculation  

---

## 🔐 Security Features

- Password hashing using SHA-256
- Role-based access control (RBAC)
- Restricted database access per user role
- Secure login system with session validation

---

## 🛠️ Technology Stack

- Programming Language: Python 3.10+
- GUI Framework: Tkinter
- Database: MySQL 8.0
- Connector: mysql-connector-python
- PDF Generation: ReportLab
- Data Seeding: Custom Python scripts
- Platform: Windows Desktop Application

---

## 📊 Data Seeding

The system includes an advanced data seeding module that generates:

- 6 academic years
- 12 classes (Grades 7–12, A & B sections)
- ~280 students
- 20 teachers
- Realistic performance distribution
- Attendance patterns correlated with student ability

---

## 📄 Report Cards

Automatically generated PDF report cards include:
- Student details
- Subject-wise grades
- Performance summary
- GPA and ranking
- Attendance percentage
- Official formatted layout

---

## 🚀 Future Improvements

- Web-based version using Flask / React
- Mobile application support
- Email/SMS notification system
- Advanced AI-powered analytics dashboard
- Secure password reset system
- Cloud database deployment

---

## 📚 Project Information

Course: CSE221 – Database Systems
Semester: Spring 2026  
Institution: Galala University  
Supervisor: Prof. Shaker El-Sappagh  

---

## 👩‍💻 Developed By

- Nouran Mahmoud  
- Sondos Ahmed  
- Salsabil Shaaban  
- Basmala Ahmed  
- Maya Ibrahim  

---

## ⭐ Note

This project demonstrates:
- Strong database design skills  
- Full-stack desktop application development  
- Clean software architecture  
- Real-world academic system simulation  

---