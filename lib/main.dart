// main.dart - Главный файл приложения
// Это точка входа, с которой начинается запуск приложения
// Здесь мы указываем, какой экран показывать при старте (Главное меню)

import 'package:flutter/material.dart'; // Подключаем библиотеку Flutter для создания интерфейса
import 'screens/main_menu_screen.dart'; // Подключаем наш экран главного меню

// Функция main() - это начало работы любой программы на Dart/Flutter
void main() {
  // runApp() - запускает наше Flutter приложение
  runApp(const DistortionApp());
}

// DistortionApp - это наше основное приложение
// Мы используем const, потому что приложение не меняется во время работы
class DistortionApp extends StatelessWidget {
  const DistortionApp({super.key});

  // Метод build() описывает, что будет показано на экране
  @override
  Widget build(BuildContext context) {
    // MaterialApp - это виджет, который предоставляет готовые элементы дизайна в стиле Material Design
    return MaterialApp(
      // title - название приложения, отображается в заголовке окна или вкладки браузера
      title: 'Искажение',
      
      // theme - настройки внешнего вида всего приложения
      theme: ThemeData(
        // colorScheme - цветовая схема приложения
        // Используем тёмную тему для атмосферы игры
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Основной цвет (фиолетовый - цвет искажения)
          brightness: Brightness.dark,   // Тёмная тема
        ),
        // useMaterial3 - использовать современный дизайн Material 3
        useMaterial3: true,
      ),
      
      // home - главный экран, который показывается при запуске
      // Мы указываем MainMenuScreen - наше главное меню
      home: const MainMenuScreen(),
    );
  }
}
