import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/navigation_providers.dart';

/// A reusable bottom navigation bar that reacts to changes in the
/// [navIndexProvider]. When an item is tapped it updates the provider
/// state and triggers a rebuild of any listening widgets. The styling
/// matches the existing Money Pro design with highlighted active
/// icons and labels.
class CustomBottomNavBar extends ConsumerWidget {
  /// List of navigation items to display. The order of items
  /// corresponds to the indices managed by [navIndexProvider].
  final List<NavItem> items;
  const CustomBottomNavBar({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    return Container(
      color:  Colors.transparent,
      
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == selectedIndex;
          final color = selected ? Colors.white : Colors.white70;
          return Expanded(
            
            child: InkWell(
              onTap: () {
                // Update the selected index in the provider.
                ref.read(navIndexProvider.notifier).state = index;
              },
              child: Padding(
              
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: selected ? 13 : 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}