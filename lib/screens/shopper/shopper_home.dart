import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/shopper/cart.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({ Key? key }) : super(key: key);

  @override
  _ShopperHomeState createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  bool loading = false;

  var _searchText = '';
  var searchQuery = FirebaseFirestore.instance.collection('products').snapshots();

  final textfieldController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {

    if (_searchText == '' || _searchText.length <= 1) {
      // print (_searchText);
      searchQuery = FirebaseFirestore.instance.collection('products').snapshots();
    } else {
      // searchQuery = FirebaseFirestore.instance.collection('products').orderBy('prodName').startAt([_searchText]).endAt([_searchText + '\uf8ff']).snapshots();
      searchQuery = FirebaseFirestore.instance.collection('products').where('prodName', isGreaterThanOrEqualTo: _searchText).where('prodName', isLessThan: _searchText + '\uf8ff').snapshots();
      // print(searchQuery);
      }

    return loading ? Loading() : Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('GoGet'),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          
          IconButton(onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ShoppingCart())); }, icon: Icon(Icons.shopping_basket_outlined)),
          IconButton(onPressed: (){ AuthService().signOut(); }, icon: Icon(Icons.logout)),

        ],
        shadowColor: Colors.orange,
        ),

      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5.0),
              height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.055,
              
                child: TextField(
                  controller: textfieldController,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search, color: Colors.white,),
                    hintText: 'Search products here ...',
                    hintStyle: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.bold),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(width: 1.0, color: Colors.white)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Colors.white)
                    )
                  ),
                  onChanged: (val) => {
                    setState(() {
                      _searchText = val;
                  })
                },
              ),
            ),
            SizedBox(height: 0.0,),
            Container(
              child: SingleChildScrollView(
                child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.8,
                  child: StreamBuilder(
                    stream: searchQuery,
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
                                title: Text((document.data() as dynamic)['prodName'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.left,),
                                trailing: OutlinedButton.icon(icon: Icon(Icons.add_circle_outline), label: Text('Add to Cart'), onPressed: () async {
                                  // *** CHECK IF PRODUCT ALREADY ADDED TO STORE
                                  var prodCount = 0;
                                  await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').get()
                                  .then((snapshot) async => {
                                    if (snapshot.docs.isNotEmpty){
                                      snapshot.docs.forEach((doc) {
                                        if (doc.id == document.id) {
                                          prodCount = prodCount + 1;
                                          // print(prodCount);
                                        }
                                      })
                                    }
                                  });
                                  // print(prodCount);
                                  if (prodCount > 0) { displayAlert('Item already in your cart'); textfieldController.clear(); setState(() { _searchText = ''; }); FocusScope.of(context).unfocus(); }
                                  else {
                                    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').doc(document.id).set({
                                      'prodname' : (document.data() as dynamic)['prodName']
                                    });
                                    textfieldController.clear();
                                    FocusScope.of(context).unfocus();
                                    setState(() { _searchText = ''; });
                                  }
                                }),                                
                              )
                            );
                          }
                        ).toList(),
                      );
                    }
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  displayAlert(text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ));
  }
}