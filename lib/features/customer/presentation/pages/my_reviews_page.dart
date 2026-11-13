import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/customer/data/customer_repository.dart';
import 'package:leafeat_mobile/features/customer/data/customer_review.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});
  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  Future<List<CustomerReview>>? _reviews;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reviews ??= _load();
  }

  Future<List<CustomerReview>> _load() {
    final session = AppSessionScope.read(context);
    if (session.token == null) return Future.error('Faça login como cliente para consultar suas avaliações.');
    return CustomerRepository(session.apiClient, session.token!).reviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas avaliações'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: FutureBuilder<List<CustomerReview>>(
        future: _reviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(snapshot.error.toString(), textAlign: TextAlign.center)));
          final reviews = snapshot.data ?? const [];
          if (reviews.isEmpty) return const Center(child: Text('Você ainda não publicou avaliações.'));
          return RefreshIndicator(
            onRefresh: () async => setState(() => _reviews = _load()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final grade = review.averageRating.toStringAsFixed(1).replaceAll('.', ',');
                return Card(child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text('${review.establishmentName} — $grade'),
                  subtitle: Text('${review.dishName ?? 'Avaliação geral'}\n${review.comment}'),
                  isThreeLine: true,
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
