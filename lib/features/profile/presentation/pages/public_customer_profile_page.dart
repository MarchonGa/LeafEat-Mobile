import 'package:flutter/material.dart';
import 'package:leafeat_mobile/app/session/app_session.dart';
import 'package:leafeat_mobile/core/theme/app_colors.dart';
import 'package:leafeat_mobile/features/review/data/public_review.dart';
import 'package:leafeat_mobile/features/review/data/review_repository.dart';

class PublicCustomerProfilePage extends StatefulWidget {
  const PublicCustomerProfilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<PublicCustomerProfilePage> createState() =>
      _PublicCustomerProfilePageState();
}

class _PublicCustomerProfilePageState
    extends State<PublicCustomerProfilePage> {
  Future<PublicCustomerProfile>? _profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profile ??= ReviewRepository(
      AppSessionScope.read(context).apiClient,
    ).publicProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Perfil público'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        body: FutureBuilder<PublicCustomerProfile>(
          future: _profile,
          builder: (context, snapshot) {
            if (snapshot.connectionState !=
                ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Não foi possível carregar este perfil.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final profile = snapshot.data!;
            final initial = profile.displayName.isEmpty
                ? '?'
                : profile.displayName[0].toUpperCase();
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  profile.displayName,
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 28),
                Text(
                  'Preferências alimentares públicas',
                  style:
                      Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (profile.dietaryPreferences.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.visibility_off_outlined),
                      title: Text(
                        'Nenhuma preferência foi tornada pública.',
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preference
                          in profile.dietaryPreferences)
                        Chip(
                          avatar: const Icon(
                            Icons.restaurant_outlined,
                            size: 18,
                          ),
                          label: Text(preference),
                        ),
                    ],
                  ),
                const SizedBox(height: 20),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.privacy_tip_outlined),
                    title: Text('Privacidade preservada'),
                    subtitle: Text(
                      'E-mail e demais dados pessoais não são '
                      'exibidos neste perfil.',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
}
