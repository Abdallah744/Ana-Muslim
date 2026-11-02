import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/surah_model.dart';
import '../viewmodels/audio_bloc/audio_bloc.dart';

class SurahReaderScreen extends StatelessWidget {
  final SurahModel surah;
  
  const SurahReaderScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioBloc()
        ..add(CheckSurahDownloadStatusEvent(
          reciterId: 'mshari_alafasi', // يمكنك تغييره لاحقاً ليكون ديناميكياً
          surahNumber: surah.id.toString().padLeft(3, '0'),
        )),
      child: SurahReaderView(surah: surah),
    );
  }
}

class SurahReaderView extends StatelessWidget {
  final SurahModel surah;
  
  const SurahReaderView({super.key, required this.surah});

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('سورة ${surah.name}'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                final surahFormattedId = surah.id.toString().padLeft(3, '0');
                // The URL for Al-Afasy from mp3quran API as an example
                final apiUrl = 'https://server8.mp3quran.net/afs/$surahFormattedId.mp3';

                if (state is AudioDownloading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: state.progress,
                          color: AppColors.primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                bool isDownloaded = false;
                if (state is AudioInitial) isDownloaded = state.isDownloaded;
                if (state is AudioPlaying) isDownloaded = state.isDownloaded;

                return IconButton(
                  icon: Icon(
                    isDownloaded ? Icons.offline_pin : Icons.download_for_offline_outlined,
                    color: isDownloaded ? AppColors.primaryColor : Colors.grey,
                  ),
                  onPressed: isDownloaded ? null : () {
                    context.read<AudioBloc>().add(DownloadSurahEvent(
                      reciterId: 'mshari_alafasi',
                      surahNumber: surahFormattedId,
                      apiUrl: apiUrl,
                    ));
                  },
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Audio Player Control
              BlocBuilder<AudioBloc, AudioState>(
                builder: (context, state) {
                  bool isPlaying = false;
                  if (state is AudioPlaying) {
                    isPlaying = state.isPlaying;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: AppColors.primaryColor,
                            size: 32,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              context.read<AudioBloc>().add(PauseSurahEvent());
                            } else {
                              final surahFormattedId = surah.id.toString().padLeft(3, '0');
                              final apiUrl = 'https://server8.mp3quran.net/afs/$surahFormattedId.mp3';
                              context.read<AudioBloc>().add(PlaySurahEvent(
                                reciterId: 'mshari_alafasi',
                                surahNumber: surahFormattedId,
                                apiUrl: apiUrl,
                              ));
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'مشاري العفاسي',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Bismillah for all surahs except Tawbah (id 9) and Fatiha (id 1, because it's already in the verses)
              if (surah.id != 9 && surah.id != 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Container for Ayahs
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: RichText(
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(
                    children: surah.array.map((ayah) {
                      return TextSpan(
                        children: [
                          TextSpan(
                            text: '${ayah.ar} ',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                              height: 2.2,
                            ),
                          ),
                          TextSpan(
                            text: ' ﴿${_toArabicNumbers(ayah.id.toString())}﴾ ',
                            style: const TextStyle(
                              color: AppColors.secondaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
