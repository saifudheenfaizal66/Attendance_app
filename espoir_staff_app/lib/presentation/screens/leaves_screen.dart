// import 'package:espoir_staff_app/domain/entities/leave.dart';
// import 'package:espoir_staff_app/presentation/blocs/leave/leave_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// class LeavesScreen extends StatelessWidget {
//   const LeavesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Stack(
//         children: [
//           // 1. Background
//           Container(
//             height: size.height * 0.35,
//             decoration: const BoxDecoration(
//               color: Color(0xFF6C63FF),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(40),
//                 bottomRight: Radius.circular(40),
//               ),
//             ),
//           ),

//           // 2. Content
//           SafeArea(
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   "My Leaves",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: BlocBuilder<LeaveBloc, LeaveState>(
//                     builder: (context, state) {
//                       if (state is LeaveLoading) {
//                         return const Center(
//                             child:
//                                 CircularProgressIndicator(color: Colors.white));
//                       } else if (state is LeaveLoaded) {
//                         if (state.leaves.isEmpty) {
//                           return Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.calendar_today_outlined,
//                                     size: 60,
//                                     color: Colors.white.withOpacity(0.5)),
//                                 const SizedBox(height: 16),
//                                 const Text(
//                                   'You have not applied for any leaves.',
//                                   style: TextStyle(
//                                       fontSize: 18, color: Colors.white70),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                         return ListView.builder(
//                           padding: const EdgeInsets.all(16),
//                           itemCount: state.leaves.length,
//                           itemBuilder: (context, index) {
//                             final leave = state.leaves[index];
//                             return _buildLeaveCard(context, leave);
//                           },
//                         );
//                       } else if (state is LeaveFailure) {
//                         return Center(
//                             child: Text('Error: ${state.error}',
//                                 style: const TextStyle(color: Colors.white)));
//                       }
//                       return const Center(
//                           child: Text('Something went wrong.',
//                               style: TextStyle(color: Colors.white)));
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Implement leave application form
//         },
//         backgroundColor: const Color(0xFF6C63FF),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildLeaveCard(BuildContext context, Leave leave) {
//     final statusInfo = _getStatusInfo(leave.status);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   leave.reason,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: statusInfo.color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(statusInfo.icon, color: statusInfo.color, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         leave.status,
//                         style: TextStyle(
//                           color: statusInfo.color,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(Icons.date_range_outlined,
//                       size: 20, color: Colors.grey[700]),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   '${DateFormat.yMMMd().format(leave.fromDate)} - ${DateFormat.yMMMd().format(leave.toDate)}',
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w500),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _StatusInfo _getStatusInfo(String status) {
//     switch (status) {
//       case 'Approved':
//         return _StatusInfo(Colors.green, Icons.check_circle);
//       case 'Pending':
//         return _StatusInfo(Colors.orange, Icons.hourglass_bottom);
//       case 'Rejected':
//         return _StatusInfo(Colors.red, Icons.cancel);
//       default:
//         return _StatusInfo(Colors.grey, Icons.help_outline);
//     }
//   }
// }

// class _StatusInfo {
//   final Color color;
//   final IconData icon;

//   _StatusInfo(this.color, this.icon);
// }
