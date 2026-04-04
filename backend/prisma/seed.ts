import { PrismaClient } from './generated/prisma/client.ts';
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcryptjs';
import { env } from '../env.ts';

const adapter = new PrismaPg({ connectionString: env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

// Picsum fallback — CORS-friendly, always works
const Picsum = (seed: string) => `https://picsum.photos/seed/${seed}/600/400`;

// Query TheMealDB by search term; returns the meal thumbnail or a Picsum fallback.
async function mealImg(query: string, fallbackSeed: string): Promise<string> {
  try {
    const url = `https://www.themealdb.com/api/json/v1/1/search.php?s=${encodeURIComponent(query)}`;
    const res = await fetch(url);
    const json = (await res.json()) as { meals: Array<{ strMealThumb: string }> | null };
    if (json.meals && json.meals.length > 0) {
      console.log(`  [img] "${query}" → TheMealDB ✓`);
      return json.meals[0].strMealThumb;
    }
  } catch (e) {
    console.log(`  [img] "${query}" fetch error:`, (e as Error).message);
  }
  console.log(`  [img] "${query}" → Picsum fallback`);
  return Picsum(fallbackSeed);
}

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

  // ── Cafeteria images — restaurant/dining space photos from Unsplash ──────
  const munchiesImg = 'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=600&fit=crop';  // casual dining interior
  const hallmarkImg = 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&fit=crop';     // cafe interior
  const theSpotImg  = 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=600&fit=crop';     // restaurant/spot

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

  const theSpot = await prisma.cafeteria.upsert({
    where: { name: 'The Spot' },
    update: { imageUrl: theSpotImg },
    create: { name: 'The Spot', isOpen: true, capacityStatus: 'YELLOW', imageUrl: theSpotImg },
  });

  console.log('Cafeterias created:', { munchies: munchies.id, hallmark: hallmark.id, theSpot: theSpot.id });

  // ── Menu item images — searched by closest TheMealDB term ─────────────────
  console.log('Fetching menu item images from TheMealDB...');
  const [
    stirFriedChickenImg,
    prawnFriedRiceImg,
    indomieImg,
    grilledTilapiaImg,
    jollofRiceImg,
    freshJuiceImg,
    keleweleImg,
    waakyeImg,
    meatPieImg,
  ] = await Promise.all([
    mealImg('stir fry', 'chicken-stir'),     // Stir-Fried Chicken → Chinese stir fry
    mealImg('fried rice', 'prawn-rice'),     // Prawn Fried Rice → Chicken Fried Rice
    mealImg('noodles', 'noodles-indomie'),   // Indomie Special → Laksa Noodles
    mealImg('fish', 'grilled-tilapia'),      // Grilled Tilapia → Fish pie/dish
    mealImg('rice', 'jollof-rice'),          // Jollof Rice → Seafood Rice
    mealImg('lemon', 'fresh-juice'),         // Fresh Juice → lemon drink
    mealImg('plantain', 'fried-plantain'),   // Kelewele → plantain (likely Picsum)
    mealImg('seafood rice', 'waakye-rice'),  // Waakye → rice dish
    mealImg('beef pie', 'meat-pie'),         // Meat Pie → Minced Beef Pie
  ]);

  // ── Menu items ────────────────────────────────────────────────────────────
  await prisma.menuItem.deleteMany({
    where: { cafeteriaId: { in: [munchies.id, hallmark.id, theSpot.id] } },
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
    // The Spot
    {
      cafeteriaId: theSpot.id,
      name: 'Kelewele',
      price: 8,
      category: 'Snacks',
      description: 'Spicy fried plantain cubes seasoned with ginger and pepper',
      allergenTags: [],
      imageUrl: keleweleImg,
    },
    {
      cafeteriaId: theSpot.id,
      name: 'Waakye',
      price: 15,
      category: 'Breakfast',
      description: 'Rice and beans with gari, spaghetti, fried fish and shito',
      allergenTags: ['Fish'],
      imageUrl: waakyeImg,
    },
    {
      cafeteriaId: theSpot.id,
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
