import 'package:flutter/material.dart';
import 'package:gogetapp/services/fire_auth.dart';

class ShopperHome extends StatefulWidget {
  const ShopperHome({ Key? key }) : super(key: key);

  @override
  _ShopperHomeState createState() => _ShopperHomeState();
}

class _ShopperHomeState extends State<ShopperHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GoGet'),
        centerTitle: true,
        actions: [
          
          IconButton(onPressed: (){ AuthService().signOut(); }, icon: Icon(Icons.logout)),
          IconButton(onPressed: (){}, icon: Icon(Icons.power_settings_new))
        ],
      ),
    );
  }
}