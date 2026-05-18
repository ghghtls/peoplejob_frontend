// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadExcelOnWeb(List<int> bytes, String fileName) async {
  await downloadBytesOnWeb(
    bytes,
    fileName,
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
}

Future<void> downloadBytesOnWeb(
  List<int> bytes,
  String fileName, [
  String mimeType = 'application/octet-stream',
]) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
