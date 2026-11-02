import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../data/datasources/islam_house_remote_data_source.dart';
import '../../data/datasources/lesson_audio_cache_service.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/lessons_repository_impl.dart';
import '../../domain/usecases/get_lessons_usecase.dart';
import '../viewmodels/lessons_bloc/lessons_bloc.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonsBloc(
        getLessonsUseCase: GetLessonsUseCase(
          LessonsRepositoryImpl(
            remoteDataSource: IslamHouseRemoteDataSource(),
          ),
        ),
      )..add(FetchLessonsEvent()),
      child: const LessonsView(),
    );
  }
}

class LessonsView extends StatefulWidget {
  const LessonsView({super.key});

  @override
  State<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends State<LessonsView> {
  final TextEditingController _searchController = TextEditingController();
  final LessonAudioCacheService _audioCacheService = LessonAudioCacheService();

  int? _playingLessonId;
  bool _isPlaying = false;
  final Set<int> _downloadedLessonIds = {};
  final Map<int, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _audioCacheService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _playingLessonId = null;
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioCacheService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkDownloadStatus(int lessonId) async {
    final isDownloaded = await _audioCacheService.isLessonDownloaded(lessonId);
    if (isDownloaded && mounted) {
      setState(() {
        _downloadedLessonIds.add(lessonId);
      });
    }
  }

  Future<void> _playOrPauseLesson(LessonModel lesson) async {
    if (lesson.audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط الصوت غير متوفر لهذا الدرس')),
      );
      return;
    }

    if (_playingLessonId == lesson.id && _isPlaying) {
      await _audioCacheService.pauseLesson();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _playingLessonId = lesson.id;
        _isPlaying = true;
      });
      try {
        await _audioCacheService.playLesson(
          lessonId: lesson.id,
          audioUrl: lesson.audioUrl,
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _playingLessonId = null;
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر تشغيل الصوت: $e')),
          );
        }
      }
    }
  }

  Future<void> _downloadLesson(LessonModel lesson) async {
    if (lesson.audioUrl.isEmpty) return;

    setState(() {
      _downloadProgress[lesson.id] = 0.0;
    });

    try {
      await _audioCacheService.downloadLesson(
        lessonId: lesson.id,
        audioUrl: lesson.audioUrl,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress[lesson.id] = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloadedLessonIds.add(lesson.id);
          _downloadProgress.remove(lesson.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ درس "${lesson.title}" للعمل أوفلاين بنجاح! 🎧'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadProgress.remove(lesson.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحميل: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المكتبة الدعوية والدروس'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = constraints.maxWidth > 600;

              return Padding(
                padding: Responsive.pagePadding(context),
                child: Column(
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        context.read<LessonsBloc>().add(SearchLessonsEvent(value));
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اسم الدرس أو الشيخ...',
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

                    // Lessons List Content
                    Expanded(
                      child: BlocBuilder<LessonsBloc, LessonsState>(
                        builder: (context, state) {
                          if (state is LessonsLoading) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppColors.primaryColor),
                                  SizedBox(height: 16),
                                  Text('جاري جلب الدروس من منصة IslamHouse...'),
                                ],
                              ),
                            );
                          } else if (state is LessonsError) {
                            return Center(
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (state is LessonsLoaded) {
                            if (state.lessons.isEmpty) {
                              return const Center(
                                child: Text('لا توجد دروس مطابقة لبحثك'),
                              );
                            }

                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 2 : 1,
                                childAspectRatio: isTablet ? 2.8 : 3.4,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: state.lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = state.lessons[index];
                                _checkDownloadStatus(lesson.id);
                                return _buildLessonCard(context, lesson);
                              },
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonModel lesson) {
    final theme = Theme.of(context);
    final isPlayingCurrent = _playingLessonId == lesson.id && _isPlaying;
    final isDownloaded = _downloadedLessonIds.contains(lesson.id);
    final progress = _downloadProgress[lesson.id];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDownloaded
              ? AppColors.primaryColor.withOpacity(0.4)
              : Colors.grey.withOpacity(0.2),
          width: isDownloaded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Play/Pause Button
          InkWell(
            onTap: () => _playOrPauseLesson(lesson),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPlayingCurrent
                    ? AppColors.secondaryColor
                    : AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isPlayingCurrent
                            ? AppColors.secondaryColor
                            : AppColors.primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Icon(
                isPlayingCurrent ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Author
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFont(14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.author,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: context.respFont(12),
                  ),
                ),
                if (isDownloaded) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.offline_pin,
                        color: AppColors.primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'محفوظ أوفلاين',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: context.respFont(10.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Download Action Button
          if (progress != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  color: AppColors.primaryColor,
                ),
              ),
            )
          else
            IconButton(
              tooltip: isDownloaded ? 'محفوظ أوفلاين' : 'تحميل الدرس أوفلاين',
              icon: Icon(
                isDownloaded
                    ? Icons.offline_pin
                    : Icons.download_for_offline_outlined,
                color: isDownloaded ? AppColors.primaryColor : Colors.grey,
                size: 26,
              ),
              onPressed: isDownloaded ? null : () => _downloadLesson(lesson),
            ),
        ],
      ),
    );
  }
}
