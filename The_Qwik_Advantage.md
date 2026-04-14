# The Qwik Advantage

## Ashesi Campus Food Pre-ordering System

---

Vanessa Logan Berinyuy Anabi
Welile Ndabenhle Dlamini
Edem Korbla Anagbah
Daniel Kwasi Kpatamia

**Date: February 10, 2025**

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Problem Statement](#2-problem-statement)
3. [Proposed Solution](#3-proposed-solution)
4. [System Architecture](#4-system-architecture)
5. [Technology Stack](#5-technology-stack)
6. [Database Design](#6-database-design)
7. [Backend API](#7-backend-api)
8. [Mobile Application](#8-mobile-application)
9. [User Flows](#9-user-flows)
10. [Features](#10-features)
11. [Future Enhancements](#11-future-enhancements)

---

## 1. Introduction

The Qwik Advantage is a campus food pre-ordering system designed for Ashesi University. It enables students and staff to browse cafeteria menus, place food orders in advance, make payments, and track their orders in real time — eliminating long queues and wait times during peak hours.

---

## 2. Problem Statement

Students and staff at Ashesi University face recurring challenges with on-campus dining:

- **Long queues** during peak meal times (breakfast, lunch breaks between classes).
- **Limited visibility** into what each cafeteria is serving or what is available.
- **No way to pre-order**, leading to wasted time standing in line.
- **Cafeteria congestion** with no real-time indication of how busy a location is.

These issues reduce productivity, cause students to miss class time, and create an inefficient dining experience.

---

## 3. Proposed Solution

Qwik is a mobile-first food pre-ordering platform that allows users to:

- Browse menus across multiple on-campus cafeterias.
- Place orders ahead of time and select a pickup window.
- Pay digitally (Mobile Money, Meal Plan) or choose cash on pickup.
- Track order status in real time (Received → Prepping → Ready → Pickup).
- View cafeteria congestion levels before deciding where to eat.

For cafeteria merchants, Qwik provides a dashboard to manage inventory, update order statuses, and broadcast real-time updates to customers.

---

## 4. System Architecture

```
┌─────────────────┐        ┌──────────────────────┐        ┌──────────────┐
│   Flutter App    │◄──────►│   Express.js API      │◄──────►│  PostgreSQL  │
│  (Mobile Client) │  HTTP  │   (Node.js Backend)   │ Prisma │  (Database)  │
│                  │◄──────►│                        │  ORM   │              │
│   Provider State │ Socket │                        │        │              │
│   Hive Cache     │  .io   │                        │        │              │
└────────┬────────┘        └──────────┬───────────┘        └──────────────┘
         │                            │
         ▼                            ▼
┌─────────────────┐        ┌──────────────────────┐
│  Firebase (FCM)  │        │    Railway (Hosting)  │
│  Push Notifs     │        │    Production Deploy  │
└─────────────────┘        └──────────────────────┘
```

**Architecture Pattern:** Client-Server with RESTful API, real-time WebSocket layer, and offline-first caching.

- **Mobile Client** — Flutter app (Dart) with Provider state management, Hive offline cache, and Firebase push notifications.
- **Backend Server** — Express.js (TypeScript) deployed on Railway, handling business logic, JWT authentication, and data access.
- **Database** — PostgreSQL managed via Prisma ORM.
- **Real-Time Layer** — Socket.io for live order status updates, inventory changes, and cafeteria congestion broadcasts.
- **Push Notifications** — Firebase Cloud Messaging (FCM) for background order updates.

---

## 5. Technology Stack

### Backend

| Component           | Technology                      |
|---------------------|---------------------------------|
| Language            | TypeScript                      |
| Framework           | Express.js 5.2.1                |
| Database            | PostgreSQL                      |
| ORM                 | Prisma 7.5.0                    |
| Real-Time           | Socket.io 4.8.3                 |
| Validation          | Zod 4.3.6                       |
| Security            | Helmet, bcrypt (password hashing)|
| File Uploads        | Multer 2.1.1                    |
| Testing             | Vitest, Supertest               |
| Logging             | Morgan                          |

### Mobile App

| Component           | Technology                      |
|---------------------|---------------------------------|
| Language            | Dart                            |
| Framework           | Flutter                         |
| State Management    | Provider (ChangeNotifier)       |
| Local Storage       | shared_preferences, Hive        |
| HTTP Client         | http package                    |
| Real-Time           | socket_io_client                |
| Push Notifications  | Firebase Cloud Messaging (FCM)  |
| Local Notifications | flutter_local_notifications     |
| QR Codes            | qr_flutter                      |
| Biometric Auth      | local_auth                      |
| URL Launcher        | url_launcher (MoMo dialer)      |
| Target Platforms    | Android, iOS, macOS             |

---

## 6. Database Design

The database consists of five core models:

### User
| Field             | Type       | Description                          |
|-------------------|------------|--------------------------------------|
| id                | UUID       | Primary key                          |
| email             | String     | Unique user email                    |
| name              | String     | Display name                         |
| password          | String     | Hashed password                      |
| role              | Enum       | CUSTOMER, STAFF, or ADMIN            |
| dietaryLifestyle  | String[]   | Dietary preferences (e.g., vegan)    |
| allergies         | String[]   | Known food allergies                 |
| createdAt         | DateTime   | Account creation timestamp           |

### Cafeteria
| Field            | Type       | Description                           |
|------------------|------------|---------------------------------------|
| id               | Int        | Primary key                           |
| name             | String     | Unique cafeteria name                 |
| isOpen           | Boolean    | Whether currently operating           |
| capacityStatus   | Enum       | GREEN, YELLOW, or RED (congestion)    |

### MenuItem
| Field          | Type       | Description                             |
|----------------|------------|-----------------------------------------|
| id             | Int        | Primary key                             |
| cafeteriaId    | Int        | Foreign key to Cafeteria                |
| name           | String     | Item name                               |
| description    | String     | Item description                        |
| price          | Decimal    | Price in GHS (₵)                        |
| category       | String     | Food category                           |
| isAvailable    | Boolean    | Current availability                    |
| allergenTags   | String[]   | Allergen information                    |
| imageUrl       | String     | Menu item photo URL                     |

### Order
| Field          | Type       | Description                             |
|----------------|------------|-----------------------------------------|
| id             | Int        | Primary key                             |
| userId         | UUID       | Foreign key to User                     |
| cafeteriaId    | Int        | Foreign key to Cafeteria                |
| totalAmount    | Decimal    | Order total in GHS (₵)                  |
| status         | Enum       | Order lifecycle status                  |
| isPaid         | Boolean    | Payment confirmation                    |
| pickupWindow   | String     | Requested pickup time                   |
| qrCodeSecret   | String     | Unique QR code for pickup verification  |
| createdAt      | DateTime   | Order placement time                    |

**Order Status Flow:**
```
PENDING_PAYMENT → RECEIVED → PREPPING → READY → COMPLETED
                                                ↘ CANCELLED
```

### OrderItem
| Field       | Type       | Description                                |
|-------------|------------|--------------------------------------------|
| id          | Int        | Primary key                                |
| orderId     | Int        | Foreign key to Order (cascade delete)      |
| menuItemId  | Int        | Reference to original menu item            |
| name        | String     | Snapshot of item name at time of order     |
| price       | Decimal    | Snapshot of price at time of order         |
| quantity    | Int        | Number ordered                             |

---

## 7. Backend API

### Endpoints

| Method  | Route                            | Description                         |
|---------|----------------------------------|-------------------------------------|
| GET     | `/health`                        | Service health check                |
| PATCH   | `/api/merchant/status`           | Update cafeteria congestion status  |
| PUT     | `/api/merchant/inventory`        | Toggle menu item availability       |
| GET     | `/api/merchant/orders/:cafeteriaId` | Fetch active order queue         |
| PATCH   | `/api/merchant/orders/:id`       | Advance order to next status        |

### Real-Time Events (Socket.io)

| Event                | Direction       | Description                        |
|----------------------|-----------------|------------------------------------|
| `join_cafeteria`     | Client → Server | Subscribe to a cafeteria's updates |
| `status_changed`     | Server → Client | Cafeteria congestion level changed |
| `inventory_updated`  | Server → Client | Menu item availability changed     |
| `order_status_update`| Server → Client | Order moved to next stage          |

### Validation

All request payloads are validated using **Zod** schemas via middleware, covering:
- Authentication payloads (login/register)
- Cafeteria operations
- Merchant actions
- Order creation and updates
- Payment webhook data

### Business Logic

- **Staff Discount**: 20% automatic discount for users with `STAFF` role.
- **Order State Machine**: Validates transitions to prevent invalid status changes (e.g., cannot go from READY back to PENDING_PAYMENT).

---

## 8. Mobile Application

### Design System

The app uses a warm, earthy color palette:

| Color        | Hex       | Usage                    |
|--------------|-----------|--------------------------|
| Background   | `#F2EDE8` | App background (cream)   |
| Rust         | `#B85C38` | Primary action buttons   |
| Dark Brown   | `#2C1A0E` | Text and headings        |
| Orange       | `#F5A623` | Highlights and accents   |
| Subtext      | `#9E9E9E` | Secondary text (gray)    |

### Screens

1. **Splash Screen** — Branded loading screen with biometric auth support (fingerprint/face).
2. **Login / Register Screen** — Email and password authentication against the backend API. Registration with name, email, password. Guest browsing mode available.
3. **Forgot Password Screen** — Password reset flow.
4. **Home Screen** — Main dashboard with:
   - Personalized greeting (fetched from API) and Ashesi University location
   - Notification bell with unread badge count
   - Today Specials carousel (loaded from SpecialService API)
   - Search bar (taps through to Menu tab)
   - Cafeteria listing (horizontal scroll, loaded from API with offline cache)
   - Recommended food items grid with **allergen badges** and **Express meal indicators**
   - Cart item count badge on bottom nav
5. **Food Detail Sheet** — Tappable food card opens a bottom sheet showing:
   - Full **ingredient list** for nutritional transparency
   - **Allergen warning tags** (Peanuts, Gluten, Dairy, Shellfish, Fish)
   - **Dietary lifestyle labels** (Vegan, Keto, Halal)
   - Express meal badge with estimated prep time
   - "Add to Cart" button with cafeteria conflict detection
6. **Cafeteria Screen (Menu)** — Browse menu by cafeteria with:
   - Cafeteria tabs (selects active cafeteria, loads its menu from API)
   - Live search across all cafeterias
   - **Hide Allergens** toggle (filters based on user's saved allergies)
   - **Dietary filter chips** (Vegan, Keto, Halal) and **Express Meals** toggle
   - Add-to-cart with cafeteria conflict dialog
7. **Cart Screen** — Enhanced cart with Provider-based state:
   - Quantity controls (+/−) and order summary (subtotal, 4.4% tax, ₵6.00 delivery)
   - Empty cart state with helpful message
   - Clear cart button
   - **Bill Splitting** — tap to split the total among 2+ people with per-person breakdown
   - Checkout button shows per-person amount when splitting
   - Guest users prompted to log in before checkout
8. **Payment Screen** — Localized payment with selectable methods:
   - **Mobile Money (MoMo)** — Places order, then shows network sheet (MTN *170#, Telecel *110#, AirtelTigo *100#) with dialer integration
   - **Meal Plan** — Pay at cafeteria counter
   - **Cash On Pickup** — Pay when collecting
   - Bill split summary when applicable
   - Loading spinner during order placement
9. **Order Tracking Screen** — Real-time order tracking with:
   - Live status updates via Socket.io (auto-refreshes on status change)
   - Order progress timeline (Received → Preparing → Ready → Completed)
   - **QR code** displayed when order is READY for contactless pickup verification
   - Order items breakdown with prices
   - Cancel order button (available during Received/Prepping)
   - Refresh button for manual status check
10. **Notifications Screen** — Persistent notification list:
    - Order placed, status change notifications (via socket + FCM)
    - Native device banners via flutter_local_notifications
    - Mark as read / mark all read
    - Tap notification to view order
11. **Order History Screen** — Full list of past orders:
    - Status badge, cafeteria name, item count, total, date
    - Tap to open order tracking page
12. **Profile Screen** — User profile with expandable accordion sections:
    - Edit Profile (name, email read-only) — saves to API
    - Order History (last 3 orders + "View All" link)
    - Payment Details (placeholder)
    - **Dietary Preferences** — multi-select lifestyle (Vegetarian, Vegan, Pescatarian, Halal, Gluten-Free, Dairy-Free) + comma-separated allergies — saves to API
    - Logout
13. **Staff Dashboard Screen** — Merchant/admin operations:
    - Order queue management (advance orders through status pipeline)
    - Menu item CRUD (add, edit, delete, toggle availability)
    - Cafeteria capacity status (Green/Yellow/Red)
    - Specials management

### Bottom Navigation

| Tab      | Screen           |
|----------|------------------|
| Home     | Home Screen      |
| Menu     | Cafeteria Screen |
| Cart     | Cart Screen      |
| Profile  | Profile Screen   |

---

## 9. User Flows

### Authentication Flow
```
App Launch → Splash Screen → Biometric Check (if enabled)
    ↓
Login / Register Screen → API Authentication → JWT Token Saved
    ↓
Home Screen  (or Guest Browse mode → prompted to login at checkout)
    ↑
Profile → Logout → Clear Token → Login Screen
```

### Ordering Flow
```
Home Screen → Browse Cafeterias / Recommended Items
    ↓
Cafeteria Screen → Filter (Dietary: Vegan/Keto/Halal, Express, Hide Allergens)
    ↓
Tap Food Card → View Ingredients, Allergens, Dietary Tags → Add to Cart
    ↓
Cart Screen → Adjust Quantities → (Optional) Split Bill ÷N people
    ↓
Payment Screen → Select Method (MoMo / Meal Plan / Cash)
    ↓
MoMo: Place Order → Network Sheet (*170# / *110# / *100#) → Dialer
Others: Place Order → Navigate to Tracking
    ↓
Order Tracking → Live Socket.io Updates → QR Code at READY status
    ↓
Done → Home Screen
```

### Bill Splitting Flow
```
Cart Screen → Tap "Split the Bill" → Choose number of people (2–20)
    ↓
See per-person breakdown → Confirm Split
    ↓
Checkout shows "₵XX.XX each" → Payment shows split summary
```

### Real-Time Order Updates
```
Backend advances order status (RECEIVED → PREPPING → READY → COMPLETED)
    ↓
Socket.io emits order_status_update → Mobile receives via SocketService
    ↓
NotificationService creates AppNotification + shows native banner
    ↓
OrderTrackingPage auto-refreshes status timeline + shows QR when READY
```

### Merchant Flow (Staff Dashboard)
```
View Active Orders Queue → Advance Order Status (Prepping → Ready → Completed)
Manage Menu Items → Add / Edit / Delete / Toggle Availability
Update Cafeteria Capacity → Set Congestion (Green / Yellow / Red)
Manage Specials → Create / Edit / Delete Promotions
```

---

## 10. Features

### Implemented

**Authentication & User Management**

| Feature                                              | Status |
|------------------------------------------------------|--------|
| User registration & login (API-based, JWT)           | Done   |
| Guest browsing mode                                  | Done   |
| Biometric authentication (fingerprint / face)        | Done   |
| User profile with editable name                      | Done   |
| Dietary preferences & allergies (saved to API)       | Done   |
| Logout with token cleanup                            | Done   |

**Cafeteria & Menu Browsing**

| Feature                                              | Status |
|------------------------------------------------------|--------|
| Cafeteria listing (API + Hive offline cache)         | Done   |
| Menu browsing by cafeteria with tab selection        | Done   |
| Live search across all cafeterias                    | Done   |
| **Nutritional transparency** (ingredient lists)      | Done   |
| **Automated allergen tags** on food cards            | Done   |
| **Hide Allergens toggle** (user profile-based)       | Done   |
| **Advanced dietary filtering** (Vegan, Keto, Halal)  | Done   |
| **Express Meals filter** (quick-prep items)          | Done   |
| Food detail sheet (ingredients, allergens, dietary)  | Done   |
| Today Specials carousel (from API)                   | Done   |

**Cart & Checkout**

| Feature                                              | Status |
|------------------------------------------------------|--------|
| Provider-based cart with singleton state             | Done   |
| Cafeteria conflict detection (multi-cafeteria guard) | Done   |
| Quantity controls (+/−) with auto-remove at zero     | Done   |
| Order summary (subtotal, 4.4% tax, ₵6.00 delivery)  | Done   |
| **Bill Splitting** (divide total among 2–20 people)  | Done   |
| Cart badge on bottom navigation                      | Done   |
| Guest checkout guard (redirect to login)             | Done   |

**Payment & Orders**

| Feature                                              | Status |
|------------------------------------------------------|--------|
| **Mobile Money (MoMo)** — MTN *170#, Telecel *110#, AirtelTigo *100# with dialer | Done |
| **Meal Plan** — pay at cafeteria counter             | Done   |
| **Cash On Pickup**                                   | Done   |
| Order creation via API                               | Done   |
| Order cancellation                                   | Done   |
| Order history with full list view                    | Done   |
| **QR code pickup verification** (shown at READY)     | Done   |

**Real-Time & Notifications**

| Feature                                              | Status |
|------------------------------------------------------|--------|
| Live order status via Socket.io                      | Done   |
| Push notifications via Firebase Cloud Messaging      | Done   |
| Local notification banners (flutter_local_notifications) | Done |
| Notification list with read/unread state             | Done   |

**Backend**

| Feature                                              | Status |
|------------------------------------------------------|--------|
| Express.js API deployed on Railway                   | Done   |
| Prisma ORM with PostgreSQL                           | Done   |
| JWT authentication with bcrypt password hashing      | Done   |
| Zod request validation                               | Done   |
| Order state machine (PENDING → RECEIVED → PREPPING → READY → COMPLETED) | Done |
| Staff discount logic (20%)                           | Done   |
| Cafeteria congestion tracking (Green/Yellow/Red)     | Done   |
| Merchant dashboard API (queue, inventory, capacity)  | Done   |
| Menu CRUD endpoints                                  | Done   |
| Specials management endpoints                        | Done   |
| Socket.io real-time event broadcasting               | Done   |
| FCM push notification delivery                       | Done   |

### Planned Enhancements

| Feature                              | Status  |
|--------------------------------------|---------|
| Payment gateway processing (MoMo API)| Pending |
| Group order invites (share link)     | Pending |
| Image upload for menu items          | Pending |
| Rating & review system               | Pending |
| Re-order from history                | Pending |
| Analytics dashboard for merchants    | Pending |

---

## 11. Future Enhancements

1. **Payment Gateway Processing** — Integrate actual MoMo API (MTN, Telecel, AirtelTigo) for automated payment confirmation instead of manual dialer redirect.
2. **Group Order Invites** — Share a group order link so friends can add items from their own devices before a single checkout.
3. **Image Upload** — Allow merchants to upload food photos directly from the staff dashboard.
4. **Rating & Review System** — Allow students to rate food items and cafeterias after pickup.
5. **Re-order from History** — One-tap re-order from past orders for repeat customers.
6. **Analytics Dashboard** — Provide cafeteria merchants with sales analytics, popular items, peak hour data, and revenue reports.
7. **Dietary AI Recommendations** — Suggest meals based on user's dietary preferences, order history, and allergen profile.
8. **Multi-Language Support** — Add French and local language support for broader accessibility.

---

*Built with Flutter, Express.js, PostgreSQL, Prisma, Socket.io, and Firebase.*
