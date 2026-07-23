import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/hex_color.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/profil/profil_bloc.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfilBloc, ProfilState>(
        builder: (context, state) {
          if (state.status == ProfilStatus.chargement || state.status == ProfilStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ProfilStatus.erreur || state.profil == null) {
            return ErrorView(
              message: state.messageErreur ?? 'Impossible de charger le profil.',
              onRetry: () => context.read<ProfilBloc>().add(const ProfilChargementDemande()),
            );
          }

          final profil = state.profil!;
          final user = profil.utilisateur;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => context.read<ProfilBloc>().add(const ProfilChargementDemande()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    color: AppColors.profile,
                    padding: EdgeInsets.only(
                      left: 20, right: 20, bottom: 24,
                      top: MediaQuery.of(context).padding.top + 20,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(user.initiales,
                              style: AppTextStyles.serif(fontSize: 22, color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        Text(user.nom, style: AppTextStyles.serif(fontSize: 18, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text(
                          '${user.ville ?? ''}${user.region != null ? ', ${user.region}' : ''}',
                          style: AppTextStyles.sans(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(child: _statCard('${profil.stats.nbCultures}', 'Cultures suivies')),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('${profil.stats.anneesExperience}', "Ans d'expérience")),
                          const SizedBox(width: 10),
                          Expanded(child: _statCard('${profil.stats.superficieTotaleHa}', 'ha cultivés')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const SectionTitle('Mes cultures'),
                      if (profil.mesCultures.isEmpty)
                        Text('Aucune culture suivie pour le moment.',
                            style: AppTextStyles.sans(color: AppColors.textSecondary))
                      else
                        ...profil.mesCultures.map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(p.culture.couleur.replaceFirst('#', '0xFF'))).withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.eco_rounded,
                                        color: Color(int.parse(p.culture.couleur.replaceFirst('#', '0xFF'))),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.culture.nom,
                                              style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800)),
                                          Text('${p.superficieHa} ha · ${p.typeSol}',
                                              style: AppTextStyles.sans(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: hexToColor(p.statutCouleur).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(p.statut,
                                          style: AppTextStyles.sans(
                                            fontSize: 10, fontWeight: FontWeight.w700,
                                            color: hexToColor(p.statutCouleur),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      const SizedBox(height: 24),
                      const SectionTitle('Résumé'),
                      AppCard(
                        child: Column(
                          children: [
                            _ligneResume('Prévisions de rendement', '${profil.resumePrevisions.nbPrevisions}'),
                            const Divider(height: 20, color: AppColors.border),
                            _ligneResume('Cultures recommandées', '${profil.resumePrevisions.nbRecommandations}'),
                            const Divider(height: 20, color: AppColors.border),
                            _ligneResume('Alertes actives', '${profil.resumePrevisions.nbAlertes}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => context.read<AuthBloc>().add(const AuthDeconnexionRequested()),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Se déconnecter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String valeur, String label) => AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(valeur, style: AppTextStyles.serif(fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center,
                style: AppTextStyles.sans(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _ligneResume(String label, String valeur) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.sans(fontSize: 12, color: AppColors.textSecondary)),
          Text(valeur, style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      );
}
