# ID LINK SYSTEM

A digital student identification and ID request management system designed to streamline student ID card creation, approval, tracking, and verification.

ID LINK SYSTEM provides a digital workflow connecting students, administrators, and the ID card printing process through a mobile application and web-based administration dashboard.

---

## Overview

ID LINK SYSTEM was developed to digitize the process of requesting, approving, generating, and managing student identification cards.

The system allows students to submit ID card requests through a mobile application, track the status of their requests, and access their digital identification information. Administrators can review and manage requests through an administrative dashboard.

The system also supports QR-code-based identification and automated printing workflows.

---

## Key Features

### Student Mobile Application

- Student registration and authentication
- Student profile management
- Submit ID card requests
- Track request status
- View digital student ID
- QR code generation and scanning
- Request history
- Receive administrative messages and notifications

### Administration Dashboard

- View and manage student ID requests
- Review and approve requests
- Manage student information
- View approved IDs
- Manage digital student IDs
- Monitor request status
- Administrative messaging
- Manage printing workflows

### ID Card Management

- Digital student ID generation
- QR-code-based identification
- Student information verification
- Request approval workflow
- ID printing management
- Printing status tracking

### Automated Printing

The system includes a server-side printing workflow that monitors approved ID requests and sends eligible requests to the connected ID card printer.

---

## System Architecture

ID LINK SYSTEM consists of three main components:

```text
┌──────────────────────────┐
│     Flutter Student      │
│       Application        │
└────────────┬─────────────┘
             │
             │ REST API
             ▼
┌──────────────────────────┐
│      Spring Boot         │
│        Backend           │
└────────────┬─────────────┘
             │
       ┌─────┴─────┐
       │           │
       ▼           ▼
┌───────────┐  ┌───────────────┐
│   MySQL   │  │ Admin System  │
│ Database  │  │ / Dashboard   │
└───────────┘  └───────────────┘
             │
             ▼
      ┌──────────────┐
      │ ID Printing  │
      │   Workflow   │
      └──────────────┘


## Technology Stack

Mobile Application
Flutter
Dart
REST APIs
QR Code
Backend
Java
Spring Boot
Spring Data JPA
RESTful APIs
Authentication & Authorization
Database
MySQL
Infrastructure
Docker
Linux
Network-connected printing
Automated printing workflow
Development Tools
Git
GitHub
Postman
Android Studio / VS Code
Core System Workflow

The general ID request workflow is:

Student
   │
   ▼
Submit ID Request
   │
   ▼
Backend Validation
   │
   ▼
Administrator Review
   │
   ├── Rejected ──────► Student Notified
   │
   ▼
Approved
   │
   ▼
Digital ID Generated
   │
   ▼
Printing Queue
   │
   ▼
ID Card Printed
   │
   ▼
Student Can Access Digital ID
QR Code Identification

Each generated ID contains a QR code that can be used to retrieve or verify the student's identification information.

The QR-code workflow provides a convenient way to connect a physical student ID with the student's digital information stored within the system.

API Structure

The backend exposes RESTful APIs consumed by the mobile application and administrative interfaces.

Example endpoint groups include:

/api/auth
/api/student/request
/api/student/status/{regNumber}
/api/student/idcard/view
/api/admin/requests
/api/admin/approved
/api/print/all-approved

The APIs handle authentication, student requests, status tracking, ID information, administration, and printing workflows.

Database

The system uses MySQL as its primary relational database.

Core information managed by the system includes:

Student information
ID requests
Request status
Request dates
Generated QR codes
Digital IDs
Printing status
Administrative information
Installation & Setup
Prerequisites

Make sure the following are installed:

Java 17+
Maven
MySQL 8+
Flutter SDK
Dart SDK
Docker
Git
Clone the Repository
git clone https://github.com/KHASHIM-HAMZA/ID_LINK_SYSTEM.git


cd YOUR_REPOSITORY
Backend Setup

Configure the database connection in the Spring Boot application configuration.

Example:

spring.datasource.url=jdbc:mysql://localhost:3306/id_link
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD

Then start the backend:

./mvnw spring-boot:run

Or:

mvn spring-boot:run
Flutter Application

Navigate to the Flutter project:

cd mobile

Install dependencies:

flutter pub get

Run the application:

flutter run
Project Structure

A simplified structure of the system is:

ID-LINK-SYSTEM/
│
├── backend/
│   ├── src/
│   ├── pom.xml
│   └── ...
│
├── mobile/
│   ├── lib/
│   ├── assets/
│   ├── pubspec.yaml
│   └── ...
│
├── admin/
│   └── ...
│
├── docker/
│   └── ...
│
└── README.md

The exact structure may vary depending on the version of the project.

My Contribution

I designed and developed the ID LINK SYSTEM as a full-stack application.

My responsibilities included:

Designing the overall system architecture
Developing the Flutter mobile application
Designing and implementing the Spring Boot backend
Developing RESTful APIs
Designing the database structure
Implementing authentication and authorization
Implementing student ID request workflows
Implementing QR-code functionality
Developing administrative workflows
Integrating the ID printing workflow
Containerizing backend/database components using Docker
Testing and debugging the application
Deploying and configuring system components
Engineering Highlights

The project provided practical experience with:

Full-stack application architecture
REST API design
Backend development with Spring Boot
Mobile application development with Flutter
Relational database design
Authentication and authorization
QR-code integration
Automated system workflows
Docker-based development
Linux server environments
Hardware/software integration
Production-oriented troubleshooting

Security Considerations

The system was designed with common application security practices in mind, including:

Authentication and authorization
Role-based access control
Server-side validation
Protected API endpoints
Secure database access
Environment-based configuration
Avoiding hard-coded sensitive credentials

Production deployments should additionally use HTTPS, secure secret management, appropriate database access controls, logging, monitoring, and other security controls appropriate to the deployment environment.

Future Improvements

Potential improvements include:

Enhanced notification system
Advanced ID verification
Improved audit logging
More comprehensive administrative reporting
Cloud-based deployment
Improved monitoring and observability
Expanded role and permission management
Automated deployment through CI/CD
Project Status

Status: Completed / Maintained

The project was developed as a complete student identification management solution covering the request, approval, digital ID, verification, and printing workflows.

Author

Khashim AbdulKadir Hamza

Software Engineer | Backend & Mobile Development

Dar es Salaam, Tanzania

GitHub: https://github.com/YOUR_USERNAME
LinkedIn: https://www.linkedin.com/in/khashim-hamza
License

This project is intended for educational and portfolio purposes.
