import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'slot_selection_screen.dart';
import '../models/game_model.dart';
import 'game/game_board_screen.dart';

// Константы для настройки партии
class PartyConstants {
  static const int minPlayers = 1;
  static const int maxPlayers = 4;
  static const int defaultPlayerCount = 1;
}

// Модель данных для компании
class GameCompany {
  final String id;
  final String name;
  final String description;

  const GameCompany({
    required this.id,
    required this.name,
    required this.description,
  });
}

// Список доступных компаний
const List<GameCompany> availableCompanies = [
  GameCompany(
    id: 'bunker',
    name: 'Мрачный бункер',
    description: 'Темный подземный комплекс, полный тайн и опасностей',
  ),
  GameCompany(
    id: 'datacenter',
    name: 'Случай в ЦОДе',
    description: 'Загадочные события в центре обработки данных',
  ),
];

// Модель данных для сложности
enum GameDifficulty { easy, standard, hardcore }

extension GameDifficultyExtension on GameDifficulty {
  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Легкая';
      case GameDifficulty.standard:
        return 'Стандартная';
      case GameDifficulty.hardcore:
        return 'Хардкор';
    }
  }

  IconData get icon {
    switch (this) {
      case GameDifficulty.easy:
        return Icons.sentiment_satisfied;
      case GameDifficulty.standard:
        return Icons.sentiment_neutral;
      case GameDifficulty.hardcore:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  Color get color {
    switch (this) {
      case GameDifficulty.easy:
        return Colors.green;
      case GameDifficulty.standard:
        return Colors.orange;
      case GameDifficulty.hardcore:
        return Colors.red;
    }
  }
}

// Модель данных для персонажа
class Character {
  final String id;
  final String name;
  final String role;
  final String description;

  const Character({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
  });
}

// Список доступных персонажей
const List<Character> availableCharacters = [
  Character(
    id: 'soldier',
    name: 'Солдат',
    role: 'Боец',
    description: 'Опытный военный с боевой подготовкой',
  ),
  Character(
    id: 'engineer',
    name: 'Инженер',
    role: 'Техник',
    description: 'Специалист по электронике и механике',
  ),
  Character(
    id: 'medic',
    name: 'Медик',
    role: 'Врач',
    description: 'Квалифицированный медицинский работник',
  ),
  Character(
    id: 'scientist',
    name: 'Ученый',
    role: 'Исследователь',
    description: 'Эксперт в области аномальных явлений',
  ),
  Character(
    id: 'hacker',
    name: 'Хакер',
    role: 'Киберспециалист',
    description: 'Мастер взлома и компьютерных систем',
  ),
  Character(
    id: 'scout',
    name: 'Разведчик',
    role: 'Скаут',
    description: 'Быстрый и скрытный исследователь',
  ),
];

// Модель данных для настроек партии
class PartySetup {
  final String slotId;
  final String? companyId;
  final int playerCount;
  final GameDifficulty difficulty;
  final List<String?> selectedCharacterIds; // ID выбранных персонажей для каждого игрока

  PartySetup({
    required this.slotId,
    this.companyId,
    this.playerCount = 1,
    this.difficulty = GameDifficulty.standard,
    List<String?>? selectedCharacterIds,
  }) : selectedCharacterIds = selectedCharacterIds ?? List.filled(4, null);

  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'companyId': companyId,
      'playerCount': playerCount,
      'difficulty': difficulty.index,
      'selectedCharacterIds': selectedCharacterIds,
    };
  }

  factory PartySetup.fromJson(Map<String, dynamic> json) {
    return PartySetup(
      slotId: json['slotId'],
      companyId: json['companyId'],
      playerCount: json['playerCount'] ?? 1,
      difficulty: GameDifficulty.values[json['difficulty'] ?? 1],
      selectedCharacterIds: List<String?>.from(json['selectedCharacterIds'] ?? List.filled(4, null)),
    );
  }
}

class PartySetupScreen extends StatefulWidget {
  final int slotId;
  final String slotName;

  const PartySetupScreen({
    super.key,
    required this.slotId,
    required this.slotName,
  });

  @override
  State<PartySetupScreen> createState() => _PartySetupScreenState();
}

class _PartySetupScreenState extends State<PartySetupScreen> {
  GameCompany? _selectedCompany;
  int _playerCount = 1;
  GameDifficulty _difficulty = GameDifficulty.standard;
  final List<String?> _selectedCharacters = List.filled(4, null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка партии'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Center(
                  child: Text(
                    'Слот ${widget.slotId}: ${widget.slotName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Выбор компании
                _buildSectionTitle('1. Выберите компанию'),
                const SizedBox(height: 12),
                _buildCompanySelection(),
                const SizedBox(height: 24),

                // 2. Количество игроков
                _buildSectionTitle('2. Количество игроков'),
                const SizedBox(height: 12),
                _buildPlayerCountSelection(),
                const SizedBox(height: 24),

                // 3. Сложность
                _buildSectionTitle('3. Выберите сложность'),
                const SizedBox(height: 12),
                _buildDifficultySelection(),
                const SizedBox(height: 24),

                // 4. Выбор персонажей
                _buildSectionTitle('4. Выберите персонажей'),
                const SizedBox(height: 12),
                _buildCharacterSelection(),
                const SizedBox(height: 32),

                // Кнопка начала игры
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _validateAndStartGame,
                    child: const Text(
                      'НАЧАТЬ ИГРУ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildCompanySelection() {
    return Column(
      children: availableCompanies.map((company) {
        final isSelected = _selectedCompany?.id == company.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCompany = company;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade800, Colors.grey.shade900],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.purpleAccent : Colors.white24,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.purpleAccent : Colors.white54,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          company.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerCountSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        final count = index + 1;
        final isSelected = _playerCount == count;
        return GestureDetector(
          onTap: () {
            setState(() {
              _playerCount = count;
              // Очищаем лишних персонажей при уменьшении количества игроков
              for (int i = count; i < 4; i++) {
                _selectedCharacters[i] = null;
              }
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade800, Colors.grey.shade900],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.purpleAccent : Colors.white24,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDifficultySelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: GameDifficulty.values.map((difficulty) {
        final isSelected = _difficulty == difficulty;
        return GestureDetector(
          onTap: () {
            setState(() {
              _difficulty = difficulty;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [difficulty.color.withOpacity(0.7), difficulty.color],
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade800, Colors.grey.shade900],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? difficulty.color : Colors.white24,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  difficulty.icon,
                  color: isSelected ? Colors.white : difficulty.color,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  difficulty.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCharacterSelection() {
    return Column(
      children: List.generate(_playerCount, (playerIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Игрок ${playerIndex + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCharacters[playerIndex],
                decoration: InputDecoration(
                  hintText: 'Выберите персонажа',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                dropdownColor: Colors.grey.shade800,
                style: const TextStyle(color: Colors.white),
                items: availableCharacters.map((character) {
                  return DropdownMenuItem(
                    value: character.id,
                    child: Text('${character.name} (${character.role})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCharacters[playerIndex] = value;
                  });
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  void _validateAndStartGame() {
    // Проверка выбора компании
    if (_selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите компанию'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Проверка выбора персонажей для всех игроков
    for (int i = 0; i < _playerCount; i++) {
      if (_selectedCharacters[i] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пожалуйста, выберите персонажа для игрока ${i + 1}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Сохранение настроек партии
    _savePartySetup();

    // Создаём модель игры
    final gameModel = GameModel(
      slotId: widget.slotId.toString(),
      companyId: _selectedCompany!.id,
      playerCount: _playerCount,
      difficulty: _difficulty.index,
      selectedCharacterIds: _selectedCharacters.whereType<String>().toList(),
    );

    // Переход на экран игрового поля (начнётся с предыстории)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => GameBoardScreen(gameModel: gameModel)),
      (route) => false, // Удаляем все предыдущие экраны из стека
    );
  }

  // Сохранение настроек партии с обработкой ошибок
  Future<void> _savePartySetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Создаём объект настроек партии
      final partySetup = PartySetup(
        slotId: widget.slotId.toString(),
        companyId: _selectedCompany!.id,
        playerCount: _playerCount,
        difficulty: _difficulty,
        selectedCharacterIds: List.from(_selectedCharacters),
      );

      // Сохраняем настройки партии
      await prefs.setString(
        'party_setup_${widget.slotId}',
        json.encode(partySetup.toJson()),
      );

      // Обновляем информацию о слоте
      final slotsJson = prefs.getString('game_slots');
      if (slotsJson != null) {
        final List<dynamic> decoded = json.decode(slotsJson);
        final List<GameSlot> slots = decoded.map((slot) => GameSlot.fromJson(slot)).toList();
        
        // Находим нужный слот и обновляем его
        for (int i = 0; i < slots.length; i++) {
          if (slots[i].id == widget.slotId) {
            // Можно добавить дополнительную информацию в saveName
            slots[i].saveName = '${widget.slotName} (${_selectedCompany!.name})';
            break;
          }
        }
        
        await prefs.setString('game_slots', json.encode(slots.map((s) => s.toJson()).toList()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения настроек: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
