import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

class EventService {
  final DioClient _dioClient;

  EventService(this._dioClient);

  Future<Response> getJadwal() async {
    return await _dioClient.get('/jadwal');
  }

  Future<Response> getBookingByLocation(String slug) async {
    return await _dioClient.get('/booking/$slug');
  }
}
