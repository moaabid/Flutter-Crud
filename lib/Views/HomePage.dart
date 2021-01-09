import 'package:crud/Helper/dbHelper.dart';
import 'package:flutter/material.dart';
import 'package:crud/Model/employee.dart';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Employee>> employees;
  TextEditingController controller = TextEditingController();
  String name;
  int curUserId;

  final formKey = new GlobalKey<FormState>();

  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      employees = dbHelper.getEmployees();
    });
  }

  clearName() {
    controller.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Employee e = Employee(curUserId, name);
        dbHelper.update(e);
        
        setState(() {
          isUpdating = false;
        });
       
      } else {
        Employee e = Employee(null, name);
        dbHelper.save(e);
        
      }
       clearName();
      refreshList();
    }
  }
  


  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (val) => val.length == 0 ? 'Enter Name' : null,
              onSaved: (val) => name = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: validate,
                  child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                    });
                    clearName();
                  },
                  child: Text('CANCEL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Employee> employees) {
    
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: [
              DataColumn(label: Text('S.no')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Action')),
            ],
            rows: employees.map((employee)=>DataRow(
              cells: [
                DataCell(
                 
              Text((employee.id).toString()),
            ),
            DataCell(
              Text(employee.name),
              onTap: (){
                setState(() {
                  isUpdating = true;
                  curUserId = employee.id;
                  
                  
                });
                controller.text= employee.name;
              },
            ),
            DataCell(
              Builder(
              builder:(context)=>IconButton(
                icon: Icon(Icons.delete),
                onPressed: (){
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content:Row(
                      children:[
                          Icon(Icons.thumb_up),
                          SizedBox(width:20),
                          Expanded(child: Text(employee.name+'  Deleted Successfully'),),
                      ],
                    ) 
                  ));
                  dbHelper.delete(employee.id);
                  refreshList();
                },
              ),
              )
            ),
          ],
        ))
        .toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: employees,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }
          if (null == snapshot.data || snapshot.data.lenght == 0) {
            return Text("No Data Found");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crud App"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            form(),
            list(),
          ],
        ),
      ),
    );
  }
}
