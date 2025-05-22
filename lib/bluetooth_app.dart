import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothConnection? connection;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  void _getBondedDevices() async {
    final bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connected to the device')));

      connection!.input!.listen((data) {
        print('Received: ${String.fromCharCodes(data)}');
      });

      connection!.output.add(Uint8List.fromList(utf8.encode("010C\r"))); // RPM
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot connect: $e")));
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: TextButton(onPressed: () {
        connection?.dispose();
      }, child: Text("Close connection")), title: Text('OBD Bluetooth')),
      body: ListView(
        children: devices.map((device) {
          return ListTile(
            title: Text(device.name ?? "Unknown"),
            subtitle: Text(device.address),
            onTap: () => _connectToDevice(device),
          );
        }).toList(),
      ),
    );
  }
}
