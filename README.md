ID Link System (IDL): Automating Student ID Creation at SUZA

-> Project Overview
The ID Link System is a mobile and web-based application for the State University of Zanzibar (SUZA) to automate student ID requests, approvals, and printing. Students submit requests via a Flutter app, admins manage via Spring Boot dashboard, with QR code integration and automated printing.

-> Key Features
- Photo upload and real-time status tracking (mobile app).
- Request approval and PDF generation (admin dashboard).
- QR code for verification/lost ID recovery.
- Automated printing via Entrust Sigma DS3 and CUPS.

-> Technologies
- Frontend: Flutter (cross-platform).
- Backend: Spring Boot (RESTful APIs).
- Database: MySQL.
- Security: JWT authentication.
- Tools: Docker, Postman, Git.

## Team & Details
- **Student**: Khashim Abdulkadir Hamza
- **Reg No**: BITAM/10/22/111/TZ
- **Supervisor**: Mr. Rashid Omar Khamis
- **Institution**: State University of Zanzibar (SUZA)
- **Updated**: October 2, 2025

## Setup Instructions
1. Clone: `git clone https://github.com/KHASHIM-HAMZA/ID_LINK_SYSTEM.git`
2. Backend: `cd backendIdLinkSys && mvn spring-boot:run`
3. Frontend: `cd FrontendIdLsys.app.v1 && flutter pub get && flutter run`
4. Database: Import MySQL schema from `diagrams/erd.png` or scripts.


## Recent Changes (October 2, 2025 Update)
- Fixed permissions in backend (from previous commit).
- Updated README for better structure.
- Resolved NullPointerException in sendMessage endpoint.

## License
MIT License.

## Contact
For questions: khashimabdulkadir@gmail.com or open an issue.
