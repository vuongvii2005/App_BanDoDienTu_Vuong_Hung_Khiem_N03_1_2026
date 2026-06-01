import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/product_provider.dart';
import '../widgets/product/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  bool _hasQuery = false;

  @override
  void dispose() {
    context.read<ProductProvider>().clearSearch();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final results = _hasQuery ? provider.filteredProducts : [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: (value) {
            provider.setSearchQuery(value);
            setState(() => _hasQuery = value.trim().isNotEmpty);
          },
          decoration: const InputDecoration(
            hintText: 'Tìm sản phẩm, thương hiệu...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppTheme.grey),
          ),
        ),
        actions: [
          if (_hasQuery)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _ctrl.clear();
                provider.clearSearch();
                setState(() => _hasQuery = false);
              },
            ),
        ],
      ),
      body: !_hasQuery
          ? _buildSuggestions()
          : provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
              : results.isEmpty
                  ? const Center(
                      child: Text(
                        'Không tìm thấy sản phẩm',
                        style: TextStyle(color: AppTheme.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: results.length,
                      itemBuilder: (_, i) => ProductCard(product: results[i]),
                    ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      'iPhone',
      'AirPods',
      'Samsung Galaxy',
      'MacBook',
      'Apple Watch',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tìm kiếm phổ biến',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                _ctrl.text = suggestion;
                context.read<ProductProvider>().setSearchQuery(suggestion);
                setState(() => _hasQuery = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.greyLight),
                ),
                child: Text(
                  suggestion,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
