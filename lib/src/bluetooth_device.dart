import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class BluetoothDevice {
  final String name;
  final String address;
  final int type;

  const BluetoothDevice({
    required this.name,
    required this.address,
    required this.type,
  });

  bool get isConnected {
    final connectedDevices = BluetoothPrinter.instance.connectedDevice;
    return connectedDevices?.address == address;
  }

  Future<bool> connect() async {
    return BluetoothPrinter.instance.connect(this);
  }

  Future<void> disconnect() async {
    return BluetoothPrinter.instance.disconnect();
  }
}
