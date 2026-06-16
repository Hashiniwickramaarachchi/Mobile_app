import 'contact.dart';

class Profile {
  const Profile({
    required this.guardianName,
    required this.elderlyName,
    required this.age,
    required this.disabilities,
    required this.emergencyContacts,
  });

  final String guardianName;
  final String elderlyName;
  final String age;
  final String disabilities;
  final List<Contact> emergencyContacts;

  Profile copyWith({
    String? guardianName,
    String? elderlyName,
    String? age,
    String? disabilities,
    List<Contact>? emergencyContacts,
  }) {
    return Profile(
      guardianName: guardianName ?? this.guardianName,
      elderlyName: elderlyName ?? this.elderlyName,
      age: age ?? this.age,
      disabilities: disabilities ?? this.disabilities,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  static const defaultProfile = Profile(
    guardianName: 'James Johnson',
    elderlyName: 'Margaret Johnson',
    age: '72',
    disabilities: 'Diabetes, blood pressure medication',
    emergencyContacts: [
      Contact(
        id: 'c1',
        name: 'Dr. Sarah Williams',
        phone: '+1 234 987 1234',
        relationship: 'Primary Doctor',
      ),
      Contact(
        id: 'c2',
        name: 'Mary Johnson',
        phone: '+1 234 876 2210',
        relationship: 'Daughter',
      ),
    ],
  );
}
