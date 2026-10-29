import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/responsive/responsive_context.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../view_models/category_cubit.dart';
import '../view_models/category_state.dart';
import '../widgets/category_list_item.dart';

/// Lists all product categories with an image and title.
class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryCubit()..loadCategories(),
      child: const _CategoryScreen(),
    );
  }
}

class _CategoryScreen extends StatelessWidget {
  const _CategoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            debugPrint('[CategoryView] build state -> ${state.runtimeType}');

            return switch (state) {
              CategorySuccess(:final categories) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    context.read<CategoryCubit>().loadCategories(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(context.spacing.md),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: context.spacing.sm),
                  itemBuilder: (context, index) =>
                      CategoryListItem(category: categories[index]),
                ),
              ),
              CategoryEmpty() => const _CategoryStatus(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                message: 'There is nothing to show right now. Check back soon.',
              ),
              CategoryError(:final message) => _CategoryStatus(
                icon: Icons.wifi_off_rounded,
                title: 'Something went wrong',
                message: message,
                action: SizedBox(
                  width: 180,
                  child: AppButton(
                    text: 'Retry',
                    onPressed: () =>
                        context.read<CategoryCubit>().loadCategories(),
                  ),
                ),
              ),
              CategoryLoading() || CategoryInitial() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _CategoryStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _CategoryStatus({
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
