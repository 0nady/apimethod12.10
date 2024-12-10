// Этот класс описывает один пост (запись) со стены ВК
class Post {
  final int id; // Уникальный идентификатор записи
  final String text; // Текст поста
  final int date; // Дата публикации поста

  // Конструктор для создания объекта записи
  Post({
    required this.id, //  указать ID записи
    required this.text, // указать текст записи
    required this.date, // указать дату публикации
  });
}
