part of 'statistics_bloc.dart';

abstract class StatisticsEvent {}

class LoadStatistics extends StatisticsEvent {
  final String userId;
  LoadStatistics(this.userId);
}
