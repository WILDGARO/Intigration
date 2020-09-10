import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient('192.168.137.1', '');
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Screen1(),

        ),
      ),
    );
  }
}


class Screen1 extends StatefulWidget {
  
  
  
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  String _message = "";
  connectionMqtt()async{

	//fixต้องใส่   เช็คการ connection
    client.port = 1883;
    client.onConnected = onConnected;
    try {
      await client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('EXAMPLE::Mosquitto client connected');
    } else {
      print(
          'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus.state}');
      client.disconnect();
    }
    final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    client.connectionMessage = connMess;


    //subscribe  ส่วนของการ connection หากต้องการ subscribe ให้ setstateตรงนี้  อย่าลืมนะ ใช้ stateful 
    const topic = 'cpe5camp/at2';
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {

      final MqttPublishMessage recMess = c[0].payload;
	//pt เป็นข้อความที่ได้รับมา หากจะรับและมาแสดงผล ให้ setstate ที่นี่
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          setState(() {
            _message = pt;
          });

      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
  }
   void onConnected(){
    print("......................connected...............");  
  }

  final pubTopic = 'cpe5camp/at2/sftohw';
  sendsftohw(){
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello World!');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
  }

  @override

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Distance \n$_message",
          style: TextStyle(
            fontSize: 40.0
          ),
        ),
        RaisedButton(
          onPressed: (){
             connectionMqtt();
            
          }
        ),
        FlatButton(
          onPressed: (){
            sendsftohw();
          }, 
          child: Container(
            alignment: Alignment.center,
            height: 200.0,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(100),
              )
            ),
            child: Text(
              "Send",
              style: TextStyle(
                fontSize: 50,
                color: Colors.yellow,
              ),
            ),
          )
          )
      ],
    );
  }
}