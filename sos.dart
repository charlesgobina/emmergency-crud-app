import 'dart:io';
import 'dart:math';

// Creating our model class. This represents the object of an emergency.
class Emergency {
  String? id;
  String name;
  String description;
  String severity;
  String location;
  String phoneNumber;
  String createdAt;

  Emergency({
    required this.name,
    required this.description,
    required this.severity,
    required this.location,
    required this.createdAt,
    required this.phoneNumber,
  }) {
    id = _generateId();
  }

  // Function to auto generate id 
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;

    return "SOS$timestamp$random";
  }
}

// Creating a service class the performs actions to the database (CSV)
class EmergencyHandler {
  final String fileName;

  EmergencyHandler({required this.fileName});

  // function to write to the databse
  void writeToEmergencyDatabase (List<Emergency> emergencies) async {
    final file = File(fileName);
    final data = emergencies.map((obj) => emergencyToCsv(obj)).join('\n');
    await file.exists() ? file.writeAsStringSync(data, mode: FileMode.append) : file.writeAsStringSync(data, mode: FileMode.write);
  }

  String emergencyToCsv(Emergency emergency) {
    return '${emergency.id}, ${emergency.name}, ${emergency.description}, ${emergency.location}, ${emergency.phoneNumber}, ${emergency.createdAt}, ${emergency.severity} \n';
  }

  // function to read from the database;  

  Emergency csvToCsv(String csv) {
    final fields = csv.split(',');
    Emergency zem = new Emergency(
      name: fields[1],
      description: fields[2],
      severity: fields[3],
      location: fields[4],
      createdAt: fields[5],
      phoneNumber: fields[6]
    );
    return zem;
  }
}

class EmergencySos {
  final List<Emergency> emergencies = [];
  final EmergencyHandler fileHander;

  EmergencySos({required String fileName})
      : fileHander = EmergencyHandler(fileName: fileName);

  void createEmergency() {
    print('Enter your name');
    final name = stdin.readLineSync() ?? '';
    print('Enter description');
    final description = stdin.readLineSync() ?? '';
    print('Enter the location of the emergency');
    final location = stdin.readLineSync() ?? '';
    print('serverity (critical, not to bad, mild)');
    final serverity = stdin.readLineSync() ?? '';
    print('Enter your phonenumber');
    final phoneNumber = stdin.readLineSync() ?? '';
    final createdAt = DateTime.now().toString();

    final emergency = Emergency(
        name: name,
        description: description,
        severity: serverity,
        location: location,
        createdAt: createdAt,
        phoneNumber: phoneNumber);

    emergencies.add(emergency);
    fileHander.writeToEmergencyDatabase(emergencies);
    print('Emergency With ID: ${emergency.id} created successfuly');
  }

  deleteEmergencyData(id) {
    List<Emergency> rows = [];
    final theFile = File("./sos1");
    final lines = theFile.readAsLinesSync();
    for (final line in lines) {
      Emergency file = fileHander.csvToCsv(line);
      rows.add(file);
    }
    for (final dor in rows) {
      dor.id == id ? rows.remove(dor) : "Request does not exist";
    }
    fileHander.writeToEmergencyDatabase(rows);
  }
}

void main(){
  var firstEmergency = EmergencySos(fileName: 'sos1');
  print("++++++++ MAIN MENU +++++++++++");
  showMenu();
  String choice = stdin.readLineSync()!;
  int actualChoice = int.parse(choice);

  switch(actualChoice) {
    case 1: {
      firstEmergency.createEmergency();
    }
    break;
    case 2: {
      print("Enter a id for the request you want to delete");
      String del = stdin.readLineSync()!;
      print(del);
      firstEmergency.deleteEmergencyData(del);
      print("Ok");
    }
  }
                                                                                                                                                                      
}


void showMenu() {
  print("Enter (1) to create a new emergency report \n");
  print("Enter (2) to see all reports");
  print("Enter (3) to update an emergency");
  print("Enter (4) to delete an emergency");
  print("Press any other key to quit");
}
