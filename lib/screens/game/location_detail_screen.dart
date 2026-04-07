import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_model.dart';
import '../../models/location.dart';
import '../data/locations_data.dart';

// Константы для локаций
class LocationConstants {
  static const int maxRandomLocations = 3;
  static const int baseDifficulty = 3;
  static const int checkRequiredDifficulty = 5;
}

class LocationDetailScreen extends StatefulWidget {
  final Location location;
  final GameModel gameModel;

  const LocationDetailScreen({
    super.key,
    required this.location,
    required this.gameModel,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  late GameModel _gameModel;
  bool _isLoading = false;
  
  // Геттер для удобного доступа к локации из виджета
  Location get location => widget.location;

  @override
  void initState() {
    super.initState();
    _gameModel = widget.gameModel;
  }

  // Сохранение игры с обработкой ошибок
  Future<void> _saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'game_save_${_gameModel.slotId}',
        json.encode(_gameModel.toJson()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Карточка с информацией о локации
              _buildLocationCard(),
              
              const SizedBox(height: 24),
              
              // Описание локации
              _buildDescriptionCard(),
              
              const SizedBox(height: 24),
              
              // Кнопки взаимодействия
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Карточка с основной информацией
  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent, width: 2),
      ),
      child: Row(
        children: [
          // Иконка типа локации
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              location.typeIcon,
              size: 48,
              color: Colors.purpleAccent,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Тип локации
                Row(
                  children: [
                    const Icon(Icons.category, size: 16, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      _getLocationTypeName(location.locationType),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Сложность
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Сложность: ${location.difficulty}/5',
                      style: TextStyle(
                        color: _getDifficultyColor(location.difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Карточка с описанием
  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: Colors.white54),
              SizedBox(width: 8),
              Text(
                'Описание',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            location.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Кнопки взаимодействия
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Действия',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Кнопка "Исследовать"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.explore),
            label: const Text('Исследовать локацию'),
            onPressed: () {
              _showExploreDialog(context);
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Кнопка "Проверить навык"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.school),
            label: const Text('Проверить навык'),
            onPressed: () {
              _showSkillCheckDialog(context);
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Кнопка "Отдохнуть"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.local_cafe),
            label: const Text('Отдохнуть'),
            onPressed: () {
              _showRestDialog(context);
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Кнопка "Закрыть"
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Закрыть'),
          ),
        ),
      ],
    );
  }

  // Диалог исследования - добавляет новую локацию на карту
  void _showExploreDialog(BuildContext context) {
    // Если это Металлический проход, то открываем Кровавый перекресток
    if (widget.location.id == 'metal_corridor') {
      _addBloodyCrossroad();
      return;
    }
    
    // Если это Кровавый перекресток, то добавляем 3 случайные локации
    if (widget.location.id == 'bloody_crossroad') {
      _addRandomLocationsFromCrossroad();
      return;
    }
    
    // Для остальных локаций - просто сообщение
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Исследование', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы внимательно осматриваете локацию. Здесь пока нечего исследовать.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
  
  // Добавление Кровавого перекрестка
  void _addBloodyCrossroad() {
    final crossroadTemplate = getLocationTemplate('bloody_crossroad');
    
    // Проверяем, есть ли уже эта локация на карте
    final exists = _gameModel.mapLocations.any((loc) => loc.id == crossroadTemplate.id);
    
    if (!exists) {
      final newLocation = Location(
        id: crossroadTemplate.id,
        name: crossroadTemplate.name,
        description: crossroadTemplate.description,
        locationType: LocationType.underground,
        difficulty: 2,
        imageUrl: crossroadTemplate.imagePath ?? '', // Если картинки нет, пустая строка
      );
      
      setState(() {
        _gameModel.addLocationToMap(newLocation);
        _gameModel.moveToLocation(newLocation.id);
      });
      
      _saveGame();
      
      // Показываем сообщение и закрываем текущий экран
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: const Text('Новая локация!', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Вы вышли на Кровавый перекресток. Отсюда расходятся три тоннеля...',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрываем диалог
                Navigator.pop(context); // Закрываем экран локации
              },
              child: const Text('Продолжить', style: TextStyle(color: Colors.purpleAccent)),
            ),
          ],
        ),
      ).then((_) {
        // После закрытия диалога обновляем карту
        setState(() {});
      });
    }
  }
  
  // Добавление 3 случайных локаций из перекрестка
  void _addRandomLocationsFromCrossroad() {
    // Получаем все доступные локации кроме уже добавленных
    final existingIds = _gameModel.mapLocations.map((loc) => loc.id).toList();
    
    final availableLocations = bunkerLocations.where((loc) => 
      !existingIds.contains(loc.id) && 
      loc.id != 'metal_corridor' && 
      loc.id != 'bloody_crossroad'
    ).toList();
    
    // Перемешиваем и берем 3 случайные
    availableLocations.shuffle(math.Random());
    final selectedLocations = availableLocations.take(3).toList();
    
    if (selectedLocations.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: const Text('Нет путей', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Все возможные пути уже исследованы.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      );
      return;
    }
    
    // Добавляем новые локации на карту
    for (var template in selectedLocations) {
      final newLocation = Location(
        id: template.id,
        name: template.name,
        description: template.description,
        locationType: LocationType.underground,
        difficulty: template.type == 'checkRequired' 
            ? LocationConstants.checkRequiredDifficulty 
            : LocationConstants.baseDifficulty,
        imageUrl: template.imagePath ?? '', // Если картинки нет, пустая строка
      );
      
      _gameModel.addLocationToMap(newLocation);
    }
    
    setState(() {});
    _saveGame();
    
    // Показываем сообщение о новых локациях
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Новые пути открыты!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Из перекрестка ведут три тоннеля:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ...selectedLocations.map((loc) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.purpleAccent),
                  const SizedBox(width: 8),
                  Text(loc.name, style: const TextStyle(color: Colors.white)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрываем диалог
              Navigator.pop(context); // Закрываем экран локации
            },
            child: const Text('Продолжить', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  // Диалог проверки навыка
  void _showSkillCheckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Проверка навыка', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выберите навык для проверки:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            // Здесь будет список навыков персонажей
            // Пока заглушка
            Text(
              'Функционал в разработке',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  // Диалог отдыха
  void _showRestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Отдых', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы решаете отдохнуть в этой локации, чтобы восстановить силы...',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  // Получить название типа локации
  String _getLocationTypeName(LocationType type) {
    switch (type) {
      case LocationType.indoor:
        return 'Помещение';
      case LocationType.outdoor:
        return 'Открытая местность';
      case LocationType.underground:
        return 'Подземелье';
    }
  }

  // Получить цвет сложности
  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 2) return Colors.green;
    if (difficulty <= 3) return Colors.yellow;
    if (difficulty <= 4) return Colors.orange;
    return Colors.red;
  }
}
