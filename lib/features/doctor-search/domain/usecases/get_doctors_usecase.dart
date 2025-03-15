import 'package:medical_app/features/doctor-search/data/repos/dummy_doctor_profiles.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';

class GetDoctorsUsecase {
  final DoctorsList doctorsList;
  GetDoctorsUsecase(this.doctorsList);

  List<DoctorProfiles> call() {
    return doctorsList.getProfiles();
  }
}
