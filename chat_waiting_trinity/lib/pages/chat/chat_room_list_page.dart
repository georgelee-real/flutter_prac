// import 'dart:html';

import 'package:chat_waiting_trinity/controllers/chat_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_profile_edit_page.dart';

// import 'chat_room_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import '../../widgets/chat/user_list.dart';
import '../../widgets/chat/guest_chat_list.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class ChatRoomListPage extends StatefulWidget {
  static const routeName = '/chat-room-list';
  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  int _currentBottomNavigationIndex = 1;
  final _user = FirebaseAuth.instance.currentUser;
  int _newChatRoomCount = 0;
  // var _guestChatList = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //   final fbm = FirebaseMessaging();
    //   fbm.requestNotificationPermissions();
    //   fbm.configure(
    //     onMessage: (msg) {
    //       print(msg);
    //       return;
    //     },
    //     onLaunch: (msg) {
    //       print(msg);
    //       return;
    //     },
    //     onResume: (msg) {
    //       print(msg);
    //       return;
    //     },
    //     //  onBackgroundMessage: (msg) {
    //     //   print(msg);
    //     //   return;
    //     // }
    //   );

    //   fbm.subscribeToTopic(_user.uid);
  }

  void _bottomNavigation(int index) {
    print('bottom navy select: $index');
    if (index == 0) {
      // Navigator.of(context).pushReplacementNamed(UserListPage.routeName);
      setState(() {
        _currentBottomNavigationIndex = 0;
      });
    }
    if (index == 1) {
      // Navigator.of(context).pushReplacementNamed(UserListPage.routeName);
      setState(() {
        _currentBottomNavigationIndex = 1;
      });
    }
    if (index == 2) {
      setState(() {
        // _guestChatList = true;
        _currentBottomNavigationIndex = 2;
      });
    }
  }

  Widget _badge(int value) {
    FlutterAppBadger.updateBadgeCount(value);
    return (value == 0)
        ? SizedBox.shrink()
        : Container(
            padding: EdgeInsets.all(2.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.red,
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          );
  }

  int _badgeControll(
    int formerValue,
    int newValue,
  ) {
    if (formerValue == newValue) {
      return formerValue;
    }
    return newValue;
  }

  Widget _bodyController() {
    if (_currentBottomNavigationIndex == 0) {
      // return UserList(_user.uid, );
    } else if (_currentBottomNavigationIndex == 2) {
      // return GuestChatList(_user.uid);
    } else {
      return StreamBuilder(
        // stream: FirebaseFirestore.instance.collection('chats').doc('1on1').collection('chatRooms').doc('2020-11-03 10:45:50.374778').collection('chatMessages').snapshots(),
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_user.uid)
            .collection('chatRooms')
            .where('chatRoomType', isEqualTo: '1on1')
            .orderBy('lastMessageCreatedAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          print('user : ${_user.uid}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final chatRoomListData = snapshot.data.docs;
          // print('streambuilder: ${chatRoomListData}');
          return ListView.builder(
            shrinkWrap: true,
            itemCount: chatRoomListData.length,
            itemBuilder: (ctx, index) {
              print('unread No :${chatRoomListData[index]['unRead']}');
              final unread = chatRoomListData[index]['unRead'];
              _newChatRoomCount = _badgeControll(_newChatRoomCount, unread);
              return ListTile(
                // title:Text('chats chatData'),
                key: ValueKey(chatRoomListData[index].id),
                title: Text(chatRoomListData[index]['chatUserName']),
                subtitle: Text(chatRoomListData[index]['lastMessage']),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(chatRoomListData[index]['chatUserImageUrl']),
                  radius: 25,
                ),
                trailing: Column(
                  children: [
                    Text(DateFormat.yMMMd().format(chatRoomListData[index]
                            ['lastMessageCreatedAt']
                        .toDate())),
                    // Badge(value: chatRoomListData[index]['unRead'].toString()),
                    // (unread == 0)? Container() :_badge(unread.toString()),
                    _badge(unread),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  // print(chatRoomListData[index].data());
                  ChatRoomController.instance.chatContinue(context, {
                    ...chatRoomListData[index].data(),
                    'chatRoomId': chatRoomListData[index].id
                  });
                  // print(chatData[index].documentID);
                },
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final getAuth = Provider.of<Auth>(context, listen: false).userId;
    final getAuthState = Provider.of<Auth>(context, listen: false).authState;
    // final _auth = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          DropdownButton(
              underline: Container(),
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Logout')
                      ],
                    ),
                  ),
                  value: 'logout',
                ),
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Edit Profile')
                      ],
                    ),
                  ),
                  value: 'edit',
                ),
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Test Page')
                      ],
                    ),
                  ),
                  value: 'test',
                ),
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'edit') {
                  Navigator.of(context)
                      .pushNamed(UserProfileEditPage.routeName);
                } else if (itemIdentifier == 'logout') {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamed('/');
                } else if (itemIdentifier == 'test') {
                  print(getAuthState);
                  // Navigator.of(context).pushNamed(UserProfileImagePicker.routeName);
                }
              })
        ],
      ),
      body: _bodyController(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Stack(children: [
              Icon(
                Icons.people,
                color: Colors.grey,
              ),
            ]),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Stack(children: [
              Icon(
                Icons.chat_bubble,
                color: Colors.grey,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _badge(_newChatRoomCount),
              )
            ]),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.emoji_people,
              color: Colors.grey,
            ),
            label: 'Guest',
          ),
        ],
        currentIndex: _currentBottomNavigationIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _bottomNavigation,
      ),
    );
  }
}
