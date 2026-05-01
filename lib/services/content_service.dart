import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

class ContentService {
  final DioClient _dioClient;

  ContentService(this._dioClient);

  Future<Response> getHomeData() async {
    return await _dioClient.get('/home');
  }

  Future<Response> getAllWisata() async {
    return await _dioClient.get('/wisata');
  }

  Future<Response> getWisataDetail(String slug) async {
    return await _dioClient.get('/wisata/$slug');
  }
}
