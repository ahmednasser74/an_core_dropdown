import 'package:an_core_network/an_core_network.dart';

class AppDropDownRequestModel extends RequestModel {
  AppDropDownRequestModel({
    this.page = 0,
    this.search,
    RequestProgressListener? progressListener,
  }) : super(progressListener);

  final int page;
  final String? search;

  @override
  List<Object?> get props => [page, search, identityHashCode(this)];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'page': page,
        'search': search,
      };
}
