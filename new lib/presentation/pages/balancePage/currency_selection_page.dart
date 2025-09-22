import 'package:flutter/material.dart';

/// A simple page that allows the user to select a currency code from
/// a predefined list.  Favourites are displayed first followed by a
/// longer general list.  When a currency is tapped the page pops
/// with the selected value.
class CurrencySelectionPage extends StatelessWidget {
  final String selected;
  const CurrencySelectionPage({Key? key, required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of favourite currencies.  These appear at the top.
    final favourites = [
      'USD',
      'EUR',
      'GBP',
      'YER',
    ];
    // A sample of additional currencies.  In a full implementation
    // these could be loaded from an external source or service.
    final general = [
      'AUD', 'CAD', 'CHF', 'CNY', 'JPY', 'NZD', 'SAR', 'AED', 'INR',
      'KWD', 'SGD', 'TRY', 'RUB', 'BRL', 'MYR', 'PHP', 'THB', 'ZAR'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF01304B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01304B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Currency',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('FAVOURITES'),
          ...favourites.map((code) => _buildCurrencyTile(context, code)).toList(),
          _buildSectionHeader('GENERAL'),
          ...general.map((code) => _buildCurrencyTile(context, code)).toList(),
        ],
      ),
    );
  }

  /// Builds a section header with subtle styling.  This separates
  /// favourites from the general list.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds a list tile for a given currency code.  When tapped it
  /// returns the code to the caller via Navigator.pop.
  Widget _buildCurrencyTile(BuildContext context, String code) {
    final bool isSelected = code == selected;
    return ListTile(
      title: Text(
        code,
        style: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blueAccent)
          : null,
      onTap: () {
        Navigator.of(context).pop(code);
      },
    );
  }
}