import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../kingdom_zone_data.dart';
import 'kingdom_shared_widgets.dart';

const kingdomMapSize = Size(1180, 860);

class KingdomMapCanvas extends StatelessWidget {
  const KingdomMapCanvas({
    super.key,
    required this.zones,
    required this.activeZoneId,
    required this.recommendedZoneId,
    required this.onZoneTap,
  });

  final List<KingdomZoneData> zones;
  final String activeZoneId;
  final String recommendedZoneId;
  final ValueChanged<KingdomZoneData> onZoneTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kingdomMapSize.width,
      height: kingdomMapSize.height,
      child: Stack(
        children: [
          const Positioned.fill(child: _KingdomTerrain()),
          ...zones.expand(
            (zone) => [
              if (zone.id == recommendedZoneId)
                _RecommendedZoneRing(zone: zone),
              KingdomZoneArea(
                zone: zone,
                isActive: zone.id == activeZoneId,
                onTap: () => onZoneTap(zone),
              ),
              ..._zoneRewardItems(zone),
            ],
          ),
          const Positioned(
            left: 880,
            top: 42,
            child: KingdomCloud(width: 112, height: 50),
          ),
          const Positioned(
            left: 320,
            top: 64,
            child: KingdomCloud(width: 86, height: 38),
          ),
        ],
      ),
    );
  }
}

class _KingdomTerrain extends StatelessWidget {
  const _KingdomTerrain();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFCBEEFF),
                const Color(0xFFE8F8FF),
                const Color(0xFFCCEEAF),
                const Color(0xFFACE08A),
              ],
              stops: const [0.0, 0.26, 0.27, 1.0],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 230,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFA1D66A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(80)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 720,
          top: 520,
          child: Transform.rotate(
            angle: -0.32,
            child: Container(
              width: 340,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF7FD6F6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 245,
          top: 444,
          child: Transform.rotate(
            angle: -0.14,
            child: Container(
              width: 550,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF7D8A3),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedZoneRing extends StatefulWidget {
  const _RecommendedZoneRing({required this.zone});

  final KingdomZoneData zone;

  @override
  State<_RecommendedZoneRing> createState() => _RecommendedZoneRingState();
}

class _RecommendedZoneRingState extends State<_RecommendedZoneRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.zone.rect.inflate(10),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: widget.zone.color
                    .withValues(alpha: 0.35 + (_controller.value * 0.45)),
                width: 3 + (_controller.value * 2),
              ),
            ),
          );
        },
      ),
    );
  }
}

class KingdomZoneArea extends StatelessWidget {
  const KingdomZoneArea({
    super.key,
    required this.zone,
    required this.isActive,
    required this.onTap,
  });

  final KingdomZoneData zone;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = !zone.unlocked;

    return Positioned.fromRect(
      rect: zone.rect.inflate(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 145;
              final cozy = constraints.maxHeight < 180;
              final padding = compact ? 12.0 : (cozy ? 14.0 : 18.0);
              final titleStyle = compact
                  ? AppTypography.bodyStrong.copyWith(
                      color: isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    )
                  : AppTypography.h3.copyWith(
                      color: isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    );

              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.white.withValues(alpha: 0.50)
                          : zone.softColor
                              .withValues(alpha: isActive ? 0.96 : 0.82),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isActive
                            ? zone.color
                            : zone.color
                                .withValues(alpha: isLocked ? 0.28 : 0.55),
                        width: isActive ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: zone.color
                              .withValues(alpha: isActive ? 0.22 : 0.10),
                          blurRadius: isActive ? 22 : 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              zone.emoji,
                              style: TextStyle(fontSize: compact ? 20 : 26),
                            ),
                            SizedBox(width: compact ? 6 : 8),
                            Expanded(
                              child: Text(
                                zone.title,
                                maxLines: compact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: titleStyle,
                              ),
                            ),
                            if (!zone.playable)
                              const KingdomMiniBadge(
                                label: 'Soon',
                                color: AppColors.info,
                              ),
                          ],
                        ),
                        SizedBox(height: compact ? 6 : 10),
                        if (!compact)
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                isLocked
                                    ? 'Unlock this place by growing earlier zones.'
                                    : zone.subtitle,
                                maxLines: cozy ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: compact ? 1.2 : 1.35,
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            isLocked
                                ? 'Unlock by growing earlier zones.'
                                : zone.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        SizedBox(height: compact ? 6 : 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: compact ? 8 : 10,
                            value: zone.progressFraction,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.75),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLocked ? AppColors.disabled : zone.color,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 8),
                        Text(
                          '${zone.progress}/${zone.goal} kingdom rewards',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: isLocked
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: ColoredBox(
                          color: Colors.white.withValues(alpha: 0.42),
                          child: const Center(
                            child: KingdomCloud(width: 120, height: 54),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

List<Widget> _zoneRewardItems(KingdomZoneData zone) {
  if (!zone.unlocked) {
    return [
      Positioned(
        left: zone.rect.left + 22,
        top: zone.rect.top + 18,
        child: const KingdomCloud(width: 84, height: 36),
      ),
    ];
  }

  final items = <Widget>[];
  switch (zone.id) {
    case 'garden':
      for (var i = 0; i < zone.itemCount; i++) {
        final column = i % 4;
        final row = i ~/ 4;
        items.add(
          Positioned(
            left: zone.rect.left + 28 + (column * 52) + (row.isOdd ? 10 : 0),
            top: zone.rect.bottom - 48 - (row * 32),
            child: const KingdomMapItemBubble(
              icon: Icons.local_florist_rounded,
              color: AppColors.gardenGreen,
              glowColor: Color(0xFF93E89C),
            ),
          ),
        );
      }
    case 'meadow':
      for (var i = 0; i < zone.itemCount; i++) {
        final column = i % 3;
        final row = i ~/ 3;
        items.add(
          Positioned(
            left: zone.rect.left + 36 + (column * 70),
            top: zone.rect.top + 72 + (row * 34),
            child: const KingdomMapItemBubble(
              icon: Icons.pets_rounded,
              color: AppColors.warning,
              glowColor: Color(0xFFFFE9B0),
            ),
          ),
        );
      }
    case 'castle':
      for (var i = 0; i < zone.itemCount; i++) {
        final width = 36.0 + (i * 8);
        final height = 26.0 + (i * 12);
        items.add(
          Positioned(
            left: zone.rect.left + 40 + (i * 26),
            top: zone.rect.bottom - height - 18,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.castleGray.withValues(alpha: 0.95),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.castle_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }
    case 'path':
      for (var i = 0; i < zone.itemCount; i++) {
        items.add(
          Positioned(
            left: zone.rect.left + 32 + (i * 54),
            top: zone.rect.top + 38 + (i.isEven ? 0 : 14),
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.pathwayPeach,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        );
      }
    case 'bridge':
      for (var i = 0; i < zone.itemCount; i++) {
        items.add(
          Positioned(
            left: zone.rect.left + 18 + (i * 28),
            top: zone.rect.top + 74 - ((i % 2) * 6),
            child: Container(
              width: 20,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFF3D08B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD7B26C)),
              ),
            ),
          ),
        );
      }
      if (zone.sunshine) {
        items.add(
          Positioned(
            right: 40,
            top: zone.rect.top - 28,
            child: const Icon(
              Icons.wb_sunny_rounded,
              size: 36,
              color: AppColors.accent,
            ),
          ),
        );
      }
    case 'stairs':
      for (var i = 0; i < zone.itemCount; i++) {
        items.add(
          Positioned(
            left: zone.rect.left + 26 + (i * 20),
            top: zone.rect.bottom - 28 - (i * 12),
            child: Container(
              width: 48,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.stairsLavender,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      }
  }

  return items;
}

class KingdomMapItemBubble extends StatefulWidget {
  const KingdomMapItemBubble({
    super.key,
    required this.icon,
    required this.color,
    required this.glowColor,
  });

  final IconData icon;
  final Color color;
  final Color glowColor;

  @override
  State<KingdomMapItemBubble> createState() => _KingdomMapItemBubbleState();
}

class _KingdomMapItemBubbleState extends State<KingdomMapItemBubble> {
  bool _active = false;

  void _triggerPop() {
    if (_active) return;
    HapticFeedback.lightImpact();
    setState(() => _active = true);
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() => _active = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerPop,
      child: AnimatedScale(
        scale: _active ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _active ? widget.glowColor : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _active ? 0.35 : 0.18),
                blurRadius: _active ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: widget.color, width: 2),
          ),
          child: Icon(widget.icon, size: 18, color: widget.color),
        ),
      ),
    );
  }
}
