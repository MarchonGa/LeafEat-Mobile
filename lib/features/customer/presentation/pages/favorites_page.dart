import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/establishments/domain/models/establishment.dart';
import 'package:leafeat_mobile/features/explore/presentation/pages/establishment_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final List<Establishment> _favorites = [];
  bool _initialized = false;
  bool _loading = true;
  String? _error;

  CustomerRepository _repository() {
    final session = AppSessionScope.read(context);
    if (session.token == null) {
      throw StateError('Faça login como cliente para acessar seus favoritos.');
    }
    return CustomerRepository(session.apiClient, session.token!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final favorites = await _repository().favorites();
      if (!mounted) return;
      setState(() {
        _favorites
          ..clear()
          ..addAll(favorites);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _remove(Establishment establishment) async {
    final session = AppSessionScope.read(context);
    if (session.confirmFavoriteRemoval) {
      final decision = await _confirmRemoval(establishment);
      if (decision == null || !decision.confirmed || !mounted) return;
      if (decision.doNotAskAgain) {
        await session.setConfirmFavoriteRemoval(false);
      }
    }

    final originalIndex = _favorites.indexWhere(
      (item) => item.id == establishment.id,
    );
    if (originalIndex < 0) return;
    setState(() => _favorites.removeAt(originalIndex));

    try {
      await _repository().removeFavorite(establishment.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 6),
            content: Text('${establishment.name} removido dos favoritos.'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () => _undoRemoval(establishment, originalIndex),
            ),
          ),
        );
    } catch (error) {
      if (!mounted) return;
      _restoreAt(establishment, originalIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível remover: $error')),
      );
    }
  }

  Future<void> _undoRemoval(
    Establishment establishment,
    int originalIndex,
  ) async {
    if (_favorites.any((item) => item.id == establishment.id)) return;
    _restoreAt(establishment, originalIndex);

    try {
      await _repository().addFavorite(establishment.id);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _favorites.removeWhere((item) => item.id == establishment.id),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível desfazer: $error')),
      );
      return;
    }

    if (!mounted) return;
    try {
      final serverFavorites = await _repository().favorites();
      if (mounted) {
        setState(() {
          _favorites
            ..clear()
            ..addAll(serverFavorites);
        });
      }
    } catch (_) {
      // A restauração local é mantida; a próxima atualização reconcilia a lista.
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${establishment.name} voltou aos favoritos.')),
    );
  }

  void _restoreAt(Establishment establishment, int originalIndex) {
    var insertionIndex = originalIndex;
    if (insertionIndex < 0 || insertionIndex > _favorites.length) {
      insertionIndex = _favorites.length;
    }
    setState(() => _favorites.insert(insertionIndex, establishment));
  }

  Future<_RemovalDecision?> _confirmRemoval(
    Establishment establishment,
  ) async {
    var doNotAskAgain = false;
    return showDialog<_RemovalDecision>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Remover dos favoritos?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deseja remover ${establishment.name} da sua lista de favoritos?',
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Não perguntar novamente'),
                value: doNotAskAgain,
                onChanged: (value) => setDialogState(
                  () => doNotAskAgain = value ?? false,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                _RemovalDecision(
                  confirmed: true,
                  doNotAskAgain: doNotAskAgain,
                ),
              ),
              child: const Text('Remover'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais favoritos'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _Message(icon: Icons.cloud_off_outlined, text: _error!);
    }
    if (_favorites.isEmpty) {
      return const _Message(
        icon: Icons.favorite_border,
        text: 'Você ainda não salvou nenhum estabelecimento.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final establishment = _favorites[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(establishment.name),
              subtitle: Text(establishment.category),
              trailing: IconButton(
                tooltip: 'Remover dos favoritos',
                onPressed: () => _remove(establishment),
                icon: const Icon(Icons.delete_outline),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EstablishmentDetailPage(
                    establishment: establishment,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RemovalDecision {
  const _RemovalDecision({
    required this.confirmed,
    required this.doNotAskAgain,
  });

  final bool confirmed;
  final bool doNotAskAgain;
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
