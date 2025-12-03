import 'package:espoir_staff_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/attendance/attendance_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/weekly_status/weekly_status_bloc.dart';
import 'package:espoir_staff_app/presentation/blocs/statistics/statistics_bloc.dart';
import 'package:espoir_staff_app/presentation/screens/daily_report_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<StatisticsBloc>().add(LoadStatistics(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AttendanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance Marked Successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh weekly status after successful attendance
            context.read<WeeklyStatusBloc>().add(LoadWeeklyStatus());
          }
        },
        child: Stack(
          children: [
            // 1. Background
            Container(
              height: size.height * 0.35,
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),

            // 2. Content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(),
                      const SizedBox(height: 20),
                      _buildSubmitAttendanceCard(),
                      const SizedBox(height: 20),
                      _buildDateAndStatusCard(),
                      const SizedBox(height: 20),
                      _buildStatisticsCard(),
                      const SizedBox(height: 20),
                      _buildGridMenuCard(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'User';
        if (state is AuthAuthenticated) {
          userName = state.user.email?.split('@')[0] ?? 'User';
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: Colors.white),
            ),
            Column(
              children: [
                const Text(
                  "Espoir Digital solution",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  "Hello, $userName",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 40), // Balance the row
          ],
        );
      },
    );
  }

  Widget _buildSubmitAttendanceCard() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        String title = "Take attendance today";
        String buttonText = "Submit";
        VoidCallback? onPressed;
        Color buttonColor = const Color(0xFFE76F84);

        if (state is AttendanceLoading) {
          buttonText = "Loading...";
          onPressed = null;
        } else if (state is AttendanceLoaded) {
          if (state.punchInTime == null) {
            // Not punched in yet
            onPressed = () {
              context.read<AttendanceBloc>().add(PunchIn());
            };
          } else if (!state.isAttendanceCompleted) {
            // Punched in, check if can punch out
            // With new logic, attendance is completed immediately after punch in.
            // But if we want to show "Marked Late" etc, we can check isLate.

            // However, the bloc sets isAttendanceCompleted = true immediately.
            // So this block might not be reached if we rely on that flag.
            // Let's check the bloc logic again.
            // Bloc: if (currentAttendance != null && isToday) -> isAttendanceCompleted = true.
            // So we will fall into the 'else' block below (lines 167+).

            // We should modify the 'else' block to show specific status.
            title = "Attendance Marked";
            buttonText = "Done";
            buttonColor = Colors.green;
            onPressed = null;
          } else {
            // Attendance completed for today
            if (state.isLate) {
              title = "Marked Late";
              buttonColor = Colors.orange;
            } else {
              title = "Attendance Marked";
              buttonColor = Colors.green;
            }

            // We can also check if it was half day if we had that info in state.
            // The state has isLate, but not isHalfDay explicitly (it has punchInTime).
            // We can infer or add to state. For now, let's stick to isLate.

            buttonText = "Done";
            onPressed = null;
          }
        } else if (state is AttendanceFailure) {
          title = "Error: ${state.error}";
          buttonText = "Retry";
          onPressed = () {
            context.read<AttendanceBloc>().add(AttendanceStarted());
          };
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(buttonText),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateAndStatusCard() {
    final now = DateTime.now();
    final day = DateFormat('d').format(now);
    // Add suffix th, st, nd, rd
    String suffix = 'th';
    int dayNum = int.parse(day);
    if (dayNum >= 11 && dayNum <= 13) {
      suffix = 'th';
    } else {
      switch (dayNum % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
          break;
      }
    }

    final weekDay = DateFormat('EEEE').format(now);
    final monthYear = DateFormat('MMMM y').format(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: day,
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF))),
                        TextSpan(
                            text: suffix,
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF6C63FF))),
                      ],
                    ),
                  ),
                  Text(weekDay,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  Text(monthYear, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.chevron_right, color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text("This week status",
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 15),
          // Placeholder for weekly status as we don't have history in state yet
          // We can highlight today
          // Placeholder for weekly status as we don't have history in state yet
          // We can highlight today
          BlocBuilder<WeeklyStatusBloc, WeeklyStatusState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusCircle(context, "M", 1, state),
                  _buildStatusCircle(context, "T", 2, state),
                  _buildStatusCircle(context, "W", 3, state),
                  _buildStatusCircle(context, "Th", 4, state),
                  _buildStatusCircle(context, "Fr", 5, state),
                  _buildStatusCircle(context, "Sat", 6, state),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        String attendanceValue = "--";
        String remainingDaysValue = "--";
        String leavesValue = "--";
        double attendancePercent = 0.0;

        if (state is StatisticsLoaded) {
          attendanceValue = state.attendancePercentage;
          remainingDaysValue = state.remainingDays;
          leavesValue = state.totalLeavesTaken;

          String cleanPercent = attendanceValue.replaceAll('%', '');
          attendancePercent = (double.tryParse(cleanPercent) ?? 0) / 100;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("     Monthly Statistics",
                  style: TextStyle(
                      fontSize: 14, color: Color.fromARGB(255, 133, 132, 132))),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircularStat(
                    title: "Attendance",
                    value: attendanceValue,
                    percent: attendancePercent,
                    isPercentage: true,
                    color: const Color(0xFF6C63FF),
                  ),
                  _buildCircularStat(
                    title: "Remaining Days",
                    value: remainingDaysValue,
                    percent: 1.0,
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.7),
                  ),
                  _buildCircularStat(
                    title: "Total Leaves",
                    value: leavesValue,
                    percent: 1.0,
                    color: const Color(0xFF6C63FF),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildGridMenuCard(BuildContext context) {
  final List<Map<String, dynamic>> menuItems = [
    //  {'icon': Icons.newspaper, 'label': 'News', 'hasDot': true},
    {'icon': Icons.calendar_today, 'label': 'Leaves', 'hasDot': false},
    {'icon': Icons.edit_note_outlined, 'label': 'Assignments', 'hasDot': true},
    {
      'icon': Icons.assignment,
      'label': 'Daily Reports',
      'hasDot': false,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyReportScreen()),
        );
      }
    },
  ];

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5)),
      ],
    ),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        return _buildMenuItem(
          context,
          menuItems[index]['icon'],
          menuItems[index]['label'],
          menuItems[index]['hasDot'],
          menuItems[index]['onTap'],
        );
      },
    ),
  );
}

Widget _buildStatusCircle(BuildContext context, String dayLabel,
    int weekdayIndex, WeeklyStatusState state) {
  // weekdayIndex: 1 = Mon, ..., 7 = Sun
  final now = DateTime.now();
  final isToday = now.weekday == weekdayIndex;

  Color bgColor = Colors.transparent;
  Color textColor = Colors.grey;
  Widget? icon;
  bool isPresent = false;
  bool isFuture = false;

  // Check if this day is in the future
  if (weekdayIndex > now.weekday) {
    isFuture = true;
  }

  if (state is WeeklyStatusLoaded) {
    // Check if we have attendance for this weekday
    final attendanceForDay = state.weeklyAttendance.where((a) {
      return a.punchIn.weekday == weekdayIndex;
    });

    if (attendanceForDay.isNotEmpty) {
      isPresent = true;
    }
  }

  if (isPresent) {
    bgColor = const Color(0xFF6C63FF);
    textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    icon = const Icon(Icons.check, size: 16, color: Colors.white);
  } else if (isToday) {
    // Today but not punched in yet
    bgColor = Colors.grey.shade200;
    textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    icon = const Text("?", style: TextStyle(fontWeight: FontWeight.bold));
  } else if (isFuture) {
    // Future days
    bgColor = Colors.transparent;
    textColor = Colors.grey;
    icon = null; // Border only
  } else {
    // Past days, absent
    bgColor = Colors.red.withValues(alpha: 0.1);
    textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    icon = const Icon(Icons.close, size: 16, color: Colors.red);
  }

  return Column(
    children: [
      Text(dayLabel, style: TextStyle(color: textColor, fontSize: 12)),
      const SizedBox(height: 8),
      Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: icon == null ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Center(child: icon),
      ),
    ],
  );
}

Widget _buildCircularStat(
    {required String title,
    required String value,
    double percent = 1.0,
    bool isPercentage = false,
    required Color color}) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              value: isPercentage ? percent : 1.0,
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}

Widget _buildMenuItem(BuildContext context, IconData icon, String label,
    bool hasDot, VoidCallback? onTap) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color)),
            if (hasDot)
              Container(
                margin: const EdgeInsets.only(left: 5),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              )
          ],
        )
      ],
    ),
  );
}
