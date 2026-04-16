import { PrismaClient } from './generated/prisma/client.ts';
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcryptjs';
import { env } from '../env.ts';

const adapter = new PrismaPg({ connectionString: env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Seeding database...');

  // ── Users ─────────────────────────────────────────────────────────────────
  const password = await bcrypt.hash('password123', 12);

  const customer = await prisma.user.upsert({
    where: { email: 'nessa@ashesi.edu.gh' },
    update: {},
    create: { name: 'Nessa Asante', email: 'nessa@ashesi.edu.gh', password, role: 'CUSTOMER' },
  });

  const staff = await prisma.user.upsert({
    where: { email: 'kwame.mensah@ashesi.edu.gh' },
    update: {},
    create: { name: 'Kwame Mensah', email: 'kwame.mensah@ashesi.edu.gh', password, role: 'STAFF' },
  });

  const admin = await prisma.user.upsert({
    where: { email: 'ama.owusu@ashesi.edu.gh' },
    update: {},
    create: { name: 'Ama Owusu', email: 'ama.owusu@ashesi.edu.gh', password, role: 'ADMIN' },
  });

  console.log('Users created:', { customer: customer.email, staff: staff.email, admin: admin.email });

  // ── Cafeteria images ──────────────────────────────────────────────────────
  const cafeteriaImg = (file: string) => `${env.IMAGE_BASE_URL}/images/cafeterias/${file}`;
  const munchiesImg = cafeteriaImg('munchies.png');
  const hallmarkImg = cafeteriaImg('hallmark.png');
  const akornorImg  = cafeteriaImg('akornor.png');

  // ── Remove stale cafeterias (menu items first to satisfy FK constraint) ──
  const stale = await prisma.cafeteria.findMany({ where: { name: { in: ['Akornor'] } } });
  if (stale.length > 0) {
    await prisma.menuItem.deleteMany({ where: { cafeteriaId: { in: stale.map(c => c.id) } } });
    await prisma.cafeteria.deleteMany({ where: { id: { in: stale.map(c => c.id) } } });
  }

  // ── Cafeterias ────────────────────────────────────────────────────────────
  const munchies = await prisma.cafeteria.upsert({
    where: { name: 'Munchies' },
    update: { imageUrl: munchiesImg },
    create: { name: 'Munchies', isOpen: true, capacityStatus: 'GREEN', imageUrl: munchiesImg },
  });

  const hallmark = await prisma.cafeteria.upsert({
    where: { name: 'HallMark Cafe' },
    update: { imageUrl: hallmarkImg },
    create: { name: 'HallMark Cafe', isOpen: true, capacityStatus: 'GREEN', imageUrl: hallmarkImg },
  });

  const akornor = await prisma.cafeteria.upsert({
    where: { name: 'Akornor' },
    update: { imageUrl: akornorImg },
    create: { name: 'Akornor', isOpen: true, capacityStatus: 'YELLOW', imageUrl: akornorImg },
  });

  console.log('Cafeterias created:', { munchies: munchies.id, hallmark: hallmark.id, akornor: akornor.id });

  // ── Menu item images (local — served from backend/public/images/menu/) ─────
  const menuImg = (file: string) => `${env.IMAGE_BASE_URL}/images/menu/${file}`;

  const stirFriedChickenImg = menuImg('stir_fried_chicken.png');
  const prawnFriedRiceImg   = menuImg('prawn_fried_rice.png');
  const indomieImg          = menuImg('indomie_special.png');
  const grilledTilapiaImg   = menuImg('grilled_tilapia.png');
  const jollofRiceImg       = menuImg('jollof_rice.png');
  const freshJuiceImg       = menuImg('fresh_juice.png');
  const keleweleImg         = menuImg('kelewele.png');
  const waakyeImg           = menuImg('waakye.png');
  const meatPieImg          = menuImg('meat_pie.png');

  // ── Menu items ────────────────────────────────────────────────────────────
  await prisma.menuItem.deleteMany({
    where: { cafeteriaId: { in: [munchies.id, hallmark.id, akornor.id] } },
  });

  const menuItems = [
    // Munchies
    {
      cafeteriaId: munchies.id,
      name: 'Stir-Fried Chicken',
      price: 35,
      category: 'Lunch',
      description: 'Tender chicken stir-fried with seasonal vegetables',
      allergenTags: ['Soy'],
      imageUrl: stirFriedChickenImg,
    },
    {
      cafeteriaId: munchies.id,
      name: 'Prawn Fried Rice',
      price: 12,
      category: 'Lunch',
      description: 'Fragrant fried rice packed with plump prawns',
      allergenTags: ['Shellfish', 'Soy'],
      imageUrl: prawnFriedRiceImg,
    },
    {
      cafeteriaId: munchies.id,
      name: 'Indomie Special',
      price: 8,
      category: 'Snacks',
      description: 'Indomie noodles loaded with egg and vegetables',
      allergenTags: ['Gluten', 'Egg'],
      imageUrl: indomieImg,
    },
    // HallMark Cafe
    {
      cafeteriaId: hallmark.id,
      name: 'Grilled Tilapia',
      price: 45,
      category: 'Lunch',
      description: 'Fresh whole tilapia grilled over charcoal, served with banku',
      allergenTags: ['Fish'],
      imageUrl: grilledTilapiaImg,
    },
    {
      cafeteriaId: hallmark.id,
      name: 'Jollof Rice',
      price: 20,
      category: 'Lunch',
      description: 'Classic Ghanaian party jollof rice with grilled chicken',
      allergenTags: [],
      imageUrl: jollofRiceImg,
    },
    {
      cafeteriaId: hallmark.id,
      name: 'Fresh Juice',
      price: 10,
      category: 'Drinks',
      description: 'Freshly squeezed seasonal fruit juice',
      allergenTags: [],
      imageUrl: freshJuiceImg,
    },
    // Akornor
    {
      cafeteriaId: akornor.id,
      name: 'Kelewele',
      price: 8,
      category: 'Snacks',
      description: 'Spicy fried plantain cubes seasoned with ginger and pepper',
      allergenTags: [],
      imageUrl: keleweleImg,
    },
    {
      cafeteriaId: akornor.id,
      name: 'Waakye',
      price: 15,
      category: 'Breakfast',
      description: 'Rice and beans with gari, spaghetti, fried fish and shito',
      allergenTags: ['Fish'],
      imageUrl: waakyeImg,
    },
    {
      cafeteriaId: akornor.id,
      name: 'Meat Pie',
      price: 5,
      category: 'Snacks',
      description: 'Flaky golden pastry with seasoned minced meat filling',
      allergenTags: ['Gluten'],
      imageUrl: meatPieImg,
    },
  ];

  await prisma.menuItem.createMany({ data: menuItems });

  console.log(`${menuItems.length} menu items created`);
  console.log('\n── Seed complete! ───────────────────────────────');
  console.log('Test accounts (all passwords: password123)');
  console.log(`  CUSTOMER : nessa@ashesi.edu.gh`);
  console.log(`  STAFF    : kwame.mensah@ashesi.edu.gh`);
  console.log(`  ADMIN    : ama.owusu@ashesi.edu.gh`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
