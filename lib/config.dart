class Config {
  static const bool itIsDBG =
      false; // Установите на true для тестового режима
  static void mprint(String s) { if (itIsDBG) print(s); }
  static const String baseUrl =
      'https://zavadovskayakurs.ru/api/v1'; // Замените на ваш реальный API URL
}
// http://95.165.146.92:3000/api
// 172.27.208.1