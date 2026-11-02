// ignore_for_file: unnecessary_to_list_in_spreads, non_const_argument_for_const_parameter

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../main_layout/presentation/views/notifications_screen.dart';
import '../viewmodels/habit_bloc/habit_bloc.dart';

class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HabitBloc(),
      child: const HabitTrackerView(),
    );
  }
}

class HabitTrackerView extends StatelessWidget {
  const HabitTrackerView({super.key});

  void _showQuitHabitDialog(BuildContext context, QuitHabit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomContext),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'سلسلة الالتزام الحالية: ${habit.streakDays} يوماً متتالياً ✨',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<HabitBloc>()
                        .add(IncrementQuitHabitEvent(habit.id));
                    Navigator.pop(bottomContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ماشاء الله! أضفت يوماً جديداً لالتزامك بترك ${habit.title} 🎉'),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('+١ يوم التزام جديد'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    context
                        .read<HabitBloc>()
                        .add(ResetQuitHabitEvent(habit.id));
                    Navigator.pop(bottomContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إعادة ضبط العداد، الاستعانة بالله بداية جديدة 💪'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  label: const Text(
                    'إعادة ضبط العداد إلى ١',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddQuitHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة عادة سلبية لتركها'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'اسم العادة (مثال: ترك التدخين، ترك السهر)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'وصف قصير أو هدف',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    context.read<HabitBloc>().add(
                          AddQuitHabitEvent(
                            title: title,
                            subtitle: subtitleController.text.trim(),
                          ),
                        );
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeBloc>().isDark;

    HijriCalendar.setLocal('ar');
    final hijriDate = HijriCalendar.now();
    final String todayDateStr =
        '${hijriDate.dayWeName} ${hijriDate.hDay} ${hijriDate.longMonthName}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة العادات'),
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
              // Date Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {},
                      ),
                      Text(
                        'اليوم',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: context.respFont(15),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Text(
                    todayDateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontSize: context.respFont(13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              BlocBuilder<HabitBloc, HabitState>(
                builder: (context, state) {
                  if (state is! HabitLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryColor.withOpacity(0.2)
                              : AppColors.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Circular Progress
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: state.progress,
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      '${(state.progress * 100).toInt()}٪',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.respFont(18),
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.progress == 1.0
                                        ? 'يومك ممتاز!'
                                        : 'يومك عامر بالخير',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                      fontSize: context.respFont(18),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'أنجزت ${state.completedCount} من ${state.totalCount} عادات لليوم',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: context.respFont(13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Good Habits
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'عادات أواظب عليها',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: context.respFont(16),
                            ),
                          ),
                          Text(
                            '${state.completedCount} من ${state.totalCount} مكتملة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontSize: context.respFont(12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...state.goodHabits
                          .map(
                            (habit) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildHabitItem(
                                context,
                                habit.id,
                                habit.title,
                                habit.subtitle,
                                habit.isCompleted,
                                habit.icon,
                              ),
                            ),
                          )
                          .toList(),

                      const SizedBox(height: 28),

                      // Quit Habits Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'عادات أتركها',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: context.respFont(16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () => _showAddQuitHabitDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quit Habits Dynamic Cards
                      Row(
                        children: state.quitHabits
                            .map(
                              (qHabit) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: _buildQuitHabitCard(
                                    context,
                                    qHabit,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Motivation Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.secondaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: context.respFont(12),
                          ),
                          children: const [
                            TextSpan(
                              text: 'رسالة تشجيع: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'دعائك الصادق... كل بذور نبتة طيبة ثمارها مقبلة، اجعل عملك اليوم خالصاً لله.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItem(
    BuildContext context,
    String id,
    String title,
    String subtitle,
    bool isCompleted,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        context.read<HabitBloc>().add(ToggleHabitEvent(id));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.primaryColor.withOpacity(0.5)
                : theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isCompleted ? AppColors.primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFont(14),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: context.respFont(12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: isCompleted ? Colors.white : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuitHabitCard(
    BuildContext context,
    QuitHabit qHabit,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showQuitHabitDialog(context, qHabit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    qHabit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFont(13.5),
                    ),
                  ),
                ),
                Icon(qHabit.icon, color: AppColors.primaryColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${qHabit.streakDays}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    fontSize: context.respFont(24),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'يوماً متتالياً',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryColor,
                      fontSize: context.respFont(11),
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              qHabit.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontSize: context.respFont(10.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
