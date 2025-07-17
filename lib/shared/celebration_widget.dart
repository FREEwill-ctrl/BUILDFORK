import 'package:flutter/material.dart';
import 'constants.dart';

class CelebrationWidget extends StatefulWidget {
  final VoidCallback? onDismiss;

  const CelebrationWidget({
    Key? key,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: InkWell(
        onTap: _dismiss,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Celebration Image
                        Image.asset(
                          'assets/images/completed_tasks.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        // Congratulations Text
                        Text(
                          'Congratulations!',
                          style: AppConstants.headingStyle.copyWith(
                            color: AppConstants.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: AppConstants.paddingSmall),

                        Text(
                          'Task completed successfully!',
                          style: AppConstants.bodyStyle.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        // Dismiss Button
                        TextButton(
                          onPressed: _dismiss,
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Helper function to show celebration
void showCelebration(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => CelebrationWidget(
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );
}
