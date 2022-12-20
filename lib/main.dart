import 'dart:async';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  IO.Socket socket = IO.io('http://localhost:3000?platformToken=r43xv43vi');
  TextEditingController textController = TextEditingController(text: '');
  List messages = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    socket.onConnect((_) {
      print('connected');
    });
    loadData();
  }

  loadData() {
    socket.on('messages_list', (data) {
      messages = data;
      setState(() {});
      Timer(const Duration(milliseconds: 1), () {
        _controller.jumpTo(_controller.position.maxScrollExtent + 100);
      });
    });
  }

  sendMessage(message) {
    socket.emit(
      "message",
      {
        "id": socket.id,
        "message": message, // Message to be sent
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chat Test',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
        ),
        home: MaterialApp(
          home: Scaffold(
            body: Column(children: [
              Container(
                width: 500,
                height: 600,
                color: Colors.amber[200],
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.vertical,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${messages[index]['id']}:'),
                      subtitle: Text(messages[index]['message']),
                    );
                  },
                ),
              ),
              Container(
                width: 500,
                height: 100,
                color: Colors.grey[200],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          maxLength: 50,
                          controller: textController,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            sendMessage(textController.text);
                            textController.clear();
                          },
                          child: const Text('send message'))
                    ]),
              )
            ]),
          ),
        ));
  }
}
