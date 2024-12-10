import 'dart:convert'; // Библиотека для работы с JSON-данными
import 'package:http/http.dart' as http; // Библиотека для выполнения HTTP-запросов
import '../dto/wall_response.dart'; // Импортируем структуру данных для работы с ответами от API
import '../token.dart'; // Импортируем файл с ключом доступа (serviceKey) для VK API

// Класс для работы с API ВК
class ApiService {
  // Ключ доступа для работы с VK API (в token.dart)
  final String _serviceKey = serviceKey;

  // URL для получения записей со стены (wall.get)
  final String _wallGetUrl = 'https://api.vk.com/method/wall.get';

  // URL для разрешения короткого имени (utils.resolveScreenName)
  final String _resolveScreenNameUrl = 'https://api.vk.com/method/utils.resolveScreenName';

  // Метод для извлечения ID группы из URL
  // Затем вызывает другой метод (`resolveGroupId`) для преобразования короткого имени в ID
  Future<int> resolveGroupIdFromUrl(String url) async {
    // Преобразуем текст ссылки в объект Uri, чтобы проще работать с её частями
    final uri = Uri.parse(url);

    // Получаем последний сегмент пути из ссылки
    final screenName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';

    // Если в ссылке отсутствует короткое имя, выбрасываем ошибку
    if (screenName.isEmpty) {
      throw Exception('Неверная ссылка'); // Сообщение об ошибке
    }

    // Возвращаем ID группы, преобразовав короткое имя
    return await resolveGroupId(screenName);
  }

  // Метод для получения ID группы по её короткому имени
  // Использует метод VK API `utils.resolveScreenName`
  Future<int> resolveGroupId(String screenName) async {
    // Формируем URL для запроса к API с указанием короткого имени и ключа доступа
    final response = await http.get(Uri.parse(
        '$_resolveScreenNameUrl?screen_name=$screenName&access_token=$_serviceKey&v=5.131'));

    // Если запрос успешен (статус код 200):
    if (response.statusCode == 200) {
      // Расшифровываем JSON-ответ от API
      final jsonResponse = json.decode(response.body);

      // Если ответ содержит данные о группе:
      if (jsonResponse['response'] != null && jsonResponse['response']['type'] == 'group') {
        // Возвращаем ID группы с минусом (требование VK API)
        return -jsonResponse['response']['object_id'];
      } else {
        // Если тип не группа, выбрасываем ошибку
        throw Exception('Короткий адрес не принадлежит сообществу');
      }
    } else {
      // Если запрос не удался, выбрасываем ошибку
      throw Exception('Не удалось разрешить короткий адрес');
    }
  }

  // Метод для получения названия группы по её ID
  Future<String> getGroupName(int groupId) async {
    // Формируем URL запроса к API VK
    final response = await http.get(Uri.parse(
        'https://api.vk.com/method/groups.getById?group_id=${groupId.abs()}&access_token=$_serviceKey&v=5.131'));

    // Проверяем, что сервер вернул успешный ответ (HTTP статус 200)
    if (response.statusCode == 200) {
      // Декодируем ответ из формата JSON в структуру данных Dart
      final jsonResponse = json.decode(response.body);
      // Проверяем, есть ли в ответе поле "response" и что оно не пустое
      if (jsonResponse['response'] != null && jsonResponse['response'].isNotEmpty) {
        // Возвращаем название группы из ответа
        return jsonResponse['response'][0]['name'];
      } else {
        // Если поле "response" отсутствует или пустое, выбрасываем ошибку
        throw Exception('Не удалось получить информацию о группе');
      }
    } else {
      // Если сервер вернул ошибку (статус не 200), выбрасываем исключение
      throw Exception('Ошибка при запросе названия группы');
    }
  }

  // Метод для получения записей со стены по ID пользователя или сообщества
  // Использует метод VK API `wall.get`
  Future<WallResponseDto> fetchWallPosts({required int ownerId, int count = 20}) async {
    // Формируем URL для запроса к API с указанием ID стены, количества записей и ключа доступа
    final response = await http.get(Uri.parse(
        '$_wallGetUrl?owner_id=$ownerId&count=$count&access_token=$_serviceKey&v=5.131'));

    // Если запрос успешен (статус код 200):
    if (response.statusCode == 200) {
      // Расшифровываем JSON-ответ от API
      final jsonResponse = json.decode(response.body);

      // Преобразуем JSON в объект WallResponseDto (специальный формат данных)
      return WallResponseDto.fromJson(jsonResponse['response']);
    } else {
      // Если запрос не удался, выбрасываем ошибку
      throw Exception('Не удалось загрузить записи');
    }
  }
}
