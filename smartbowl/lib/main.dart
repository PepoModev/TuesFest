
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
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

// --- ГЛАВНА СТРАНИЦА ---
class MainDashboard extends StatefulWidget {
  final String owner;
  final String petType;
  final String petName;
  MainDashboard({required this.owner, required this.petType, required this.petName});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int waterLevel = 0; 
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool _hasShownLowWaterAlert = false; // Флаг, за да не показваме алерта постоянно

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
    _cleanOldHistory();
  }

  void _setupRealtimeUpdates() {
    FirebaseDatabase.instance.ref("users/$uid/waterLevel").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        int newLevel = int.parse(data.toString());
        setState(() {
          waterLevel = newLevel;
        });

        // Проверка за изскачащо съобщение
        if (waterLevel <= 10 && !_hasShownLowWaterAlert) {
          _showLowWaterDialog();
          _hasShownLowWaterAlert = true;
        } else if (waterLevel > 10) {
          _hasShownLowWaterAlert = false; // Рестартираме флага, ако е долято
        }
      }
    });
  }

  // Функция за изскачащия прозорец
  void _showLowWaterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("Внимание!"),
          ],
        ),
        content: Text("Водата на ${widget.petName} е на привършване ($waterLevel%). Моля, долейте купата!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("РАЗБРАХ", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _cleanOldHistory() async {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Здравей, ${widget.owner}! 🐾", style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("Твоето ${widget.petType} се казва ${widget.petName}",
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        // Визуално предупреждение в самия интерфейс
                        if (waterLevel <= 10)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Критично ниско ниво на водата!",
                                    style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: CircularProgressIndicator(
                                value: waterLevel / 100.0,
                                strokeWidth: 12,
                                backgroundColor: Colors.blue[100],
                                valueColor: AlwaysStoppedAnimation<Color>(waterLevel <= 10 ? Colors.red : Colors.blue)
                              )
                            ),
                            Column(children: [
                              Text("$waterLevel%", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text("Вода в купата", style: TextStyle(color: Colors.grey[600])),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Align(alignment: Alignment.centerLeft, child: Text("История (последни 48ч)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("history")
                              .orderBy("timestamp", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Text("Зареждане...");
                            if (snapshot.data!.docs.isEmpty) return const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text("Няма записи за пиене."),
                            );
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!.docs[index];
                                return ListTile(
                                  leading: const Icon(Icons.history, color: Colors.blue),
                                  title: Text(data["label"] ?? "Пиене на вода"), 
                                  trailing: Text("${data["amount"]} мл"), 
                                );
                              },
                            );
                          },
                        ),
                        
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                          },
                          child: const Text("ИЗХОД", style: TextStyle(color: Colors.white))
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