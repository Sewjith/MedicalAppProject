

class Patient {
  final String name;
  final String condition;
  final String profileImage;
  bool isRead; // ← NEW field!

  Patient({
    required this.name,
    required this.condition,
    required this.profileImage,
    this.isRead = false,
  });

}

final List<Patient> patients = [
  Patient(name: "Alice Johnson", profileImage: "assets/patient1.jpg", condition: "Asthma"),
  Patient(name: "Liam Carter", profileImage: "assets/patient2.jpg", condition: "Diabetes"),
  Patient(name: "Sophia Hill", profileImage: "assets/patient3.jpg", condition: "Hypertension"),
  Patient(name: "Noah Evans", profileImage: "assets/patient4.jpg", condition: "Asthma"),
  Patient(name: "Emma Baker", profileImage: "assets/patient5.jpg", condition: "Arthritis"),
  Patient(name: "Oliver Perez", profileImage: "assets/patient6.jpg", condition: "Hypertension"),
  Patient(name: "Ava Scott", profileImage: "assets/patient7.jpg", condition: "Diabetes"),
  Patient(name: "William Rogers", profileImage: "assets/patient8.jpg", condition: "Depression"),
  Patient(name: "Isabella Murphy", profileImage: "assets/patient9.jpg", condition: "Anxiety"),
  Patient(name: "James Bailey", profileImage: "assets/patient10.jpg", condition: "Asthma"),
  Patient(name: "Mia Cooper", profileImage: "assets/patient11.jpg", condition: "Arthritis"),
  Patient(name: "Ethan Ramirez", profileImage: "assets/patient12.jpg", condition: "Diabetes"),
  Patient(name: "Charlotte Reed", profileImage: "assets/patient13.jpg", condition: "Anxiety"),
  Patient(name: "Logan Kelly", profileImage: "assets/patient14.jpg", condition: "Depression"),
  Patient(name: "Amelia Jenkins", profileImage: "assets/patient15.jpg", condition: "Hypertension"),
  Patient(name: "Benjamin Howard", profileImage: "assets/patient16.jpg", condition: "Asthma"),
  Patient(name: "Harper Bryant", profileImage: "assets/patient17.jpg", condition: "Arthritis"),
  Patient(name: "Lucas Rivera", profileImage: "assets/patient18.jpg", condition: "Diabetes"),
  Patient(name: "Evelyn Simmons", profileImage: "assets/patient19.jpg", condition: "Anxiety"),
  Patient(name: "Henry Patterson", profileImage: "assets/patient20.jpg", condition: "Depression"),
];
