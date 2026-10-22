import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/product_model.dart';
import '../../data/models/search_history_model.dart';
import '../view_models/product_search_cubit.dart';
import '../view_models/product_search_state.dart';
import 'product_detail_view.dart';

class ProductSearchView extends StatelessWidget {
  const ProductSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductSearchCubit(),
      child: const _ProductSearchScreen(),
    );
  }
}

class _ProductSearchScreen extends StatefulWidget {
  const _ProductSearchScreen();

  @override
  State<_ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<_ProductSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 10000), () {
      if (mounted) context.read<ProductSearchCubit>().search(value);
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    context.read<ProductSearchCubit>().search(value);
  }

  void _selectHistory(String query) {
    _debounce?.cancel();
    _controller.text = query;
    _controller.selection = TextSelection.collapsed(offset: query.length);
    context.read<ProductSearchCubit>().search(query);
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    context.read<ProductSearchCubit>().search('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(context.spacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: context.spacing.sm),
                  Expanded(
                    child: AppTextField(
                      hintText: 'Search Product',
                      prefixIcon: Icons.search,
                      suffixIcon: _controller.text.isEmpty ? null : Icons.close,
                      onSuffixPressed: _clearQuery,
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      onFieldSubmitted: _onSubmitted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductSearchCubit, ProductSearchState>(
                builder: (context, state) {
                  return switch (state) {
                    ProductSearchInitial(:final history) =>
                      history.isEmpty
                          ? const _SearchMessage(
                              icon: Icons.search,
                              title: 'Search for products',
                              message: 'Try "phone", "watch" or "bag".',
                            )
                          : _SearchHistory(
                              history: history,
                              onSelect: _selectHistory,
                              onDelete: (id) => context
                                  .read<ProductSearchCubit>()
                                  .deleteHistoryEntry(id),
                              onClear: () => context
                                  .read<ProductSearchCubit>()
                                  .clearHistory(),
                            ),
                    ProductSearchLoading() => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    ProductSearchEmpty(:final query) => _SearchMessage(
                      icon: Icons.search_off,
                      title: 'No results',
                      message: 'Nothing matched "$query". Try another term.',
                    ),
                    ProductSearchError(:final message) => _SearchMessage(
                      icon: Icons.wifi_off_rounded,
                      title: 'Something went wrong',
                      message: message,
                      action: SizedBox(
                        width: 180,
                        child: AppButton(
                          text: 'Retry',
                          onPressed: () =>
                              context.read<ProductSearchCubit>().retry(),
                        ),
                      ),
                    ),
                    ProductSearchSuccess(:final query, :final products) =>
                      _SearchResults(query: query, products: products),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHistory extends StatelessWidget {
  final List<SearchHistoryEntry> history;
  final ValueChanged<String> onSelect;
  final ValueChanged<int> onDelete;
  final VoidCallback onClear;

  const _SearchHistory({
    required this.history,
    required this.onSelect,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Row(
            children: [
              Text('Recent searches', style: context.textStyles.heading4),
              const Spacer(),
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Clear all',
                  style: context.textStyles.body.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.spacing.xs),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              context.spacing.md,
              0,
              context.spacing.md,
              context.spacing.lg,
            ),
            itemCount: history.length,
            separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
            itemBuilder: (context, index) {
              final entry = history[index];
              return InkWell(
                onTap: () => onSelect(entry.query),
                borderRadius: AppRadius.card,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.md,
                    vertical: context.spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: context.spacing.sm),
                      Expanded(
                        child: Text(
                          entry.query,
                          style: context.textStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onDelete(entry.id),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<ProductModel> products;

  const _SearchResults({required this.query, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
          child: Text(
            '${products.length} results for "$query"',
            style: context.textStyles.body,
          ),
        ),
        SizedBox(height: context.spacing.sm),
        Expanded(
          //30
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              context.spacing.md,
              0,
              context.spacing.md,
              context.spacing.lg,
            ),
            itemCount: products.length,
            separatorBuilder: (_, _) => SizedBox(height: context.spacing.sm),
            itemBuilder: (context, index) =>
                _ProductResultTile(product: products[index]),
          ),
        ),
      ],
    );
  }
}

class _ProductResultTile extends StatelessWidget {
  final ProductModel product;

  const _ProductResultTile({required this.product});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailView(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.thumbnail ??
        (product.images.isNotEmpty ? product.images.first : null);

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: AppRadius.card,
      child: Container(
        padding: EdgeInsets.all(context.spacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppRadius.card,
              child: SizedBox(
                width: 88,
                height: 88,
                child: _ResultImage(url: imageUrl),
              ),
            ),
            SizedBox(width: context.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: context.textStyles.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.spacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.star, size: 14),
                      SizedBox(width: context.spacing.xs),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: context.textStyles.caption,
                      ),
                      SizedBox(width: context.spacing.md),
                      Expanded(
                        child: Text(
                          product.brand ?? product.category,
                          style: context.textStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.spacing.xs),
                  Row(
                    children: [
                      Text(
                        '\$${product.discountedPrice.toStringAsFixed(2)}',
                        style: context.textStyles.price,
                      ),
                      SizedBox(width: context.spacing.sm),
                      if (product.hasDiscount)
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: context.textStyles.oldPrice,
                        ),
                      const Spacer(),
                      if (!product.inStock)
                        Text(
                          'Out of stock',
                          style: context.textStyles.caption.copyWith(
                            color: AppColors.discount,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  final String? url;

  const _ResultImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(Icons.image, color: AppColors.border),
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: AppColors.surface,
        child: const Icon(Icons.image, color: AppColors.border),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: Icon(icon, size: 40, color: AppColors.textSecondary),
            ),
            SizedBox(height: context.spacing.md),
            Text(
              title,
              style: context.textStyles.heading4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              message,
              style: context.textStyles.body,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: context.spacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
