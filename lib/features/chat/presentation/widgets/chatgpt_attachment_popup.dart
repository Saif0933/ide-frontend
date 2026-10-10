import 'package:flutter/material.dart';

class ChatGptAttachmentPopup extends StatelessWidget {
  final Function(String action) onActionSelected;

  const ChatGptAttachmentPopup({
    super.key,
    required this.onActionSelected,
  });

  static void show({
    required BuildContext context,
    required GlobalKey plusButtonKey,
    required Function(String action) onActionSelected,
  }) {
    RenderBox? renderBox;
    if (plusButtonKey.currentContext != null) {
      renderBox = plusButtonKey.currentContext!.findRenderObject() as RenderBox?;
    }

    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(20, 500);
    final screenSize = MediaQuery.of(context).size;

    // Position popup right above the plus button
    final bottomPosition = screenSize.height - offset.dy + 8;
    final leftPosition = offset.dx.clamp(14.0, screenSize.width - 240);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Attachment Options',
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogCtx, anim1, anim2) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogCtx),
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              bottom: bottomPosition,
              left: leftPosition,
              width: 220,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionItem(
                        dialogCtx,
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(dialogCtx);
                          onActionSelected('Camera');
                        },
                      ),
                      _buildOptionItem(
                        dialogCtx,
                        icon: Icons.photo_outlined,
                        label: 'Photos',
                        onTap: () {
                          Navigator.pop(dialogCtx);
                          onActionSelected('Photos');
                        },
                      ),
                      _buildOptionItem(
                        dialogCtx,
                        icon: Icons.attach_file_rounded,
                        label: 'Files',
                        onTap: () {
                          Navigator.pop(dialogCtx);
                          onActionSelected('Files');
                        },
                      ),
                      _buildOptionItem(
                        dialogCtx,
                        icon: Icons.auto_awesome_outlined,
                        label: 'Create image',
                        onTap: () {
                          Navigator.pop(dialogCtx);
                          onActionSelected('Create image');
                        },
                      ),
                      _buildOptionItem(
                        dialogCtx,
                        icon: Icons.psychology_outlined,
                        label: 'Thinking',
                        onTap: () {
                          Navigator.pop(dialogCtx);
                          onActionSelected('Thinking');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 19,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
