import 'dart:async';

import 'package:flutter/material.dart';

import 'package:helpi_admin/app/theme.dart';
import 'package:helpi_admin/core/l10n/app_strings.dart';
import 'package:helpi_admin/core/services/admin_api_service.dart';

/// Result from address autocomplete selection.
class SelectedAddress {
  final String placeId;
  final String fullAddress;

  const SelectedAddress({required this.placeId, required this.fullAddress});
}

/// Address autocomplete field using backend proxy.
/// Calls GET /api/places/autocomplete?input=...
///
/// Uses Flutter's built-in [RawAutocomplete] for robust overlay positioning
/// inside scroll containers and dialogs.
class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.onSelected,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final void Function(SelectedAddress) onSelected;
  final bool required;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<_Place> _lastResults = [];
  bool _selecting = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<_Place>> _fetchOptions(String input) async {
    final text = input.trim();
    if (text.length < 3) return [];

    final result = await AdminApiService().placesAutocomplete(text);
    if (!result.success || result.data == null) return [];

    return result.data!
        .map(
          (m) => _Place(
            placeId: m['placeId'] as String? ?? '',
            description: m['description'] as String? ?? '',
            mainText: m['mainText'] as String? ?? '',
            secondaryText: m['secondaryText'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<_Place>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) async {
        // After selecting an option, don't re-fetch
        if (_selecting) {
          _selecting = false;
          return _lastResults;
        }

        final completer = Completer<List<_Place>>();
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 350), () async {
          final results = await _fetchOptions(textEditingValue.text);
          if (!mounted) return;
          _lastResults = results;
          completer.complete(results);
        });

        return completer.future;
      },
      displayStringForOption: (place) => place.description,
      onSelected: (place) {
        _selecting = true;
        widget.onSelected(
          SelectedAddress(
            placeId: place.placeId,
            fullAddress: place.description,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 500),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final place = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 18),
                    title: Text(
                      place.mainText,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      place.secondaryText,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => onSelected(place),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(HelpiTheme.cardRadius),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: const Icon(Icons.location_on_outlined, size: 20),
          ),
          validator: widget.required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.fieldRequired
                    : null
              : null,
        );
      },
    );
  }
}

/// Internal model for autocomplete suggestion.
class _Place {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const _Place({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}
