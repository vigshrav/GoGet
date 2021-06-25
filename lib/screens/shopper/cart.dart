import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({ Key? key }) : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('My Cart'),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.9,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if( !snapshot.hasData ){ return new Text('Loading...'); }
                  else if( snapshot.data!.docs.length == 0) { return Center(child: Text('No products found'),); }
                  else return ListView(
                    children: snapshot.data!.docs.map(
                      (DocumentSnapshot document) {
                        return Container(
                          height: 49,
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),),),
                          child: ListTile(
                            title: Text((document.data() as dynamic)['prodname'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.left,),
                            trailing: IconButton(icon: Icon(Icons.delete), onPressed: () async {

                            }
                          ),
                        ),
                      );
                    }
                  ).toList(),
                );
              }
            )
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: ElevatedButton(
            child: Text('Store Suggestions'), 
            onPressed: (){}, 
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.orange),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),))
              ),)),),
    );
  }
}