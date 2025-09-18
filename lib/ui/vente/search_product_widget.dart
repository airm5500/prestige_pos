import 'dart:async';

import 'package:flutter/material.dart';


import 'package:prestige_pos/model/vente/search_produit_result.dart';
import 'package:prestige_pos/provider/produit_provider.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';

class SearchProductWidget extends StatefulWidget {
  final Function(SearchProduitResult) onProductSelected;
  final bool showStocks;

  const SearchProductWidget({
    super.key,
    required this.onProductSelected,
    required this.showStocks,
  });

  @override
  State<SearchProductWidget> createState() => _SearchProductWidgetState();
}

class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() => _timer?.cancel();
}

class _SearchProductWidgetState extends State<SearchProductWidget> {
  final searchCtl = TextEditingController();
  final searchFocus = FocusNode();
  final debouncer = Debouncer(milliseconds: 400);
  List<SearchProduitResult> results = [];
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(searchFocus);
    });
  }

  @override
  void dispose() {
    searchCtl.dispose();
    searchFocus.dispose();
    debouncer.dispose();
    super.dispose();
  }


  Future<void> _search(String searchTerm) async {
    final produitProvider = context.read<ProduitProvider>();
    if (searchTerm.length <= 2) {
      produitProvider.clearProduits();
      debouncer.run(() {}); // cancel any pending search
      return;
    }
    debouncer.run(() async {
      await produitProvider.fetchProduits(search: searchTerm, pageSize: 5);

      if (!mounted) return;

      final results = produitProvider.produits;
      if (results.isNotEmpty && !_sheetOpen) {
        _openResultsSheet(results);
      }
    });
  }

  void _openResultsSheet(List<SearchProduitResult> results) {
    if (_sheetOpen || results.isEmpty) return;
    _sheetOpen = true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Material(
              child: ListView.builder(
                controller: controller,
                itemCount: results.length + 1,
                itemBuilder: (c, i) {
                  if (i == 0) {
                    return const ListTile(
                      title: Text('Résultats de recherche'),
                      subtitle: Text('Touchez un article pour l’ajouter'),
                    );
                  }
                  final p = results[i - 1];
                  return _resultCard(p);
                },
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _sheetOpen = false;
      if(!mounted) return;
      FocusScope.of(context).requestFocus(searchFocus);
    });
  }

  Widget _resultCard(SearchProduitResult p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          widget.onProductSelected(p);
        },
        child: Container(
          decoration: BoxDecoration(
            color: _chipBg(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.libelle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CIP: ${p.codeCip}${widget.showStocks ? '  •  Stock: ${p.quantity}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Constants.formatCFA(p.regularUnitPrice),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _chipBg(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer.withAlpha((255 * 0.18).round());//TODO deplacer dans un service de theme

  @override
  Widget build(BuildContext context) {
    return Consumer<ProduitProvider>(
      builder: (context, provider, child) {
        return TextField(
          controller: searchCtl,
          focusNode: searchFocus,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Recherche produit (CIP / nom)',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Voir résultats',
                  icon: const Icon(Icons.list),
                  onPressed: provider.produits.isEmpty
                      ? null
                      : () => _openResultsSheet(provider.produits),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchCtl.clear();
                    provider.clearProduits();
                    FocusScope.of(context).requestFocus(searchFocus);
                  },
                ),
              ],
            ),
          ),
          onChanged: _search,
          onSubmitted: (v) async {
            debouncer.run(() {}); // cancel any pending search
            if (v.length > 2) {
              await provider.fetchProduits(search: v, pageSize: 5);
              if (!mounted) return;

              if (provider.produits.length == 1) {
                widget.onProductSelected(provider.produits.first);
              } else {
                _openResultsSheet(provider.produits);
              }
            } else {
              provider.clearProduits();
            }
          },
        );
      },
    );
  }
}