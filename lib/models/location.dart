// location.dart - Модель локации
// Этот файл описывает, что такое "локация" в нашей игре
// Модель определяет структуру данных: какие свойства есть у локации

// Перечисление типов локаций
// enum позволяет создать фиксированный набор значений
enum LocationType {
  indoor,      // Помещение (внутри здания)
  outdoor,     // Открытая местность (улица, лес и т.д.)
  underground, // Подземелье (пещеры, бункеры)
}

// Класс Location - это шаблон для создания объектов локаций
// Каждая локация в игре будет экземпляром этого класса
class Location {
  // id - уникальный идентификатор локации
  // Используется для поиска и сохранения конкретной локации
  final String id;
  
  // name - название локации, которое видит игрок
  final String name;
  
  // description - подробное описание локации
  // Создаёт атмосферу и помогает игроку представить место
  final String description;
  
  // locationType - тип локации (помещение, улица, подземелье)
  // Может влиять на геймплей (например, разные события для разных типов)
  final LocationType locationType;
  
  // difficulty - сложность локации от 1 до 5
  // 1 - очень легко, 5 - очень сложно
  // Влияет на опасность событий и силу врагов
  final int difficulty;
  
  // imageUrl - путь к изображению локации
  // Позже добавим картинки для каждой локации
  final String imageUrl;
  
  // isExplored - исследована ли эта локация
  // По умолчанию false, становится true когда игрок посещает локацию
  bool isExplored;
  
  // Конструктор класса Location
  // required означает, что эти параметры обязательны при создании локации
  const Location({
    required this.id,           // Обязательно: уникальный ID
    required this.name,         // Обязательно: название
    required this.description,  // Обязательно: описание
    required this.locationType, // Обязательно: тип
    required this.difficulty,   // Обязательно: сложность
    required this.imageUrl,     // Обязательно: путь к картинке
    this.isExplored = false,    // Необязательно: по умолчанию не исследована
  });

  // Метод для получения иконки в зависимости от типа локации
  // Возвращает IconData - иконку из набора Material Icons
  IconData get typeIcon {
    // switch выбирает иконку в зависимости от типа
    switch (locationType) {
      case LocationType.indoor:
        return Icons.house;       // Дом для помещений
      case LocationType.outdoor:
        return Icons.park;        // Парк для улицы
      case LocationType.underground:
        return Icons.water_damage; // Пещера для подземелий
    }
  }

  // Метод для получения цвета сложности
  // Возвращает цвет в зависимости от уровня сложности
  // Можно использовать для подсветки карточки локации
  String get difficultyColor {
    if (difficulty <= 2) {
      return 'green';   // Лёгкие локации - зелёный
    } else if (difficulty <= 3) {
      return 'yellow';  // Средние - жёлтый
    } else if (difficulty <= 4) {
      return 'orange';  // Сложные - оранжевый
    } else {
      return 'red';     // Очень сложные - красный
    }
  }

  // Метод для преобразования локации в JSON
  // Нужен для сохранения прогресса в файл
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'locationType': locationType.index, // Сохраняем как число (индекс в enum)
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'isExplored': isExplored,
    };
  }

  // Метод для создания локации из JSON
  // Используется при загрузке сохранённой игры
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      locationType: LocationType.values[json['locationType']], // Преобразуем число обратно в тип
      difficulty: json['difficulty'],
      imageUrl: json['imageUrl'],
      isExplored: json['isExplored'] ?? false, // Если поля нет, считаем false
    );
  }

  // Переопределяем метод toString для удобного вывода в консоль
  // Полезно при отладке
  @override
  String toString() {
    return 'Location(id: $id, name: $name, type: $locationType, difficulty: $difficulty)';
  }

  // Переопределяем оператор == для сравнения локаций
  // Две локации равны, если у них одинаковый ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location && other.id == id;
  }

  // Переопределяем hashCode для корректной работы с коллекциями
  @override
  int get hashCode => id.hashCode;
}
