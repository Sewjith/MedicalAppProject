import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Doctor/D_Consultation_History/consultation_history_db.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class DoctorConsultationHistoryPage extends StatefulWidget {
  const DoctorConsultationHistoryPage({super.key});

  @override
  State<DoctorConsultationHistoryPage> createState() =>
      _DoctorConsultationHistoryPageState();
}

class _DoctorConsultationHistoryPageState
    extends State<DoctorConsultationHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentDoctorId;
  bool _isInitialLoading = true;
  String? _initialErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorId();
    });
  }

   void _initializeDoctorId() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      if (mounted) {
        setState(() {
          _currentDoctorId = userState.user.uid;
          _isInitialLoading = false; // Mark initial loading as done once ID is fetched
          _initialErrorMessage = null;
        });
      }
    } else {
       if (mounted) {
           setState(() {
             _isInitialLoading = false;
             _initialErrorMessage = "User is not logged in as a doctor or doctor ID is missing.";
           });
       }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback
            }
          },
        ),
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPallete.whiteColor,
          unselectedLabelColor: AppPallete.whiteColor.withOpacity(0.7),
          indicatorColor: AppPallete.whiteColor,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Completed'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _initialErrorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_initialErrorMessage!, style: const TextStyle(color: Colors.red))))
              : _currentDoctorId == null
                 ? const Center(child: Text("Doctor ID not found."))
                 : TabBarView(
                      controller: _tabController,
                      children: [
                        _DoctorAppointmentsList(
                          key: const PageStorageKey('completedList'), // Add key for state preservation
                          doctorId: _currentDoctorId!,
                          statusType: 'completed',
                        ),
                        _DoctorAppointmentsList(
                          key: const PageStorageKey('upcomingList'), // Add key
                          doctorId: _currentDoctorId!,
                          statusType: 'upcoming',
                        ),
                        _DoctorAppointmentsList(
                          key: const PageStorageKey('cancelledList'), // Add key
                          doctorId: _currentDoctorId!,
                          statusType: 'cancelled',
                        ),
                      ],
                   ),
    );
  }
}

// Internal StatefulWidget for displaying lists based on status
class _DoctorAppointmentsList extends StatefulWidget {
  final String doctorId;
  final String statusType; // 'completed', 'upcoming', or 'cancelled'

  // Use super(key: key)
  const _DoctorAppointmentsList({
    required this.doctorId,
    required this.statusType,
    super.key, // Pass key to super constructor
  });

  @override
  State<_DoctorAppointmentsList> createState() => _DoctorAppointmentsListState();
}


class _DoctorAppointmentsListState extends State<_DoctorAppointmentsList> with AutomaticKeepAliveClientMixin {
  final DoctorHistoryDB _db = DoctorHistoryDB();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Keep state alive
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Map<String, dynamic>> data;
      // Call the CORRECT methods from DoctorHistoryDB
      switch (widget.statusType) {
        case 'completed':
          data = await _db.getCompletedAppointments(widget.doctorId);
          break;
        case 'upcoming':
          data = await _db.getUpcomingAppointments(widget.doctorId);
          break;
        case 'cancelled':
          data = await _db.getCancelledAppointments(widget.doctorId);
          break;
        default:
          data = [];
      }

      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _appointments = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
      ));
    }
    if (_appointments.isEmpty) {
       return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
             constraints: BoxConstraints(minHeight: constraints.maxHeight),
             child: Center(child: Text('No ${widget.statusType} appointments found.')),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        // Ensure list view uses state preservation key if needed, but AutomaticKeepAliveClientMixin handles it
        padding: const EdgeInsets.all(12.0),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _buildHistoryCard(appointment, context);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> appointment, BuildContext context) {
    final status = appointment['appointment_status'] ?? 'unknown';
    final isCompleted = status == 'completed';
    final isUpcoming = status == 'upcoming';
    final isCancelled = status == 'cancelled';

    Color statusColor = Colors.grey;
    if (isCompleted) statusColor = Colors.green.shade700;
    if (isCancelled) statusColor = Colors.red.shade700;
    if (isUpcoming) statusColor = Colors.blue.shade700;

    final patientName = appointment['patient_name'] ?? 'Unknown Patient';
    final patientAge = appointment['patient_age'] ?? 'N/A';
    final patientGender = appointment['patient_gender'] ?? 'N/A';
    final patientId = appointment['patient_id'] ?? '';
    final notes = appointment['notes'] ?? 'No notes available.';
    final appointmentId = appointment['appointment_id'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor
                    ),
                     overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 4),
             Text(
              'Age: $patientAge • Gender: $patientGender',
              style: const TextStyle(fontSize: 13, color: AppPallete.greyColor),
            ),
             const SizedBox(height: 8),
             Text(
              _db.formatAppointmentDateTime(
                  appointment['appointment_date'], appointment['appointment_time']),
              style: const TextStyle(fontSize: 13, color: AppPallete.textColor),
            ),

            if (notes != 'No notes available.') ...[
              const SizedBox(height: 12),
              const Text(
                'Consultation Notes:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                notes,
                style: const TextStyle(fontSize: 13, color: AppPallete.greyColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                 if (isUpcoming)
                     ElevatedButton.icon(
                         icon: const Icon(Icons.video_call_outlined, size: 18),
                         label: const Text('Start Call'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           textStyle: const TextStyle(fontSize: 13)
                         ),
                         onPressed: () {
                              const appId = "bc06bf6bab7645abbc9b9d56db3f2868";
                              const token = "007eJxTYLh7OefL0v7fU7e+81X30H74mZ369K6Jz993fT6/uMX+a84KDKZGhqkmhqlppoYWRhamxkbJyebJiUbGyeZJqUaGacmmzJ59SmsIZGTY8X9kYIRCEH4GRkYGJmZmlgaGADK+H/s=";
                              context.go('/video-call', extra: {
                                'appId': appId,
                                'token': token,
                                'channelName': appointmentId,
                              });
                         },
                     ),
                 if (isCompleted && patientId.isNotEmpty && widget.doctorId.isNotEmpty)
                     TextButton.icon(
                         style: TextButton.styleFrom(foregroundColor: AppPallete.primaryColor),
                         icon: const Icon(Icons.chat_bubble_outline, size: 18),
                         label: const Text('Chat Follow-up'),
                         onPressed: () {
                            final userState = context.read<AppUserCubit>().state;
                            final doctorName = userState is AppUserLoggedIn
                                              ? '${userState.user.firstname ?? ''} ${userState.user.lastname ?? ''}'.trim()
                                              : 'Doctor';

                            final List ids = [patientId, widget.doctorId]
                                .where((id) => id.isNotEmpty)
                                .toList();
                            ids.sort();
                            final String sortedIdsString = ids.join('_');
                            final consultationId = 'consult_$sortedIdsString';

                            context.push('/chat/consultation', extra: {
                              'consultationId': consultationId,
                              'userName': doctorName.isNotEmpty ? doctorName : 'Doctor',
                              'userRole': 'doctor',
                              'recipientName': patientName,
                              'doctorName': doctorName.isNotEmpty ? doctorName : 'Doctor',
                              'patientName': patientName,
                              'doctorId': widget.doctorId,
                              'patientId': patientId,
                            });
                         },
                     ),
                 TextButton.icon(
                   style: TextButton.styleFrom(foregroundColor: AppPallete.textColor),
                   icon: const Icon(Icons.notes_outlined, size: 18),
                   label: const Text('View Details'),
                   onPressed: () {
                       showDialog(
                         context: context,
                         builder: (_) => AlertDialog(
                             title: const Text('Consultation Notes'),
                             content: SingleChildScrollView(child: Text(notes)),
                             actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Close'))],
                           )
                       );
                   },
                 ),
              ],
            )
          ],
        ),
      ),
    );
  }
}