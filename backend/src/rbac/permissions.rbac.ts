import { User } from "../../prisma/generated/prisma/client.ts";

type Permission =
  | "cafeteria:create"
  | "cafeteria:delete"
  | "cafeteria:update"
  | "cafeteria:read"
  | "cafetaria-open-status:update"
  | "cafetaria-open-status:read"
  |"cafetaria-queue-status:read"
  | "cafeteria-queue-status:update"
  | "order-status:update" // involves setting order to 'completed' ,'ready', etc
  |"order-status:read"
  | "order:create"
  | "order:delete"
  | "order:read"
  | "order:update"
  | "menu-item:create" // involves setting order to 'completed' ,'ready', etc
  | "menu-item:delete"
  | "menu-item:update"
  | "menu-item:read"; // involves setting order to 'completed' ,'ready', etc

const permissionsByRole: Record<User["role"], Permission[]> = {
  ADMIN: [
    "cafeteria:create",
    "cafeteria:delete",
    "cafeteria:update",
    "cafeteria:read",
  ],
    CUSTOMER: [
        "order:create",
        "order:read",
        "order-status:read",
        "cafeteria:read",
        "cafetaria-open-status:read",
        "cafetaria-queue-status:read"
    ],
  STAFF: [
    "cafetaria-open-status:update",
    "cafeteria-queue-status:update",
    "order-status:update", // involves setting order to 'completed' ,'ready', etc
    "order:create",
    "order:delete",
    "order:read",
    "order:update",
    "menu-item:create", // involves setting order to 'completed' ,'ready', etc
    "menu-item:delete",
    "menu-item:update",
    "menu-item:read",
  ],
};

export function can(user: Pick<User, "role"> | null, permission: Permission) {
  // automatic failure for no user
  if (user == null) return false;
  return permissionsByRole[user.role].includes(permission);
}
