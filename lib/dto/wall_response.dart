import 'post_dto.dart'; // Подключаем класс PostDto

// класс описывает ответ от VK API на запрос записей со стены
class WallResponseDto {
  final int count; // Общее количество записей на стене
  final List<PostDto> items; // Список записей (каждая запись представлена объектом PostDto)

  // Конструктор для создания объекта ответа.
  WallResponseDto({
    required this.count, // Указываем общее количество записей
    required this.items, // Указываем список записей
  });


  factory WallResponseDto.fromJson(Map<String, dynamic> json) {
    // Берем массив записей из поля "items" в JSON
    var itemsList = json['items'] as List;

    // Преобразуем каждый элемент массива в объект PostDto
    List<PostDto> postsList = itemsList.map((i) => PostDto.fromJson(i)).toList();

    // Создаем объект WallResponseDto с количеством записей и списком постов
    return WallResponseDto(
      count: json['count'], // Берем количество записей из поля "count"
      items: postsList, // Указываем список постов
    );
  }
}
