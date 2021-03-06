import 'dart:convert';
import 'dart:io';

import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];

  final _toDoController = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["tittle"] = _toDoController.text;
      _toDoController.text = "";
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
    });
  }

  Future<Null> _refresh() async{
    print("refresh");
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a,b){
        print (1);
        if(a["ok"] && !b["ok"]) return 1;
        if (!a["ok"] && b["ok"]) return -1;
        return 0;
      });
      print(2);
      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _toDoController,
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                )),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addTodo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(child:  ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem
            ), onRefresh: _refresh)
          )
        ],
      ),
    );
  }

  Widget buildItem (context, index) {
      return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white,),
          )
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(_toDoList[index]['tittle']),
          value: _toDoList[index]['ok'],
          secondary: CircleAvatar(
              child: Icon(_toDoList[index]['ok']
                  ? Icons.check
                  : Icons.error)),
          onChanged: (checked) {
            setState(() {
              _toDoList[index]["ok"] = checked;
              _saveData();
            });
          },
        ),
        onDismissed: (direction){
          setState(() {
            _lastRemoved = Map.from(_toDoList[index]);
            
            _lastRemovedPos = index;
            _toDoList.removeAt(index);

            _saveData();
            
            final snack = SnackBar(
              content: Text("Tarefa ${_lastRemoved["tittle"]} removida"),
              action: SnackBarAction(label: "desfazer", onPressed: (){
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });

              }),
              duration: Duration(seconds: 3),
            );
            Scaffold.of(context).showSnackBar(snack);
          });
         
        
          
          
        },
      );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
