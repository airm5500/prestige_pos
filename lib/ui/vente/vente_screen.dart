import 'package:flutter/material.dart';
import 'package:prestige_pos/provider/mode_reglement_provider.dart';
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
import 'package:prestige_pos/ui/vente/prevente_list_tab.dart';
import 'package:prestige_pos/ui/vente/remise_selector.dart';
import 'package:prestige_pos/ui/vente/search_product_widget.dart';
import 'package:prestige_pos/ui/vente/vente_details_table.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:prestige_pos/utils/navigation_service.dart';
import 'package:prestige_pos/service/receipt_service.dart';

class VenteScreen extends StatefulWidget {
  final ReceiptService receiptService;

  const VenteScreen({super.key, required this.receiptService});

  static const String routeName = '/vente';

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;

    final provider = context.read<VenteProvider>();
    if (provider.isFromPrevente) {
      provider.resetPreventeFlag();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.homeBtnVenteLabel),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: Constants.venteTab),
            Tab(text: Constants.preventeTab),
            Tab(text: Constants.preventeListTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VenteTab(receiptService: widget.receiptService, isPrevente: false),
          VenteTab(receiptService: widget.receiptService, isPrevente: true),
          PreventeListTab(tabController: _tabController),
        ],
      ),
    );
  }
}

class VenteTab extends StatefulWidget {
  final ReceiptService receiptService;
  final bool isPrevente;

  const VenteTab({
    super.key,
    required this.receiptService,
    required this.isPrevente,
  });

  @override
  State<VenteTab> createState() => _VenteTabState();
}

class _VenteTabState extends State<VenteTab> {
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        final currentVente = context.read<VenteProvider>().currentVente;
        if (currentVente != null) {
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Quitter?'),
                content: const Text(
                  'Voulez-vous vraiment quitter? La vente en cours sera annulée.',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Annuler'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Quitter'),
                    onPressed: () {
                      context.read<VenteProvider>().createNewVente();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Consumer<VenteProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Constants.showSnack(context, provider.errorMessage!);
              provider.clearError();
            });
          }
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return _buildDesktopLayout();
                    } else {
                      return _buildMobileLayout();
                    }
                  },
                ),
              ),
              if (provider.isLoading)
                const Opacity(
                  opacity: 0.8,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                ),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildControlsColumn(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildSummaryAndActions(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(flex: 5, child: VenteDetailsScreen()),

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
          _buildSummaryAndActions(),
        ],
      ),
    );
  }

  Widget _buildControlsColumn() {
    return SearchProductWidget(
      onProductSelected: (SearchProduitResult product) async {
        _showQuantityDialog(product);
      },
      showStocks: true,
      focusNode: _searchFocusNode,
      controller: _searchController,
    );
  }

  Widget _buildSummaryAndActions() {
    final venteProvider = context.watch<VenteProvider>();
    final vente = venteProvider.currentVente;
    final details = vente?.items.content ?? [];

    if (details.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: _buildActionButtons(),
      );
    }

    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(top: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vente != null && (vente.discount ?? 0) > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    Constants.totalVenteLabel,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    Constants.formatCFA(vente.amount),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    Constants.remise,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  Text(
                    Constants.formatCFA(vente.discount ?? 0),
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  Constants.totalPayer,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  Constants.formatCFA(
                    (vente?.montantNet != null && vente!.montantNet! > 0)
                        ? vente.montantNet ?? 0
                        : vente?.amount ?? 0,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            RemiseSelector(
              onSelected: (Remise remise) {
                if (vente != null) {
                  final addRemise = AddRemise.newAddRemise(
                    vente.saleId,
                    remise.id,
                  );
                  venteProvider.addRemise(addRemise);
                }
              },
            ),
            const SizedBox(height: 8),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  void _showPrintPreventeDialog() {
    final venteProvider = context.read<VenteProvider>();
    final currentVente = venteProvider.currentVente;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(Constants.preventeAlertTitle),
          content: const Text(Constants.preventeReceiptLabel),
          actions: <Widget>[
            TextButton(
              child: const Text(Constants.btnAnnuler),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text(Constants.btnPrint),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (currentVente != null) {
                  final isSuccess = await widget.receiptService
                      .printPreventeReceipt(
                        context: NavigationService.navigatorKey.currentContext!,
                        currentSale: currentVente,
                      );
                  if (isSuccess) {
                    venteProvider.createNewVente();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    final venteProvider = context.watch<VenteProvider>();
    final CreateResponse? currentVente = venteProvider.currentVente;
    final isProgress = currentVente?.isInProgress;
    final VenteDetailWrapper? itemWrapper = currentVente?.items;
    final List<VenteDetail> items = itemWrapper?.content ?? [];
    final bool canFinalize =
        items.isNotEmpty && (isProgress == true) && !widget.isPrevente;

    final bool canProcessPrevente = widget.isPrevente && items.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: widget.isPrevente
                ? const Icon(Icons.sailing)
                : const Icon(Icons.check_circle),
            label: Text(
              widget.isPrevente
                  ? Constants.finalysePreventeLabel
                  : Constants.finalyseLabel,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: canFinalize
                ? () {
                    _showFinalizeSheet();
                  }
                : canProcessPrevente
                ? () {
                    _showPrintPreventeDialog();
                  }
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context.read<VenteProvider>().createNewVente();
            },
            child: const Text(Constants.newBtnLabel),
          ),
        ),
      ],
    );
  }

  void _handleQuantitySubmission(
    String value,
    SearchProduitResult product,
  ) async {
    final int? requestedQuantity = int.tryParse(value);
    if (requestedQuantity == null || requestedQuantity <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Constants.inavlideNumberInputLabel)),
      );
      return;
    }

    if (requestedQuantity > product.quantity) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text(Constants.stockInsuffisantMsg),
            content: Text(
             Constants.stockInsuffisantLabel.replaceFirst('%s', '${product.quantity}'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(Constants.btnNo),
                onPressed: () {
                  Navigator.of(alertContext).pop(false);
                },
              ),
              ElevatedButton(
                child: const Text(Constants.btnYes),
                onPressed: () {
                  Navigator.of(alertContext).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (confirmed == true) {
        _submitQuantity(product, requestedQuantity.toString());
      }
    } else {
      _submitQuantity(product, value);
    }
  }

  void _showQuantityDialog(SearchProduitResult product) {
    final TextEditingController quantityController = TextEditingController(
      text: '1',
    );

    showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(Constants.saisirQtyLabel),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: Constants.qunatityLabel,
              ),
              onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(Constants.btnAnnuler),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text(Constants.btnAdd),
              onPressed: () {
                Navigator.of(dialogContext).pop(quantityController.text);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        _handleQuantitySubmission(value, product);
      }
    });
  }

  void _showFinalizeSheet() {
    final venteProvider = context.read<VenteProvider>();
    final currentVente = venteProvider.currentVente;
    ModeReglement? selectedMode;

    final modeReglementProvider = context.read<ModeReglementProvider>();
    if (modeReglementProvider.modeReglements.isEmpty) {
      modeReglementProvider.fetch();
    }

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Consumer<ModeReglementProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (provider.errorMessage != null && provider.errorMessage!.isNotEmpty) {
                                return Text(provider.errorMessage!, style: const TextStyle(color: Colors.red));
                              }
                              if (provider.modeReglements.isEmpty) {
                                return const Text("Aucun mode de règlement disponible");
                              }

                              // TODO: groupValue and onChanged are deprecated.
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.modeReglements.length,
                                itemBuilder: (context, index) {
                                  final mode = provider.modeReglements[index];


                                  return RadioListTile<ModeReglement>(
                                    title: Text(mode.libelle),
                                    selectedTileColor: Colors.green.withOpacity(0.1),
                                    value: mode,
                                    groupValue: selectedMode,
                                    onChanged: (ModeReglement? value) {
                                      setState(() {
                                        selectedMode = value;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
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
                              : () async {
                                  Navigator.pop(ctx);
                                  if (currentVente != null) {
                                    venteProvider.updateSelectedModeReglement(
                                      selectedMode!,
                                    );
                                    final ClotureVente clotureVente =
                                        ClotureVente.newClotureVente(
                                          currentVente,
                                          selectedMode!.id,
                                          null,
                                        );
                                    final finalyseResponse = await venteProvider
                                        .finalizeVno(clotureVente);

                                    if (finalyseResponse != null && mounted) {
                                      await showDialog<void>(
                                        context: NavigationService.navigatorKey.currentContext!,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text(
                                              Constants.printReciptTitle,
                                            ),
                                            content: const Text(
                                              Constants.printReciptMessage,
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text(Constants.btnNon),
                                                onPressed: () {
                                                  venteProvider.createNewVente();
                                                  NavigationService.navigatorKey.currentState?.pop();
                                                },
                                              ),
                                              ElevatedButton(
                                                child: const Text(
                                                  Constants.btnPrint,
                                                ),
                                                onPressed: () async {
                                                  final isSuccess = await widget
                                                      .receiptService
                                                      .printTicket(
                                                        NavigationService.navigatorKey.currentContext!,
                                                        currentVente,
                                                        selectedMode!,
                                                      );
                                                  if (isSuccess) {
                                                    venteProvider.createNewVente();
                                                  }
                                                  NavigationService.navigatorKey.currentState?.pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
        final vente = Vente.newVente(item, widget.isPrevente);
        await venteProvider.createVno(vente);
      } else {
        await venteProvider.addItem(item);
      }
      _searchController.clear();
      _searchFocusNode.requestFocus();
    }
  }
}
