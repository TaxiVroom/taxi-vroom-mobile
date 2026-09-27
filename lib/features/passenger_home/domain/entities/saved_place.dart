import 'package:equatable/equatable.dart';

// An address the passenger saved under a label, e.g. "Maison".
class SavedPlace extends Equatable {
  const SavedPlace({required this.label, required this.address});

  final String label;
  final String address;

  @override
  List<Object?> get props => [label, address];
}
