import 'package:flutter/material.dart';
import 'chatgpt_logo.dart';

class ChatGptSidebarDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  final Function(String title) onSelectChat;

  const ChatGptSidebarDrawer({
    super.key,
    required this.onNewChat,
    required this.onSelectChat,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      width: (MediaQuery.of(context).size.width * 0.78).clamp(280.0, 320.0),
      child: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // DRAWER HEADER
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const ChatGptLogo(size: 26),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF475569)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF475569)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ==========================================
            // MAIN NAVIGATION ITEMS
            // ==========================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                physics: const BouncingScrollPhysics(),
                children: [
                  // New Chat (Highlighted)
                  _buildNavTile(
                    icon: Icons.edit_note_rounded,
                    title: 'New chat',
                    isSelected: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onNewChat();
                    },
                  ),
                  const SizedBox(height: 4),

                  _buildNavTile(
                    icon: Icons.auto_stories_outlined,
                    title: 'Library',
                    onTap: () {},
                  ),
                  _buildNavTile(
                    icon: Icons.folder_outlined,
                    title: 'Projects',
                    trailing: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF64748B)),
                    onTap: () {},
                  ),
                  _buildNavTile(
                    icon: Icons.access_time_rounded,
                    title: 'Scheduled',
                    onTap: () {},
                  ),
                  _buildNavTile(
                    icon: Icons.extension_outlined,
                    title: 'Plugins',
                    onTap: () {},
                  ),
                  _buildNavTile(
                    icon: Icons.code_rounded,
                    title: 'Codex',
                    trailing: const Icon(Icons.arrow_outward_rounded, size: 16, color: Color(0xFF64748B)),
                    onTap: () {},
                  ),
                  _buildNavTile(
                    icon: Icons.more_horiz_rounded,
                    title: 'More',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // Pinned Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'Pinned',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),

                  // Pinned Chat Items
                  _buildPinnedChatItem(context, 'Frontend vs Backend Interview Prep'),
                  _buildPinnedChatItem(context, 'React JS RN Interview Guide'),
                  _buildPinnedChatItem(context, 'Docker Interview Prep'),
                  _buildPinnedChatItem(context, 'GitHub Actions CI/CD'),
                  _buildPinnedChatItem(context, 'MySQL Interview Questions'),
                  _buildPinnedChatItem(context, 'Add Project in Resume'),
                ],
              ),
            ),

            // ==========================================
            // BOTTOM USER PROFILE SECTION
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              child: Row(
                children: [
                  // Initials Avatar
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFF64748B),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'SA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Saif',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Go',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.storefront_outlined, size: 20, color: Color(0xFF475569)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    bool isSelected = false,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedChatItem(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onSelectChat(title);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
