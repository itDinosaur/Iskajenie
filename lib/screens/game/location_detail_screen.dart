// location_detail_screen.dart - Экран детального просмотра локации
// Этот экран открывается при клике на локацию на карте
// Показывает описание локации и кнопки взаимодействия

import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../models/location.dart';

class LocationDetailScreen extends StatelessWidget {
  final Location location;
  final GameModel gameModel;

  const LocationDetailScreen({
    super.key,
    required this.location,
    required this.gameModel,
  });

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

  // Диалог исследования
  void _showExploreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Исследование', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы внимательно осматриваете локацию в поисках полезных предметов или тайн...',
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
