import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;
int num;
var user;

class ChatScreen extends StatefulWidget {
  static String screenKey = 'Chat_Screen_Key';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String textMessage;
  TextEditingController _controller = new TextEditingController();
  @override
  void initState() {
    super.initState();
    initializeFireBase();
    messageStream();
  }

  void initializeFireBase() async {
    await Firebase.initializeApp();
    print('Done');
    getCurrentUsers();
  }

  void getCurrentUsers() async {
    user = _auth.currentUser;
    try {
      if (user != null) {
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messageStream() async {
    await for (var snapShot in _firestore
        .collection("Messeges")
        .orderBy('order number', descending: true)
        .snapshots()) {
      print(snapShot.docs);
      if (snapShot.docs.isEmpty) {
        num = 0;
        return;
      }
      var message = snapShot.docs[0];
      num = message.data()['order number'];
      print(num);
      print('space');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.of(context).pop();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamMessageBuilder(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.clear();
                      if (num == null) {
                        num = 0;
                      }
                      _firestore.collection('Messeges').add(
                        {
                          'sender': user.email,
                          'message': textMessage,
                          'order number': ++num
                        },
                      );
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamMessageBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("Messeges")
          .orderBy('order number', descending: false)
          .snapshots(),
      builder: (context, snapShot) {
        print('Iam here');
        if (!snapShot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        List<MessageBubbleWidget> messageTextWidgets = [];
        final messages = snapShot.data.docs.reversed;
        for (var message in messages) {
          print(message.data());
          final String sender = message.data()['sender'];
          final String text = message.data()['message'];
          messageTextWidgets.add(MessageBubbleWidget(
            text: text,
            sender: sender,
            isCurrentUser: user.email == sender,
          ));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageTextWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubbleWidget extends StatelessWidget {
  const MessageBubbleWidget({
    @required this.text,
    @required this.sender,
    @required this.isCurrentUser,
  });

  final String text;
  final String sender;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Material(
            elevation: 10,
            color: isCurrentUser ? Colors.lightBlueAccent : Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
              topLeft: isCurrentUser ? Radius.circular(25) : Radius.circular(0),
              topRight:
                  isCurrentUser ? Radius.circular(0) : Radius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
