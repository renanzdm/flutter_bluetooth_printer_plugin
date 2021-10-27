

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bluetooth_printer_example/resume_ticket.dart';
import 'package:webcontent_converter/webcontent_converter.dart';

import 'esc_printer_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<BluetoothDevice> _devices = [];
  final BluetoothPrinter _printer = BluetoothPrinter();

  @override
  void initState() {
    super.initState();
    _printer.scanResults.listen((event) {
      print(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.search),
          onPressed: () async {
          var per =  await _printer.isEnabled();
          print(per);
            await _printer.startScan();
          },
        ),
        body: Center(
          child: StreamBuilder<List<BluetoothDevice>>(
            stream: _printer.scanResults,
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (_, index) => ListTile(
                  title: Text(snapshot.data?[index].name ?? ''),
                  onTap: () async {

                    var device = snapshot.data![index];
                    await device.connect();
                    if (device.isConnected) {
                         final content = ResumeTicket.resumeTicket();
                  var bytes = await WebcontentConverter.contentToImage(content: content);
                      var service = ESCPrinterService(receipt:bytes);
                      var data =await service.getBytes(paperSize: PaperSize.mm80);
                      device.printBytes(bytes: Uint8List.fromList(data));
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


