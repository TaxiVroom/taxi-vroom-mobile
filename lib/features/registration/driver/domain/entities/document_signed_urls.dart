import 'package:equatable/equatable.dart';

class DocumentSignedUrls extends Equatable {
  const DocumentSignedUrls({required this.frontUrl, this.backUrl});

  final String frontUrl;
  final String? backUrl;

  @override
  List<Object?> get props => [frontUrl, backUrl];
}
