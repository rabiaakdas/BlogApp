import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/post_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/snackbar_helper.dart';
import '../auth/login_screen.dart';
import '../posts/create_post_screen.dart';
import '../posts/edit_post_screen.dart';
import '../posts/post_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostProvider>().fetchPosts();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    context.read<PostProvider>().clear();
    context.read<CommentProvider>().clear();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _openCreatePost() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const CreatePostScreen()));

    if (!mounted || created != true) return;

    showSuccessSnackBar(context, 'Gönderi paylaşıldı');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: postProvider.refreshPosts,
          child: _HomeBody(
            postProvider: postProvider,
            onCreatePost: _openCreatePost,
            onLogout: authProvider.isLoading ? null : () => _logout(context),
          ),
        ),
      ),
      floatingActionButton: _GradientFab(onPressed: _openCreatePost),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'create_post_fab',
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        onPressed: onPressed,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Paylaş'),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.postProvider,
    required this.onCreatePost,
    required this.onLogout,
  });

  final PostProvider postProvider;
  final VoidCallback onCreatePost;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().user?.id;

    if (postProvider.isLoading && postProvider.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          _HomeHeader(onLogout: null),
          SizedBox(
            height: 180,
            child: LoadingView(message: 'Gönderiler yükleniyor...'),
          ),
        ],
      );
    }

    if (postProvider.error != null && postProvider.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _HomeHeader(onLogout: onLogout),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: EmptyState(
              icon: Icons.wifi_off_outlined,
              message: postProvider.error!,
            ),
          ),
        ],
      );
    }

    if (postProvider.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _HomeHeader(onLogout: onLogout),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.48,
            child: EmptyState(
              icon: Icons.auto_awesome_outlined,
              message:
                  'Henüz paylaşılmış gönderi yok.\nİlk gönderiyi sen paylaş.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: PrimaryButton(
              label: 'İlk gönderiyi paylaş',
              icon: Icons.edit_outlined,
              onPressed: onCreatePost,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: postProvider.posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _HomeHeader(onLogout: onLogout);

        final post = postProvider.posts[index - 1];

        return PostCard(
          post: post,
          onLike: () => context.read<PostProvider>().toggleLike(post),
          onComment: () => _openPostDetail(context, post),
          canEdit: post.userId == currentUserId,
          onEdit: () => _editPost(context, post),
          canDelete: post.userId == currentUserId,
          onDelete: () => _deletePost(context, post),
          onTap: () => _openPostDetail(context, post),
        );
      },
    );
  }

  void _openPostDetail(BuildContext context, PostModel post) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
  }

  Future<void> _editPost(BuildContext context, PostModel post) async {
    final updatedPost = await Navigator.of(context).push<PostModel>(
      MaterialPageRoute(builder: (_) => EditPostScreen(post: post)),
    );

    if (!context.mounted || updatedPost == null) return;

    showSuccessSnackBar(context, 'Gönderi güncellendi');
  }

  Future<void> _deletePost(BuildContext context, PostModel post) async {
    final postProvider = context.read<PostProvider>();
    final success = await postProvider.deletePost(post);

    if (!context.mounted) return;

    if (success) {
      showSuccessSnackBar(context, 'Gönderi silindi');
    } else {
      showErrorSnackBar(context, postProvider.error ?? 'Gönderi silinemedi');
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BlogApp', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Bugün neler paylaşılıyor?',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.person_outline,
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.logout,
            tooltip: 'Çıkış Yap',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
      ),
    );
  }
}
