import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:ui';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double blurSigma;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
    this.blurSigma = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 20.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundColor ?? AppTheme.glassWhite,
                    (backgroundColor ?? AppTheme.glassWhite).withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: borderColor ?? AppTheme.glassBorder,
                  width: 1,
                ),
                boxShadow: boxShadow ?? AppTheme.cardShadow,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final Color? color;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.color,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.color ?? AppTheme.neonGreen;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.width ?? double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [btnColor, btnColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: btnColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
              BoxShadow(color: btnColor.withOpacity(0.2), blurRadius: 40, spreadRadius: 4),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.background,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: AppTheme.background, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: AppTheme.background,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.5,
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

class NeonProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showGlow;

  const NeonProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppTheme.neonGreen;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor, barColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: showGlow
                ? [BoxShadow(color: barColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                : null,
          ),
        ),
      ),
    );
  }
}

class FlowProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const FlowProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isCompleted
                      ? AppTheme.neonGreen
                      : isCurrent
                          ? AppTheme.neonGreen.withOpacity(0.4)
                          : AppTheme.surfaceLight,
                  boxShadow: isCompleted
                      ? [BoxShadow(color: AppTheme.neonGreenGlow, blurRadius: 6)]
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${currentStep + 1} / $totalSteps',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class XPBadge extends StatelessWidget {
  final int xp;
  final bool compact;

  const XPBadge({super.key, required this.xp, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.neonGreenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.neonGreen.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: AppTheme.background, size: compact ? 12 : 14),
          SizedBox(width: compact ? 2 : 4),
          Text(
            '+$xp XP',
            style: TextStyle(
              color: AppTheme.background,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
