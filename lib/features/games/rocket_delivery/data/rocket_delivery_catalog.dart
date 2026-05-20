import 'package:flutter/material.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/delivery_zone.dart';
import 'package:game_ex/features/games/rocket_delivery/domain/package_item.dart';

const rocketDeliveryZones = [
  DeliveryZone('A', '강남', Icons.apartment_rounded, Color(0xFF2BB673)),
  DeliveryZone('B', '홍대', Icons.storefront_rounded, Color(0xFFE56B1F)),
  DeliveryZone('C', '잠실', Icons.stadium_rounded, Color(0xFF54C6EB)),
  DeliveryZone('D', '용산', Icons.train_rounded, Color(0xFF8E6BE8)),
  DeliveryZone('E', '성수', Icons.factory_rounded, Color(0xFFE84A5F)),
  DeliveryZone('F', '판교', Icons.business_rounded, Color(0xFF60707F)),
];

const rocketDeliveryItems = [
  PackageItem('생수', Icons.water_drop_rounded, Color(0xFF54C6EB)),
  PackageItem('휴지', Icons.description_rounded, Color(0xFFCAD4E1)),
  PackageItem('간식', Icons.cookie_rounded, Color(0xFFE56B1F)),
  PackageItem('충전기', Icons.battery_charging_full_rounded, Color(0xFF2BB673)),
  PackageItem('양말', Icons.checkroom_rounded, Color(0xFF8E6BE8)),
  PackageItem('샴푸', Icons.soap_rounded, Color(0xFF54C6EB)),
  PackageItem('사료', Icons.pets_rounded, Color(0xFFE8A15A)),
  PackageItem('키보드', Icons.keyboard_rounded, Color(0xFF60707F)),
  PackageItem('책', Icons.menu_book_rounded, Color(0xFF8E6BE8)),
  PackageItem('비타민', Icons.medication_rounded, Color(0xFFE84A5F)),
  PackageItem('게임패드', Icons.sports_esports_rounded, Color(0xFF18212F)),
  PackageItem('헤드폰', Icons.headphones_rounded, Color(0xFF60707F)),
  PackageItem('화분', Icons.local_florist_rounded, Color(0xFF2BB673)),
  PackageItem('커피', Icons.coffee_rounded, Color(0xFFE56B1F)),
  PackageItem('냄비', Icons.soup_kitchen_rounded, Color(0xFFE8A15A)),
  PackageItem('의자', Icons.chair_rounded, Color(0xFF60707F)),
  PackageItem('장난감', Icons.toys_rounded, Color(0xFFFFD166)),
  PackageItem('세제', Icons.local_laundry_service_rounded, Color(0xFF54C6EB)),
];
