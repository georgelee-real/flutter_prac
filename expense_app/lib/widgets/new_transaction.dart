import 'package:flutter/material.dart';

class NewTransaction extends StatelessWidget {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  final Function addNewTransaction;
  NewTransaction(this.addNewTransaction);

  void submitData(){
    final enteredTitle = titleController.text;
    final enteredAmount = double.parse(amountController.text);
    
    if(enteredTitle.isEmpty || enteredAmount <=0) {
      return;
    }

    addNewTransaction(
                  enteredTitle,
                  enteredAmount,
                );
  }
   

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: titleController,
              onSubmitted: (_)=>submitData(), // '_' : receive value but will ignore
              // onChanged: (val) {
              //   inputTitle = val;
              // },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: amountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_)=>submitData(), // '_' : receive value but will ignore
              // onChanged: (val) => inputAmount = val,
            ),
            FlatButton(
              onPressed: () {
                print(titleController.text);
                print(amountController.text);
                submitData();
                // print(inputAmount);
              },
              child: Text('Add Transaction'),
              textColor: Colors.purple,
            )
          ],
        ),
      ),
    );
  }
}
