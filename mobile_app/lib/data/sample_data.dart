import '../models/special.dart';
import '../models/cafeteria.dart';
import '../models/food_item.dart';

final List<Special> specials = [
  Special(
    tag: '#eatwelleveryday',
    title: 'Home-Chew: Indomie',
    subtitle: 'Details about meal',
    period: 'Period  4 – 28 Apr 2023',
    imageAsset:
        'https://unsplash.com/photos/pasta-with-meat-on-white-ceramic-plate-FIGcCVQeGwE',
  ),
  Special(
    tag: '#freshstart',
    title: 'Home-Chew: Jollof',
    subtitle: 'Classic West African rice',
    period: 'Period  1 – 15 May 2023',
    imageAsset:
        'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=300',
  ),
];

final List<Cafeteria> cafeterias = [
  Cafeteria(
    name: 'Munchies',
    imageAsset:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300',
  ),
  Cafeteria(
    name: 'HallMark Cafe',
    imageAsset:
        'https://images.unsplash.com/photo-1567521464027-f127ff144326?w=300',
  ),
  Cafeteria(
    name: 'The Spot',
    imageAsset:
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300',
  ),
];

final List<FoodItem> recommended = [
  FoodItem(
    name: 'Stir-Fried Chicken',
    description: 'Chicken with Peanuts',
    price: '₵35.00',
    imageAsset:
        'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=300',
  ),
  FoodItem(
    name: 'Prawn Fried Rice',
    description: 'Fried Rice with Prawns',
    price: '₵12.00',
    imageAsset:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=300',
  ),
  FoodItem(
    name: 'Grilled Tilapia',
    description: 'Tilapia with Banku',
    price: '₵45.00',
    imageAsset:
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=300',
  ),
  FoodItem(
    name: 'Kelewele',
    description: 'Spiced Fried Plantain',
    price: '₵8.00',
    imageAsset:
        'https://images.unsplash.com/photo-1574484284002-952d92456975?w=300',
  ),
];
