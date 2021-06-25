import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/screens/grocery/addProduct.dart';
import 'package:gogetapp/screens/grocery/newStore.dart';
import 'package:gogetapp/screens/grocery/search&add.dart';
import 'package:gogetapp/services/fire_auth.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopHome extends StatefulWidget {
  const ShopHome({ Key? key }) : super(key: key);

  @override
  _ShopHomeState createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> {

  final user = FirebaseAuth.instance.currentUser;
  var storeName = 'Store Name';

  bool loading = false;

  late Future<DocumentSnapshot> groceryStore;

  @override
  void initState(){
    super.initState();
    groceryStore = _getStoreDetails();
  }

  @override
  Widget build(BuildContext context) {

    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Store Front'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){ AuthService().signOut(); }, icon: Icon(Icons.logout)),
          // IconButton(onPressed: (){}, icon: Icon(Icons.power_settings_new))
        ],
      ),
      
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
// ***** CHECK IF STORE EXISTS
            if( !snapshot.hasData ){
              return Container(
                height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.82,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 0.0),
                child: noStoreView()
              );
            } else { 
              var storeDetails = FirebaseFirestore.instance.collection('stores').doc(user!.uid).get();
              
              storeDetails.then((doc) async => {
                setState((){
                  storeName = (doc.data() as dynamic)['storename'];
                })
              });
// ***** CHECK IF STORE HAS PRODUCTS (--NO)
              if (snapshot.data!.docs.length == 0) {
                return Column(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.05,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('$storeName', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),],)
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                    height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.05,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),)),
                        child: 
                          Center(
                            child: Text('No Products Found')),
                          ),
                ]);}
// ***** IF STORE HAS PRODUCTS 
              return Column(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.05,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Text('$storeName', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),],)
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                    height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.05,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),)),
                    child: Row(
                    children: [
                      Container(width: 260, child: Text('Product Name', overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)),
                      Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),)),
                      Expanded(child: Text('Unit Price (\u{20B9})',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),)
                    ],)
                  ),
                  Column(
                    children: [
                      SingleChildScrollView(
                        child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.72,
                          child: ListView(
                            children: snapshot.data!.docs.map(
                              (DocumentSnapshot document) {
                                return Container(
                                  height: 60,
                                  decoration: BoxDecoration( 
                                    border: Border(bottom: BorderSide(color: Colors.grey),),
                                  ),
                                  child: ListTile(
                                    leading: IconButton(icon: Icon(Icons.delete), onPressed: (){ displayDeleteConfirm('Delete this product : ${(document.data() as dynamic)['prodName']} ?', document.id); },),
                                    title: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Container(width: 180.0, child: Text((document.data() as dynamic)['prodName'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.start,)),
                                        Expanded(child: Text((document.data() as dynamic)['stockCount'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.center,)),
                                        Expanded(child: Text((document.data() as dynamic)['price'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0),textAlign: TextAlign.center,)),
                                      ],
                                    ),
                                    onTap: (){
                                      double _qty = 0.0; 
                                      double _price = 0.0;
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                            elevation: 16,
                                            child: Container(height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.35,
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(height: 10),
                                                  Center(child: Text((document.data() as dynamic)['prodName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 20.0))),
                                                  SizedBox(height: 10),
                                                  // _buildRow((document.data() as dynamic)['stockCount'], (document.data() as dynamic)['price']),
                                                  Padding(padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                                  child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      SizedBox(height: 0),
                                                      Container(height: 2, color: Colors.redAccent),
                                                      SizedBox(height: 10),
                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: <Widget>[

                                                          Text('Quantity :', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),           
                                                          Container(width: 80.0, child: TextField(decoration: InputDecoration(labelText: '${(document.data() as dynamic)['stockCount']}'), onChanged: (val) => _qty = double.parse(val),)),

                                                        ],
                                                      ),
                                                      SizedBox(height: 10,),
                                                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: <Widget>[

                                                          Text('Price : (\u{20B9})', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                                                          Container(width: 80.0, child: TextField(decoration: InputDecoration(labelText: '${(document.data() as dynamic)['price']}'), onChanged: (val) => _price = double.parse(val),)),
                                                          
                                                        ],
                                                      ),
                                                        
                                                   
                                                  SizedBox(height: 10,),
                                                  ElevatedButton(child: Text('Done'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
                                                  onPressed: () async { 
                                                    if (_price > 0.0 || _qty > 0.0) {
                                                      setState(() { loading = true; });
                                                      await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(document.id).update({
                                                        'price' : _price > 0.0 ? _price : (document.data() as dynamic)['price'],
                                                        'stockCount' : _qty > 0.0 ? _qty : (document.data() as dynamic)['stockCount'],
                                                      });
                                                      setState(() { loading = false; });
                                                      Navigator.of(context).pop();

                                                    } else {displayAlert('No Changes to SAVE'); Navigator.of(context).pop();}
                                                  }, 
                                                  )
                                                 ],
                                                  ),
                                              )],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              }
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SearchNadd())); //AddProductSeller()));
        },
      ),
    );
  }

  Future<DocumentSnapshot<Object?>> _getStoreDetails() async {
    var usrStore = await FirebaseFirestore.instance.collection('stores').doc(user!.uid).get();
    return usrStore;
  }

  noStoreView() {
      return Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text('NO STORES FOUND. PLEASE ADD A NEW STORE TO START ADDING PRODUCTS.',textAlign: TextAlign.center,)),
          SizedBox(height: 45.0,),
          ElevatedButton(onPressed: (){ Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddNewStore())); }, child: Text('ADD STORE'), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),)
        ],
      );
    } 
  
  displayAlert(text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ));
  }

  displayDeleteConfirm(text, id){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'YES',
          onPressed: () async {
            await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(id).delete();
          },
        ),
      ));
  }

}