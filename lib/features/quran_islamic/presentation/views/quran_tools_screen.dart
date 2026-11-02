import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../main_layout/presentation/views/notifications_screen.dart';
import '../viewmodels/quran_bloc/quran_bloc.dart';
import '../viewmodels/hadith_bloc/hadith_bloc.dart';
import 'hadith_screen.dart';
import 'surah_reader_screen.dart';

class QuranToolsScreen extends StatelessWidget {
  const QuranToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => QuranBloc()..add(LoadQuranDataEvent())),
        BlocProvider(create: (context) => HadithBloc()..add(LoadHadithDataEvent())),
      ],
      child: const QuranToolsView(),
    );
  }
}

class QuranToolsView extends StatefulWidget {
  const QuranToolsView({super.key});

  @override
  State<QuranToolsView> createState() => _QuranToolsViewState();
}

class _QuranToolsViewState extends State<QuranToolsView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isQuranSelected = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeBloc>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصحف والأدوات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs Header
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isQuranSelected = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isQuranSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.menu_book,
                                color: _isQuranSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'سور القرآن',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: _isQuranSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.respFont(14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isQuranSelected = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isQuranSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'الأذكار والأحاديث',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: !_isQuranSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: context.respFont(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_isQuranSelected) ...[
                // Last Read Card
                BlocBuilder<QuranBloc, QuranState>(
                  builder: (context, state) {
                    String lastReadName = 'سورة الفاتحة';
                    String lastReadDetails = 'الجزء الأول - الصفحة ١';

                    if (state is QuranLoaded) {
                      lastReadName = state.lastReadSurahName;
                      lastReadDetails = state.lastReadSurahDetails;
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'متابعة القراءة',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: context.respFont(12),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    lastReadName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                      fontSize: context.respFont(15),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.bookmark,
                                    color: AppColors.secondaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lastReadDetails,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: context.respFont(11.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Search Box
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<QuranBloc>().add(SearchSurahEvent(value));
                  },
                  decoration: InputDecoration(
                    hintText: 'ابحث عن سورة أو رقم آية',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    fillColor: theme.colorScheme.surface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Index
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'فهرس السور',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: context.respFont(16),
                      ),
                    ),
                    Text(
                      '١١٤ سورة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: context.respFont(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // List of Surahs
                BlocBuilder<QuranBloc, QuranState>(
                  builder: (context, state) {
                    if (state is QuranLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is QuranError) {
                      return Center(child: Text(state.message));
                    } else if (state is QuranLoaded) {
                      if (state.surahs.isEmpty) {
                        return const Center(child: Text('لا توجد نتائج للبحث'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.surahs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final surah = state.surahs[index];
                          return _buildSurahItem(
                            context,
                            'سورة ${surah.name}',
                            '${surah.type} - ${surah.array.length} آية',
                            surah.id.toString(),
                            () {
                              context.read<QuranBloc>().add(SaveLastReadSurahEvent(
                                    'سورة ${surah.name}',
                                    '${surah.type} - ${surah.array.length} آية',
                                  ));

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SurahReaderScreen(surah: surah),
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
              ] else ...[
                const HadithView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahItem(
    BuildContext context,
    String name,
    String details,
    String number,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.respFont(15),
              ),
            ),
            Row(
              children: [
                Text(
                  details,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: context.respFont(12),
                  ),
                ),
                const SizedBox(width: 14),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.star_border,
                      color: AppColors.secondaryColor,
                      size: 38,
                    ),
                    Text(
                      number,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.respFont(11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
