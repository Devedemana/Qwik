import { Role} from "../../prisma/generated/prisma/client.ts";
type User = {
  role: Role,
  id: string,
  email:string 
}

export type Permission =
  | "cafeteria:create"
  | "cafeteria:delete"
  | "cafeteria:update"
  | "cafeteria:read"
  | "cafeteria-open-status:update"
  | "cafeteria-open-status:read"
  |"cafeteria-queue-status:read"
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
        "cafeteria-open-status:read",
        "cafeteria-queue-status:read"
    ],
  STAFF: [
    "cafeteria-open-status:update",
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

export function can(user: Pick<User, "role"> | null, permission: Permission): boolean {
  // automatic failure for no user
  console.log("USER::::", user)
  if (user == null) return false;
  return permissionsByRole[user.role].includes(permission);
}
