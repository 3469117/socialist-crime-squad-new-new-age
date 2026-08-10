import 'package:flutter_test/flutter_test.dart';
import 'package:lcs_new_age/location/location_type.dart';
import 'package:lcs_new_age/location/site.dart';

import 'test_support.dart';

void main() {
  setUpAll(ensureGameDataLoaded);

  group('Union local maturity', () {
    test('75 strength makes a recognized local self-managing', () {
      final Site site = Site(SiteType.departmentStore);
      site.laborOrganizingProgress = 100;
      site.laborUnionLocalStrength = 75;

      expect(site.laborUnionSelfManaging, isTrue);
      expect(site.laborUnionManagementStatus, 'Self-managing');
      expect(site.laborUnionAutonomous, isFalse);
    });

    test('complete powerhouse local is autonomous and stable', () {
      final Site site = Site(SiteType.departmentStore);
      site.laborOrganizingProgress = 100;
      for (int demand = Site.laborDemandHigherWages;
          demand <= Site.laborDemandUnionProtections;
          demand++) {
        site.startLaborBargaining(demand);
        site.settleLaborContract();
      }
      site.laborUnionLocalStrength = 100;

      expect(site.hasAllLaborDemands, isTrue);
      expect(site.laborUnionAutonomous, isTrue);
      expect(site.laborUnionManagementStatus, 'Autonomous');
      expect(site.laborUnionCurrentStatus, 'Stable');
      expect(site.laborUnionNeedsPlayerAttention, isFalse);
    });

    test('unionized employer resistance remains visible after recognition', () {
      final Site site = Site(SiteType.departmentStore);
      site.laborOrganizingProgress = 100;
      site.laborEmployerResistance = 80;

      expect(site.laborEmployerResistanceStatus, 'Severe');
    });
  });
}
