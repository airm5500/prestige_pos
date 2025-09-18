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
import 'package:prestige_pos/utils/constants.dart';
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
          child: VenteDetailsScreen()
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
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    final venteProvider = context.watch<VenteProvider>();
    final CreateResponse? currentVente = venteProvider.currentVente;
    final VenteDetailWrapper? itemWrapper = currentVente?.items;
    final List<VenteDetail> items = itemWrapper?.content ?? [];
    final bool canFinalize = items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text(Constants.finalyseLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: canFinalize
              ? () {
                  _showFinalizeSheet();
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
          title: const Text(Constants.saisirQtyLabel),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: Constants.qunatityLabel),
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop();
              _submitQuantity(product, value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(Constants.BtnAnnuler),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(Constants.BtnAdd),
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

  void _showFinalizeSheet() {
    final venteProvider = context.read<VenteProvider>();
    final currentVente = venteProvider.currentVente;
    ModeReglement? selectedMode;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModeReglementSelector(
                    onSelected: (ModeReglement mode) {
                      setState(() {
                        selectedMode = mode;
                      });
                    },
                    initialValue: selectedMode,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text(Constants.terminerLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: selectedMode == null
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            if (currentVente != null) {
                              venteProvider
                                  .updateSelectedModeReglement(selectedMode!);
                              final ClotureVente clotureVente =
                                  ClotureVente.newClotureVente(
                                currentVente,
                                selectedMode!.id,
                                null,
                              );
                              venteProvider.finalizeVno(clotureVente);
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _submitQuantity(SearchProduitResult product, String quantity) async {
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
        await venteProvider.createVno(vente);
      } else {
        await venteProvider.addItem(item);
      }
    }
  }
}
