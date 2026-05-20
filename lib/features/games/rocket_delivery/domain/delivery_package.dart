import 'package:game_ex/features/games/rocket_delivery/domain/delivery_zone.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/package_item.dart';

class DeliveryPackage {
  const DeliveryPackage({required this.item, required this.target});

  final PackageItem item;
  final DeliveryZone target;
}
