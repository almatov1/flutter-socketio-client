import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

void main() async {
  runApp(MaterialApp(
      title: 'WebSocket Test',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IO.Socket socket;
  TextEditingController loginController = TextEditingController(text: '');
  TextEditingController ipController = TextEditingController(text: '');
  bool isLoading = false;
  bool connected = false;
  List users = [];

  loadingChange() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  connectionResultDialog(BuildContext context, String result) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(result),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // sendMessage(message) {
  //   socket.emit(
  //     "message",
  //     {
  //       "id": socket.id,
  //       "message": message, // Message to be sent
  //       "timestamp": DateTime.now().millisecondsSinceEpoch,
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 500,
        height: 300,
        color: Colors.amber[200],
        child: connected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('connected to server'),
                  Text('users count: ${users.length} / 5'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('users names: '),
                      if (users.isNotEmpty)
                        ...users.map((e) => Text('${e['name']} ')),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        connectionResultDialog(
                            context, 'Successfully disconnected');
                        connected = false;
                        socket.disconnect();
                        setState(() {});
                      },
                      child: const Text('disconnect'))
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'IP'),
                      maxLength: 50,
                      controller: ipController,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      decoration: const InputDecoration(hintText: 'Login'),
                      maxLength: 50,
                      controller: loginController,
                    ),
                  ),
                  if (isLoading) const CircularProgressIndicator(),
                  ElevatedButton(
                      onPressed: () {
                        if (ipController.text.isNotEmpty &&
                            loginController.text.isNotEmpty) {
                          loadingChange();
                          socket = IO.io(
                              'http://${ipController.text}:3000?serverToken=r43xv43vi&userName=${loginController.text}',
                              OptionBuilder()
                                  .enableForceNewConnection()
                                  .disableAutoConnect()
                                  .build());

                          socket.connect();

                          socket.onConnectError((data) {
                            connectionResultDialog(context, 'Invalid Address');
                            socket.disconnect();
                            loadingChange();
                          });

                          socket.on('connectResult', (data) {
                            if (data == true) {
                              connectionResultDialog(
                                  context, 'Successfully connection');
                              connected = true;
                            } else {
                              connectionResultDialog(context, data);
                            }

                            loadingChange();
                          });

                          socket.on('kicked', (data) {
                            if (data == 'enabled another session') {
                              connectionResultDialog(context, data);
                              setState(() {
                                connected = false;
                              });
                            }
                          });

                          socket.on('usersList', (data) {
                            setState(() {
                              users = data;
                            });
                          });

                          ipController.clear();
                          loginController.clear();
                        }
                      },
                      child: const Text('connect'))
                ],
              ),
      ),
    );
  }
}
