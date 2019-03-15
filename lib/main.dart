import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_sqflite/database/Helper.dart';
import 'package:flutter_sqflite/model/User.dart';
import 'package:flutter_sqflite/utils/Utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xff00bfa5),
          appBarTheme: AppBarTheme(
              textTheme: TextTheme(
                  title: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )))),
      home: MyHomePage(title: 'SQFlite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool flag = false;
  final teNameController = TextEditingController();
  final tePhoneController = TextEditingController();
  final teEmailController = TextEditingController();
  List<User> items = new List();
  List<User> values;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: getAllUser(),
      floatingActionButton:  FloatingActionButton(
          onPressed: () => openAlertBox(null),
          tooltip: 'Increment',
          backgroundColor: Color(0xff00bfa5),
          child: Icon(Icons.add),
        ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// openAlertBox to add user
  openAlertBox(User user) {
    if (user != null) {
      teNameController.text = user.name;
      tePhoneController.text = user.phone;
      teEmailController.text = user.email;
      flag = true;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        flag ? "Edit User" : "Add User",
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: teNameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: "Add Name",
                              fillColor: Colors.grey[300],
                              border: InputBorder.none,
                            ),
                            validator: validateName,
                            onSaved: (String val) {
                              teNameController.text = val;
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: tePhoneController,
                            decoration: InputDecoration(
                              hintText: "Add Phone",
                              fillColor: Colors.grey[300],
                              border: InputBorder.none,
                            ),
                            maxLines: 1,
                            validator: validateMobile,
                            onSaved: (String val) {
                              tePhoneController.text = val;
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: teEmailController,
                            decoration: InputDecoration(
                              hintText: "Add Email",
                              fillColor: Colors.grey[300],
                              border: InputBorder.none,
                            ),
                            maxLines: 1,
                            validator: validateEmail,
                            onSaved: (String val) {
                              teEmailController.text = val;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => flag ? editUser(user.id) : addUser(),
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Color(0xff00bfa5),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        flag ? "Edit User" : "Add User",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// Validation Check
  String validateName(String value) {
    if (value.length < 3)
      return 'Name must be more than 2 charater';
    else if (value.length > 30) {
      return 'Name must be less than 30 charater';
    } else
      return null;
  }

  String validateMobile(String value) {
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = new RegExp(pattern);
    if (value.trim().length != 10)
      return 'Mobile Number must be of 10 digit';
    else if(value.startsWith('+', 0)) {
      return 'Mobile Number should not contain +91';
    } else if(value.trim().contains(" ")) {
      return 'Blank space is not allowed';
    } else if(!regex.hasMatch(value)) {
      return 'Characters are not allowed';
    } else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else if (value.length > 30) {
      return 'Email length exceeds';
    } else
      return null;
  }

  ///edit User
  editUser(int id) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var user = User();
      user.id = id;
      user.name = teNameController.text;
      user.phone = tePhoneController.text;
      user.email = teEmailController.text;
      var dbHelper = Helper();
      dbHelper.update(user).then((update) {
        teNameController.text = "";
        tePhoneController.text = "";
        teEmailController.text = "";
        Navigator.of(context).pop();
        showtoast("Data Saved successfully");
        setState(() {
          getAllUser();
        });
      });
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  ///add User Method
  addUser() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var user = User();
      user.name = teNameController.text;
      user.phone = tePhoneController.text;
      user.email = teEmailController.text;
      var dbHelper = Helper();
      dbHelper.insert(user);
      teNameController.text = "";
      tePhoneController.text = "";
      teEmailController.text = "";
      Navigator.of(context).pop();
      setState(() {
        getAllUser();
      });

      showtoast("Successfully Added Data");
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  /// Get all users data
  getAllUser() {
    return FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return showProgress();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                return createListView(context, snapshot);
              }
          }
        });
  }

  ///Fetch data from database
  Future<List<User>> _getData() async {
    var dbHelper = Helper();

    await dbHelper.getAllUsers().then((value) {
      items = value;
    });
    return items;
  }

  ///create List View with Animation
  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    values = snapshot.data;
    return new AnimatedList(
        key: _listKey,
        shrinkWrap: true,
        initialItemCount: values.length,
        itemBuilder: (BuildContext context, int index, animation) {
          return _buildItem(values[index], animation, index);
        });
  }

  ///Construct cell for List View
  Widget _buildItem(User values, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Color.fromRGBO(240, 240, 240, 10.0),
        child: ListTile(
            leading: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.brown.shade800,
                  child: Text(
                    values.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 35, color: Colors.white),
                  ),
                ),
              ],
            ),
            onTap: () => onItemClick(values),
            title: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0)),
                new Row(
                  children: <Widget>[
                    Icon(Icons.account_circle),
                    Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0)),
                    new InkWell(
                      child: Text(
                        values.name,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.normal,
                            color: Colors.black),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0)),
                new Row(
                  children: <Widget>[
                    Icon(Icons.phone),
                    Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0)),
                    new InkWell(
                      child: new Text(
                        values.phone.toString(),
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0)),
                new Row(
                  children: <Widget>[
                    Icon(Icons.email),
                    Padding(padding: EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0)),
                    new InkWell(
                      child: new Text(
                        values.email.toString(),
                        style: TextStyle(fontSize: 18.0, color: Colors.black),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 10.0)),
              ],
            ),
            trailing: Column(
              children: <Widget>[
                IconButton(
                    color: Colors.black,
                    icon: new Icon(Icons.edit),
                    onPressed: () => onEdit(values, index)),
                IconButton(
                    color: Colors.black,
                    icon: new Icon(Icons.delete),
                    onPressed: () => onDelete(values, index)),
              ],
            )),
      ),
    );
  }

  ///On Item Click
  onItemClick(User values) {
    print("Clicked position is ${values.name}");
  }

  /// Delete Click and delete item
  onDelete(User values, int index) {
    var id = values.id;
    var dbHelper = Helper();
    dbHelper.delete(id).then((value) {
      User removedItem = items.removeAt(index);

      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return _buildItem(removedItem, animation, index);
      };
      _listKey.currentState.removeItem(index, builder);
    });
  }

  /// Edit Click
  onEdit(User user, int index) {
    openAlertBox(user);
  }
}
