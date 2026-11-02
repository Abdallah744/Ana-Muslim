import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/hadith_bloc/hadith_bloc.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HadithBloc()..add(LoadHadithDataEvent()),
      child: const HadithView(),
    );
  }
}

class HadithView extends StatefulWidget {
  const HadithView({super.key});

  @override
  State<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<HadithView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<HadithBloc>().add(SearchHadithEvent(value));
            },
            decoration: InputDecoration(
              hintText: 'ابحث في الأحاديث...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              fillColor: theme.colorScheme.surface,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Index
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأربعون النووية',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocBuilder<HadithBloc, HadithState>(
                builder: (context, state) {
                  if (state is HadithLoaded) {
                    return Text(
                      '${state.hadiths.length} حديث',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List of Hadiths
          BlocBuilder<HadithBloc, HadithState>(
            builder: (context, state) {
              if (state is HadithLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HadithError) {
                return Center(child: Text(state.message));
              } else if (state is HadithLoaded) {
                if (state.hadiths.isEmpty) {
                  return const Center(child: Text('لا يوجد نتائج للبحث'));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.hadiths.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final hadith = state.hadiths[index];
                    // نستخرج العنوان من النص إذا كان موجوداً
                    String title = 'الحديث ${index + 1}';
                    if (hadith.hadith.split('\n').isNotEmpty) {
                      title = hadith.hadith.split('\n')[0].trim();
                    }
                    return ListTile(
                      title: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        hadith.hadith.replaceAll(title, '').trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                      trailing: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.star_border,
                            color: AppColors.secondaryColor,
                            size: 40,
                          ),
                          Text(
                            '${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Open details
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.9,
                            minChildSize: 0.5,
                            maxChildSize: 0.9,
                            expand: false,
                            builder: (context, scrollController) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: ListView(
                                controller: scrollController,
                                padding: const EdgeInsets.all(24),
                                children: [
                                  Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                                  const SizedBox(height: 24),
                                  Text(hadith.hadith.replaceAll(title, '').trim(), style: const TextStyle(fontSize: 18, height: 1.6)),
                                  const SizedBox(height: 32),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Text('الشرح:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondaryColor)),
                                  const SizedBox(height: 12),
                                  Text(hadith.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
