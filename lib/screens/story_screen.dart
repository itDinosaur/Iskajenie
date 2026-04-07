// story_screen.dart - Экран предыстории
// Этот экран показывает вводную историю перед началом игры
// Для каждого сценария (компании) своя предыстория

import 'package:flutter/material.dart';
import '../models/game_model.dart';
import 'game/game_board_screen.dart';

// Экран предыстории для компании "Мрачный бункер"
class StoryScreen extends StatelessWidget {
  final GameModel gameModel;

  const StoryScreen({super.key, required this.gameModel});

  @override
  Widget build(BuildContext context) {
    // Определяем текст предыстории в зависимости от компании
    String storyTitle;
    String storyText;

    if (gameModel.companyId == 'bunker') {
      storyTitle = 'Мрачный бункер';
      storyText = '''Вы очнулись в темном и мрачном месте. 

Почему вы тут оказались? Что от вас требуется? 

Много вопросов, но ответы придется искать вам самим.

Вокруг царит тишина, нарушаемая лишь редким капанием воды где-то вдалеке. Воздух спёртый и пахнет ржавчиной. 

Ваши глаза постепенно привыкают к темноте, и вы начинаете различать очертания металлического прохода...''';
    } else if (gameModel.companyId == 'datacenter') {
      storyTitle = 'Случай в ЦОДе';
      storyText = '''Вы пришли в себя среди рядов серверных стоек.

Гудение вентиляторов заполняет всё пространство. 

Что произошло здесь? Почему нет других сотрудников?

На мониторах мигают странные сообщения, а некоторые серверы покрыты инеем, хотя должно быть жарко.

Впереди виден коридор, ведущий глубже в центр обработки данных...''';
    } else {
      storyTitle = 'Неизвестная история';
      storyText = 'История для этого сценария ещё не написана.';
    }

    return Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Заголовок истории
                const SizedBox(height: 40),
                Text(
                  storyTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Иконка для атмосферы
                Icon(
                  Icons.psychology,
                  size: 80,
                  color: Colors.purpleAccent.withOpacity(0.8),
                ),
                
                const SizedBox(height: 40),
                
                // Текст предыстории
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.purpleAccent.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        storyText,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6, // Межстрочный интервал
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Кнопка "Продолжить"
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Переходим на игровое поле
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameBoardScreen(gameModel: gameModel),
                        ),
                      );
                    },
                    child: const Text(
                      'ПРОДОЛЖИТЬ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
