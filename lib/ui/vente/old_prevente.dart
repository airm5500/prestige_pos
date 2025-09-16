/*
class _PreventePageState extends State<PreventePage> {
  final api = ApiService();

  // Listes
  List<TypeVente> typeVentes = [];
  List<NatureVente> natures = [];
  List<Reglement> reglements = [];
  List<RemiseClient> remises = [];

  // Sélection
  String selectedTypeVenteId = AppConfig.defaultTypeVenteId;
  String selectedNatureVenteId = AppConfig.defaultNatureVenteId;
  String? selectedRemiseId;

  // Vente courante
  String? venteId;
  String? venteRef;
  List<VenteItem> panier = [];
  NetVente? net;

  // Autorisations
  bool canEditPrice = true;
  bool showStocks = true;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    setState(() => loading = true);
    try {
      if (appSession.officineNomComplet.isEmpty ||
          appSession.officineFullName.isEmpty) {
        await api.fetchOfficine();
      }

      final tv = await api.fetchTypeVentes();
      final nv = await api.fetchNatures();
      final rg = await api.fetchReglements();
      final rm = await api.fetchRemises();
      bool can = true;
      bool ss = true;
      try {
        can = await api.autorisationPrixVente();
      } catch (_) {}
      try {
        ss = await api.showStock();
      } catch (_) {}
      setState(() {
        typeVentes = tv;
        natures = nv;
        reglements = rg;
        remises = rm;
        canEditPrice = can;
        showStocks = ss;
      });
    } catch (e) {
      showSnack(context, 'Init: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addProduit(SearchProduitResult p, {int qte = 1}) async {
    try {
      if (venteId == null) {
        final r = await api.addFirstItemVno(
          typeVenteId: selectedTypeVenteId,
          natureVenteId: selectedNatureVenteId,
          produitId: p.id,
          itemPu: p.regularUnitPrice,
          qte: qte,
          qteServie: qte,
          prevente: true,
          remiseId: selectedRemiseId,
        );
        venteId = r.venteId;
        venteRef = r.venteRef;
      } else {
        await api.addItem(
          typeVenteId: selectedTypeVenteId,
          natureVenteId: selectedNatureVenteId,
          produitId: p.id,
          itemPu: p.regularUnitPrice,
          qte: qte,
          qteServie: qte,
          venteId: venteId!,
          prevente: true,
          remiseId: selectedRemiseId,
        );
      }
      await _reloadPanier();
    } catch (e) {
      showSnack(context, 'Ajout produit: $e');
    }
  }

  Future<void> _reloadPanier() async {
    if (venteId == null) {
      setState(() {
        panier = [];
        net = null;
      });
      return;
    }
    final items = await api.fetchDetails(venteId!);
    final n = await api.netVno();
    setState(() {
      panier = items;
      net = n;
    });
  }

  Future<void> _removeItem(VenteItem it) async {
    final ok = await api.removeItem(it.itemId);
    if (ok) {
      await _reloadPanier();
    } else {
      showSnack(context, 'Suppression échouée');
    }
  }

  Future<void> _editItem(VenteItem it) async {
    final qCtl = TextEditingController(text: it.qty.toString());
    final puCtl = TextEditingController(text: it.pu.toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(it.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: qCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: puCtl,
              enabled: canEditPrice,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PU',
                helperText: canEditPrice
                    ? null
                    : 'Modification du prix non autorisée',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final newQty = int.tryParse(qCtl.text.trim()) ?? it.qty;
    final newPu = int.tryParse(puCtl.text.trim()) ?? it.pu;
    final success = await api.updateItem(
      itemId: it.itemId,
      produitId: it.produitId,
      itemPu: newPu,
      qte: newQty,
      qteServie: newQty,
    );
    if (!success) {
      showSnack(context, 'Échec modification');
      return;
    }
    await _reloadPanier();
  }

  Future<bool> _ensurePrinter() async {
    try {
      final ok = await SunmiPrinter.bindingPrinter();
      if (!ok!) {
        showSnack(context, "Impossible de se lier à l'imprimante Sunmi");
        return false;
      }
      try {
        await SunmiPrinter.initPrinter();
      } catch (_) {}
      return true;
    } catch (e) {
      showSnack(context, 'Sunmi non disponible: $e');
      return false;
    }
  }

  Future<void> _testPrint() async {
    if (!await _ensurePrinter()) return;
    try {
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printText(
        '*** TEST IMPRESSION ***',
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );
      await SunmiPrinter.printText('Modèle interne Sunmi', style: SunmiStyle());
      await SunmiPrinter.lineWrap(3);
    } catch (e) {
      showSnack(context, 'Test impression: $e');
    } finally {
      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {}
    }
  }

  Future<void> _printTicket() async {
    if (!await _ensurePrinter()) return;
    try {
      const int cols = 32;
      String line([String ch = '-']) => List.filled(cols, ch).join();
      String fit(String s, int len) {
        final t = s.replaceAll("\n", " ");
        if (t.runes.length <= len) return t.padRight(len);
        return String.fromCharCodes(t.runes.take(len));
      }

      String r(int v, int len) => v.toString().padLeft(len);

      await SunmiPrinter.startTransactionPrint(true);

      final now = DateTime.now();
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      // >>> Entête: NOM PHARMACIE (nomComplet), pas le pharmacien
      final head = appSession.officineNomComplet.isNotEmpty
          ? appSession.officineNomComplet
          : (appSession.officineAuthName.isNotEmpty
                ? appSession.officineAuthName
                : 'PHARMACIE');
      await SunmiPrinter.printText(
        head.toUpperCase(),
        style: SunmiStyle(bold: true, fontSize: SunmiFontSize.MD),
      );
      if (appSession.address.isNotEmpty) {
        await SunmiPrinter.printText(appSession.address, style: SunmiStyle());
      }
      if (appSession.phone.isNotEmpty) {
        await SunmiPrinter.printText(
          'Tél: ${appSession.phone}',
          style: SunmiStyle(),
        );
      }

      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText(line());
      await SunmiPrinter.printText(
        "Date: ${DateFormat("dd/MM/yyyy HH:mm").format(now)}",
      );
      await SunmiPrinter.printText(line());

      // En-têtes colonnes (32: 18 | 2 | 5 | 7) — nous affichons Qt sur la 1ère ligne avec *(n)
      await SunmiPrinter.printText(
        fit('Article', 18) + fit('Qt', 2) + fit('PU', 5) + fit('Total', 7),
        style: SunmiStyle(bold: true),
      );

      final items = panier.isEmpty && (venteId != null)
          ? await api.fetchDetails(venteId!)
          : panier;
      for (final it in items) {
        // Ligne 1: Nom + *(qte)
        final tag = ' *(${it.qty})';
        final maxName = cols - tag.length;
        final name = fit(it.name, maxName);
        await SunmiPrinter.printText(
          name + tag,
          style: SunmiStyle(fontSize: SunmiFontSize.SM),
        );
        // Ligne 2: colonnes PU/Total alignées (18|2|5|7)
        final left = ' ' * 20;
        final pu = r(it.pu, 5);
        final tot = r(it.total, 7);
        await SunmiPrinter.printText(left + pu + tot);
      }

      await SunmiPrinter.printText(line());

      // Totaux
      final n = await api.netVno();
      final montant = n?.montant ?? items.fold<int>(0, (a, b) => a + b.total);
      final remise = n?.remise ?? 0;
      final netAPayer = (n?.montantNet ?? (montant - remise));

      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      await SunmiPrinter.printText('Montant: ${formatCFA(montant)}');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.LEFT);
      await SunmiPrinter.printText('Remise:  ${formatCFA(remise)}');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
      await SunmiPrinter.printText(
        'NET À PAYER: ${formatCFA(netAPayer)}',
        style: SunmiStyle(bold: true),
      );

      // QR code: afficher la référence/ID sans préfixe
      final code = (venteRef != null && venteRef!.isNotEmpty)
          ? venteRef!
          : (venteId ?? 'VENTE');
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
      await SunmiPrinter.printQRCode(code);
      await SunmiPrinter.printText(code);

      await SunmiPrinter.lineWrap(3);
      try {
        await SunmiPrinter.cut();
      } catch (_) {}
    } catch (e) {
      showSnack(context, 'Impression: $e');
    } finally {
      try {
        await SunmiPrinter.exitTransactionPrint(true);
      } catch (_) {}
    }
  }

  Future<void> _chooseRemiseFlow() async {
    if (remises.isEmpty) {
      try {
        remises = await api.fetchRemises();
      } catch (_) {}
    }

    String? tmpId = selectedRemiseId;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Choisir une remise'),
                subtitle: Text('La remise s’applique à la vente en cours'),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: remises.length,
                  itemBuilder: (c, i) {
                    final r = remises[i];
                    return RadioListTile<String?>(
                      title: Text(r.label),
                      value: r.id,
                      groupValue: tmpId,
                      onChanged: (v) => setState(() => tmpId = v),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Appliquer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) return;

    selectedRemiseId = tmpId;

    if (venteId != null) {
      if (selectedRemiseId != null) {
        final applied = await api.applyRemise(
          remiseId: selectedRemiseId!,
          venteId: venteId!,
        );
        if (!applied) {
          showSnack(context, 'Application de la remise échouée');
        }
      }
      await _reloadPanier();
    } else {
      showSnack(
        context,
        'Remise sélectionnée: elle sera appliquée au premier ajout.',
      );
    }
  }

  Future<void> _terminerPrevente() async {
    if (venteId == null) return;
    final ok = await api.terminerPrevente(venteId!);
    if (!ok) {
      showSnack(context, 'Échec terminer prévente');
      return;
    }

    final wantPrint = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impression'),
        content: const Text('Voulez-vous imprimer le ticket ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (wantPrint == true) await _printTicket();

    setState(() {
      venteId = null;
      venteRef = null;
      panier = [];
      net = null;
      selectedTypeVenteId = AppConfig.defaultTypeVenteId;
      selectedNatureVenteId = AppConfig.defaultNatureVenteId;
      selectedRemiseId = null;
    });
    await _initAll();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topBar = Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedTypeVenteId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Type de vente'),
            items: typeVentes
                .map(
                  (e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: null, // grisé
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedNatureVenteId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Nature de vente'),
            items: natures
                .map(
                  (e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.libelle, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: null, // grisé
          ),
        ),
      ],
    );

    final searchBox = SearchProductWidget(
      api: api,
      showStocks: showStocks,
      onProductSelected: (p) => _addProduit(p),
    );

    // ==== Corps scrollable ====
    final List<Widget> listChildren = [
      // (Demandé) Pas d'affichage nomComplet + fullName sur la page Prévente
      topBar,
      const SizedBox(height: 12),
      searchBox,
      const SizedBox(height: 12),

      // Panier
      if (panier.isEmpty)
        Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Panier vide'),
        )
      else
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (final it in panier) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne 1: nom
                      Text(
                        it.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Ligne 2: QTE/PU + actions
                      Row(
                        children: [
                          Text('QTE: ${it.qty}  /  PU: ${formatCFA(it.pu)}'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Modifier',
                            onPressed: () => _editItem(it),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever, size: 20),
                            tooltip: 'Supprimer',
                            onPressed: () => _removeItem(it),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ],
          ),
        ),

      const SizedBox(height: 12),

      // Totaux
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Montant',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formatCFA(
                      net?.montant ??
                          panier.fold<int>(0, (a, b) => a + b.total),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Net à payer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    formatCFA(
                      net?.montantNet ??
                          ((net?.montant ??
                                  panier.fold<int>(0, (a, b) => a + b.total)) -
                              (net?.remise ?? 0)),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 8),

      // Actions : Remise + Terminer
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.percent),
              label: Text(
                selectedRemiseId == null ? 'Remise' : 'Remise (appliquée)',
              ),
              onPressed: _chooseRemiseFlow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Terminer prévente'),
              onPressed: (venteId == null) ? null : _terminerPrevente,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévente / Vente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _testPrint,
            tooltip: 'Test imprimante',
          ),
          IconButton(
            tooltip: appSession.useLocal
                ? 'Basculer vers Distant'
                : 'Basculer vers Local',
            icon: Icon(appSession.useLocal ? Icons.wifi : Icons.public),
            onPressed: () async {
              appSession.useLocal = !appSession.useLocal;
              final sp = await SharedPreferences.getInstance();
              await sp.setBool('useLocal', appSession.useLocal);
              setState(() {
                venteId = null;
                venteRef = null;
                panier = [];
                net = null;
              });
              _initAll();
            },
          ),
          if (venteRef != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text('Réf: $venteRef')),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await api
                  .logout(); // supprime cookie, garde login/pwd si rememberMe=true
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(children: listChildren),
              ),
            ),
    );
  }
}
 */