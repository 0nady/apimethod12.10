// Подключение необходимых библиотек
import 'package:flutter/material.dart'; // Для построения интерфейса приложения
import 'domain/api_service.dart'; // Сервис для работы с VK API
import 'dto/wall_response.dart'; // Модель данных для обработки ответов от VK API

// Главная функция, с которой начинается выполнение программы
void main() {
  runApp(MyApp()); // Запускает приложение с главным виджетом MyApp
}

// Основной виджет приложения
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Построение структуры приложения
    return MaterialApp(
      title: 'VK Wall Posts', // Заголовок приложения
      home: WallScreen(), // Указываем, что стартовым экраном будет WallScreen
    );
  }
}

// Экран для работы с записями стены VK
class WallScreen extends StatefulWidget {
  @override
  _WallScreenState createState() => _WallScreenState(); // Создаём состояние экрана
}

// Состояние экрана WallScreen
class _WallScreenState extends State<WallScreen> {
  // Контроллер для отслеживания текста в поле ввода
  final TextEditingController _controller = TextEditingController();

  // Переменная для хранения результата загрузки записей
  Future<WallResponseDto>? _futurePosts;

  // Объект сервиса для работы с VK API
  final ApiService _apiService = ApiService();

  String? _groupName; // Название группы
  int? _totalPosts;   // Общее количество записей

  // Метод для загрузки записей со стены сообщества
  void _fetchWallPosts(String url) async {
    try {
      final groupId = await _apiService.resolveGroupIdFromUrl(url); // Получаем ID группы из ссылки
      final groupName = await _apiService.getGroupName(groupId); // Получаем название группы.
      final wallResponse = await _apiService.fetchWallPosts(ownerId: groupId); // Загружаем записи

      // Обновляем состояние экрана с новой информацией
      setState(() {
        _groupName = groupName; // Сохраняем название группы
        _totalPosts = wallResponse.count; // Сохраняем количество записей
        _futurePosts = Future.value(wallResponse); // Сохраняем записи
      });
    } catch (e) {

      // Если произошла ошибка, сбрасываем значения и отображаем ошибку
      setState(() {
        _groupName = null; // Сбрасываем название группы при ошибке
        _totalPosts = null; // Сбрасываем количество записей при ошибке
        _futurePosts = Future.error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VK Wall Posts'), // Заголовок верхней панели
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Отступы по краям
        child: Column(
          children: [
            TextField(
              controller: _controller, // Подключаем контроллер для ввода текста
              decoration: InputDecoration(
                hintText: 'Введите ссылку на сообщество',
                border: OutlineInputBorder(), // Стиль рамки
              ),
            ),
            SizedBox(height: 10), // Расстояние между элементами
            ElevatedButton(
              onPressed: () => _fetchWallPosts(_controller.text), // Обработчик нажатия кнопки
              child: Text('Получить записи'), // Текст кнопки
            ),
            SizedBox(height: 20), // Расстояние между элементами

            // Если название группы и количество записей есть, отображаем их
            if (_groupName != null && _totalPosts != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по левому краю
                children: [
                  Text(
                    'Название группы: $_groupName', // Отображение названия группы
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Количество постов: $_totalPosts', // Отображение количества записей
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20), // Отступ перед списком записей
                ],
              ),
            Expanded(
              child: FutureBuilder<WallResponseDto>(
                future: _futurePosts, // Ожидание загрузки записей
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Индикатор загрузки
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}')); // Сообщение об ошибке
                  } else if (snapshot.hasData) {
                    final posts = snapshot.data!.items; // Получаем список записей
                    return ListView.builder(
                      itemCount: posts.length, // Количество элементов в списке
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(posts[index].text), // Текст записи
                          subtitle: Text('ID: ${posts[index].id}'), // ID записи
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('Введите ссылку для начала.')); // Сообщение для пустого экрана
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
