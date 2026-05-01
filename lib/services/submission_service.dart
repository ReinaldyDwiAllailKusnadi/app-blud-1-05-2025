import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

class SubmissionService {
  final DioClient _dioClient;

  SubmissionService(this._dioClient);

  Future<Response> getHistory() async {
    return await _dioClient.get('/history');
  }

  Future<Response> submitRequest(FormData formData) async {
    return await _dioClient.postMultipart('/submission', data: formData);
  }

  Future<Response> getLocations() async {
    return await _dioClient.get('/submission/locations');
  }
}
