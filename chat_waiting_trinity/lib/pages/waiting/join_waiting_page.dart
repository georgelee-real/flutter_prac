import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/join_waiting_controller.dart';
import '../../controllers/sms_controller.dart';
// import 'package:flutter_sms/flutter_sms.dart';
// import 'package:telephony/telephony.dart';

class JoinWaitingPage extends StatefulWidget {
  @override
  _JoinWaitingPageState createState() => _JoinWaitingPageState();
}

enum SelectTime { nowPick, userPick }

class _JoinWaitingPageState extends State<JoinWaitingPage> {
  final _formKey = GlobalKey<FormState>();
  var _name = '';
  var _phone = '';
  var _people = '';
  DateTime _reserveAt;
  String _waitingStatus;
  // String _reserveDate;
  // String _reserveTime;
  var _isLoading = false;
  bool _hasDone = false;
  TextEditingController _reserveAtController = TextEditingController();
  // TextEditingController _reserveDateController = TextEditingController();
  // TextEditingController _reserveTimeController = TextEditingController();
  var _selectedReserveTime;
  // DateTime _selectedDate;
  // DateTime _selectedTime;
  var _reservationNumber = 1;

  // final Telephony telephony = Telephony.instance;
  // final SmsSendStatusListener listener = (SendStatus status) {
  //   // Handle the status
  //   print(status);
  // };

  Future<void> _showConfirmDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Please Confirm Your Reservation',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Card(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Name : $_name'),
                        Text('Number of people : $_people'),
                        Text('Phone# : $_phone'),
                        Text('Reserve At : $_reserveAt'),
                      ],
                    ),
                  ),
                ),
              ),
              RaisedButton(
                child: Text('Confirm'),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });

                  // telephony.sendSms(
                  //     to: "16478587567",
                  //     message: "May the force be with you!",
                  //     statusListener: listener);
                   
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Reservation Time',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlatButton(
                child: Text('Now'),
                onPressed: () {
                  setState(() {
                    _selectedReserveTime = SelectTime.nowPick;
                    _waitingStatus =
                        JoinWaitingController.instance.defaultStatus;
                  });
                  print(_selectedReserveTime);

                  // setState(() {
                  // _reserveAt = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now());
                  _reserveAtController.text = _roundUpTime(DateTime.now());

                  // });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Later'),
                onPressed: () {
                  setState(() {
                    _selectedReserveTime = SelectTime.userPick;
                  });
                  print(_selectedReserveTime);

                  Navigator.of(context).pop();
                  _reserveAtPicker();
                },
              ),
              // FlatButton(
              //   child: Text('Cancel'),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          ),
          // actions: [

          // ],
        );
      },
    );
  }

  String _roundUpTime(DateTime dt) {
    DateTime roundUpTime = dt.add(Duration(minutes: (5 - dt.minute % 5)));
    _reserveAt = roundUpTime;

    return DateFormat('yyyy/MM/dd HH:mm').format(roundUpTime);
  }

  bool _timePassed(String pickedTime) {
    final DateTime now = DateTime.now();
    final DateTime picked = DateFormat('yyyy/MM/dd HH:mm').parse(pickedTime);
    print('picked: $picked');
    // final nowformatted = DateFormat('yyyy/MM/dd HH:mm').format(now);
    final earlier = now.subtract(const Duration(minutes: 5));
    // final earlierFormatted = DateFormat('yyyy/MM/dd HH:mm').format(now);
    // print(pickedTime);
    final passed = earlier.isBefore(picked);
    // print(pickedTime);
    print('earllier: $earlier');
    print(passed);
    final diff = now.difference(picked);
    print(diff);

    return passed;
  }

  Future<void> _reserveAtPicker() async {
    try {
      final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(
            Duration(days: 100),
          ));
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      DateTime resultTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, selectedTime.hour, selectedTime.minute);

      _reserveAtController.text = _roundUpTime(resultTime);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getStatus() async {
    final value = await JoinWaitingController.instance.getStatus(_reserveAt);
    // .then((String value) {
    // print('getstatus value $value');
    setState(() {
      _waitingStatus = value;
    });
    // print('waitingstatus getstatus $_waitingStatus');
    // });
  }

  Future<void> _makeReservation() async {
    final isValid = _formKey.currentState.validate();

    final DateTime now = DateTime.now();
    if (isValid) {
      _formKey.currentState.save();
      // final docId = _reserveAt.substring(0,10);
      // final docId = DateFormat('yyyy/MM/dd').format(DateTime.now());
      final docId = DateFormat("yyyy/MM/dd").format(_reserveAt);
      bool isToday = true;
      if (_reserveAt.difference(now).inDays != 0) {
        isToday = false;
      }

      // final docId = '2020/11/18';
      print('makereservation docId:$docId');
      await _showConfirmDialog();
      try {
        setState(() {
          _isLoading = true;
        });

        final docSnap = await FirebaseFirestore.instance
            .collection('waiting')
            .doc(docId)
            .collection('list')
            // .where('waitingStatus', isEqualTo: 'waiting')
            .get();
        print('docsnap length : ${docSnap.docs.length}');
        int currentWaitingTime;

        int currentWaitingTimeUpdated;
        // docSnap.docs['currentWaitingTime'];
        if (docSnap.docs.length == 0) {
          // _reservationNumber = 1;
          await FirebaseFirestore.instance
              .collection('waiting')
              .doc(docId)
              .set({'currentWaitingTime': 0, 'docId': docId});
          currentWaitingTime = 0;
          currentWaitingTimeUpdated = 0;
        } else {
          final docRef = await FirebaseFirestore.instance
              .collection('waiting')
              .doc(DateFormat('yyyy/MM/dd').format(now))
              .get();
// print('docref length : ${docRef.data().length}');
          currentWaitingTime = docRef.data()['currentWaitingTime'];
          print('current wait time $currentWaitingTime');
          _reservationNumber = docSnap.docs.length + 1;
          var counterActive = 0;
          // var currentWaitingTime = 0;
          docSnap.docs.map((e) {
            // print(e['waitingStatus']);
            if (e['waitingStatus'] == 'waiting') {
              counterActive++;
            }
          }).toList();
          print('counteractive $counterActive');
          if (counterActive < 2) {
            currentWaitingTimeUpdated = 0;
          } else if (counterActive < 5) {
            currentWaitingTimeUpdated = 10;
          } else if (counterActive < 10) {
            currentWaitingTimeUpdated = 30;
          } else if (counterActive < 20) {
            currentWaitingTimeUpdated = 45;
          } else if (counterActive < 30) {
            currentWaitingTimeUpdated = 60;
          } else {
            currentWaitingTimeUpdated = 90;
          }
          print('current wainting updated time $currentWaitingTimeUpdated');
        }
        if (currentWaitingTime != currentWaitingTimeUpdated) {
          await FirebaseFirestore.instance
              .collection('waiting')
              .doc(docId)
              .update({'currentWaitingTime': currentWaitingTimeUpdated});
          await JoinWaitingController.instance
              .pendingCheck(currentWaitingTimeUpdated);
        }

        if (_selectedReserveTime == SelectTime.userPick) {
          await _getStatus();
          // print('joinwaitingControllergetStatus triggerred');
        }
        print('_waitingStatus $_waitingStatus');
        // if(_waitingStatus == null){
        //   Timer(Duration(seconds: 1), (){print('_getstatus null why');});
        // }
        final result = await FirebaseFirestore.instance
            .collection('waiting')
            .doc(docId)
            .collection('list')
            .add({
          'createdAt': now,
          'name': _name,
          'people': _people,
          'phone': _phone,
          'reserveAt': _reserveAt,
          'reservationNumber': _reservationNumber,
          'waitingStatus': _waitingStatus
        });

        print(result.path);
        if (_waitingStatus == 'pending' && isToday) {
          final diff = _reserveAt.difference(now);
          final triggerTime = diff - Duration(minutes: currentWaitingTime);
          print('trigger time $triggerTime');
          // Timer(Duration(seconds: 15, minutes: 0), () {
          Timer(triggerTime, () {
            print("Yeah, this line is printed after $triggerTime ");
            JoinWaitingController.instance.pendingToWaiting(result.path);
          });
        }
        setState(() {
          _isLoading = false;
          _hasDone = true;
        });
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
      }
      print('$_name $_phone $_people $_reserveAt');
      // Timer(Duration(seconds: 15, minutes: 0), () {
      //   print("Yeah, this line is printed after 15 second");
      //   JoinWaitingController.instance.pendingCheck();
      // });
    }
  }

  Widget _finished() {
      // 
    
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reservation Number : $_reservationNumber',
          ),
          RaisedButton(
            child: Text('Back to Home'),
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Wainting List'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasDone
              ? _finished()
              : InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Card(
                    margin: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // if (!_isSignIn) UserImagePicker(_pickedImage),
                              TextFormField(
                                key: ValueKey('guest_name'),
                                // autocorrect: false,
                                textCapitalization: TextCapitalization.words,
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value.isEmpty || value.length < 2) {
                                    return 'Prease name at least 2 characters';
                                  }

                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                ),
                                onSaved: (value) {
                                  _name = value;
                                },
                              ),

                              TextFormField(
                                key: ValueKey('guest_phone'),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value.isEmpty || value.length != 10) {
                                    return 'phone must be 10 digits long.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(labelText: 'phone'),
                                // obscureText: true,
                                onSaved: (value) {
                                  _phone = '+1' + value;
                                },
                              ),

                              TextFormField(
                                key: ValueKey('guest_people'),
                                initialValue: '0',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (int.parse(value) < 1) {
                                    return 'Please choose number of people.';
                                  }
                                  if (int.parse(value) > 10) {
                                    return 'more than 10 people need to contact to the restaurant.';
                                  }
                                  return null;
                                },
                                decoration:
                                    InputDecoration(labelText: 'People'),
                                // obscureText: true,
                                onSaved: (value) {
                                  _people = value;
                                },
                              ),

                              TextFormField(
                                key: ValueKey('guest_ReserveAt'),
                                // initialValue: DateTime.now().toString(),
                                controller: _reserveAtController,
                                validator: (value) {
                                  if (value.isEmpty || !_timePassed(value)) {
                                    return 'Please pick a time for the reservation.';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'reserveAt',
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        _reserveAtController.clear(),
                                    icon: Icon(Icons.clear),
                                  ),
                                ),
                                // obscureText: true,
                                onSaved: (value) {
                                  // _reserveAt =
                                  //     DateFormat('yyyy/MM/dd HH:mm').parse(value);
                                  // JoinWaitingController.instance.getStatus(_reserveAt).then((String value) { _waitingStatus = value; });
                                },
                                onTap: _showMyDialog,
                              ),

                              

                              SizedBox(height: 12),
                              if (_isLoading) CircularProgressIndicator(),
                              if (!_isLoading)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RaisedButton(
                                      child: Text('Reserve'),
                                      onPressed: _makeReservation,
                                    ),
                                    FlatButton(
                                      child: Text('Back to List'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/home');
                                      },
                                    )
                                  ],
                                ),
                              
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
