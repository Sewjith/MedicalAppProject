import 'package:medical_app/features/Patient/doctor-search/domain/entities/doctor_profiles.dart';

class DoctorsList {
  List<DoctorProfiles> getProfiles() {
    return [
      DoctorProfiles(
          id: 1,
          firstName: "Sam",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          location: "Kadawatha",
          experience: "5",
          pictueURl: ""),
      DoctorProfiles(
          id: 2,
          firstName: "Sam",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          experience: "5",
          location: "Gampaha",
          pictueURl: ""),
      DoctorProfiles(
          id: 3,
          firstName: "Rob",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          experience: "5",
          location: "Galle",
          pictueURl: ""),
      DoctorProfiles(
          id: 4,
          firstName: "Gohan",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          experience: "5",
          location: "Colombo",
          pictueURl: ""),
      DoctorProfiles(
          id: 5,
          firstName: "Tim",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          experience: "5",
          location: "Kandy",
          pictueURl: ""),
      DoctorProfiles(
          id: 5,
          firstName: "Timothy",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          experience: "5",
          location: "Negombo",
          pictueURl: ""),
      DoctorProfiles(
          id: 5,
          firstName: "Drake",
          lastName: "Lake",
          contact: "12345567",
          email: "test@gmail.com",
          experience: "5",
          location: "Homagama",
          pictueURl: ""),
      DoctorProfiles(
          id: 5,
          firstName: "Tim",
          lastName: "Bake",
          contact: "12345567",
          experience: "5",
          email: "test@gmail.com",
          location: "Colombo",
          pictueURl: "")
    ];
  }
}
