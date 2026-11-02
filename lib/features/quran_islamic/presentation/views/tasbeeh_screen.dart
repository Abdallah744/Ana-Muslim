import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../viewmodels/tasbeeh_bloc/tasbeeh_bloc.dart';

class TasbeehScreen extends StatelessWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasbeehBloc(),
      child: const TasbeehView(),
    );
  }
}

class TasbeehView extends StatelessWidget {
  const TasbeehView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('السبحة الإلكترونية'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double counterSize = (constraints.maxWidth * 0.65).clamp(200.0, 300.0);

            return Center(
              child: SingleChildScrollView(
                padding: Responsive.pagePadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Counter Display Ring
                    Container(
                      width: counterSize,
                      height: counterSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryColor, width: 4),
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: BlocBuilder<TasbeehBloc, TasbeehState>(
                          builder: (context, state) {
                            int count = 0;
                            if (state is TasbeehUpdated) {
                              count = state.count;
                            }
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$count',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: context.respFont(64),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Interaction Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reset Button
                        InkWell(
                          onTap: () {
                            context.read<TasbeehBloc>().add(ResetTasbeehEvent());
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.red,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 36),

                        // Increment Button
                        InkWell(
                          onTap: () {
                            context.read<TasbeehBloc>().add(IncrementTasbeehEvent());
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor,
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'ألا بذكر الله تطمئن القلوب',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: context.respFont(15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
