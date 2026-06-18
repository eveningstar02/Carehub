import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/repositories/community_repository.dart';
import 'package:carehub_app/data/repositories/distribution_repository.dart';
import 'package:carehub_app/data/repositories/donation_repository.dart';
import 'package:carehub_app/data/repositories/financial_repository.dart';
import 'package:carehub_app/data/repositories/school_repository.dart';

class ImpactMetrics {
  ImpactMetrics({
    required this.totalPadsDonated,
    required this.totalPadsDistributed,
    required this.girlsSupported,
    required this.schoolsReached,
    required this.communitiesServed,
    required this.monetaryBalance,
  });

  final int totalPadsDonated;
  final int totalPadsDistributed;
  final int girlsSupported;
  final int schoolsReached;
  final int communitiesServed;
  final double monetaryBalance;
}

class ImpactService {
  ImpactService({
    DonationRepository? donations,
    DistributionRepository? distributions,
    SchoolRepository? schools,
    CommunityRepository? communities,
    FinancialRepository? financial,
  })  : _donations = donations ?? DonationRepository(),
        _distributions = distributions ?? DistributionRepository(),
        _schools = schools ?? SchoolRepository(),
        _communities = communities ?? CommunityRepository(),
        _financial = financial ?? FinancialRepository();

  final DonationRepository _donations;
  final DistributionRepository _distributions;
  final SchoolRepository _schools;
  final CommunityRepository _communities;
  final FinancialRepository _financial;

  Future<ImpactMetrics> compute() async {
    final donations = await _donations.getAll();
    final distributions = await _distributions.getAll();
    final schools = await _schools.getAll();
    final communities = await _communities.getAll();
    final financial = await _financial.getAll();

    final totalDonated = donations.fold<int>(0, (s, d) => s + d.quantity);
    final totalDistributed =
        distributions.fold<int>(0, (s, d) => s + d.quantity);

    final girlsFromSchools =
        schools.fold<int>(0, (s, sc) => s + sc.girlsServed);
    final girlsFromCommunities =
        communities.fold<int>(0, (s, c) => s + c.girlsServed);

    var balance = 0.0;
    for (final f in financial) {
      switch (f.recordType) {
        case FinancialType.monetaryDonation:
          balance += f.amount;
        case FinancialType.purchase:
        case FinancialType.expense:
          balance -= f.amount;
      }
    }

    return ImpactMetrics(
      totalPadsDonated: totalDonated,
      totalPadsDistributed: totalDistributed,
      girlsSupported: girlsFromSchools + girlsFromCommunities,
      schoolsReached: schools.length,
      communitiesServed: communities.length,
      monetaryBalance: balance,
    );
  }
}
