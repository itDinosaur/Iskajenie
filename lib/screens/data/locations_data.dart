// lib/screens/data/locations_data.dart
// Файл содержит описание всех локаций для компании "Мрачный бункер"
// Каждая локация имеет название, описание, тип (тупик или нет) и иконку.

import 'package:flutter/material.dart';

// Мы НЕ создаем здесь свой enum LocationType, а используем тот, что в models/location.dart
// Это предотвращает конфликт имен при импорте

// Класс, описывающий шаблон локации (статические данные)
class LocationTemplate {
  final String id;              // Уникальный идентификатор локации
  final String name;            // Название локации
  final String description;     // Описание для игрока
  final String type;            // Тип локации как строка ('start', 'crossroad', 'normal', 'deadEnd', 'checkRequired')
  final IconData icon;          // Иконка для отображения на карте
  final String? imagePath;      // Путь к картинке (если есть)
  final String? checkMessage;   // Текст проверки навыка (если требуется)

  const LocationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    this.imagePath,
    this.checkMessage,
  });
}

// Список всех доступных локаций для компании "Мрачный бункер"
// Здесь мы определяем правила для каждой локации
const List<LocationTemplate> bunkerLocations = [
  // 1. Стартовая локация - всегда первая
  LocationTemplate(
    id: 'metal_corridor',
    name: 'Металлический проход',
    description: 'Длинный коридор с металлическими стенами. Слышен гул вентиляции.',
    type: 'start',
    icon: Icons.subway, // Используем доступную иконку метро/тоннеля
    imagePath: 'assets/images/metal_corridor.png', // Место под будущую картинку
  ),

  // 2. Вторая обязательная локация - развилка
  LocationTemplate(
    id: 'bloody_crossroad',
    name: 'Кровавый перекресток',
    description: 'Пересечение тоннелей. На стенах следы борьбы и засохшая кровь.',
    type: 'crossroad',
    icon: Icons.call_split,
  ),

  // 3. Проходная локация (не тупик)
  LocationTemplate(
    id: 'ladder',
    name: 'Лестница',
    description: 'Ржавая металлическая лестница, ведущая вверх или вниз.',
    type: 'normal',
    icon: Icons.stairs,
  ),

  // 4. Тупиковая локация
  LocationTemplate(
    id: 'dead_passage',
    name: 'Тупиковый проход',
    description: 'Коридор упирается в завал. Дальше пути нет.',
    type: 'deadEnd',
    icon: Icons.block,
  ),

  // 5. Проходная локация
  LocationTemplate(
    id: 'service_tunnel',
    name: 'Запасной туннель',
    description: 'Узкий служебный туннель с проводами и трубами.',
    type: 'normal',
    icon: Icons.settings_input_component,
  ),

  // 6. Проходная локация
  LocationTemplate(
    id: 'tech_room',
    name: 'Техническое помещение',
    description: 'Комната с серверными шкафами и щитами управления.',
    type: 'normal',
    icon: Icons.memory,
  ),

  // 7. Тупик с проверкой навыка
  LocationTemplate(
    id: 'cleaner_closet',
    name: 'Кладовая уборщика',
    description: 'Маленькое помещение с инвентарем. Дверь заклинило.',
    type: 'checkRequired',
    icon: Icons.cleaning_services,
    checkMessage: 'Требуется сила, чтобы выбить дверь (Сложность: 5)',
  ),
];

// Функция для получения шаблона локации по её ID
LocationTemplate getLocationTemplate(String id) {
  try {
    return bunkerLocations.firstWhere((loc) => loc.id == id);
  } catch (e) {
    // Если локация не найдена, возвращаем заглушку (для безопасности)
    return bunkerLocations[0];
  }
}
