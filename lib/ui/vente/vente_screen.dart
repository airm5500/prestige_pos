import 'package:flutter/material.dart';
import 'package:prestige_pos/auth/service/meta_data_service.dart';
import 'package:provider/provider.dart';

class VenteScreen extends StatefulWidget {
  const VenteScreen({super.key});

  static const String routeName = '/vente';

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen> {
  final searchCtl = TextEditingController();
  final searchFocus = FocusNode();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _fetchCommonData();
      }
    });
  }

  Future<void> _fetchCommonData() async {
    await Provider.of<MetaDataService>(
      context,
      listen: false,
    ).fetchAllMetaData(true);
  }

  @override
  void dispose() {
    searchCtl.dispose();
    searchFocus.dispose();
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
