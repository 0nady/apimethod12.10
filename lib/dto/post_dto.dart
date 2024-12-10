// класс представляет пост, полученный в формате, который возвращает VK API
class PostDto {
  final int id; // Уникальный идентификатор записи
  final String text; // Текст поста
  final int date; // Дата публикации поста

  // Конструктор для создания объекта записи
  PostDto({
    required this.id, // Указываем ID записи
    required this.text, // Указываем текст записи
    required this.date, // Указываем дату публикации
  });

  // Фабричный метод для создания объекта из JSON
  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'], // Берем ID из поля "id"
      text: json['text'] ?? '', // Берем текст из поля "text" или пустую строку, если текста нет
      date: json['date'], // Берем дату из поля "date"
    );
  }
}
