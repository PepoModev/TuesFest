
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // Трябва да го имаш в pubspec.yaml
import 'package:intl/intl.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCloD7czzox1dpz0XZBYIzsllFO6M6Kxvk",
      authDomain: "smartbowl-b9c86.firebaseapp.com",
      projectId: "smartbowl-b9c86",
      databaseURL: "https://smartbowl-b9c86-default-rtdb.europe-west1.firebasedatabase.app",
      storageBucket: "smartbowl-b9c86.firebasestorage.app",
      messagingSenderId: "717245853926",
      appId: "1:717245853926:web:344656817cccbe9e2b8b27",
      measurementId: "G-4H1WQBT0XE",
    ),
  );
  runApp(SmartBowlApp());
}

class SmartBowlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Water Bowl',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

// --- УНИВЕРСАЛЕН ФОН ---
class MainBackground extends StatelessWidget {
  final Widget child;
  MainBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298), Color(0xFF2193b0)],
        ),
      ),
      child: child,
    );
  }
}

// --- ЕКРАН: ВХОД ---
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailLogin = TextEditingController();
  final _passLogin = TextEditingController();

  void _handleLogin() async {
    if (_emailLogin.text.trim().isEmpty || _passLogin.text.trim().isEmpty) {
      _msg("Моля, въведете имейл и парола!", Colors.orange);
      return;
    }

    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailLogin.text.trim(),
        password: _passLogin.text.trim(),
      );

      var doc = await FirebaseFirestore.instance.collection("users").doc(user.user!.uid).get();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainDashboard(
          owner: doc["name"],
          petType: doc["pet"],
          petName: doc["petName"],
        )),
      );
    } catch (e) {
      _msg("Грешен имейл или парола!", Colors.red);
    }
  }

  void _msg(String t, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t), backgroundColor: c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 20,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(Icons.water_drop, size: 60, color: Colors.blue),
                    const Text("Smart Water", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    TextField(controller: _emailLogin, decoration: const InputDecoration(labelText: 'Имейл', prefixIcon: Icon(Icons.email))),
                    const SizedBox(height: 15),
                    TextField(controller: _passLogin, obscureText: true, decoration: const InputDecoration(labelText: 'Парола', prefixIcon: Icon(Icons.lock))),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: _handleLogin,
                      child: const Text("ВХОД"),
                    ),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen())), child: const Text("Забравена парола?")),
                    TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen())), child: const Text("Регистрация")),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ЕКРАН: РЕГИСТРАЦИЯ ---
class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailReg = TextEditingController();
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();

  void _nextStep() {
    String email = _emailReg.text.trim();
    if (email.isEmpty || _p1.text.isEmpty || _p2.text.isEmpty) {
      _msg("Всички полета са задължителни!");
    } else if (_p1.text != _p2.text) {
      _msg("Паролите не съвпадат!");
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PetSetupScreen(email: email, password: _p1.text)));
    }
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainBackground(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Регистрация", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(controller: _emailReg, decoration: const InputDecoration(labelText: 'Имейл')),
                  TextField(controller: _p1, obscureText: true, decoration: const InputDecoration(labelText: 'Парола')),
                  TextField(controller: _p2, obscureText: true, decoration: const InputDecoration(labelText: 'Потвърди парола')),
                  const SizedBox(height: 25),
                  ElevatedButton(onPressed: _nextStep, child: const Text("НАПРЕД")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ЕКРАН: ДАННИ ЗА ЛЮБИМЕЦА ---
class PetSetupScreen extends StatefulWidget {
  final String email;
  final String password;
  PetSetupScreen({required this.email, required this.password});

  @override
  _PetSetupScreenState createState() => _PetSetupScreenState();
}

class _PetSetupScreenState extends State<PetSetupScreen> {
  final _ownerName = TextEditingController();
  final _petType = TextEditingController();
  final _petName = TextEditingController();

  void _finish() async {
    if (_ownerName.text.isEmpty || _petName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Попълнете имената!")));
      return;
    }

    try {
      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      await FirebaseFirestore.instance.collection("users").doc(user.user!.uid).set({
        "name": _ownerName.text.trim(),
        "pet": _petType.text.trim(),
        "petName": _petName.text.trim(),
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainDashboard(
          owner: _ownerName.text,
          petType: _petType.text,
          petName: _petName.text,
        )),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Грешка: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainBackground(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(25),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Настройка на профила", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextField(controller: _ownerName, decoration: const InputDecoration(labelText: 'Вашето име')),
                  TextField(controller: _petType, decoration: const InputDecoration(labelText: 'Животно (напр. куче)')),
                  TextField(controller: _petName, decoration: const InputDecoration(labelText: 'Име на любимеца')),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _finish, child: const Text("ЗАВЪРШИ")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ЕКРАН: ЗАБРАВЕНА ПАРОЛА ---
class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainBackground(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(25),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Забравена парола", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Въведете имейл')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Линкът за нулиране е изпратен!")));
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Имейлът не е намерен!")));
                      }
                    },
                    child: const Text("ИЗПРАТИ"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ГЛАВНА СТРАНИЦА (ОБНОВЕНА С УМНА ЛОГИКА) ---
class MainDashboard extends StatefulWidget {
  final String owner;
  final String petType;
  final String petName;
  MainDashboard({required this.owner, required this.petType, required this.petName});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  double waterLevel = 0.0; 
  double lastRecordedLevel = -1.0; 
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool _hasShownLowWaterAlert = false;

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
    _cleanOldHistory();
  }

  void _setupRealtimeUpdates() {
    // Слушаме Firebase Realtime Database за промени в процентите
    FirebaseDatabase.instance.ref("users/$uid/waterLevel").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        double newLevel = double.parse(data.toString());
        
        // Викаме логиката за сравнение преди да обновим UI
        _checkWaterChange(newLevel);

        setState(() {
          waterLevel = newLevel;
        });

        // Проверка за критично ниско ниво
        if (waterLevel <= 10 && !_hasShownLowWaterAlert) {
          _showLowWaterDialog();
          _hasShownLowWaterAlert = true;
        } else if (waterLevel > 10) {
          _hasShownLowWaterAlert = false;
        }
      }
    });
  }

  // УМНА ЛОГИКА ЗА СРАВНЕНИЕ
  void _checkWaterChange(double newLevel) async {
    if (lastRecordedLevel == -1.0) {
      lastRecordedLevel = newLevel;
      return;
    }

    String? eventMessage;
    DateTime now = DateTime.now();
    String timeStr = DateFormat('HH:mm').format(now);
    String dateStr = DateFormat('dd.MM').format(now);

    // Ако нивото е паднало (Кучето е пило) - праг 2% шум
    if (newLevel < (lastRecordedLevel - 2.0)) {
      double diff = lastRecordedLevel - newLevel;
      eventMessage = "${widget.petName} изпи ${diff.toStringAsFixed(1)}% вода в $timeStr на $dateStr";
    } 
    // Ако нивото се е вдигнало (Налята е вода) - праг 5%
    else if (newLevel > (lastRecordedLevel + 5.0)) {
      eventMessage = "Купата беше налята от ${lastRecordedLevel.toStringAsFixed(0)}% до ${newLevel.toStringAsFixed(0)}% в $timeStr";
    }

    if (eventMessage != null) {
      // Записваме в Firestore историята
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("history")
          .add({
        "label": eventMessage,
        "timestamp": FieldValue.serverTimestamp(),
        "amount": (lastRecordedLevel - newLevel).abs().toStringAsFixed(1)
      });
      
      lastRecordedLevel = newLevel;
    }
  }

  void _showLowWaterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 10), Text("Внимание!")]),
        content: Text("Водата на ${widget.petName} е на привършване (${waterLevel.toStringAsFixed(0)}%)!"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("РАЗБРАХ"))],
      ),
    );
  }

  void _cleanOldHistory() async {
    // Изтрива всичко по-старо от 48 часа (както поиска)
    DateTime threshold = DateTime.now().subtract(const Duration(hours: 48));
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("history")
        .where("timestamp", isLessThan: threshold)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Здравей, ${widget.owner}!", style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("${widget.petName} е жаден 🐾", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        // ИНТЕЛИГЕНТЕН КРЪГ
                        CircularPercentIndicator(
                          radius: 100.0,
                          lineWidth: 15.0,
                          animation: true,
                          animateFromLastPercent: true,
                          percent: (waterLevel / 100).clamp(0.0, 1.0),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${waterLevel.toStringAsFixed(0)}%", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: waterLevel <= 10 ? Colors.red : Colors.blue)),
                              Text("Ниво", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: waterLevel <= 10 ? Colors.redAccent : Colors.blueAccent,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ),
                        
                        const SizedBox(height: 40),
                        const Align(alignment: Alignment.centerLeft, child: Text("История на активностите", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        const Divider(),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("history")
                              .orderBy("timestamp", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            if (snapshot.data!.docs.isEmpty) return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text("Все още няма събития."),
                            );

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var doc = snapshot.data!.docs[index];
                                bool isRefill = doc["label"].toString().contains("налята");
                                return Card(
                                  elevation: 0,
                                  color: isRefill ? Colors.green[50] : Colors.blue[50],
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: ListTile(
                                    leading: Icon(isRefill ? Icons.add_circle : Icons.opacity, color: isRefill ? Colors.green : Colors.blue),
                                    title: Text(doc["label"], style: TextStyle(fontSize: 14)),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}