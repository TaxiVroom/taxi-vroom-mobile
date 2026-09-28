import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geo_hash/flutter_geo_hash.dart';
import 'package:mobile/features/passenger_home/data/models/nearby_taxi_model.dart';
import 'package:stream_transform/stream_transform.dart';

abstract class NearbyTaxiRemoteDataSource {
  Stream<List<NearbyTaxiModel>> watchNearbyTaxis({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });
}

// Firebase Realtime Database: the drivers online, written by the driver app
// at drivers/<uid>. One query per geohash range around the passenger, as in
// https://firebase.google.com/docs/firestore/solutions/geoqueries ("the same
// approach works for Realtime Database") and
// https://firebase.google.com/docs/database/flutter/lists-of-data
class NearbyTaxiRemoteDataSourceImpl implements NearbyTaxiRemoteDataSource {
  NearbyTaxiRemoteDataSourceImpl(this._database);

  final FirebaseDatabase _database;
  final _geoHash = GeoHashUtils();

  @override
  Stream<List<NearbyTaxiModel>> watchNearbyTaxis({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) {
    final ranges = _geoHash.geohashQueryBounds(
      GeoHashPoint(latitude, longitude),
      radiusMeters,
    );
    final drivers = _database.ref('drivers');
    final taxisByRange = [
      for (final [start, end] in ranges)
        drivers
            .orderByChild('geohash')
            .startAt(start)
            .endAt(end)
            .onValue
            .map(
              (event) => [
                for (final driver in event.snapshot.children)
                  NearbyTaxiModel.fromJson({
                    'id': driver.key,
                    ...Map<String, dynamic>.from(driver.value! as Map),
                  }),
              ],
            ),
    ];
    // Each range is listened to: any driver moving gives the whole list.
    return taxisByRange.first
        .combineLatestAll(taxisByRange.skip(1))
        .map((ranges) => ranges.expand((taxis) => taxis).toList());
  }
}
