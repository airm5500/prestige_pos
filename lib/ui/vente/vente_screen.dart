import 'package:flutter/material.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/model/vente/cloture_vente.dart';
import 'package:prestige_pos/model/vente/create_response.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/model/vente/add_remise.dart';
import 'package:prestige_pos/model/vente/remise.dart';
import 'package:prestige_pos/model/vente/search_produit_result.dart';
import 'package:prestige_pos/model/vente/vente.dart';
import 'package:prestige_pos/model/vente/vente_detail.dart';
import 'package:prestige_pos/model/vente/vente_detail_wrapper.dart';
import 'package:prestige_pos/provider/vente_provider.dart';
import 'package:prestige_pos/ui/vente/mode_reglement_selector.dart';
import 'package:prestige_pos/ui/vente/remise_selector.dart';
import 'package:prestige_pos/ui/vente/search_product_widget.dart';
import 'package:prestige_pos/ui/vente/vente_details_table.dart';
import 'package:provider/provider.dart';

class VenteScreen extends StatefulWidget {
  const VenteScreen({super.key});

  static const String routeName = '/vente';

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen> {
  static const String title = 'Vente';
  static const bool isPrevente = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenteProvider>().createNewVente();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Vente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ventes en attente',
            onPressed: () {
              // TODO: Navigate to old prevente screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Nouvelle vente',
            onPressed: () {
              context.read<VenteProvider>().createNewVente();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return _buildDesktopLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 3,
          child: VenteDetailsScreen(), // Contains table and totals
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildControlsColumn()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlsColumn(),
          const SizedBox(height: 16),
          const VenteDetailsScreen(),
        ],
      ),
    );
  }

  Widget _buildControlsColumn() {
    final venteProvider = context.watch<VenteProvider>();
    final currentVente = venteProvider.currentVente;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchProductWidget(
          onProductSelected: (SearchProduitResult product) {
            _showQuantityDialog(product);
          },
          showStocks: true,
        ),
        const SizedBox(height: 24),
        RemiseSelector(
          onSelected: (Remise remise) {
            if (currentVente != null) {
              final addRemise = AddRemise.newAddRemise(
                currentVente.saleId,
                remise.id,
              );
              venteProvider.addRemise(addRemise);
            }
          },
        ),
        const SizedBox(height: 16),
        ModeReglementSelector(
          onSelected: (ModeReglement mode) {
            venteProvider.updateSelectedModeReglement(mode);
          },
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    final venteProvider = context.watch<VenteProvider>();
    final ModeReglement? selectedMode = venteProvider.selectedModeReglement;
    final String modeId = selectedMode?.id ?? '';
    final CreateResponse? currentVente = venteProvider.currentVente;
    final VenteDetailWrapper? itemWrapper = currentVente?.items;
    final List<VenteDetail> items = itemWrapper?.content ?? [];
    final bool canFinalize = modeId.isNotEmpty && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('FINALISER LA VENTE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: canFinalize
              ? () {
                  if (currentVente != null) {
                    final ClotureVente clotureVente =
                        ClotureVente.newClotureVente(
                          currentVente,
                          modeId,
                          null,
                        );
                    venteProvider.finalizeVno(clotureVente);
                  }
                }
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: canFinalize
                    ? () {
                        //not yet implemented
                      }
                    : null,
                child: const Text('Mettre en attente'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextButton(
                child: const Text('Annuler'),
                onPressed: () {
                  context.read<VenteProvider>().createNewVente();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showQuantityDialog(SearchProduitResult product) {
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Quantité pour ${product.name}'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Quantité'),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop();
              _submitQuantity(product, value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                final String quantity = quantityController.text;
                Navigator.of(dialogContext).pop();
                _submitQuantity(product, quantity);
              },
            ),
          ],
        );
      },
    );
  }

  void _submitQuantity(SearchProduitResult product, String quantity) {
    final int? requestedQuantity = int.tryParse(quantity);
    if (requestedQuantity != null && requestedQuantity > 0) {
      final venteProvider = context.read<VenteProvider>();
      final currentVente = venteProvider.currentVente;
      final item = AddVenteItem.produit(
        product,
        requestedQuantity,
        currentVente?.saleId,
      );
      if (currentVente == null) {
        final vente = Vente.newVente(item, isPrevente);
        venteProvider.createVno(vente);
      } else {
        venteProvider.addItem(item);
      }
    }
  }
}
