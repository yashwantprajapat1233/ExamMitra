
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color bg = Color(0xFF071713);
const Color surface = Color(0xFF102720);
const Color lime = Color(0xFFB8FF43);
const Color muted = Color(0xFF9BAFA5);


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ifnkoffsplirnzvpamct.supabase.co',
    publishableKey: 'sb_publishable_GtCri541PH1jvOm-EaPzpw_D31PklHr',
  );

  print('ExamMitra connected to Supabase!');

  runApp(const ExamMitraApp());
}
class ExamMitraApp extends StatelessWidget {
  const ExamMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamMitra',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lime,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: Colors.white,
        ),
      ),
      home: const IntroScreen(),
    );
  }
}

// INTRO SLIDER

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  final List<Map<String, dynamic>> slides = [
    {
      'icon': Icons.groups_rounded,
      'title': 'Your Exam Journey, Together.',
      'description':
          'Meet students who are preparing for the same exam as you.',
    },
    {
      'icon': Icons.location_on_rounded,
      'title': 'Find Your Exam Partners.',
      'description':
          'Discover students with the same exam, date, city and centre.',
    },
    {
      'icon': Icons.chat_bubble_rounded,
      'title': 'Connect. Chat. Prepare.',
      'description':
          'Send connection requests and communicate with your exam partners.',
    },
  ];

void finishIntro() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const AuthScreen(),
    ),
  );
}

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.graphic_eq,
                      color: lime, size: 32),
                  const SizedBox(width: 8),
                  const Text(
                    'ExamMitra',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: finishIntro,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(color: muted),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surface,
                            border: Border.all(
                              color: lime.withOpacity(0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: lime.withOpacity(0.10),
                                blurRadius: 45,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 100,
                            color: lime,
                          ),
                        ),

                        const SizedBox(height: 55),

                        Text(
                          slide['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          slide['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 7,
                    width: currentPage == index ? 28 : 7,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? lime
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: bg,
                  ),
                  onPressed: () {
                    if (currentPage < slides.length - 1) {
                      controller.nextPage(
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      finishIntro();
                    }
                  },
                  child: Text(
                    currentPage == slides.length - 1
                        ? 'GET STARTED'
                        : 'CONTINUE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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

// HOME SCREEN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

late Future<List<Map<String, dynamic>>> examsFuture;

@override
void initState() {
  super.initState();
  examsFuture = fetchMyExams();
}

Future<List<Map<String, dynamic>>> fetchMyExams() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return [];

  final response = await supabase
      .from('exam_registrations')
      .select('id, exam_name, exam_date, city, centre_name')
      .eq('student_id', user.id)
      .order('exam_date');

  return List<Map<String, dynamic>>.from(response);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.graphic_eq, color: lime, size: 30),
            SizedBox(width: 8),
            Text(
              'ExamMitra',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: selectedIndex == 0
          ? buildHome()
          : Center(
              child: Text(
                ['Home', 'Connections', 'Chats', 'Profile']
                    [selectedIndex],
                style: const TextStyle(fontSize: 24),
              ),
            ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: surface,
        indicatorColor: lime.withOpacity(0.18),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: lime),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Connections',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your exam journey,',
            style: TextStyle(fontSize: 27),
          ),
          const Text(
            'together.',
            style: TextStyle(
              fontSize: 34,
              color: lime,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Find students taking the same exam at your centre.',
            style: TextStyle(
              color: muted,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

        // UPCOMING EXAM CARD

          
        FutureBuilder<List<Map<String, dynamic>>>(
          future: examsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: lime),
              );
            }
        
            if (snapshot.hasError) {
              return Text('Error loading exams: ${snapshot.error}');
            }
        
            final exams = snapshot.data ?? [];
        
            return Column(
              children: [
                if (exams.isEmpty)
                  const Text('You have not added any exams yet.')
                else
                  ...exams.map((exam) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: lime.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.event_available,
                              color: lime, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            exam['exam_name'].toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('Date: ${exam['exam_date']}'),
                          Text('City: ${exam['city']}'),
                          Text('Centre: ${exam['centre_name']}'),
                        ],
                      ),
                    );
                  }),
        
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddExamScreen(),
                        ),
                      );
        
                      if (mounted) {
                        setState(() {
                          examsFuture = fetchMyExams();
                        });
                      }
                    },
                    child: const Text('ADD EXAM DETAILS'),
                  ),
                ),
              ],
            );
          },
        ),


          const SizedBox(height: 32),

          const Text(
            'Find your exam partners',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white12,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: lime,
                  size: 52,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Your exam community starts here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add your exam details to find matching students.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: lime,
                      side: const BorderSide(color: lime),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddExamScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('FIND STUDENTS'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ADD EXAM SCREEN

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});

  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _AddExamScreenState extends State<AddExamScreen> {
  bool isSaving = false;
  final formKey = GlobalKey<FormState>();
  final cityController = TextEditingController();
  final centreController = TextEditingController();

  String? selectedExam;
  DateTime? selectedDate;

  final exams = [
    'SSC CGL',
    'SSC CHSL',
    'SSC MTS',
    'IBPS PO',
    'IBPS Clerk',
    'SBI PO',
    'Other',
  ];

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }



Future<void> saveExam() async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  if (selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select exam date'),
      ),
    );
    return;
  }

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in first'),
      ),
    );
    return;
  }

  setState(() {
    isSaving = true;
  });

  try {
    await supabase.from('exam_registrations').insert({
      'student_id': user.id,
      'exam_name': selectedExam!,
      'exam_date':
          selectedDate!.toIso8601String().split('T')[0],
      'city': cityController.text.trim(),
      'centre_name': centreController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exam registration saved successfully!'),
      ),
    );
  } on PostgrestException catch (error) {
    debugPrint('DATABASE ERROR: ${error.message}');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Database error: ${error.message}'),
      ),
    );
  } catch (error) {
    debugPrint('SAVE EXAM ERROR: $error');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }
}


  @override
  void dispose() {
    cityController.dispose();
    centreController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Exam')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your exam details',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              const Text('Exam name'),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedExam,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select your exam',
                ),
                items: exams.map((exam) {
                  return DropdownMenuItem(
                    value: exam,
                    child: Text(exam),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedExam = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select an exam' : null,
              ),

              const SizedBox(height: 22),

              const Text('Exam date'),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: chooseDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  selectedDate == null
                      ? 'Choose exam date'
                      : '${selectedDate!.day}/'
                        '${selectedDate!.month}/'
                        '${selectedDate!.year}',
                ),
              ),

              const SizedBox(height: 22),

              const Text('City'),
              const SizedBox(height: 8),

              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Indore',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter your city'
                        : null,
              ),

              const SizedBox(height: 22),

              const Text('Exam centre'),
              const SizedBox(height: 8),

              TextFormField(
                controller: centreController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter centre name',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter your exam centre'
                        : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: bg,
                  ),
                  onPressed: isSaving ? null : saveExam,

                  child: isSaving
                   ? const CircularProgressIndicator(color: bg)
                   : const Text(
                   'SAVE EXAM DETAILS',
                    style: TextStyle(fontWeight: FontWeight.bold),
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


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool hidePassword = true;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> authenticate() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (isLogin) {
        // LOGIN EXISTING STUDENT

        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        // REGISTER NEW STUDENT

        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: 'exammitra://login-callback',
        );
 
        if (!mounted) return;

        if (response.session != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        } else {
          showMessage(
            'Account created! Please verify your email, '
            'then log in.',
          );
        }
      }
    }  on AuthException catch (error) {
  debugPrint('SUPABASE AUTH ERROR: ${error.message}');
  debugPrint('STATUS CODE: ${error.statusCode}');

  if (!mounted) return;
  showMessage(error.message);
} catch (error, stackTrace) {
  debugPrint('GENERAL ERROR: $error');
  debugPrint('$stackTrace');

  if (!mounted) return;
  showMessage('Something went wrong. Please try again.');
} finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Center(
                    child: Icon(
                      Icons.groups_rounded,
                      color: lime,
                      size: 65,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      isLogin
                          ? 'Welcome Back!'
                          : 'Join ExamMitra',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      isLogin
                          ? 'Login to find your exam partners.'
                          : 'Create an account and meet your exam partners.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted),
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text('Email Address'),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  const Text('Password'),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: lime,
                        foregroundColor: bg,
                      ),
                      onPressed: isLoading
                          ? null
                          : authenticate,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: bg,
                            )
                          : Text(
                              isLogin ? 'LOGIN' : 'SIGN UP',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                              formKey.currentState?.reset();
                              emailController.clear();
                              passwordController.clear();
                            },
                      child: Text(
                        isLogin
                            ? "Don't have an account? Sign Up"
                            : 'Already have an account? Login',
                        style: const TextStyle(color: lime),
                      ),
                    ),
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
