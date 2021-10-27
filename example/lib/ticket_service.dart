import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:image/image.dart' as img;

class ESCPrinterService {
  final Uint8List ticket;
  late PaperSize _paperSize;
  late CapabilityProfile _profile;

  ESCPrinterService({required this.ticket});

  Future<List<int>> getBytes(
      {PaperSize paperSize = PaperSize.mm80, CapabilityProfile? profile}) async {
    List<int> bytes = [];
    _profile = profile ?? (await CapabilityProfile.load());
    _paperSize = paperSize;
    Generator generator = Generator(_paperSize, _profile);
    img.Image? decodeImage = img.decodeImage(ticket);
    if(decodeImage != null){
      final img.Image _resize =
      img.copyResize(decodeImage, width: _paperSize.width);
      bytes += generator.image(_resize);
    }
    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }

  Future<List<int>> testTicket()async {
  
  // Using default profile
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  bytes += generator.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ');
      
  bytes += generator.text('Special 2: blåbærgrød',
    );

  bytes += generator.text('Bold text', styles: PosStyles(bold: true));
  bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
  bytes += generator.text('Underlined text',
      styles: PosStyles(underline: true), linesAfter: 1);
  bytes += generator.text('Align left', styles: PosStyles(align: PosAlign.left));
  bytes += generator.text('Align center', styles: PosStyles(align: PosAlign.center));
  bytes += generator.text('Align right',
      styles: PosStyles(align: PosAlign.right), linesAfter: 1);

  bytes += generator.text('Text size 200%',
      styles: PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  bytes += generator.feed(2);
  bytes += generator.cut();
  return bytes;
}
}