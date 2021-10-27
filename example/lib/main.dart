

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bluetooth_printer_example/resume_ticket.dart';
import 'package:flutter_bluetooth_printer_example/ticket_service.dart';
import 'package:webcontent_converter/webcontent_converter.dart';


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
                       var data = await ESCPrinterService(ticket:bytes).getBytes();
                       if(Platform.isIOS){
                        final len = data.length;
                        List<List<int>> chunks = [];
                        for (var i = 0; i < len; i += 100) {
                          var end = (i + 100 < len) ? i + 100 : len;
                          chunks.add(data.sublist(i, end));
                        }
                        for (var i = 0; i < chunks.length; i++) {
                        device.printBytes(bytes:Uint8List.fromList(chunks[i]));
                        }
                       }else{
                       device.printBytes(bytes:Uint8List.fromList(data));
                       }
                      
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



