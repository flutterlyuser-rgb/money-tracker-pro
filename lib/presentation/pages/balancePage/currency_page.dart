import 'package:flutter/material.dart';

/// Page listing available currencies.  The layout mirrors the
/// screenshot: a title bar with "Currency" and a back arrow, a
/// "Favorites" section with the current selection, and a "General"
/// section with a handful of example currencies and rates.  Selecting
/// a currency returns it to the caller via Navigator.pop.
class CurrencyPage extends StatelessWidget {
  final String selected;
  const CurrencyPage({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    // Hardcoded currency list with dummy exchange rates.  In a real
    // application these would be fetched from an API.
    final favourites = {selected: 1.0};
    final general = <String, double>{
      'AUD': 0.65,
      'BGN': 0.60,
      'BRL': 0.18,
      'BTC': 115635.63,
      'BYN': 0.32,
      'CAD': 0.72,
      'CHF': 1.26,
      'CNY': 0.14,
      'CZK': 0.048,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Favorites'),
          ...favourites.entries
              .map((e) => _buildCurrencyTile(context, e.key, e.value))
              .toList(),
          _buildSectionHeader(context, 'General'),
          ...general.entries
              .map((e) => _buildCurrencyTile(context, e.key, e.value))
              .toList(),
        ],
      ),
    );
  }

  /// Renders a header for the favourites or general sections.  The
  /// colour is drawn from the current theme's card colour for
  /// consistency with the rest of the app.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  /// Constructs a tile for a single currency entry.  A generic flag
  /// icon is used in place of real flags to comply with the image
  /// generation policies.  Selecting a tile pops back the currency
  /// code.
  Widget _buildCurrencyTile(
      BuildContext context, String code, double rate) {
    return ListTile(
      leading: const Icon(Icons.flag),
      title: Text(code),
      trailing: Text(
        rate >= 100 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2),
      ),
      onTap: () {
        Navigator.pop(context, code);
      },
    );
  }
}