import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/review/presentation/pages/review_form_page.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isCustomer = AppSessionScope.watch(context).mode == UserMode.customer;
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar'), backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rate_review_outlined, size: 96, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text('Avalie sua experiência', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(isCustomer ? 'Compartilhe sua opinião sobre o prato e o ambiente.' : 'Entre como cliente para publicar avaliações.', textAlign: TextAlign.center),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () {
                  if (!isCustomer) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entre ou crie uma conta de cliente para avaliar.')));
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReviewFormPage()));
                },
                icon: Icon(isCustomer ? Icons.play_arrow : Icons.lock_outline),
                label: Text(isCustomer ? 'Escrever avaliação' : 'Recurso exclusivo para clientes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
