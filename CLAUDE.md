# Project Brief for Claude

## 1. Current Project State

This repository currently contains a set of static HTML pages for a business that operates a book lending platform. The existing pages explain the service offering but contain no application logic or dynamic behavior.

The business model has two main aspects:

1. Subscribers can borrow books owned by the business.
2. Users can list their own books, which can then be borrowed by subscribers of the business.

Right now, the site is purely informational. There is:
- No backend code.
- No database or persistent storage.
- No authentication or user accounts.
- No integration with external APIs.
- No admin interface.

The goal is to use this existing HTML structure and content as a starting point and evolve it into a fully functional portal.

---

## 2. Target Vision

I want to turn this static site into a complete, production-ready portal that supports:

- **Persistent storage**
  - Store users, subscriber accounts, user-owned books, business-owned books, loans/borrowing records, and any relevant metadata.
  - Use Firebase as the primary backend (Firestore and/or Realtime Database, plus Firebase Storage if needed).

- **Authentication and authorization**
  - User registration and login (email/password to start, expandable to OAuth providers later).
  - Distinguish between at least:
    - Standard users (who can list books and borrow).
    - Admins/staff (who can manage catalog, users, and loans).
  - Protect routes and views appropriately based on user role.

- **Book lending domain logic**
  - Allow subscribers to:
    - Browse available books (both business-owned and user-owned).
    - Request or borrow books.
    - View their active and past loans.
  - Allow users to:
    - List their own books, set availability, and manage their inventory.
  - Represent the lifecycle of a loan (requested, approved, checked out, returned, overdue, etc.).

- **Admin area**
  - Admin dashboard to:
    - Review and manage all books.
    - Manage user accounts and roles.
    - Monitor and manage loan requests and returns.
    - View basic analytics (e.g., number of active loans, popular books).

- **API integrations (present and future)**
  - Make the architecture ready to integrate with external APIs, such as:
    - Book metadata providers (e.g., ISBN lookup, cover images).
    - Notification services (email, SMS, push).
  - Initially, this can be mocked or stubbed, but the design should anticipate adding these integrations.

- **Modern, responsive UI**
  - Replace or rebuild the front end using Flutter with Material UI principles.
  - Ensure the UI is responsive and mobile-friendly.
  - Reuse the existing content and structure from the HTML pages where it makes sense, but the Flutter app should become the primary user interface.

---

## 3. Preferred Tech Stack and Architecture

I would like the project to use:

- **Frontend**
  - Flutter as the main frontend framework.
  - Material UI components and design language.
  - A structured navigation flow suitable for both mobile and web (if applicable).

- **Backend / Data Layer**
  - Firebase as the backend:
    - Firebase Authentication for user accounts.
    - Firestore and/or Realtime Database for storing domain data (users, books, loans, etc.).
    - Firebase Storage for book cover images or other media, if needed.
    - Firebase Cloud Functions if server-side logic is required beyond what can be done on the client.

- **General architecture preferences**
  - Clear separation of concerns:
    - Presentation layer (Flutter UI).
    - State management (e.g., using a recommended Flutter pattern such as Provider, Riverpod, Bloc, or similar).
    - Data access layer for Firebase operations (repositories/services).
  - A modular structure that will be easy to scale and maintain as the portal grows.
  - Support for environment-specific configuration (development vs. production).

---

## 4. Migration and Implementation Goals

When transforming this project, please:

1. **Analyze existing HTML**
   - Identify existing content, pages, and user journeys described in the static site.
   - Use this to inform the initial Flutter navigation structure and page layout.
   - Where possible, preserve the wording and informational content, but adapt it to the new Flutter UI.

2. **Propose an architecture and folder structure**
   - Suggest a recommended folder structure for a Flutter + Firebase project.
   - Show how UI, state management, and data access will be organized.
   - Clarify where domain models (Book, User, Loan, etc.) will live.

3. **Design the data model**
   - Propose a Firebase data schema for:
     - Users (including roles and relevant profile fields).
     - Books (business-owned and user-owned).
     - Loans/borrowing records.
     - Any other necessary entities (categories, tags, notifications, etc.).
   - Ensure the data model supports:
     - Efficient querying for common use cases.
     - Security rules that enforce authorization constraints.

4. **Authentication and security rules**
   - Implement Firebase Authentication flows.
   - Define Firebase security rules enforcing:
     - Users can only update their own data where appropriate.
     - Admins have extended privileges.
     - Borrowing operations are constrained by business rules (e.g., a user cannot borrow a book that is not available).

5. **Core features to implement first**
   - User registration, login, logout.
   - Basic user profile screen.
   - Book browsing:
     - List of available books.
     - Detail page for a book.
   - Ability for a user to list their own books.
   - Basic borrowing flow (e.g., request/borrow a book, show borrowed books).

6. **Admin features (initial version)**
   - Admin login via role-based access.
   - Simple admin dashboard for:
     - Viewing all books.
     - Viewing all users.
     - Viewing active and past loans.

7. **Future extensibility**
   - Keep the codebase structured so that:
     - New features (notifications, external APIs, recommendations) can be added without major refactoring.
     - Additional platforms (e.g., web deployment via Flutter) can be supported.

---

## 5. Development Workflow Preferences

- Please work in small, reviewable steps.
- Before making large structural changes, propose:
  - The planned directory structure.
  - The initial data model.
  - The authentication and navigation flow.
- Provide clear explanations of:
  - What files are added or modified.
  - How to run the project locally (including Firebase setup and configuration).
- Help with:
  - Setting up Firebase project configuration (what keys/files are needed and where to place them).
  - Adding basic error handling and input validation patterns.
  - Adding comments or short documentation in key parts of the code where the logic is non-obvious.

---

## 6. Summary

In short: this project starts as a static HTML site describing a book lending business. The goal is to transform it into a full-featured Flutter + Firebase portal that supports authentication, persistent storage, lending workflows for business-owned and user-owned books, an admin area, and room for future API integrations and enhancements.
