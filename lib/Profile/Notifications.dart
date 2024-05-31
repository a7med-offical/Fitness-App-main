import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications extends StatefulWidget {
  @override
  State<Notifications> createState() {
    return NotificationsState();
  }
}

class NotificationsState extends State<Notifications> {
  List<bool> isSelectedList = List.generate(8, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              height: 60.0,
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFF35383F),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.navigate_before),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const Text(
                    "Notification",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFF35383F),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz),
                      color: Colors.white,
                      onPressed: () {
                        // Add your action here for the more options
                      },
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance.collection('notifications').get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No documents found"),
                  );
                }
                List<DocumentSnapshot> documents = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        documents[index].data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () async {
                        await addUserNotification(data);
                       
                      },
                      child: CustomCard(
                        title: data['title'] ?? 'No Title',
                        image: data['image'] ?? 'assets/images/default.png',
                        documentId: documents[index].id,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

 /////////////

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
   

  Future<void> addUserNotification(
      Map<String, dynamic> notificationData) async {
    try {
      CollectionReference users = firestore.collection('users');

      await users.doc('wDocNH9ZERO53kpRPi7j').update({
        'userList': FieldValue.arrayUnion([notificationData]),
      });

      print('Notification added successfully!');
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        await firestore.collection('users').doc('wDocNH9ZERO53kpRPi7j').set({
          'userList': [notificationData],
        });
        print('User document created and notification added successfully!');
      } else {
        print('Error adding notification: $e');
      }
    }
  }
}

class CustomCard extends StatefulWidget {
  const CustomCard({
    super.key,
    required this.image,
    required this.title,
    required this.documentId,
  });
  final String image;
  final String title;
  final String documentId;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  bool isClicked = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  shape: BoxShape.rectangle,
                ),
                child: Image.asset(widget.image),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "about 1 minutes ago",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    isClicked = !isClicked;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isClicked
                        ? Icons.check_box_outline_blank
                        : Icons.check_box_outlined,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                ),
              )
            ],
          ),
        ),
        const Divider(
          color: Colors.white,
          thickness: 1,
        ),
      ],
    );
  }
}
