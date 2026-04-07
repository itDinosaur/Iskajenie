// locations_data.dart - Данные о локациях
// В этом файле хранится список всех возможных локаций для игры
// Разделение данных в отдельный файл позволяет легко добавлять новые локации
// не трогая основной код игры

import '../models/location.dart'; // Подключаем модель локации

// Список всех доступных локаций в игре
// Каждая локация имеет: название, описание, тип и сложность
final List<Location> allLocations = [
  // Локация 1: Заброшенная лаборатория
  Location(
    id: 'lab_01', // Уникальный идентификатор локации
    name: 'Заброшенная лаборатория', // Название, которое видит игрок
    description: 'Здесь когда-то проводились опасные эксперименты. Оборудование покрыто пылью, но некоторые приборы ещё работают.', // Описание для атмосферы
    locationType: LocationType.indoor, // Тип: помещение (внутри здания)
    difficulty: 2, // Сложность от 1 до 5 (2 - довольно легко)
    imageUrl: 'assets/locations/lab.png', // Путь к изображению (добавим позже)
  ),
  
  // Локация 2: Тёмный лес
  Location(
    id: 'forest_01',
    name: 'Тёмный лес',
    description: 'Густые деревья скрывают множество опасностей. Свет с трудом пробивается сквозь кроны.',
    locationType: LocationType.outdoor, // Тип: открытая местность
    difficulty: 3, // Средняя сложность
    imageUrl: 'assets/locations/forest.png',
  ),
  
  // Локация 3: Старая больница
  Location(
    id: 'hospital_01',
    name: 'Старая больница',
    description: 'Коридоры наполнены эхом прошлых страданий. Кто знает, что скрывается за каждой дверью?',
    locationType: LocationType.indoor,
    difficulty: 4, // Высокая сложность
    imageUrl: 'assets/locations/hospital.png',
  ),
  
  // Локация 4: Пустошь
  Location(
    id: 'wasteland_01',
    name: 'Пустошь',
    description: 'Выжженная земля, где время словно остановилось. Искажение здесь особенно сильно.',
    locationType: LocationType.outdoor,
    difficulty: 3,
    imageUrl: 'assets/locations/wasteland.png',
  ),
  
  // Локация 5: Подземный бункер
  Location(
    id: 'bunker_01',
    name: 'Подземный бункер',
    description: 'Глубоко под землёй находится секретный объект. Воздух спёртый, а стены давят.',
    locationType: LocationType.underground, // Тип: подземелье
    difficulty: 5, // Очень высокая сложность
    imageUrl: 'assets/locations/bunker.png',
  ),
  
  // Локация 6: Руины города
  Location(
    id: 'ruins_01',
    name: 'Руины города',
    description: 'Остатки цивилизации, поглощённые искажением. Здания полуразрушены, улицы заросли.',
    locationType: LocationType.outdoor,
    difficulty: 4,
    imageUrl: 'assets/locations/ruins.png',
  ),
  
  // Локация 7: Мистическое озеро
  Location(
    id: 'lake_01',
    name: 'Мистическое озеро',
    description: 'Вода в озере имеет странный оттенок. Говорят, оно исполняет желания... но какой ценой?',
    locationType: LocationType.outdoor,
    difficulty: 2,
    imageUrl: 'assets/locations/lake.png',
  ),
  
  // Локация 8: Загадочная пещера
  Location(
    id: 'cave_01',
    name: 'Загадочная пещера',
    description: 'В глубине пещеры слышны странные звуки. Стены покрыты светящимся мхом.',
    locationType: LocationType.underground,
    difficulty: 3,
    imageUrl: 'assets/locations/cave.png',
  ),
];

// Функция для получения случайной локации
// Можно использовать при генерации карты
Location getRandomLocation() {
  // Если список пуст, возвращаем null
  if (allLocations.isEmpty) {
    throw Exception('Список локаций пуст!');
  }
  
  // Выбираем случайный индекс от 0 до количества локаций минус 1
  final randomIndex = DateTime.now().millisecondsSinceEpoch % allLocations.length;
  
  // Возвращаем локацию по случайному индексу
  return allLocations[randomIndex];
}

// Функция для получения нескольких случайных уникальных локаций
// Используется при генерации игровой карты
List<Location> getRandomLocations(int count) {
  // Проверяем, что запрошенное количество не больше общего числа локаций
  if (count > allLocations.length) {
    count = allLocations.length; // Ограничиваем максимальным количеством
  }
  
  // Создаём копию списка, чтобы не изменять оригинал
  final shuffled = List<Location>.from(allLocations);
  
  // Перемешиваем список
  shuffled.shuffle();
  
  // Возвращаем первые 'count' элементов
  return shuffled.take(count).toList();
}

// Функция для получения локации по ID
// Полезно, когда нужно найти конкретную локацию
Location? getLocationById(String id) {
  // Ищем локацию с matching ID
  try {
    return allLocations.firstWhere((location) => location.id == id);
  } catch (e) {
    // Если локация не найдена, возвращаем null
    return null;
  }
}

// Функция для получения локаций по типу
// Например, получить только подземные локации
List<Location> getLocationsByType(LocationType type) {
  // Фильтруем список, оставляя только локации указанного типа
  return allLocations.where((location) => location.locationType == type).toList();
}
