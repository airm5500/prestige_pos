import 'package:flutter/material.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:prestige_pos/model/vente/vente_detail.dart';
import 'package:prestige_pos/provider/vente_provider.dart';

class VenteDetailsScreen extends StatelessWidget {
  const VenteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VenteProvider>(
      builder: (context, provider, child) {
        final vente = provider.currentVente;
        final details = vente?.items.content ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VenteDetailsTable(
              details: details,
              onEdit: (VenteDetail it) {
                final addVenteItem = AddVenteItem.fromVenteDetail(
                  it,
                  vente?.saleId,
                );
                provider.updateItem(addVenteItem);
              },
              onRemove: (VenteDetail it) {
                provider.removeItem(it.id);
              },
            ),

            const SizedBox(height: 12),

            // Totaux
            if (details.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Constants.formatCFA(vente?.amount ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class VenteDetailsTable extends StatelessWidget {
  final List<VenteDetail> details;
  final void Function(VenteDetail) onEdit;
  final void Function(VenteDetail) onRemove;

  const VenteDetailsTable({
    Key? key,
    required this.details,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Aucun produit ajouté'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: Colors.grey.shade100,
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Produit',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qté',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PU',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Rows
          for (final it in details) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      it.produitName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(flex: 2, child: Text('${it.quantity}')),
                  Expanded(
                    flex: 2,
                    child: Text(Constants.formatNumber(it.unitPrice)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(Constants.formatNumber(it.amount)),
                  ),
                  SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue,
                          ),
                          tooltip: 'Modifier',
                          onPressed: () => onEdit(it),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            size: 20,
                            color: Colors.red,
                          ),
                          tooltip: 'Supprimer',
                          onPressed: () => onRemove(it),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
