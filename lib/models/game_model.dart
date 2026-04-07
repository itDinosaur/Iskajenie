// game_model.dart - Модель игровой партии
// Этот файл описывает состояние всей игры: текущая локация, искажение, раунды и т.д.
// Модель сохраняется при выходе и загружается при продолжении игры

import 'package:flutter/material.dart'; // Импортируем Material для иконок
import 'location.dart'; // Подключаем модель локации

// Перечисление фаз хода в игре
enum GamePhase {
  exploration,  // Фаза исследования (игроки перемещаются)
  event,        // Фаза событий (происходят случайные события)
  action,       // Фаза действий (игроки используют способности)
  cleanup,      // Фаза очистки (подготовка к следующему раунду)
}

// Расширение для красивого отображения фаз
extension GamePhaseExtension on GamePhase {
  String get displayName {
    switch (this) {
      case GamePhase.exploration:
        return 'Исследование';
      case GamePhase.event:
        return 'Событие';
      case GamePhase.action:
        return 'Действие';
      case GamePhase.cleanup:
        return 'Очистка';
    }
  }

  IconData get icon {
    switch (this) {
      case GamePhase.exploration:
        return Icons.explore;
      case GamePhase.event:
        return Icons.auto_awesome;
      case GamePhase.action:
        return Icons.play_arrow;
      case GamePhase.cleanup:
        return Icons.cleaning_services;
    }
  }
}

// Класс модели игровой партии
class GameModel {
  // slotId - ID слота сохранения
  final String slotId;
  
  // companyId - ID выбранной компании (сценария)
  final String companyId;
  
  // playerCount - количество игроков
  final int playerCount;
  
  // difficulty - сложность игры (0=легкая, 1=стандарт, 2=хардкор)
  final int difficulty;
  
  // selectedCharacterIds - список ID выбранных персонажей
  final List<String> selectedCharacterIds;
  
  // currentRound - текущий номер раунда
  int currentRound;
  
  // distortionCounter - счётчик искажения (основная механика игры)
  int distortionCounter;
  
  // currentPhase - текущая фаза хода
  GamePhase currentPhase;
  
  // mapLocations - список локаций на карте (игровое поле)
  List<Location> mapLocations;
  
  // currentLocationId - ID текущей локации, где находятся игроки
  String? currentLocationId;
  
  // isGameStarted - началась ли игра (после экрана предыстории)
  bool isGameStarted;
  
  // visitedLocationIds - список ID посещённых локаций
  List<String> visitedLocationIds;
  
  // Конструктор класса GameModel
  GameModel({
    required this.slotId,
    required this.companyId,
    required this.playerCount,
    required this.difficulty,
    required this.selectedCharacterIds,
    this.currentRound = 1,
    this.distortionCounter = 0,
    this.currentPhase = GamePhase.exploration,
    List<Location>? mapLocations,
    this.currentLocationId,
    this.isGameStarted = false,
    List<String>? visitedLocationIds,
  }) : 
    mapLocations = mapLocations ?? [],
    visitedLocationIds = visitedLocationIds ?? [];

  // Метод для преобразования модели в JSON (для сохранения)
  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'companyId': companyId,
      'playerCount': playerCount,
      'difficulty': difficulty,
      'selectedCharacterIds': selectedCharacterIds,
      'currentRound': currentRound,
      'distortionCounter': distortionCounter,
      'currentPhase': currentPhase.index,
      'mapLocations': mapLocations.map((loc) => loc.toJson()).toList(),
      'currentLocationId': currentLocationId,
      'isGameStarted': isGameStarted,
      'visitedLocationIds': visitedLocationIds,
    };
  }

  // Метод для создания модели из JSON (при загрузке)
  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      slotId: json['slotId'],
      companyId: json['companyId'],
      playerCount: json['playerCount'],
      difficulty: json['difficulty'],
      selectedCharacterIds: List<String>.from(json['selectedCharacterIds'] ?? []),
      currentRound: json['currentRound'] ?? 1,
      distortionCounter: json['distortionCounter'] ?? 0,
      currentPhase: GamePhase.values[json['currentPhase'] ?? 0],
      mapLocations: (json['mapLocations'] as List<dynamic>?)
          ?.map((loc) => Location.fromJson(loc))
          .toList(),
      currentLocationId: json['currentLocationId'],
      isGameStarted: json['isGameStarted'] ?? false,
      visitedLocationIds: List<String>.from(json['visitedLocationIds'] ?? []),
    );
  }

  // Метод для перехода к следующей фазе
  void nextPhase() {
    switch (currentPhase) {
      case GamePhase.exploration:
        currentPhase = GamePhase.event;
        break;
      case GamePhase.event:
        currentPhase = GamePhase.action;
        break;
      case GamePhase.action:
        currentPhase = GamePhase.cleanup;
        break;
      case GamePhase.cleanup:
        // После очистки начинается новый раунд
        currentRound++;
        currentPhase = GamePhase.exploration;
        break;
    }
  }

  // Метод для увеличения счётчика искажения
  void increaseDistortion(int amount) {
    distortionCounter += amount;
    if (distortionCounter < 0) {
      distortionCounter = 0;
    }
  }

  // Метод для посещения локации
  void visitLocation(String locationId) {
    currentLocationId = locationId;
    if (!visitedLocationIds.contains(locationId)) {
      visitedLocationIds.add(locationId);
    }
  }

  // Метод для получения текущей локации
  Location? getCurrentLocation() {
    if (currentLocationId == null) return null;
    try {
      return mapLocations.firstWhere((loc) => loc.id == currentLocationId);
    } catch (e) {
      return null;
    }
  }

  // Метод для начала игры (после экрана предыстории)
  void startGame(List<Location> initialLocations, String startLocationId) {
    mapLocations = initialLocations;
    currentLocationId = startLocationId;
    isGameStarted = true;
    visitedLocationIds.add(startLocationId);
  }
  
  // Метод для добавления новой локации на карту
  void addLocationToMap(Location location) {
    if (!mapLocations.any((loc) => loc.id == location.id)) {
      mapLocations.add(location);
    }
  }
  
  // Метод для перемещения в локацию
  void moveToLocation(String locationId) {
    visitLocation(locationId);
  }
}
