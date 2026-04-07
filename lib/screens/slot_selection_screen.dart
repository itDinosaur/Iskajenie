import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'party_setup_screen.dart';
import 'game/game_board_screen.dart';
import '../../models/game_model.dart';

// Модель данных для слота сохранения
class GameSlot {
  final int id;
  String? saveName; // Если null, значит слот свободен
  bool isOccupied;

  GameSlot({
    required this.id,
    this.saveName,
    this.isOccupied = false,
  });

  // Преобразование в JSON для сохранения
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saveName': saveName,
      'isOccupied': isOccupied,
    };
  }

  // Создание из JSON при загрузке
  factory GameSlot.fromJson(Map<String, dynamic> json) {
    return GameSlot(
      id: json['id'],
      saveName: json['saveName'],
      isOccupied: json['isOccupied'] ?? false,
    );
  }
}

class SlotSelectionScreen extends StatefulWidget {
  const SlotSelectionScreen({super.key});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  // Список слотов
  List<GameSlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  // Загрузка слотов из памяти
  Future<void> _loadSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final slotsJson = prefs.getString('game_slots');
    
    if (slotsJson != null) {
      final List<dynamic> decoded = json.decode(slotsJson);
      setState(() {
        _slots = decoded.map((slot) => GameSlot.fromJson(slot)).toList();
      });
    } else {
      // Если сохранений нет, создаем пустые слоты
      setState(() {
        _slots = List.generate(10, (index) => GameSlot(id: index + 1));
        _saveSlots();
      });
    }
  }

  // Сохранение слотов в память
  Future<void> _saveSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final slotsJson = json.encode(_slots.map((slot) => slot.toJson()).toList());
    await prefs.setString('game_slots', slotsJson);
  }

  // Очистка всех слотов
  Future<void> _clearAllSlots() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_slots');
    setState(() {
      _slots = List.generate(10, (index) => GameSlot(id: index + 1));
    });
  }

  // Диалог подтверждения очистки всех слотов
  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Очистить все сохранения', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы уверены, что хотите удалить все сохранения? Это действие нельзя отменить.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await _clearAllSlots();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все сохранения удалены'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор партии'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Вернуться в меню',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Кнопка очистки всех сохранений
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: 'Очистить все сохранения',
            onPressed: () => _showClearConfirmDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Выберите слот для игры',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 колонки
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _slots.length,
                  itemBuilder: (context, index) {
                    final slot = _slots[index];
                    return _SlotCard(
                      slot: slot,
                      onTap: () => _handleSlotTap(slot),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSlotTap(GameSlot slot) {
    if (slot.isOccupied) {
      // Если слот занят, загружаем партию
      // Переход к экрану игры с загрузкой сохранения
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameBoardScreen(
            gameModel: GameModel(
              slotId: slot.id.toString(),
              companyId: '1', // Значение по умолчанию, будет перезаписано при загрузке сохранения
              playerCount: 1,
              difficulty: 1,
              selectedCharacterIds: [],
            ),
          ),
        ),
      );
    } else {
      // Если слот свободен, просим ввести имя
      _showCreateGameDialog(slot);
    }
  }

  void _showCreateGameDialog(GameSlot slot) {
    final TextEditingController _controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: const Text('Новая партия', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите название для нового слота:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Например: Моя первая игра',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                setState(() {
                  slot.saveName = _controller.text;
                  slot.isOccupied = true;
                });
                await _saveSlots(); // Сохраняем слоты
                Navigator.pop(context);
                
                // Переход к настройке новой партии
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartySetupScreen(
                      slotId: slot.id,
                      slotName: slot.saveName!,
                    ),
                  ),
                );
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }
}

// Виджет карточки слота
class _SlotCard extends StatelessWidget {
  final GameSlot slot;
  final VoidCallback onTap;

  const _SlotCard({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: slot.isOccupied
              ? const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                )
              : LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade900],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: slot.isOccupied ? Colors.purpleAccent : Colors.white24,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slot.isOccupied ? Icons.folder_open : Icons.add_box_outlined,
              size: 40,
              color: slot.isOccupied ? Colors.purpleAccent : Colors.white54,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                slot.isOccupied 
                    ? (slot.saveName ?? "Партия ${slot.id}")
                    : "Пустой слот",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black,
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (slot.isOccupied) ...[
              const SizedBox(height: 4),
              Text(
                'Слот ${slot.id}',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Слот ${slot.id}',
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
