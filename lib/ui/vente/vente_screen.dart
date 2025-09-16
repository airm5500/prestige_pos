import 'package:flutter/material.dart';
import 'package:prestige_pos/model/vente/add_vente_item.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/model/vente/add_remise.dart';
import 'package:prestige_pos/model/vente/remise.dart';
import 'package:prestige_pos/model/vente/search_produit_result.dart';
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
            final item = AddVenteItem.produit(product, 1, currentVente?.saleId);
            venteProvider.addItem(item);

          },
          showStocks: true,
        ),
        const SizedBox(height: 24),
        RemiseSelector(
          onSelected: (Remise remise) {
            if (currentVente != null) {
              final addRemise = AddRemise.newAddRemise(
                currentVente.saleId,
                remise.id!,
              );
              venteProvider.addRemise(addRemise);
            }
          },
        ),
        const SizedBox(height: 16),
        ModeReglementSelector(
          onSelected: (ModeReglement mode) {
            // This might be more complex, involving adding a payment
            // For now, let's just store it in the provider
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
    final bool canFinalize =
        venteProvider.currentVente != null &&
        venteProvider.currentVente!.items.content.isNotEmpty;

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
                  // TODO: Implement finalization logic
                  // e.g., show confirmation dialog, process payment
                }
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                child: const Text('Mettre en attente'),
                onPressed: canFinalize
                    ? () {
                        // TODO: Implement prevente logic
                      }
                    : null,
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
}
