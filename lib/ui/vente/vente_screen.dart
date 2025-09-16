import 'package:flutter/material.dart';


class VenteScreen extends StatefulWidget {
  const VenteScreen({super.key});

  static const String routeName = '/vente';

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen> {




  @override
  void initState() {
    super.initState();

  }



  @override
  void dispose() {

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vente')),
      body: Center(child: Text('Une erreur est survenue :'))

    );
  }

}
