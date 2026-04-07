// menu_button.dart - Виджет кнопки для меню
// Это переиспользуемая кнопка, которую мы будем использовать в главном меню и других экранах
// Создание отдельного файла для кнопки позволяет легко менять её вид в одном месте

import 'package:flutter/material.dart'; // Подключаем библиотеку Flutter

// MenuButton - это виджет кнопки с красивым оформлением
// Мы используем StatefulWidget, потому что кнопка будет реагировать на нажатия
class MenuButton extends StatefulWidget {
  // text - текст, который будет отображаться на кнопке
  final String text;
  
  // onPressed - функция, которая выполнится при нажатии на кнопку
  // Знак вопроса (?) означает, что этот параметр необязательный
  final VoidCallback? onPressed;
  
  // icon - иконка слева от текста (необязательная)
  // Если не передать иконку, будет использоваться значок по умолчанию
  final IconData? icon;
  
  // isPrimary - является ли кнопка основной (выделенной)
  // Например, кнопка "Играть" может быть основной
  final bool isPrimary;

  // Конструктор класса MenuButton
  // required означает, что эти параметры обязательно нужно передать при создании кнопки
  const MenuButton({
    super.key,
    required this.text,      // Обязательно передаём текст
    this.onPressed,          // Необязательно: функция нажатия
    this.icon,               // Необязательно: иконка
    this.isPrimary = false,  // Необязательно: по умолчанию кнопка не основная
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

// _MenuButtonState - внутреннее состояние кнопки
// Здесь описывается, как кнопка ведёт себя при взаимодействии
class _MenuButtonState extends State<MenuButton> {
  // isHovered - отслеживаем, находится ли курсор над кнопкой
  // Нужно для эффекта при наведении
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Получаем цветовую схему из темы приложения
    final colorScheme = Theme.of(context).colorScheme;

    // MouseRegion - виджет, который отслеживает движение мыши
    // Нужен для эффекта при наведении курсора
    return MouseRegion(
      // Когда курсор входит в область кнопки
      onEnter: (_) => setState(() => isHovered = true),
      // Когда курсор покидает область кнопки
      onExit: (_) => setState(() => isHovered = false),
      
      // Container - контейнер для кнопки с отступами
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8), // Отступы сверху и снизу
        width: double.infinity, // Кнопка растягивается на всю доступную ширину
        
        // Декорированный контейнер с оформлением
        decoration: BoxDecoration(
          // Градиентный фон для красоты
          gradient: widget.isPrimary || isHovered
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,           // Основной цвет темы
                    colorScheme.primary.withOpacity(0.7), // Тот же цвет, но прозрачнее
                  ],
                )
              : null, // Если кнопка не основная и не наведение - без градиента
          
          // Цвет фона
          color: widget.isPrimary || isHovered
              ? null // Если есть градиент, цвет не нужен
              : colorScheme.surfaceContainerHighest, // Цвет обычной кнопки
          
          // Скруглённые углы
          borderRadius: BorderRadius.circular(16),
          
          // Тень для объёма
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          
          // Рамка вокруг кнопки
          border: Border.all(
            color: isHovered 
                ? colorScheme.onSurface 
                : colorScheme.outline,
            width: 1.5,
          ),
        ),
        
        // ClipRRect - обрезает содержимое по скруглённым углам
        child: Material(
          // Делаем фон прозрачным, чтобы было видно наш декор
          color: Colors.transparent,
          
          // InkWell - добавляет эффект волны при нажатии
          child: InkWell(
            onTap: widget.onPressed, // Вызываем функцию при нажатии
            borderRadius: BorderRadius.circular(16), // Скругление для эффекта волны
            
            // Содержимое кнопки
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,  // Отступы сверху и снизу
                horizontal: 24, // Отступы слева и справа
              ),
              child: Row(
                // Центрируем содержимое по вертикали
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Если есть иконка, показываем её слева
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 28,
                      color: widget.isPrimary || isHovered
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                    const SizedBox(width: 12), // Отступ между иконкой и текстом
                  ],
                  
                  // Текст кнопки
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isPrimary || isHovered
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
