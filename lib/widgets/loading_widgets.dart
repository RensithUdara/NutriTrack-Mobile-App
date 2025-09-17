import 'package:flutter/material.dart';

class LoadingWidgets {
  // Custom loading indicator with app theme
  static Widget buildLoadingIndicator({
    String? message,
    Color? color,
    double size = 50.0,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.green,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Shimmer loading effect for cards
  static Widget buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Container(
            height: 20,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Content shimmer
          Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Nutrition cards shimmer
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Animated loading dots
  static Widget buildDotsLoading({
    Color? color,
    double size = 8.0,
  }) {
    return _DotsLoading(
      color: color ?? Colors.green,
      size: size,
    );
  }

  // Pulse animation for empty states
  static Widget buildPulseAnimation({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return _PulseAnimation(
      duration: duration,
      child: child,
    );
  }

  // Fade in animation
  static Widget buildFadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    return _FadeInAnimation(
      duration: duration,
      delay: delay,
      child: child,
    );
  }

  // Slide in animation
  static Widget buildSlideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Offset offset = const Offset(0, 0.3),
  }) {
    return _SlideInAnimation(
      duration: duration,
      offset: offset,
      child: child,
    );
  }
}

class _DotsLoading extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoading({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (animationValue * 2 - 1).abs()));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _PulseAnimation({
    required this.child,
    required this.duration,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

class _FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const _FadeInAnimation({
    required this.child,
    required this.duration,
    required this.delay,
  });

  @override
  State<_FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<_FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class _SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const _SlideInAnimation({
    required this.child,
    required this.duration,
    required this.offset,
  });

  @override
  State<_SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<_SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
