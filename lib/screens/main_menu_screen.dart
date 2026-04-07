// main_menu_screen.dart - Экран главного меню
// Это первый экран, который видит игрок при запуске приложения
// Здесь расположены кнопки: "Играть", "Персонажи", "Настройки"

import 'package:flutter/material.dart'; // Подключаем библиотеку Flutter для создания интерфейса
import '../widgets/menu_button.dart'; // Подключаем наш виджет красивой кнопки
import 'slot_selection_screen.dart'; // Подключаем экран выбора слотов
// В будущем здесь будут импорты других экранов:
// import 'characters_screen.dart';
// import 'settings_screen.dart';

// MainMenuScreen - это виджет главного меню
// Используем StatefulWidget, потому что меню может меняться (например, показывать разные состояния)
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

// _MainMenuScreenState - внутреннее состояние экрана меню
// Здесь описывается, что именно будет показано на экране
class _MainMenuScreenState extends State<MainMenuScreen> {
  
  @override
  Widget build(BuildContext context) {
    // Scaffold - это "каркас" экрана с базовыми элементами Material Design
    // Он предоставляет: appBar, body, floatingActionButton и другие стандартные элементы
    return Scaffold(
      // body - основное содержимое экрана
      body: Container(
        // Растягиваем контейнер на весь экран
        width: double.infinity,
        height: double.infinity,
        
        // Декорированный контейнер с фоном
        decoration: BoxDecoration(
          // Градиентный фон для атмосферы игры
          gradient: LinearGradient(
            begin: Alignment.topLeft,    // Градиент начинается сверху слева
            end: Alignment.bottomRight,  // Заканчивается снизу справа
            colors: [
              Colors.deepPurple.shade900,  // Тёмно-фиолетовый
              Colors.black,                // Чёрный
              Colors.deepPurple.shade800,  // Фиолетовый
            ],
          ),
        ),
        
        // SafeArea - защищает контент от выреза экрана (чёлка, динамический остров и т.д.)
        child: SafeArea(
          // Column - вертикальная колонка для расположения элементов друг под другом
          child: Column(
            children: [
              // Расширяемое пространство сверху
              const Expanded(flex: 2, child: SizedBox()),
              
              // Заголовок игры
              _buildTitle(),
              
              // Расширяемое пространство
              const Expanded(flex: 1, child: SizedBox()),
              
              // Блок с кнопками меню
              _buildMenuButtons(),
              
              // Расширяемое пространство снизу
              const Expanded(flex: 1, child: SizedBox()),
              
              // Версия игры внизу экрана
              _buildVersionText(),
            ],
          ),
        ),
      ),
    );
  }

  // Метод для создания заголовка игры
  // Выносим в отдельную функцию для читаемости кода
  Widget _buildTitle() {
    return Column(
      children: [
        // Название игры
        Text(
          'ИСКАЖЕНИЕ',
          style: TextStyle(
            fontSize: 64,                    // Крупный размер шрифта
            fontWeight: FontWeight.w900,     // Очень жирный шрифт
            letterSpacing: 8,                // Расстояние между буквами
            foreground: Paint()              // Эффект свечения через градиент
              ..shader = LinearGradient(
                colors: [
                  Colors.purple.shade300,    // Светло-фиолетовый
                  Colors.white,              // Белый
                  Colors.purple.shade400,    // Фиолетовый
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 300, 80)),
            shadows: [
              // Тень для объёма
              Shadow(
                blurRadius: 20,
                color: Colors.purple.withOpacity(0.8),
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        
        // Подзаголовок
        const SizedBox(height: 8),
        Text(
          'Настольная игра',
          style: TextStyle(
            fontSize: 20,
            letterSpacing: 4,
            color: Colors.white70, // Полупрозрачный белый
          ),
        ),
      ],
    );
  }

  // Метод для создания блока с кнопками меню
  Widget _buildMenuButtons() {
    // Container ограничивает максимальную ширину кнопок
    return Container(
      constraints: const BoxConstraints(maxWidth: 400), // Максимальная ширина 400 пикселей
      padding: const EdgeInsets.symmetric(horizontal: 24), // Отступы по бокам
      
      // Column для вертикального расположения кнопок
      child: Column(
        children: [
          // Кнопка "Играть" - основная кнопка, начинает новую партию
          MenuButton(
            text: 'ИГРАТЬ',
            isPrimary: true, // Делаем кнопку выделенной
            icon: Icons.play_arrow, // Иконка стрелки воспроизведения
            onPressed: () {
              // При нажатии переходим на экран настройки партии
              // В будущем здесь будет навигация на SetupScreen
              _navigateToSetup();
            },
          ),
          
          // Кнопка "Персонажи" - просмотр и управление персонажами
          MenuButton(
            text: 'ПЕРСОНАЖИ',
            icon: Icons.people, // Иконка людей
            onPressed: () {
              // При нажатии переходим на экран персонажей
              // В будущем здесь будет навигация на CharactersScreen
              _navigateToCharacters();
            },
          ),
          
          // Кнопка "Настройки" - настройки приложения
          MenuButton(
            text: 'НАСТРОЙКИ',
            icon: Icons.settings, // Иконка шестерёнки
            onPressed: () {
              // При нажатии переходим на экран настроек
              // В будущем здесь будет навигация на SettingsScreen
              _navigateToSettings();
            },
          ),
        ],
      ),
    );
  }

  // Метод для отображения версии игры внизу экрана
  Widget _buildVersionText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // Отступ снизу
      child: Text(
        'Версия 0.1.0',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white54, // Полупрозрачный белый
          letterSpacing: 2,
        ),
      ),
    );
  }

  // Функция навигации на экран настройки партии
  void _navigateToSetup() {
    // Переходим на экран выбора слотов
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SlotSelectionScreen()),
    );
  }

  // Функция навигации на экран персонажей
  void _navigateToCharacters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Экран персонажей в разработке!'),
        backgroundColor: Colors.deepPurple,
        duration: Duration(seconds: 2),
      ),
    );
    
    // В будущем:
    // Navigator.pushNamed(context, '/characters');
  }

  // Функция навигации на экран настроек
  void _navigateToSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Экран настроек в разработке!'),
        backgroundColor: Colors.deepPurple,
        duration: Duration(seconds: 2),
      ),
    );
    
    // В будущем:
    // Navigator.pushNamed(context, '/settings');
  }
}
