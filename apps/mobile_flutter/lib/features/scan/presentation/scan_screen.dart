import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions.dart';
import '../../../core/locale_controller.dart';
import '../../../data/providers/api_providers.dart';
import '../../../data/providers/data_source_provider.dart';
import '../../../data/providers/scan_result_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  String? _imagePath;
  bool _analyzing = false;

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  Future<void> _pick(ImageSource source) async {
    if (!_isMobile && source == ImageSource.camera) {
      _showMessage(context.l10n.cameraUnavailable);
      source = ImageSource.gallery;
    }

    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 86,
        maxWidth: 1800,
      );
      if (file == null || !mounted) return;
      await _analyze(file.path);
    } catch (_) {
      if (mounted) _showMessage(context.l10n.scanError);
    }
  }

  Future<void> _analyze(String path) async {
    final l10n = context.l10n;
    final source = ref.read(dataSourceProvider);
    setState(() {
      _imagePath = path;
      _analyzing = true;
    });

    var fellBack = false;
    try {
      if (source == DataSource.api) {
        final items = await ref.read(apiRepositoryProvider).recognize(
          bytes: await _loadBytes(path),
          mimeType: _mimeType(path),
          locale: ref.read(localeProvider),
        );
        ref.read(scanResultProvider.notifier).set(items);
      } else {
        ref.read(scanResultProvider.notifier).clear();
        await Future<void>.delayed(const Duration(milliseconds: 1800));
      }
    } catch (_) {
      fellBack = true;
      ref.read(scanResultProvider.notifier).clear();
      if (mounted) _showMessage(l10n.apiUnreachable);
    }

    if (!mounted) return;
    setState(() => _analyzing = false);
    if (fellBack) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (!mounted) return;
    await context.push('/scan/results', extra: path);
  }

  Future<Uint8List> _loadBytes(String path) async {
    if (path.startsWith('assets/')) {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }
    return File(path).readAsBytes();
  }

  String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding,
                  AppSpacing.md,
                  context.pagePadding,
                  AppSpacing.sm,
                ),
                child: AppPageHeader(
                  title: l10n.scanTitle,
                  subtitle: l10n.scanSubtitle,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.pagePadding,
                      vertical: AppSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: _analyzing
                          ? _AnalyzingView(path: _imagePath)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ScanPreview(path: _imagePath),
                                const SizedBox(height: AppSpacing.xl),
                                if (_isMobile) ...[
                                  AppPrimaryButton(
                                    label: l10n.takePhoto,
                                    icon: Icons.photo_camera_rounded,
                                    onPressed: () =>
                                        _pick(ImageSource.camera),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AppGhostButton(
                                    label: l10n.uploadPhoto,
                                    icon: Icons.upload_rounded,
                                    onPressed: () => _pick(ImageSource.gallery),
                                  ),
                                ] else
                                  AppPrimaryButton(
                                    label: l10n.uploadPhoto,
                                    icon: Icons.upload_rounded,
                                    onPressed: () => _pick(ImageSource.gallery),
                                  ),
                                const SizedBox(height: AppSpacing.sm),
                                TextButton(
                                  onPressed: () => _analyze(
                                    'assets/images/food/shared_table.jpg',
                                  ),
                                  child: Text(l10n.useSample),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppCard(
                                  color: AppColors.surface,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        size: 20,
                                        color: AppColors.accent,
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Text(
                                          l10n.analyzingHint,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanPreview extends StatelessWidget {
  final String? path;

  const _ScanPreview({this.path});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const radius = AppSpacing.radiusXl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: 290,
        child: path == null
            ? CustomPaint(
                painter: _DashedBorderPainter(),
                child: Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 34,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.scanSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  _LocalImage(path: path!, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x990A0A0A)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.detectedSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
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

class _AnalyzingView extends StatelessWidget {
  final String? path;

  const _AnalyzingView({this.path});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: SizedBox(
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (path != null)
                  _LocalImage(path: path!, fit: BoxFit.cover)
                else
                  const ColoredBox(color: AppColors.surface),
                ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
                const Center(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(strokeWidth: 2.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.analyzing,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.analyzingHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SizedBox(
          width: 220,
          child: LinearProgressIndicator(minHeight: 4),
        ),
      ],
    );
  }
}

class _LocalImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const _LocalImage({required this.path, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit);
    }
    return Image.file(File(path), fit: fit);
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(1),
          const Radius.circular(AppSpacing.radiusXl),
        ),
      );
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + 7),
          paint,
        );
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
