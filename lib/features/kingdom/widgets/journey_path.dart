import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_localization.dart';
import '../kingdom_zone_data.dart';

enum JourneyStopStatus { done, current, open, locked }

JourneyStopStatus journeyStopStatus(
  KingdomZoneData zone,
  KingdomZoneData recommendedZone,
) {
  if (!zone.unlocked) return JourneyStopStatus.locked;
  if (zone.isComplete) return JourneyStopStatus.done;
  if (zone.id == recommendedZone.id) return JourneyStopStatus.current;
  return JourneyStopStatus.open;
}

String journeyStatusLabel(BuildContext context, JourneyStopStatus status) {
  switch (status) {
    case JourneyStopStatus.done:
      return context.tr('kingdom.status_done');
    case JourneyStopStatus.current:
      return context.tr('kingdom.status_current');
    case JourneyStopStatus.open:
      return context.tr('kingdom.status_open');
    case JourneyStopStatus.locked:
      return context.tr('kingdom.status_locked');
  }
}

/// A winding top-to-bottom trail: Start flag, one stop per zone, then the
/// royal finish crown.
class JourneyPath extends StatelessWidget {
  const JourneyPath({
    super.key,
    required this.zones,
    required this.recommendedZone,
    required this.zoneKeys,
    required this.onZoneTap,
    required this.onFinishTap,
  });

  final List<KingdomZoneData> zones;
  final KingdomZoneData recommendedZone;
  final Map<String, GlobalKey> zoneKeys;
  final ValueChanged<KingdomZoneData> onZoneTap;
  final VoidCallback onFinishTap;

  static const double _rowHeight = 136;
  static const double _endRowHeight = 96;
  static const double _nodeRadius = 38;

  bool get _journeyComplete => zones.every((zone) => zone.isComplete);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final points = _nodeCenters(width);
        final totalHeight = _endRowHeight * 2 + _rowHeight * zones.length;
        // Segment i joins point i to point i + 1; it is "walked" once the
        // stop it leads to is reachable.
        final walked = <bool>[
          for (var i = 0; i < points.length - 1; i++)
            i < zones.length ? zones[i].unlocked : _journeyComplete,
        ];

        return SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _JourneyTrailPainter(
                    points: points,
                    walked: walked,
                  ),
                ),
              ),
              _buildEndMarker(
                center: points.first,
                emoji: '🚩',
                label: context.tr('kingdom.start'),
                reached: true,
              ),
              for (var i = 0; i < zones.length; i++)
                ..._buildStop(context, zones[i], points[i + 1], width),
              _buildEndMarker(
                center: points.last,
                emoji: '👑',
                label: context.tr('kingdom.finish'),
                reached: _journeyComplete,
                onTap: onFinishTap,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Offset> _nodeCenters(double width) {
    final points = <Offset>[Offset(width / 2, _endRowHeight / 2)];
    for (var i = 0; i < zones.length; i++) {
      final fraction = i.isEven ? 0.26 : 0.74;
      points.add(
        Offset(
          width * fraction,
          _endRowHeight + _rowHeight * i + _rowHeight / 2,
        ),
      );
    }
    points.add(
      Offset(
        width / 2,
        _endRowHeight + _rowHeight * zones.length + _endRowHeight / 2,
      ),
    );
    return points;
  }

  Widget _buildEndMarker({
    required Offset center,
    required String emoji,
    required String label,
    required bool reached,
    VoidCallback? onTap,
  }) {
    const size = 58.0;
    return Positioned(
      left: center.dx - 70,
      width: 140,
      top: center.dy - size / 2,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? AppColors.premiumGoldLight : Colors.white,
                border: Border.all(
                  color: reached ? AppColors.premiumGold : AppColors.outline,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Opacity(
                opacity: reached ? 1 : 0.45,
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStop(
    BuildContext context,
    KingdomZoneData zone,
    Offset center,
    double width,
  ) {
    final status = journeyStopStatus(zone, recommendedZone);
    final nodeOnLeft = center.dx < width / 2;
    const labelGap = 12.0;

    return [
      Positioned(
        left: center.dx - _nodeRadius,
        top: center.dy - _nodeRadius,
        child: _JourneyStopNode(
          key: zoneKeys[zone.id],
          zone: zone,
          status: status,
          radius: _nodeRadius,
          onTap: () => onZoneTap(zone),
        ),
      ),
      if (status == JourneyStopStatus.current)
        Positioned(
          left: center.dx - 60,
          width: 120,
          top: center.dy - _nodeRadius - 34,
          child: const _YouAreHereFlag(),
        ),
      Positioned(
        left: nodeOnLeft ? center.dx + _nodeRadius + labelGap : 4,
        right: nodeOnLeft ? 4 : width - center.dx + _nodeRadius + labelGap,
        top: center.dy - 34,
        child: _JourneyStopLabel(
          zone: zone,
          status: status,
          alignEnd: !nodeOnLeft,
          onTap: () => onZoneTap(zone),
        ),
      ),
    ];
  }
}

class _JourneyStopNode extends StatefulWidget {
  const _JourneyStopNode({
    super.key,
    required this.zone,
    required this.status,
    required this.radius,
    required this.onTap,
  });

  final KingdomZoneData zone;
  final JourneyStopStatus status;
  final double radius;
  final VoidCallback onTap;

  @override
  State<_JourneyStopNode> createState() => _JourneyStopNodeState();
}

class _JourneyStopNodeState extends State<_JourneyStopNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _JourneyStopNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) _syncPulse();
  }

  void _syncPulse() {
    if (widget.status == JourneyStopStatus.current) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    final status = widget.status;
    final locked = status == JourneyStopStatus.locked;
    final diameter = widget.radius * 2;

    return Semantics(
      button: true,
      label: AppLocalization.kingdomZone(context, zone.id, 'title'),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Transform.scale(
            scale: 1 + _pulse.value * 0.08,
            child: child,
          ),
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: locked ? 0 : zone.progressFraction,
                    strokeWidth: 6,
                    backgroundColor: Colors.white,
                    color: zone.color,
                  ),
                ),
                Center(
                  child: Container(
                    width: diameter - 12,
                    height: diameter - 12,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: locked ? AppColors.surfaceMuted : zone.softColor,
                      boxShadow: [
                        BoxShadow(
                          color: locked
                              ? AppColors.shadow
                              : zone.color.withValues(alpha: 0.45),
                          blurRadius:
                              status == JourneyStopStatus.current ? 18 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Opacity(
                      opacity: locked ? 0.35 : 1,
                      child: Text(
                        zone.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
                if (locked)
                  const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 26,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (status == JourneyStopStatus.done)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.gardenGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyStopLabel extends StatelessWidget {
  const _JourneyStopLabel({
    required this.zone,
    required this.status,
    required this.alignEnd,
    required this.onTap,
  });

  final KingdomZoneData zone;
  final JourneyStopStatus status;
  final bool alignEnd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = status == JourneyStopStatus.locked;
    final chipColor = switch (status) {
      JourneyStopStatus.done => AppColors.gardenGreen,
      JourneyStopStatus.current => AppColors.primary,
      JourneyStopStatus.open => AppColors.info,
      JourneyStopStatus.locked => AppColors.disabled,
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: locked ? 0.7 : 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: locked
                  ? AppColors.outline
                  : zone.color.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalization.kingdomZone(context, zone.id, 'title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color:
                      locked ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      journeyStatusLabel(context, status),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (!locked)
                    Text(
                      '${math.min(zone.progress, zone.goal)}/${zone.goal}',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouAreHereFlag extends StatelessWidget {
  const _YouAreHereFlag();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            context.tr('kingdom.you_are_here'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyTrailPainter extends CustomPainter {
  _JourneyTrailPainter({required this.points, required this.walked});

  final List<Offset> points;
  final List<bool> walked;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18
      ..color = Colors.white.withValues(alpha: 0.85);
    final walkedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = AppColors.premiumGold;
    final upcomingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = AppColors.outlineStrong;

    for (var i = 0; i < points.length - 1; i++) {
      final path = _segment(points[i], points[i + 1]);
      canvas.drawPath(path, basePaint);
      if (walked[i]) {
        canvas.drawPath(path, walkedPaint);
      } else {
        _drawDashed(canvas, path, upcomingPaint);
      }
    }
  }

  Path _segment(Offset from, Offset to) {
    final midY = (from.dy + to.dy) / 2;
    return Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 10.0;
    const gap = 9.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyTrailPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.walked != walked;
  }
}
