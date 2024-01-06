import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotinas Diárias',
      home: const RoutineList(),
      theme: ThemeData(
        // Define a cor do cabeçalho (appBar)
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 22, 158, 151), // Altere para a cor desejada
        ),
      ),
    );
  }
}

class RoutineList extends StatefulWidget {
  const RoutineList({super.key});

  @override
  _RoutineListState createState() => _RoutineListState();
}

extension TimeOfDayExtension on TimeOfDay {
  int compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}

class _RoutineListState extends State<RoutineList> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<Routine> routines = [];
  
  tz.TZDateTime get scheduledDate => scheduledDate;

  void _addAndSortRoutine(Routine routine) {
  setState(() {
    routines.add(routine);
    routines.sort((a, b) => a.time.compareTo(b.time));
  });
}

  // Inicializa as notificações locais
  void _initializeNotifications() async {
    tz.initializeTimeZones();
    var androidInitializationSettings =
        const AndroidInitializationSettings('app_icon');

    // Inicialização separada para o iOS
    var iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Agenda uma notificação local com base na rotina
  void _scheduleNotification(Routine routine) async {
    tz.initializeTimeZones();
    

    var now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, routine.time.hour, routine.time.minute);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Lembrete',
    'Hora de realizar a tarefa: ${routine.name}',
    scheduledDate, // Correção aqui
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Rotinas Diárias',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            ),
          ),
          centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: routines.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(routines[index].name),
            onDismissed: (direction) {
              setState(() {
                routines.removeAt(index);
              });
            },
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.check),
            ),
            child: ListTile(
              title: Text(routines[index].name),
              subtitle: Text('Horário: ${routines[index].time.format(context)}'),
              onTap: () {
                _editRoutine(context, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRoutineDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRoutineDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (context) {
      return const AddRoutineDialog();
    },
  );

  if (result != null && result is Routine) {
    var now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      result.time.hour,
      result.time.minute,
    );

    

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Lembrete',
      'Hora de realizar a tarefa: ${result.name}',
      scheduledDate,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    _addAndSortRoutine(result);
  }
}


  // Exibe um diálogo para editar uma rotina existente
  void _editRoutine(BuildContext context, int index) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return EditRoutineDialog(routine: routines[index]);
      },
    );

    if (result != null && result is Routine) {
      setState(() {
        routines[index] = result;
      });

      var time = TimeOfDay(hour: result.time.hour, minute: result.time.minute);
      var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );
      var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Lembrete',
        'Hora de realizar a tarefa: ${result.name}',
        scheduledDate,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

    }
  }
}

class Routine {
  String name;
  TimeOfDay time;

  Routine({required this.name, required this.time});
}

// Diálogo para adicionar uma nova rotina
class AddRoutineDialog extends StatefulWidget {
  const AddRoutineDialog({super.key});

  @override
  _AddRoutineDialogState createState() => _AddRoutineDialogState();
}

class _AddRoutineDialogState extends State<AddRoutineDialog> {
  final TextEditingController _nameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Rotina'),
      content: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome da Rotina'),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Text('Horário: '),
              ElevatedButton(
                onPressed: () async {
                  var pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Text(_selectedTime.format(context)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              Navigator.pop(
                context,
                Routine(name: _nameController.text, time: _selectedTime),
              );
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

// Diálogo para editar uma rotina existente
class EditRoutineDialog extends StatefulWidget {
  final Routine routine;

  const EditRoutineDialog({super.key, required this.routine});

  @override
  _EditRoutineDialogState createState() => _EditRoutineDialogState();
}

class _EditRoutineDialogState extends State<EditRoutineDialog> {
  final TextEditingController _nameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.routine.name;
    _selectedTime = widget.routine.time;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Rotina'),
      content: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome da Rotina'),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Text('Horário: '),
              ElevatedButton(
                onPressed: () async {
                  var pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );

                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Text(_selectedTime.format(context)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              Navigator.pop(
                context,
                Routine(name: _nameController.text, time: _selectedTime),
              );
            }
          },
          child: const Text('Salvar Alterações'),
        ),
      ],
    );
  }
}