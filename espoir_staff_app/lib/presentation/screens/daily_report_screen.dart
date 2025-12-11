import 'package:espoir_staff_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/daily_report/daily_report_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/daily_report/daily_report_event.dart';
import 'package:espoir_staff_app/presentation/blocs/daily_report/daily_report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final TextEditingController _tasksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<DailyReportBloc>()
          .add(LoadDailyReportHistory(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _tasksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Daily Reports"),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Submit Report"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: BlocConsumer<DailyReportBloc, DailyReportState>(
          listener: (context, state) {
            if (state is DailyReportSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Daily Report Submitted Successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
              _tasksController.clear();
            } else if (state is DailyReportError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DailyReportLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DailyReportLoaded) {
              return TabBarView(
                children: [
                  _buildSubmitTab(context, state),
                  _buildHistoryTab(state),
                ],
              );
            }

            return const Center(child: Text("Something went wrong"));
          },
        ),
      ),
    );
  }

  Widget _buildSubmitTab(BuildContext context, DailyReportLoaded state) {
    if (state.isSubmittedToday) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "You have already submitted\nyour report for today.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              "Come back tomorrow!",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What did you work on today?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _tasksController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "List your completed tasks here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter your tasks";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<DailyReportBloc>().add(
                            SubmitDailyReport(
                              userId: authState.user.uid,
                              userName:
                                  authState.user.email?.split('@')[0] ?? 'User',
                              tasksCompleted: _tasksController.text.trim(),
                            ),
                          );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Submit Report",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(DailyReportLoaded state) {
    if (state.reports.isEmpty) {
      return const Center(
        child: Text("No reports submitted yet."),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.reports.length,
      itemBuilder: (context, index) {
        final report = state.reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM d, y').format(report.date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(report.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  report.tasksCompleted,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
