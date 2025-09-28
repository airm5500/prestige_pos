import 'package:flutter/material.dart';
import 'package:prestige_pos/provider/prevente_provider.dart';
import 'package:prestige_pos/provider/vente_provider.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:prestige_pos/utils/app_color.dart';

class PreventeListTab extends StatefulWidget {
  final TabController tabController;

  const PreventeListTab({Key? key, required this.tabController})
    : super(key: key);

  @override
  State<PreventeListTab> createState() => _PreventeListTabState();
}

class _PreventeListTabState extends State<PreventeListTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreventeProvider>().fetch(null);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PreventeProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Rechercher une pré-vente',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        provider.fetch(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _searchController.clear();
                      provider.fetch(null);
                    },
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
            ),
            if (provider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (provider.errorMessage != null)
              Expanded(child: Center(child: Text(provider.errorMessage!)))
            else if (provider.preventes.isEmpty)
              const Expanded(
                child: Center(child: Text('Aucune pré-vente trouvée')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: provider.preventes.length,
                  itemBuilder: (context, index) {
                    final prevente = provider.preventes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.receipt_long,
                          color: AppColor.primary,
                        ),
                        title: Text(
                          'Ref: ${prevente.saleRef}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${prevente.transactionDate} ${prevente.heure} - Vendeur: ${prevente.userName}',
                        ),
                        trailing: Text(
                          Constants.formatNumber(
                            prevente.montantNet ?? prevente.amount,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor.secondary,
                          ),
                        ),
                        onTap: () {
                          context.read<VenteProvider>().loadVente(prevente);
                          widget.tabController.animateTo(0);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
