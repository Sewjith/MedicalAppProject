

class Doctor {
  final String name;
  final String profileImage;
  final String specialty;
  final String? phoneNumber;

  Doctor({
    required this.name,
    required this.profileImage,
    required this.specialty,
    this.phoneNumber,
  });
}



List<Doctor> doctors = [
  Doctor(name: "Dr. Olivia Turner", profileImage: "assets/doctor1.jpg", specialty: "Cardiology"),
  Doctor(name: "Dr. John Smith", profileImage: "assets/doctor2.jpg", specialty: "Cardiology"),
  Doctor(name: "Dr. Sarah Adams", profileImage: "assets/doctor3.jpg", specialty: "Cardiology"),
  Doctor(name: "Dr. Michael Lee", profileImage: "assets/doctor4.jpg", specialty: "Neurology"),
  Doctor(name: "Dr. Emily Clark", profileImage: "assets/doctor5.jpg", specialty: "Neurology"),
  Doctor(name: "Dr. Daniel Walker", profileImage: "assets/doctor6.jpg", specialty: "Neurology"),
  Doctor(name: "Dr. Sophia Martinez", profileImage: "assets/doctor7.jpg", specialty: "Pediatrics"),
  Doctor(name: "Dr. William Brown", profileImage: "assets/doctor8.jpg", specialty: "Pediatrics"),
  Doctor(name: "Dr. Ava Thompson", profileImage: "assets/doctor9.jpg", specialty: "Pediatrics"),
  Doctor(name: "Dr. James Wilson", profileImage: "assets/doctor10.jpg", specialty: "Pediatrics"),
  Doctor(name: "Dr. Ethan Brooks", profileImage: "assets/doctor11.jpg", specialty: "Dermatology"),
  Doctor(name: "Dr. Isabella Nguyen", profileImage: "assets/doctor12.jpg", specialty: "Dermatology"),
  Doctor(name: "Dr. Liam Patel", profileImage: "assets/doctor13.jpg", specialty: "Dermatology"),
  Doctor(name: "Dr. Grace Morgan", profileImage: "assets/doctor14.jpg", specialty: "Orthopedics"),
  Doctor(name: "Dr. Benjamin Reed", profileImage: "assets/doctor15.jpg", specialty: "Orthopedics"),
  Doctor(name: "Dr. Chloe Bennett", profileImage: "assets/doctor16.jpg", specialty: "Orthopedics"),
  Doctor(name: "Dr. Noah Campbell", profileImage: "assets/doctor17.jpg", specialty: "Psychiatry"),
  Doctor(name: "Dr. Mia Foster", profileImage: "assets/doctor18.jpg", specialty: "Psychiatry"),
  Doctor(name: "Dr. Elijah Hayes", profileImage: "assets/doctor19.jpg", specialty: "Psychiatry"),
  Doctor(name: "Dr. Lily Parker", profileImage: "assets/doctor20.jpg", specialty: "Psychiatry"),
];
