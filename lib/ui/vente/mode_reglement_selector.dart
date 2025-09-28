import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/provider/mode_reglement_provider.dart';

class ModeReglementSelector extends StatefulWidget {
  final Function(ModeReglement) onSelected;
  final ModeReglement? initialValue;
  final bool useBottomSheet; // Pour choisir entre dialog ou BottomSheet

  const ModeReglementSelector({
    super.key,
    required this.onSelected,
    this.initialValue,
    this.useBottomSheet = false,
  });

  @override
  State<ModeReglementSelector> createState() => _ModeReglementSelectorState();
}

class _ModeReglementSelectorState extends State<ModeReglementSelector> {
  ModeReglement? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ModeReglementProvider>();
      if (provider.modeReglements.isEmpty) {
        provider.fetch();
      }
    });
  }

  void _openBottomSheet(List<ModeReglement> modes) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return ListView.builder(
          itemCount: modes.length,
          itemBuilder: (_, i) {
            final mode = modes[i];
            return ListTile(
              title: Text(mode.libelle),
              trailing: selected?.id == mode.id
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => selected = mode);
                widget.onSelected(mode);
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  void _openDialog(List<ModeReglement> modes) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sélectionner un mode de règlement'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: modes.length,
              itemBuilder: (_, i) {
                final mode = modes[i];
                return ListTile(
                  title: Text(mode.libelle),
                  onTap: () {
                    setState(() => selected = mode);
                    widget.onSelected(mode);
                    Navigator.pop(dialogContext);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModeReglementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          if (provider.errorMessage!.isNotEmpty) {
            return Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
        }

        if (provider.modeReglements.isEmpty) {
          return const Text("Aucun mode de règlement disponible");
        }

        final modes = provider.modeReglements;

        // --- Version Dialog
        if (!widget.useBottomSheet) {
          return InkWell(
            onTap: () => _openDialog(modes),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Mode de règlement",
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(selected?.libelle ?? "Sélectionner un mode"),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          );
        }

        // --- Version BottomSheet
        return ListTile(
          title: Text(selected?.libelle ?? "Sélectionner un mode"),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () => _openBottomSheet(modes),
        );
      },
    );
  }
}
