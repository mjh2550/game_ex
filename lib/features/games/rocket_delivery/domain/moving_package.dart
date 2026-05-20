import 'package:game_ex/features/games/rocket_delivery/domain/delivery_package.dart';

class MovingPackage {
  MovingPackage({required this.id, required this.package});

  final int id;
  final DeliveryPackage package;
  double progress = 0;
}
