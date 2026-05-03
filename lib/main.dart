import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthFlowApp());
}

class HealthFlowApp extends StatelessWidget {
  const HealthFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(builder: (context, appState, _) {
        return MaterialApp(
          title: 'HealthFlow',
          theme: ThemeData(
            brightness: appState.isDarkMode ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: appState.isDarkMode ? const Color(0xFF0a0f1a) : Colors.white,
            fontFamily: 'Outfit',
            useMaterial3: true,
          ),
          home: appState.isOnboarded ? const MainApp() : const OnboardingPage(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}

class AppState extends ChangeNotifier {
  bool isOnboarded = false;
  bool isDarkMode = true;
  String name = '';
  String mode = 'personal';
  String lang = 'id';
  double income = 0;
  double balance = 0;
  double jar1 = 0, jar2 = 0, jar3 = 0;
  double guiltFreeUsed = 0;
  String profitMethod = 'balanced';
  
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> savingsGoals = [];
  List<Map<String, dynamic>> flexHistory = [];
  List<Map<String, dynamic>> habits = [];

  late SharedPreferences _prefs;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await load();
    notifyListeners();
  }

  Future<void> save() async {
    await _prefs.setString('hf_v1', jsonEncode({
      'isOnboarded': isOnboarded,
      'isDarkMode': isDarkMode,
      'name': name,
      'mode': mode,
      'lang': lang,
      'income': income,
      'balance': balance,
      'jar1': jar1,
      'jar2': jar2,
      'jar3': jar3,
      'guiltFreeUsed': guiltFreeUsed,
      'profitMethod': profitMethod,
      'transactions': transactions,
      'savingsGoals': savingsGoals,
      'flexHistory': flexHistory,
      'habits': habits,
    }));
  }

  Future<void> load() async {
    try {
      final data = _prefs.getString('hf_v1');
      if (data != null) {
        final json = jsonDecode(data);
        isOnboarded = json['isOnboarded'] ?? false;
        isDarkMode = json['isDarkMode'] ?? true;
        name = json['name'] ?? '';
        mode = json['mode'] ?? 'personal';
        lang = json['lang'] ?? 'id';
        income = (json['income'] ?? 0).toDouble();
        balance = (json['balance'] ?? 0).toDouble();
        jar1 = (json['jar1'] ?? 0).toDouble();
        jar2 = (json['jar2'] ?? 0).toDouble();
        jar3 = (json['jar3'] ?? 0).toDouble();
        guiltFreeUsed = (json['guiltFreeUsed'] ?? 0).toDouble();
        profitMethod = json['profitMethod'] ?? 'balanced';
        transactions = List<Map<String, dynamic>>.from(json['transactions'] ?? []);
        savingsGoals = List<Map<String, dynamic>>.from(json['savingsGoals'] ?? []);
        flexHistory = List<Map<String, dynamic>>.from(json['flexHistory'] ?? []);
        habits = List<Map<String, dynamic>>.from(json['habits'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading: $e');
    }
  }

  void setProfile(String n, String m, String l) {
    name = n;
    mode = m;
    lang = l;
    isOnboarded = true;
    save();
    notifyListeners();
  }

  void setIncome(double amt) {
    income = amt;
    save();
    notifyListeners();
  }

  void recordIncome(double amt) {
    balance += amt;
    if (mode == 'personal') {
      jar1 += amt * 0.17;
      jar2 += amt * 0.10;
      jar3 += amt * 0.10;
    } else {
      final ratios = getProfitRatios();
      jar1 += amt * ratios['ops']!;
      jar2 += amt * ratios['growth']!;
      jar3 += amt * ratios['rights']!;
    }
    transactions.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'income',
      'amount': amt,
      'category': 'Gaji',
      'date': DateTime.now().toIso8601String(),
    });
    save();
    notifyListeners();
  }

  void recordExpense(double amt, String cat) {
    balance -= amt;
    transactions.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'expense',
      'amount': amt,
      'category': cat,
      'date': DateTime.now().toIso8601String(),
    });
    save();
    notifyListeners();
  }

  Map<String, double> getProfitRatios() {
    switch (profitMethod) {
      case 'cashflow':
        return {'ops': 0.60, 'growth': 0.20, 'rights': 0.20};
      case 'berkah':
        return {'ops': 0.30, 'growth': 0.25, 'rights': 0.45};
      default:
        return {'ops': 0.40, 'growth': 0.35, 'rights': 0.25};
    }
  }

  void setProfitMethod(String m) {
    profitMethod = m;
    save();
    notifyListeners();
  }

  void addFlexHistory(String item, String verdict, int riskScore) {
    flexHistory.insert(0, {
      'item': item,
      'verdict': verdict,
      'riskScore': riskScore,
      'time': DateTime.now().toIso8601String(),
    });
    if (flexHistory.length > 20) flexHistory.removeLast();
    save();
    notifyListeners();
  }

  void addHabit(String name) {
    habits.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'completed': false,
      'streak': 0,
      'date': DateTime.now().toIso8601String(),
    });
    save();
    notifyListeners();
  }

  void toggleHabit(int idx) {
    if (idx < habits.length) {
      habits[idx]['completed'] = !(habits[idx]['completed'] ?? false);
      save();
      notifyListeners();
    }
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    save();
    notifyListeners();
  }

  void toggleLang() {
    lang = lang == 'id' ? 'en' : 'id';
    save();
    notifyListeners();
  }

  void reset() {
    isOnboarded = false;
    name = '';
    income = 0;
    balance = 0;
    jar1 = jar2 = jar3 = 0;
    transactions.clear();
    savingsGoals.clear();
    flexHistory.clear();
    habits.clear();
    _prefs.remove('hf_v1');
    notifyListeners();
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;
  String name = '';
  String mode = 'personal';
  double income = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildStep(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (step) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('HealthFlow', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF22d3a0))),
            const SizedBox(height: 48),
            const Text('Siapa nama kamu?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Masukkan nama',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    name = _controller.text;
                    _controller.clear();
                    step = 1;
                  });
                }
              },
              child: const Text('Lanjut →'),
            ),
          ],
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pilih Mode', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            _modeButton('👤 Personal', 'personal'),
            const SizedBox(height: 16),
            _modeButton('🏢 Bisnis', 'bisnis'),
          ],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Berapa gaji/income bulanan?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '15000000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  income = double.tryParse(_controller.text) ?? 0;
                  if (income > 0) {
                    context.read<AppState>().setProfile(name, mode, 'id');
                    context.read<AppState>().setIncome(income);
                  }
                }
              },
              child: const Text('Mulai →'),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _modeButton(String label, String value) {
    final isSelected = mode == value;
    return ElevatedButton(
      onPressed: () => setState(() {
        mode = value;
        step = 2;
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF22d3a0) : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(double.infinity, 60),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('HealthFlow', style: TextStyle(color: Color(0xFF22d3a0), fontWeight: FontWeight.bold)),
          actions: [
            IconButton(icon: Text(state.isDarkMode ? '☀️' : '🌙'), onPressed: () => state.toggleTheme()),
            IconButton(icon: Text(state.lang == 'id' ? '🇮🇩' : '🇬🇧'), onPressed: () => state.toggleLang()),
          ],
        ),
        body: _buildPage(context, state),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: page,
          onTap: (i) => setState(() => page = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Record'),
            BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Tools'),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
          ],
        ),
      );
    });
  }

  Widget _buildPage(BuildContext context, AppState state) {
    switch (page) {
      case 0:
        return DashboardPage(state: state);
      case 1:
        return RecordPage(state: state);
      case 2:
        return ToolsPage(state: state);
      default:
        return MorePage(state: state);
    }
  }
}

class DashboardPage extends StatelessWidget {
  final AppState state;
  const DashboardPage({required this.state});

  String fmt(double n) => NumberFormat('#,##0', 'id_ID').format(n.toInt());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Balance', style: TextStyle(color: Color(0xFF8fa3bc), fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('Rp ${fmt(state.balance)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF22d3a0))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _jarCard('Saving', state.jar1),
                      _jarCard('Growth', state.jar2),
                      _jarCard('Zakat', state.jar3),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (state.mode == 'bisnis') ...[
            const Text('Metode Pembagian Profit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: ['balanced', 'cashflow', 'berkah'].map((m) {
                final isSelected = state.profitMethod == m;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () => state.setProfitMethod(m),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF22d3a0) : Colors.grey,
                      ),
                      child: Text(m, style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Recent Transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...state.transactions.take(5).map((tx) => ListTile(
            title: Text(tx['category'] ?? 'Unknown'),
            trailing: Text(
              '${tx['type'] == 'income' ? '+' : '-'}Rp ${fmt(tx['amount'])}',
              style: TextStyle(
                color: tx['type'] == 'income' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _jarCard(String label, double amount) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label == 'Saving' ? '🟢' : label == 'Growth' ? '🟡' : '🔵', style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8fa3bc))),
        const SizedBox(height: 4),
        Text('Rp ${fmt(amount)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class RecordPage extends StatefulWidget {
  final AppState state;
  const RecordPage({required this.state});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  String type = 'income';
  String category = 'Gaji';
  double amount = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => type = 'income'),
                          style: ElevatedButton.styleFrom(backgroundColor: type == 'income' ? const Color(0xFF22d3a0) : Colors.grey),
                          child: const Text('Income', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => type = 'expense'),
                          style: ElevatedButton.styleFrom(backgroundColor: type == 'expense' ? const Color(0xFF22d3a0) : Colors.grey),
                          child: const Text('Expense', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Jumlah',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: category,
                    onChanged: (v) => setState(() => category = v ?? 'Gaji'),
                    items: ['Gaji', 'Bonus', 'Makan', 'Transport', 'Lainnya']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      amount = double.tryParse(_controller.text) ?? 0;
                      if (amount > 0) {
                        if (type == 'income') {
                          widget.state.recordIncome(amount);
                        } else {
                          widget.state.recordExpense(amount, category);
                        }
                        _controller.clear();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Tercatat!')));
                      }
                    },
                    child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ToolsPage extends StatefulWidget {
  final AppState state;
  const ToolsPage({required this.state});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Flexing'), Tab(text: 'Savings'), Tab(text: 'Zakat')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FlexingPage(state: widget.state),
              SavingsPage(state: widget.state),
              ZakatPage(state: widget.state),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class FlexingPage extends StatefulWidget {
  final AppState state;
  const FlexingPage({required this.state});

  @override
  State<FlexingPage> createState() => _FlexingPageState();
}

class _FlexingPageState extends State<FlexingPage> {
  final TextEditingController _controller = TextEditingController();
  String verdict = '';
  String reasoning = '';
  int riskScore = 0;

  Map<String, dynamic> analyzeFlexing(String item) {
    final low = item.toLowerCase();
    final needs = ['makan', 'obat', 'listrik', 'air', 'kos', 'sewa', 'bensin', 'sekolah', 'tagihan'];
    final invest = ['laptop', 'kursus', 'buku', 'alat kerja', 'komputer'];
    final flex = ['gucci', 'hermes', 'rolex', 'limited', 'gengsi', 'pamer', 'branded'];
    
    int score = 0;
    String reason = '';
    
    if (flex.any((k) => low.contains(k))) {
      score += 8;
      reason = 'Mengandung indikator status/brand mewah';
      return {'verdict': 'FLEXING', 'emoji': '🚨', 'score': 9, 'reason': reason};
    }
    if (invest.any((k) => low.contains(k))) {
      score -= 2;
      reason = 'Ada nilai produktif/investasi';
      return {'verdict': 'NEED', 'emoji': '✅', 'score': 2, 'reason': reason};
    }
    if (needs.any((k) => low.contains(k))) {
      score = 0;
      reason = 'Kebutuhan pokok sehari-hari';
      return {'verdict': 'NEED', 'emoji': '✅', 'score': 1, 'reason': reason};
    }
    
    reason = 'Kategori keinginan/hiburan';
    return {'verdict': 'WANT', 'emoji': '⚡', 'score': 5, 'reason': reason};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Flexing Detector', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Cek apakah pembelian kamu NEED, WANT atau FLEXING', style: TextStyle(fontSize: 12, color: Color(0xFF8fa3bc))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Mau beli apa? (misal: Beli baju 10jt)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        final result = analyzeFlexing(_controller.text);
                        setState(() {
                          verdict = result['verdict'];
                          reasoning = result['reason'];
                          riskScore = result['score'];
                        });
                        widget.state.addFlexHistory(_controller.text, verdict, riskScore);
                      }
                    },
                    child: const Text('Analisa'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (verdict.isNotEmpty)
            Card(
              color: verdict == 'FLEXING' ? Colors.red.shade900 : verdict == 'WANT' ? Colors.orange.shade900 : Colors.green.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$verdict · Risk $riskScore/10', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(reasoning, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text('History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...widget.state.flexHistory.take(10).map((h) => ListTile(
            title: Text(h['item'], maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(h['verdict']),
            trailing: Text('${h['riskScore']}/10'),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SavingsPage extends StatefulWidget {
  final AppState state;
  const SavingsPage({required this.state});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  double targetAmount = 100000000;
  double monthlyAmount = 8333333;

  String fmt(double n) => NumberFormat('#,##0', 'id_ID').format(n.toInt());

  @override
  Widget build(BuildContext context) {
    final monthsNeeded = widget.state.income > 0 ? targetAmount / (widget.state.income * 0.17) : 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reverse Goal Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target', style: TextStyle(fontSize: 11, color: Color(0xFF8fa3bc))),
                            Text('Rp ${fmt(targetAmount)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Per Bulan', style: TextStyle(fontSize: 11, color: Color(0xFF8fa3bc))),
                            Text('Rp ${fmt(monthlyAmount)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF22d3a0))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (widget.state.balance / targetAmount).clamp(0, 1),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text('${((widget.state.balance / targetAmount).clamp(0, 1) * 100).toStringAsFixed(0)}% dari target', style: const TextStyle(fontSize: 12, color: Color(0xFF8fa3bc))),
                  const SizedBox(height: 16),
                  Text('Estimasi: ${monthsNeeded.toStringAsFixed(0)} bulan', style: const TextStyle(fontSize: 14, color: Color(0xFF22d3a0), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZakatPage extends StatelessWidget {
  final AppState state;
  const ZakatPage({required this.state});

  String fmt(double n) => NumberFormat('#,##0', 'id_ID').format(n.toInt());

  @override
  Widget build(BuildContext context) {
    const double nisab = 87125000; // 85g emas × 1.025jt
    final zakatAmount = state.jar3 * 0.025; // 2.5% zakat
    final gapToNisab = (nisab - state.jar3).clamp(0, nisab);
    final reachedNisab = state.jar3 >= nisab;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: reachedNisab ? Colors.green.shade900 : Colors.orange.shade900,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reachedNisab ? '✅ Sudah Wajib Zakat!' : '⏳ Belum Wajib Zakat',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text('Dana Zakat: Rp ${fmt(state.jar3)}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  if (!reachedNisab) Text('Butuh: Rp ${fmt(gapToNisab.toDouble())} lagi', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  if (reachedNisab) Text('Zakat 2.5%: Rp ${fmt(zakatAmount)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Info Nisab', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Nisab = 85 gram emas (setara Rp 87.125.000)', style: TextStyle(fontSize: 12, color: Color(0xFF8fa3bc))),
                  const SizedBox(height: 8),
                  const Text('Jika harta ≥ nisab dan disimpan 1 tahun, wajib zakat 2.5%', style: TextStyle(fontSize: 12, color: Color(0xFF8fa3bc))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final AppState state;
  const MorePage({required this.state});

  String fmt(double n) => NumberFormat('#,##0', 'id_ID').format(n.toInt());

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('Profile'),
          subtitle: Text('${state.name} · ${state.mode}'),
          trailing: const Icon(Icons.edit),
        ),
        ListTile(
          title: const Text('Income'),
          subtitle: Text('Rp ${fmt(state.income)}/bulan'),
        ),
        ListTile(
          title: const Text('Total Balance'),
          subtitle: Text('Rp ${fmt(state.balance)}'),
        ),
        const Divider(),
        ListTile(
          title: const Text('Habits'),
          subtitle: Text('${state.habits.length} habits tracked'),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Habits'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...state.habits.asMap().entries.map((e) => CheckboxListTile(
                    value: e.value['completed'] ?? false,
                    onChanged: (_) => state.toggleHabit(e.key),
                    title: Text(e.value['name']),
                  )),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text('Reset Profile'),
          subtitle: const Text('Delete all data and start over'),
          trailing: const Icon(Icons.delete, color: Colors.red),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Reset?'),
              content: const Text('Semua data akan dihapus. Lanjutkan?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    state.reset();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('Ya, Reset'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
