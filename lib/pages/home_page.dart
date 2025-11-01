import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/task_tile.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.authService, required this.user});

  final AuthService authService;
  final User user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService(FirebaseFirestore.instance);
  }

  Future<void> _toggleTask(Task task, bool? value) async {
    if (value == null) return;
    try {
      await _firestoreService.toggleDone(task.id, value);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui tugas: $error')),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Tugas?'),
          content: Text('Hapus "${task.title}" dari daftar strategi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('HAPUS'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await _firestoreService.deleteTask(task.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus tugas: $error')));
    }
  }

  Future<void> _openAddTask() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
          firestoreService: _firestoreService,
          ownerId: widget.user.uid,
        ),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas baru siap dijalankan!')),
      );
    }
  }

  Future<void> _signOut() async {
    await widget.authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pit Wall ${widget.user.displayName?.split(' ').first ?? 'Crew'}',
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DashboardHeader(user: widget.user),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _firestoreService.watchTasks(widget.user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final errorDetails =
                      'Terjadi kesalahan memuat tugas:\n${snapshot.error}';
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.amberAccent,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            errorDetails,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await Clipboard.setData(
                                ClipboardData(text: errorDetails),
                              );
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Pesan error disalin'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_all_outlined),
                            label: const Text('Salin Pesan'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tasks = snapshot.data ?? <Task>[];
                if (tasks.isEmpty) {
                  return _EmptyState(onCreateTask: _openAddTask);
                }

                final completed = tasks.where((task) => task.isDone).length;
                final pending = tasks.length - completed;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatusChip(
                            label: 'Selesai',
                            value: completed,
                            color: Colors.greenAccent,
                          ),
                          _StatusChip(
                            label: 'Pending',
                            value: pending,
                            color: Colors.amberAccent,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                        ),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskTile(
                            task: task,
                            onToggle: (value) => _toggleTask(task, value),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        icon: const Icon(Icons.add),
        label: const Text('TUGAS BARU'),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.black87),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C1F26), Color(0xFF111318)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${user.displayName ?? user.email?.split('@').first ?? 'Crew Chief'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Atur strategi balapanmu dan capai podium.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 28,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFC0C0C0)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'FAST LANE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(
                  color: Colors.redAccent.withValues(alpha: 0.5),
                  thickness: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTask});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_outlined, size: 80, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'Belum ada rencana balap.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tambah tugas untuk memulai strategi kemenanganmu.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateTask,
              icon: const Icon(Icons.add),
              label: const Text('BUAT TUGAS BALAP'),
            ),
          ],
        ),
      ),
    );
  }
}
