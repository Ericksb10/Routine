# Routine

The provided Flutter app appears to be a routine management application with local notifications. Here's an overview of its main functionalities:


1. Routine Management:
   
• Users can add, edit, and remove routines.

• Each routine has a name and a specific time.


2. Local Notifications:
   
• The app uses the flutter_local_notifications package to schedule local notifications.

• Notifications are triggered based on the specified time for each routine.

• When a routine's scheduled time arrives, the app sends a notification reminding the user to perform the associated task.


3.User Interface:

• The user interface is designed with a list of routines, displaying their names and scheduled times.

• Users can interact with each routine item (tap to edit or swipe to delete).

• There is a floating action button (FAB) to add new routines.


4. Dialogs:

• The app uses dialogs to facilitate user interactions, such as adding new routines or editing existing ones.

• When adding or editing a routine, users can input the routine name and select a time using the time picker.


5. Sorting:
   
• Routines are sorted based on their scheduled times to maintain a chronological order.


6. Initialization:
• The app initializes time zones and notification settings when it starts.
