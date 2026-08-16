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
