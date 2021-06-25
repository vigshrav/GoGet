import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gogetapp/widgets/spinner.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductSeller extends StatefulWidget {
  const AddProductSeller({ Key? key }) : super(key: key);

  @override
  _AddProductSellerState createState() => _AddProductSellerState();
}

class _AddProductSellerState extends State<AddProductSeller> {

  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  var _prodname = '';
  var _stock = 0.0;
  var _price = 0.0;
  bool loading = false;
  
  @override
  Widget build(BuildContext context) {
   return loading ? Loading() : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Add New Product'),
        centerTitle: true,
      ),
    body: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 60.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(key: _formKey,
              child: Column(
                children: [
                  
                  // SizedBox(height: 50.0,),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.label, color: Colors.orange,),
                      labelText: 'Product Name',
                      labelStyle: GoogleFonts.openSans(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.black45)
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (val) => val!.isEmpty ? 'Please provide product name' : null,
                    onChanged: (val) {
                      setState(() => _prodname = val);
                    }
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.more_horiz, color: Colors.orange,),
                      labelText: 'Count',
                      labelStyle: GoogleFonts.openSans(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.black45)
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Stock count is required' : null,
                    onChanged: (val) {
                      setState(() => _stock = double.parse(val));
                    }
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Text('\u{20B9}', textAlign: TextAlign.center, style: GoogleFonts.roboto(color: Colors.orange, fontSize: 32),),//Icon(Icons.store, color: Colors.orange,),
                      labelText: 'Unit Price',
                      labelStyle: GoogleFonts.openSans(color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0),),
                        borderSide: BorderSide(width: 2.0, color: Colors.black45)
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (val) => val!.isEmpty ? 'Price is mandatory' : null,
                    onChanged: (val) {
                      setState(() => _price = double.parse(val));
                    }
                  ),
                  SizedBox(height: 50.0),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange),),
                    child: Text('Add Product'),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      var productid; 
                      await FirebaseFirestore.instance.collection('products').add({
                        'prodName' : _prodname,
                        'stockCount' : _stock,
                        'price' : _price,
                      }).then((docRef) => {productid = docRef.id});
                      await FirebaseFirestore.instance.collection('stores').doc(user!.uid).collection('products').doc(productid).set({
                        'prodName' : _prodname,
                        'stockCount' : _stock,
                        'price' : _price,
                      });
                      Navigator.of(context).pop();
                    }
                  ),
                ]),
            ),
          ]),
      ),
    );
  }
}