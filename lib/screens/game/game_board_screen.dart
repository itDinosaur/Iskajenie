// game_board_screen.dart - Экран игрового поля
// Это основной экран игры, где отображается карта с локациями
// Игрок может перемещаться между локациями и взаимодействовать с ними

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_model.dart';
import '../../models/location.dart';
import '../data/locations_data.dart';
import '../story_screen.dart';
import '../slot_selection_screen.dart';
import 'location_detail_screen.dart';

class GameBoardScreen extends StatefulWidget {
  final GameModel gameModel;

  const GameBoardScreen({super.key, required this.gameModel});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen> {
  late GameModel _gameModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Откладываем инициализацию до завершения сборки виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  // Инициализация игры
  Future<void> _initializeGame() async {
    // Проверяем, есть ли сохранение для этого слота
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString('game_save_${widget.gameModel.slotId}');
    
    if (gameJson != null) {
      // Есть сохранение - загружаем игру без предыстории
      await _loadGame();
    } else {
      // Нет сохранения - новая игра, показываем предысторию
      _showStory();
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  // Загрузка сохранённой игры
  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final gameJson = prefs.getString('game_save_${widget.gameModel.slotId}');
    
    if (gameJson != null) {
      setState(() {
        _gameModel = GameModel.fromJson(json.decode(gameJson));
      });
    } else {
      // Если сохранения нет, используем модель из виджета
      setState(() {
        _gameModel = widget.gameModel;
      });
    }
  }

  // Сохранение игры
  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'game_save_${_gameModel.slotId}',
      json.encode(_gameModel.toJson()),
    );
  }

  // Показ экрана предыстории
  void _showStory() {
    // Используем push вместо pushReplacement, чтобы можно было вернуться
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryScreen(gameModel: widget.gameModel),
      ),
    ).then((_) {
      // Когда история закрыта, начинаем игру
      if (mounted) {
        startGame();
      }
    });
  }

  // Генерация начальной карты для компании "Мрачный бункер"
  // По правилам: 
  // 1. Всегда начинаем с "Металлического прохода"
  // 2. Вторая локация всегда "Кровавый перекресток"
  // 3. Остальные 5 локаций выбираются случайно из оставшихся
  List<Location> _generateInitialMap() {
    List<Location> mapLocations = [];
    
    // 1. Стартовая локация - Металлический проход (всегда первая)
    final startTemplate = getLocationTemplate('metal_corridor');
    mapLocations.add(Location(
      id: startTemplate.id,
      name: startTemplate.name,
      description: startTemplate.description,
      locationType: _convertLocationType(startTemplate.type),
      difficulty: 1,
      imageUrl: startTemplate.imagePath,
    ));
    
    // 2. Вторая обязательная локация - Кровавый перекресток (всегда вторая)
    final crossroadTemplate = getLocationTemplate('bloody_crossroad');
    mapLocations.add(Location(
      id: crossroadTemplate.id,
      name: crossroadTemplate.name,
      description: crossroadTemplate.description,
      locationType: _convertLocationType(crossroadTemplate.type),
      difficulty: 2,
      imageUrl: crossroadTemplate.imagePath,
    ));
    
    // 3. Оставшиеся 5 локаций выбираем случайно из доступных
    // Исключаем уже добавленные (metal_corridor и bloody_crossroad)
    final availableLocations = bunkerLocations.where((loc) => 
      loc.id != 'metal_corridor' && loc.id != 'bloody_crossroad'
    ).toList();
    
    // Перемешиваем и берем первые 5
    availableLocations.shuffle(math.Random());
    final selectedLocations = availableLocations.take(5).toList();
    
    // Добавляем их на карту
    for (var template in selectedLocations) {
      mapLocations.add(Location(
        id: template.id,
        name: template.name,
        description: template.description,
        locationType: _convertLocationType(template.type),
        difficulty: template.type == LocationType.checkRequired ? 5 : 3,
        imageUrl: template.imagePath,
      ));
    }
    
    return mapLocations;
  }
  
  // Вспомогательный метод для преобразования типа локации
  LocationTypeModel _convertLocationType(LocationType type) {
    switch (type) {
      case LocationType.start:
      case LocationType.crossroad:
      case LocationType.normal:
        return LocationTypeModel.indoor;
      case LocationType.deadEnd:
        return LocationTypeModel.deadEnd;
      case LocationType.checkRequired:
        return LocationTypeModel.special;
    }
  }

  // Начало игры (после предыстории)
  void startGame() {
    setState(() {
      _gameModel = GameModel(
        slotId: widget.gameModel.slotId,
        companyId: widget.gameModel.companyId,
        playerCount: widget.gameModel.playerCount,
        difficulty: widget.gameModel.difficulty,
        selectedCharacterIds: widget.gameModel.selectedCharacterIds,
      );
      
      // Генерируем карту
      final initialMap = _generateInitialMap();
      _gameModel.startGame(initialMap, 'metal_corridor');
    });
    
    _saveGame();
  }

  // Переход к следующей фазе
  void _nextPhase() {
    setState(() {
      _gameModel.nextPhase();
    });
    _saveGame();
  }

  // Открытие детального просмотра локации
  void _openLocationDetail(Location location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailScreen(
          location: location,
          gameModel: _gameModel,
        ),
      ),
    ).then((_) {
      // После возврата обновляем игру
      _saveGame();
    });
  }

  // Возврат в главное меню
  void _returnToMenu() {
    _saveGame();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SlotSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Искажение'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Кнопка сохранения
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: 'Сохранить игру',
            onPressed: () {
              _saveGame();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Игра сохранена'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          // Кнопка выхода в меню
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            tooltip: 'В меню',
            onPressed: _returnToMenu,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
              Colors.deepPurple.shade800,
            ],
          ),
        ),
        child: Column(
          children: [
            // Верхняя панель с информацией
            _buildInfoPanel(),
            
            // Карта с локациями
            Expanded(
              child: _buildGameMap(),
            ),
            
            // Нижняя панель с фазами
            _buildPhasePanel(),
          ],
        ),
      ),
    );
  }

  // Построение информационной панели
  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Раунд
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Раунд',
            value: '${_gameModel.currentRound}',
          ),
          
          // Искажение
          _buildInfoItem(
            icon: Icons.psychology,
            label: 'Искажение',
            value: '${_gameModel.distortionCounter}',
            valueColor: Colors.purpleAccent,
          ),
          
          // Фаза
          _buildInfoItem(
            icon: _gameModel.currentPhase.icon,
            label: 'Фаза',
            value: _gameModel.currentPhase.displayName,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  // Построение карты с локациями
  Widget _buildGameMap() {
    if (_gameModel.mapLocations.isEmpty) {
      return const Center(
        child: Text(
          'Карта пуста',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _gameModel.mapLocations.length,
      itemBuilder: (context, index) {
        final location = _gameModel.mapLocations[index];
        final isCurrentLocation = _gameModel.currentLocationId == location.id;
        final isVisited = _gameModel.visitedLocationIds.contains(location.id);
        
        return _LocationCard(
          location: location,
          isCurrentLocation: isCurrentLocation,
          isVisited: isVisited,
          onTap: () => _openLocationDetail(location),
        );
      },
    );
  }

  // Построение панели фаз
  Widget _buildPhasePanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Текущая фаза: ${_gameModel.currentPhase.displayName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Следующая фаза'),
            onPressed: _nextPhase,
          ),
        ],
      ),
    );
  }
}

// Виджет карточки локации
class _LocationCard extends StatelessWidget {
  final Location location;
  final bool isCurrentLocation;
  final bool isVisited;
  final VoidCallback onTap;

  const _LocationCard({
    required this.location,
    required this.isCurrentLocation,
    required this.isVisited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isCurrentLocation
              ? const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)])
              : isVisited
                  ? LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade800])
                  : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentLocation ? Colors.purpleAccent : Colors.white24,
            width: isCurrentLocation ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Иконка типа локации
                  Icon(
                    location.typeIcon,
                    color: isCurrentLocation ? Colors.purpleAccent : Colors.white54,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  
                  // Название локации
                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Сложность
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${location.difficulty}/5',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Маркер текущей локации
            if (isCurrentLocation)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ВЫ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
