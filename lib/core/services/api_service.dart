import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> fetchAddress(String cep) async {
    final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');
    if (response.data['erro'] == true) throw Exception('CEP inválido');
    return response.data;
  }

  Future<LatLng> getCoordinates(String address) async {
    final response = await _dio.get(
      'https://nominatim.openstreetmap.org/search',
      queryParameters: {
        'q': address,
        'format': 'json',
      },
    );

    final location = response.data[0];
    return LatLng(
      double.parse(location['lat']),
      double.parse(location['lon']),
    );
  }
}
