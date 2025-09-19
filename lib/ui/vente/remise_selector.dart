import 'package:flutter/material.dart';
import 'package:prestige_pos/model/vente/remise.dart';
import 'package:prestige_pos/provider/remise_provider.dart';
import 'package:prestige_pos/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:prestige_pos/model/vente/mode_reglement.dart';
import 'package:prestige_pos/provider/mode_reglement_provider.dart';

class RemiseSelector extends StatefulWidget {
  final Function(Remise) onSelected;
  final Remise? initialValue;
  final bool useBottomSheet; // Pour choisir entre Dropdown ou BottomSheet

  const RemiseSelector({
    super.key,
    required this.onSelected,
    this.initialValue,
    this.useBottomSheet = false,
  });

  @override
  State<RemiseSelector> createState() => _RemiseSelectorState();
}

class _RemiseSelectorState extends State<RemiseSelector> {
  Remise? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RemiseProvider>();
      if (provider.remises.isEmpty) {
        provider.fetch();
      }
    });
  }

  void _openBottomSheet(List<Remise> modes) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<RemiseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final errorMessage = provider.errorMessage?? "";
          if (errorMessage.isNotEmpty) {
            return Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            );
          }



        if (provider.remises.isEmpty) {
          return const Text("Aucune remise disponible");//TODO add to constants
        }

        final modes = provider.remises;

        // --- Version Dropdown
        if (!widget.useBottomSheet) {
          return DropdownButtonFormField<Remise>(
            value: selected,
            items: modes
                .map(
                  (mode) =>
                      DropdownMenuItem(value: mode, child: Text(mode.libelle)),
                )
                .toList(),
            onChanged: (mode) {
              if (mode != null) {
                setState(() => selected = mode);
                widget.onSelected(mode);
              }
            },
            decoration: const InputDecoration(
              labelText: Constants.remisePlaceHolder, //TODO add to constants
              border: OutlineInputBorder(),
            ),
          );
        }

        // --- Version BottomSheet
        return ListTile(
          title: Text(selected?.libelle ?? Constants.remisePlaceHolder),//TODO add to constants
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () => _openBottomSheet(modes),
        );
      },
    );
  }
}
