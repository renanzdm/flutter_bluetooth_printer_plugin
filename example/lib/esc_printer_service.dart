import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:image/image.dart' as img;


class ESCPrinterService {
  final Uint8List receipt;
  List<int>? _bytes;
  List<int>? get bytes => _bytes;
  PaperSize? _paperSize;
  CapabilityProfile? _profile;

  ESCPrinterService({required this.receipt});

  Future<List<int>> getBytes(
      {PaperSize paperSize = PaperSize.mm80,
      CapabilityProfile? profile}) async {
    List<int> bytes = [];
    _profile = profile ?? (await CapabilityProfile.load());
    _paperSize = paperSize;
    assert(_paperSize != null);
    assert(_profile != null);
    Generator generator = Generator(_paperSize!, _profile!);
    final img.Image? _resize =
        img.copyResize(img.decodeImage(receipt)!, width: _paperSize!.width);
    if (_resize != null) {
      bytes += generator.image(_resize);
    }
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}