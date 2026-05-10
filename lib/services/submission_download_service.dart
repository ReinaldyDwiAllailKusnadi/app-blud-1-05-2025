import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/network/dio_client.dart';

class SubmissionDownloadService {
  final DioClient _dioClient = DioClient();

  Future<File> downloadSubmissionAttachment({
    required int submissionId,
    required String type,
    required String filename,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/submission/$submissionId/download/$type',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final downloadFolder = Directory('${directory.path}/BLUD_Downloads');
      
      if (!await downloadFolder.exists()) {
        await downloadFolder.create(recursive: true);
      }

      final file = File('${downloadFolder.path}/$filename');
      await file.writeAsBytes(response.data);

      return file;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw 'Anda tidak memiliki akses ke lampiran ini.';
      } else if (e.response?.statusCode == 404) {
        throw 'Lampiran tidak ditemukan.';
      } else if (e.response?.statusCode == 401) {
        throw 'Sesi Anda berakhir. Silakan login kembali.';
      } else {
        throw 'Lampiran gagal diunduh.';
      }
    } catch (e) {
      throw 'Terjadi kesalahan saat mengunduh file.';
    }
  }
}
