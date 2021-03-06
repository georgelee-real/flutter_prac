// import 'dart:html';

// import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/chat/chat_room_page.dart';
import 'package:intl/intl.dart';

class ChatRoomController {
  static ChatRoomController get instance => ChatRoomController();
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> chatContinue(
      BuildContext context, Map<String, dynamic> chatUserInfo) async {
    final userSelfData = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    if (chatUserInfo['chatUserName'] == 'guest' ||
        chatUserInfo['chatUserName'] == 'test') {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatUserInfo['chatRoomPath'])
          .update({'chatBegin': true});
    }
    // print('chatroompath ');
    // chatUserInfo['chatRoomPath']);
    Navigator.pushNamed(context, ChatRoomPage.routeName, arguments: {
      'chatRoomId': chatUserInfo['chatRoomId'],
      'chatRoomType': chatUserInfo['chatRoomType'],
      'chatRoomPath': chatUserInfo['chatRoomPath'],
      'chatUserId': chatUserInfo['chatUserId'],
      'chatUserImageUrl': chatUserInfo['chatUserImageUrl'],
      'chatUserName': chatUserInfo['chatUserName'],
      'userSelfId': _user.uid,
      'userSelfImageUrl': userSelfData['image_url'],
      'userSelfName': userSelfData['username'],
      // 'chatUserImageUrl':userData[index]['image_url'],
    });

    return;
  }

  Future<void> chatContinuewithGuest(Map<String, dynamic> chatUserInfo) async {
    try {
      if (chatUserInfo['chatUserName'] == 'guest' ||
          chatUserInfo['chatUserName'] == 'test') {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatUserInfo['chatRoomPath'])
            .update({'chatBegin': true});
      }
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      print('call open chat room');
      _openChatRoom(chatUserInfo, data);
    } catch (e) {
      print(e);
    }

    // return Text('future??');
    return;
  }

  Widget _openChatRoom(Map<String, dynamic> chatUserInfo, data) {
    print('chatcontinuewithguestFn has data..');
    // return Text('future?');
    return ChatRoomPage(
      chatInfo: {
        'chatRoomId': chatUserInfo['chatRoomId'],
        'chatRoomType': chatUserInfo['chatRoomType'],
        'chatRoomPath': chatUserInfo['chatRoomPath'],
        'chatUserId': chatUserInfo['chatUserId'],
        'chatUserImageUrl': chatUserInfo['chatUserImageUrl'],
        'chatUserName': chatUserInfo['chatUserName'],
        'userSelfId': _user.uid,
        'userSelfImageUrl': data.data()['image_url'],
        'userSelfName': data.data()['username'],
        // 'chatUserImageUrl':userData[index]['image_url'],
      },
    );
  }

  Future<void> chat1on1(
      BuildContext context, Map<String, dynamic> chatUserInfo) async {
    // print(userIds.contains('otherUserId'));
    try {
      final userSelfData = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      final chatRoomsnapshots = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('chatRooms')
          // .orderBy('lastMessageCreatedAt')
          .where('chatRoomType', isEqualTo: '1on1')
          .where('chatUserId', isEqualTo: chatUserInfo['chatUserId'])
          .get();

      // print(chatRoomsnapshots.docs.length);
      // print(chatRoomsnapshots.docs[0].data());
      // chatRoomsnapshots.docs.forEach((element) {
      //   print(element.id);
      // });
      if (chatRoomsnapshots.docs.length != 0) {
        // print(chatRoomsnapshots.docs.last.id);
        final String chatRoomId = chatRoomsnapshots.docs.last.id;
        Navigator.pushNamed(context, ChatRoomPage.routeName, arguments: {
          'chatRoomId': chatRoomId,
          'chatRoomType': '1on1',
          'chatRoomPath': '1on1/chatRooms/$chatRoomId',
          'chatUserId': chatUserInfo['chatUserId'],
          'chatUserImageUrl': chatUserInfo['chatUserImageUrl'],
          'chatUserName': chatUserInfo['chatUserName'],
          'userSelfId': _user.uid,
          'userSelfImageUrl': userSelfData['image_url'],
          'userSelfName': userSelfData['username'],
          // 'chatUserImageUrl':userData[index]['image_url'],
        });
      } else {
        final String chatRoomId = DateTime.now().toString();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.uid)
            .collection('chatRooms')
            .doc(chatRoomId)
            .set({
          'chatRoomType': '1on1',
          'chatRoomPath': '1on1/chatRooms/$chatRoomId',
          'chatUserId': chatUserInfo['chatUserId'],
          'chatUserImageUrl': chatUserInfo['chatUserImageUrl'],
          'chatUserName': chatUserInfo['chatUserName'],
          'unRead': 0
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(chatUserInfo['chatUserId'])
            .collection('chatRooms')
            .doc(chatRoomId)
            .set({
          'chatRoomType': '1on1',
          'chatRoomPath': '1on1/chatRooms/$chatRoomId',
          'chatUserId': _user.uid,
          'chatUserImageUrl': userSelfData['image_url'],
          'chatUserName': userSelfData['username'],
          'unRead': 0
        });
        await FirebaseFirestore.instance
            .collection('chats')
            .doc('1on1/chatRooms/$chatRoomId')
            // .doc(chatRoomId)
            .set({
          // 'chatBegin': false,
          // 'chatFinished': false,
          'chatRoomId': chatRoomId,
          'chatRoomPath': '1on1/chatRooms/$chatRoomId',
          'chatRoomType': '1on1',
          'chatUserId': chatUserInfo['chatUserId'],
          'chatUserImageUrl': chatUserInfo['chatUserImageUrl'],
          'chatUserName': chatUserInfo['chatUserName'],
          'userSelfId': _user.uid,
          'userSelfImageUrl': userSelfData['image_url'],
          'userSelfName': userSelfData['username'],
        });
        Navigator.pushNamed(context, ChatRoomPage.routeName, arguments: {
          'chatRoomId': chatRoomId,
          'chatRoomPath': '1on1/chatRooms/$chatRoomId',
          'chatRoomType': '1on1',
          'chatUserId': chatUserInfo['chatUserId'],
          'chatUserImageUrl': chatUserInfo['chatUserImageUrl'],
          'chatUserName': chatUserInfo['chatUserName'],
          'userSelfId': _user.uid,
          'userSelfImageUrl': userSelfData['image_url'],
          'userSelfName': userSelfData['username'],
          // 'chatUserImageUrl':userData[index]['image_url'],
        });
        // print(chatRoomsnapshots1.docs[0].data());
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> chatWithGuest(
      // BuildContext context,
      ) async {
    final now = DateTime.now();
    final String chatRoomId = now.toString();
    final String docId = DateFormat('yyyy/MM/dd').format(now);
    print('chatwithguestbegin');
    try {
      final guestInfo = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();
      print('hatWithGuest guestid : ${_user.uid}');
      final advisorInfo = await FirebaseFirestore.instance
          .collection('users')
          .where('roll', isEqualTo: 'advisor')
          .get();
      print('hatWithGuest advisorname : ${advisorInfo.docs[0]['username']}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('chatRooms')
          .doc(chatRoomId)
          .set({
        'chatRoomType': 'withGuest',
        'chatRoomPath': 'withGuest/$docId/$chatRoomId',
        'chatUserId': advisorInfo.docs[0].id,
        'chatUserImageUrl': advisorInfo.docs[0]['image_url'],
        'chatUserName': advisorInfo.docs[0]['username'],
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc('${advisorInfo.docs[0].id}/$docId/$chatRoomId')
          // .collection('chatRooms')
          // .doc('$docId/$chatRoomId')
          .set({
        'chatRoomType': 'withGuest',
        'chatRoomPath': 'withGuest/$docId/$chatRoomId',
        'chatUserId': _user.uid,
        'chatUserImageUrl': guestInfo['image_url'],
        'chatUserName': guestInfo['username'],
        'chatFinished': false,
        'createdAt': now
      });
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('withGuest')
          .collection(docId)
          .doc(chatRoomId)
          .set({
        'chatBegin': false,
        // 'chatFinished': false,
        'chatRoomId': chatRoomId,
        'chatRoomType': 'withGuest',
        'guestId': _user.uid,
        'guestName': guestInfo['username'],
        'guestImageUrl': guestInfo['image_url'],
        'guestPhone': guestInfo['phoneNo'],
        'advisorId': advisorInfo.docs[0].id,
        'advisorName': advisorInfo.docs[0]['username'],
        'advisorImageUrl': advisorInfo.docs[0]['image_url'],
      });
      return {
        'chatRoomId': chatRoomId,
        'chatRoomPath': 'withGuest/$docId/$chatRoomId',
        'chatRoomType': 'withGuest',
        'chatUserId': advisorInfo.docs[0].id,
        'chatUserImageUrl': advisorInfo.docs[0]['image_url'],
        'chatUserName': advisorInfo.docs[0]['username'],
        'userSelfId': _user.uid,
        'userSelfImageUrl': guestInfo['image_url'],
        'userSelfName': guestInfo['username'],

        // 'chatUserImageUrl':userData[index]['image_url'],
      };
    } catch (e) {
      print(e);
    }
    return {'error': true};
  }

  Future<void> chatFinish(String chatRoomPath, String userName) async {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> systemMessage = {
      'message': '$userName has finished chat.',
      'createdAt': now,
      'sendUserName': 'system',
    };
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomPath)
        .collection('chatMessages')
        .add(systemMessage);
  }
}
