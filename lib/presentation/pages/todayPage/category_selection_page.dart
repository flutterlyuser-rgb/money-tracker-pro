import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker/presentation/widgets/background_container.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/category_providers.dart';

/// Displays a grid of categories for the user to choose from.
///
/// Tapping a category will close this screen and return the selected
/// [Category] back to the caller via the Navigator.
class CategorySelectionPage extends ConsumerWidget {
  const CategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the expense categories as per the recommended use case.
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    return  BackgroundContainer(
            
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:  Colors.transparent,
          title: const Text('Select Category'),
        ),
        backgroundColor:  Colors.transparent,
        body: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return const Center(
                child: Text(
                  'No categories available',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final CategoryEntity category = categories[index];
                  // Parse color and icon.
                  Color parseColor(String hex) {
                    hex = hex.replaceFirst('#', '');
                    if (hex.length == 6) hex = 'FF$hex';
                    return Color(int.parse(hex, radix: 16));
                  }
                  final color = parseColor(category.colorHex);
                  final iconData = IconData(
                    int.tryParse(category.iconCode) ?? 0xe15b,
                    fontFamily: 'MaterialIcons',
                  );
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(category);//يحدد الفئة ويرسلها عبر الملاح ثم يحذف الصفحة
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              iconData,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading categories: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}