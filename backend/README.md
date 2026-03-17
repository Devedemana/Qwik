# Core Endpoint Features:
## ✔️ (I.) Cafetaria Merchant - Features  
---
### 1. Cafeteria Status Management

Used to control the general "flow" of the cafeteria (e.g., setting it to **RED** if it's overcrowded), **GREEN** if it's less people, **YELLOW** if queue is managable.

* **Endpoint:** `PATCH /api/merchant/status`
* **Controller Method:** `updateStatus`
* **Payload (Body):**
```json
{
  "cafeteriaId": "string",
  "status": "GREEN" | "YELLOW" | "RED"
}

```

* **Impact:** Updates the cafeteria's congestion level in the database and pushes a real-time update to all students viewing that cafeteria.

---

### 2. Inventory Management

Used to toggle food availability in real-time.

* **Endpoint:** `PUT /api/merchant/inventory`
* **Controller Method:** `toggleInventory`
* **Payload (Body):**
```json
{
  "itemId": "string",
  "isAvailable": boolean
}

```

* **Impact:** Marks a specific menu item (like "Jollof") as sold out or available. Disables/Enables the item on students' screens instantly via Socket.io.

---

### 3. Kitchen Queue Retrieval

The "Order Board" for the kitchen staff.

* **Endpoint:** `GET /api/merchant/orders/:cafeteriaId`
* **Controller Method:** `getQueue`
* **Parameters:** `cafeteriaId` (e.g., `.../orders/cafe_123`)
* **Logic:** Fetches only active orders (`PAID`, `PREPPING`, `READY`) in chronological order (FIFO) so the chef knows what to cook next.

```json
{
  "cafeteriaId": "string",
}

```

---

### 4. Order Lifecycle Transitions

The "State Machine" that moves a single order through the kitchen process.

* **Endpoint:** `PATCH /api/merchant/orders/:id`
* **Controller Method:** `advanceOrder`
* **Parameters:** `id` (The Order ID)
* **Payload (Body):**
```json
{
  "status": "PREPPING" | "READY" | "COMPLETED" | "CANCELLED"
}

```

### 5. Order Lifecycle Transitions

The "State Machine" that moves a single order through the kitchen process.

* **Endpoint:** `PATCH /api/merchant/order/verify`
* **Controller Method:** `verifyPickupOrder`
* **Payload (Body):**
```json
{
  "qrCodeSecret": "dfer00ddre0r0fe0rerkfoeo20",
  "cafetariaId": "1od24050rkoeoro0r"
}

```
* **Impact:** Verifies the supplied qrCodeSecret associated with an order and completes the order when the order status is `READY`, this emits real-time notification so customer.

---

### Summary Table for Reference

| Action | Method | URL | Required Data |
| --- | --- | --- | --- |
| **Set Busy Level** | `PATCH` | `/status` | `cafeteriaId`, `status` |
| **Toggle Food** | `PUT` | `/inventory` | `itemId`, `isAvailable` |
| **View Orders** | `GET` | `/orders/:cafeteriaId` | `cafeteriaId` (URL) |
| **Update Order** | `PATCH` | `/orders/:id` | `id` (URL), `status` (Body) |
| **Verify Order Pickup**|`POST`|`/order/verify`| `qrCodeSecret`, `cafetariaId`|

---



## (II.) Student & Authentication - Features 
---

### 1. User Authentication (Registration & Login)

Used to onboard users (Students/Staff) and provide secure access to the platform via JWT tokens.

* **Endpoints:** `POST /api/auth/register`, `POST /api/auth/login`
* **Controller Method:** `register`, `login`
* **Payload (Body):**
```json
{
  "email": "student.name@ashesi.edu.gh",
  "password": "securepassword123",
  "name": "Daniel Kpatamia"
}
```

* **Impact:** Creates a user record in Postgres and returns a token. Sets the foundation for Role-Based Access Control (RBAC).

---

### 2. Cafeteria & Menu Discovery

Allows customers to view all campus cafeterias, their live busy status, and their specific menu offerings.

* **Endpoints:** `GET /api/cafeterias`, `GET /api/cafeterias/:id/menu`
* **Controller Method:** `getCafeterias`, `getMenu`
* **Parameters:** `id` (Cafeteria UUID)
* **Logic:** Fetches cafeterias including their `capacityStatus` and `isOpen` boolean. Filters menu items by `isAvailable: true`.

---

### 3. Order Placement (Checkout)

The core transaction where a student selects food items and schedules a pickup window.

* **Endpoint:** `POST /api/orders`
* **Controller Method:** `createOrder`
* **Payload (Body):**
```json
{
  "cafeteriaId": "uuid-string",
  "items": [
    { "menuItemId": "uuid-1", "quantity": 2 },
    { "menuItemId": "uuid-2", "quantity": 1 }
  ],
  "pickupWindow": "2026-03-17T12:30:00Z"
}
```

* **Impact:** Deducts balance (if integrated), creates `Order` and `OrderItem` records, and generates the unique `qrCodeSecret` for later verification.

---

### 4. Personal Order History
Allows students to track their current active orders and view past purchases.

* **Endpoint:** `GET /api/orders/my-history`
* **Controller Method:** `getUserOrders`
* **Logic:** Returns all orders associated with the logged-in user's ID, sorted by the most recent. Includes the `qrCodeSecret` for active orders to be rendered as QR codes.

---

### 5. Dietary & Allergy Profile

Used to store student-specific dietary needs to highlight safe food options.

* **Endpoint:** `PATCH /api/user/profile/preferences`
* **Controller Method:** `updatePreferences`
* **Payload (Body):**
```json
{
  "allergies": ["Peanuts", "Shellfish"],
  "dietaryLifestyle": "VEGAN"
}
```

* **Impact:** Updates the `User` record in Postgres, allowing the frontend to flag menu items that contain allergens.

---

### Summary Table for Reference

| Action | Method | URL | Required Data |
| --- | --- | --- | --- |
| **Register/Login** | `POST` | `/auth/...` | `email`, `password` |
| **Browse Cafes** | `GET` | `/cafeterias` | None |
| **View Menu** | `GET` | `/cafeterias/:id/menu` | `id` (URL) |
| **Place Order** | `POST` | `/orders` | `cafeteriaId`, `items`, `pickupWindow` |
| **Track Orders** | `GET` | `/orders/my-history` | Token (Header) |
| **Update Health** | `PATCH` | `/user/profile/preferences` | `allergies`, `dietaryLifestyle` |

---


