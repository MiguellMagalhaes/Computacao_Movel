// lib/services/openweather_service.dart

// Importa a biblioteca dart:convert para converter dados JSON,
// e a biblioteca http para efectuar requisições HTTP.
import 'dart:convert';
import 'package:http/http.dart' as http;

// Classe que fornece métodos para interagir com a API OpenWeather.
class OpenWeatherService {
  // Chave de API para autenticação junto da OpenWeather.
  static const String _apiKey = '5edc9f545563c6bea65447baff1c05f8';

  /// Retorna dados básicos de clima para a [cidade] fornecida (e.g., 'Lisboa', 'Porto', 'Madrid').
  /// Caso ocorra algum erro (rede, statusCode não 200, etc.), retorna null.
  static Future<Map<String, dynamic>?> fetchWeather(String cidade) async {
    try {
      // Constrói a URL para chamada à API, incluindo a chave e parâmetros como 'units' e 'lang'.
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cidade&appid=$_apiKey&units=metric&lang=pt',
      );
      // Efectua a requisição GET.
      final response = await http.get(url);

      // Verifica se a resposta teve sucesso (código 200).
      if (response.statusCode == 200) {
        // Converte o corpo da resposta de JSON para Map<String, dynamic> e retorna-o.
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Caso o statusCode não seja 200, algo correu mal e devolvemos null.
        return null;
      }
    } catch (e) {
      // Em caso de erro (por exemplo, rede) devolve null.
      return null;
    }
  }
}

// Trabalho realizado por:
// -> Miguel Magalhães;
// -> Nº:2021103166;
// -> Unidade Curricular de Computação Móvel;
// -> Licenciatura em Engenharia informática;
// -> ISPGAYA
