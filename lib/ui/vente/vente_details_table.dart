import 'package:flutter/material.dart';
import 'package:prestige_pos/model/client_user.dart';

import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:prestige_pos/model/vente/vente_detail.dart';
import 'package:prestige_pos/provider/vente_provider.dart';

class VenteDetailsScreen extends StatelessWidget {
  const VenteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final venteProvider = Provider.of<VenteProvider>(context, listen: false);
    return FutureBuilder<ClientUser?>(
      future: venteProvider.getCurrentUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Center(
            child: Text(
              'Erreur de chargement de l\'utilisateur: ${userSnapshot.error}',
            ),
          );
        }

        final clientUser = userSnapshot.data;

        final canUpdatePrice =
            clientUser?.privileges?.any((p) => p.name == Constants.canUpdatePrice) ??
            false;

        return Consumer<VenteProvider>(
          builder: (context, provider, child) {
            final vente = provider.currentVente;
            final details = vente?.items.content ?? [];
            return VenteDetailsTable(
              details: details,
              canUpdatePrice: canUpdatePrice,
              saleId: vente?.saleId,
              onEdit: (AddVenteItem item) async {
                await provider.updateItem(item);
              },
              onRemove: (VenteDetail it) {
                provider.removeItem(it.id);
              },
            );
          },
        );
      },
    );
  }
}

class VenteDetailsTable extends StatelessWidget {
  final List<VenteDetail> details;
  final void Function(AddVenteItem) onEdit;
  final void Function(VenteDetail) onRemove;
  final bool canUpdatePrice;
  final String? saleId;

  const VenteDetailsTable({
    Key? key,
    required this.details,
    required this.onEdit,
    required this.onRemove,
    required this.canUpdatePrice,
    required this.saleId,
  }) : super(key: key);

  void _showEditDialog(BuildContext context, VenteDetail detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _EditItemDialog(
          detail: detail,
          canUpdatePrice: canUpdatePrice,
          onUpdate: (int newQuantity, int newPrice) {
            final item = AddVenteItem(
              id: detail.id,
              saleId: saleId,
              produitId: detail.produitId,
              quantity: newQuantity,
              quantitySold: newQuantity,
              // Assuming quantity sold is the new quantity
              unitPrice: newPrice,
            );
            onEdit(item);
          },
        );
      },
    );
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildDataTable(context);
        } else {
          return _buildCardsList(context);
        }
      },
    );
  }

  Widget _buildCardsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final it = details[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${it.produitName} - ${it.produitCip}',

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('${it.quantity} x ${Constants.formatNumber(it.unitPrice)} = ${Constants.formatNumber(it.amount)}',  style: const TextStyle(fontSize: 15)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.blue,
                            ),
                            tooltip: 'Modifier',
                            onPressed: () => _showEditDialog(context, it),
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            padding: EdgeInsets.zero,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context) {
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
                          onPressed: () => _showEditDialog(context, it),
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

class _EditItemDialog extends StatefulWidget {
  final VenteDetail detail;
  final bool canUpdatePrice;
  final void Function(int newQuantity, int newPrice) onUpdate;

  const _EditItemDialog({
    Key? key,
    required this.detail,
    required this.canUpdatePrice,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.detail.quantity.toString(),
    );
    _priceController = TextEditingController(
      text: widget.detail.unitPrice.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newQuantity = int.parse(_quantityController.text);
      final newPrice = widget.canUpdatePrice
          ? int.parse(_priceController.text)
          : widget.detail.unitPrice;

      widget.onUpdate(newQuantity, newPrice);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier l\'article'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Quantité invalide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix unitaire'),
                keyboardType: TextInputType.number,
                readOnly: !widget.canUpdatePrice,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(Constants.btnAnnuler),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text(Constants.btnValider),
        ),
      ],
    );
  }
}
