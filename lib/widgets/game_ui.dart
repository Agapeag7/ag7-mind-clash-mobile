import 'package:flutter/material.dart';

import '../core/constants.dart';

class GamePageBackground extends StatelessWidget {
  final Widget child;

  const GamePageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _bubble(190, AppColors.blue.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _bubble(230, AppColors.red.withValues(alpha: 0.05)),
          ),
          SizedBox.expand(child: child),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class GamePageHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const GamePageHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ],
      ],
    );
  }
}

class GamePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GamePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GameActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color foregroundColor;
  final IconData? icon;
  final double height;

  const GameActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.red,
    this.foregroundColor = Colors.white,
    this.icon,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.navy.withValues(alpha: 0.12)),
          ),
        ),
        child: icon == null
            ? child
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 19),
                  const SizedBox(width: 8),
                  child,
                ],
              ),
      ),
    );
  }
}

class GameModeArtwork extends StatelessWidget {
  final double height;

  const GameModeArtwork({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        'assets/icon/icone_ag7mindclash.png',
        width: height,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
