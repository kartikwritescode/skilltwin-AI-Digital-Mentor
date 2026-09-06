import '../../../../core/models/resource.dart';
import 'dart:io';

abstract class LibraryRepository {
  Future<List<Resource>> getResources({String? query});
  Future<Resource> uploadPdf(File file, String title);
  Future<Resource> addLink(String url, String title);
  Future<Resource> createNote(String content, String title);
  Future<void> deleteResource(String id);
  Future<Resource> getResourceDetails(String id);
}
