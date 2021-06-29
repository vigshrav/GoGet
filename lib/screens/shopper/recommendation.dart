import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommScreen extends StatefulWidget {
  const RecommScreen({ Key? key }) : super(key: key);

  @override
  _RecommScreenState createState() => _RecommScreenState();
}

class _RecommScreenState extends State<RecommScreen> {

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    double stRating;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Store Recommendations'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Container(
          height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                height: 0.04 * (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom)),
                padding: const EdgeInsets.fromLTRB(40.0, 0, 0.0, 0),
                  child:Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Store')),
                      Expanded(child: Text('Distance')),
                      Expanded(child: Text('Bill')),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.86,
                      child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('suggestions').orderBy('score').snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if( !snapshot.hasData ){ return new Text('Loading...'); }
                          else return ListView(
                            children: snapshot.data!.docs.map(
                              (DocumentSnapshot document) {
                                var stRating = (document.data() as dynamic)['rating'];
                                return Container(
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),),),
                                  child: ExpansionTile(
                                    textColor: Colors.black,
                                    collapsedTextColor: Colors.black,
                                    title: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text((document.data() as dynamic)['storeName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0))),
                                        Expanded(child: Text('${(document.data() as dynamic)['distance']} kms', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 12.0))),
                                        Expanded(child: Text('\u20B9 ${(document.data() as dynamic)['totalCost']}', textAlign: TextAlign.center, style: GoogleFonts.openSans(fontSize: 12.0))),
                                      ],
                                    ),
                                    // subtitle: Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Text((document.data() as dynamic)['storeAdd'],),
                                    //     Text((document.data() as dynamic)['storePhNo'],)
                                    //   ],
                                    // ),
                                    children: [
                                      Container(
                                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)),
                                        child: Column(
                                          children: [
                                            Row(mainAxisSize: MainAxisSize.max,
                                              children: [
                                                
                                                Container(padding: EdgeInsets.only(left: 10.0),
                                                  width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)) * 0.75,
                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Address :', style: GoogleFonts.openSans(fontWeight: FontWeight.bold),),
                                                      SizedBox(height: 5,),
                                                      Text((document.data() as dynamic)['storeAdd'],),
                                                      SizedBox(height: 5,),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.phone, size: 18.0,),
                                                          SizedBox(width: 10.0,),
                                                          Text((document.data() as dynamic)['storePhNo'],),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)) * 0.25,
                                                  child:_showRating(stRating)),

                                              ],
                                            ),
                                            Divider(color: Colors.grey,),
                                            SingleChildScrollView(
                                              child: Container(
                                                padding: const EdgeInsets.only(top: 5.0),
                                                height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.5,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                    height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom)) * 0.04,
                                                    width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)),
                                                    // padding: const EdgeInsets.only(top: 25.0),
                                                      child:Row(//mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          Container(
                                                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.5,
                                                            padding: EdgeInsets.only(right: 70),
                                                            child: Text('Item'), alignment: Alignment.center,),
                                                          Container(
                                                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                            child: Text('Unit Price'), alignment: Alignment.centerLeft,),
                                                          Container(
                                                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                            padding: EdgeInsets.only(right: 50),
                                                            child: Text('Qty'), alignment: Alignment.center,),
                                                          Container(
                                                            width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.1,
                                                            child: Text('Cost'), alignment: Alignment.centerLeft,)
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right)),
                                                      height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom))*0.4,
                                                      child: StreamBuilder(
                                                        stream: document.reference.collection('prods').snapshots(),
                                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> prodsnapshot) {
                                                          if( !prodsnapshot.hasData ){ return new Text('Loading...'); }
                                                          else return ListView(
                                                            children: prodsnapshot.data!.docs.map(
                                                              (DocumentSnapshot proddocument) {
                                                                return ListTile(
                                                                  title: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.4,
                                                                        child: Text((proddocument.data() as dynamic)['prodName'], style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0)), alignment: Alignment.centerLeft),
                                                                      Container(
                                                                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,                                                                        child: Text('${(proddocument.data() as dynamic)['unitPrice']}', style: GoogleFonts.openSans(fontSize: 14.0)), alignment: Alignment.center),
                                                                      Container(
                                                                        width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                                        child: Text('${(proddocument.data() as dynamic)['qty']}', style: GoogleFonts.openSans(fontSize: 14.0)), alignment: Alignment.center),
                                                                      // Container(
                                                                      //   width: (MediaQuery.of(context).size.width - (MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right))*0.2,
                                                                      //   child: Text('${(proddocument.data() as dynamic)['cost']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0)), alignment: Alignment.center),
                                                                    ],
                                                                  ),
                                                                  trailing: Text('${(proddocument.data() as dynamic)['cost']}', style: GoogleFonts.openSans(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                                                );
                                                              }).toList(),
                                                          );
                                                        }
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),  
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                            ).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
      ),
    );        
  }
  _showRating(double rating){
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 20.0,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
      },
    );
  }
}