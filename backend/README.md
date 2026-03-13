# Core Endpoint Features:
## (I.) Cafetaria Merchant - Features 
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


* **Impact:** Changes the order status. If moved to `READY`, the student receives a real-time notification to come pick up their food.

---

### Summary Table for Reference

| Action | Method | URL | Required Data |
| --- | --- | --- | --- |
| **Set Busy Level** | `PATCH` | `/status` | `cafeteriaId`, `status` |
| **Toggle Food** | `PUT` | `/inventory` | `itemId`, `isAvailable` |
| **View Orders** | `GET` | `/orders/:cafeteriaId` | `cafeteriaId` (URL) |
| **Update Order** | `PATCH` | `/orders/:id` | `id` (URL), `status` (Body) |

---
