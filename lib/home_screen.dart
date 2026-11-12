import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'request_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = false;

  void _showAddRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RequestDialog(
        onSubmit: (title, description, category) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          await FirebaseFirestore.instance.collection('service_requests').add({
            'title': title,
            'description': description,
            'category': category,
            'userId': user.uid,
            'userEmail': user.email ?? 'Unknown',
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'Pending',
          });
        },
      ),
    );
  }

  void _showEditRequestDialog(
    BuildContext context,
    String docId,
    String currentTitle,
    String currentDescription,
    String currentCategory,
  ) {
    showDialog(
      context: context,
      builder: (context) => RequestDialog(
        docId: docId,
        initialTitle: currentTitle,
        initialDescription: currentDescription,
        initialCategory: currentCategory,
        onSubmit: (title, description, category) async {
          await FirebaseFirestore.instance
              .collection('service_requests')
              .doc(docId)
              .update({
            'title': title,
            'description': description,
            'category': category,
          });
        },
      ),
    );
  }

  void _deleteRequest(String docId) async {
    await FirebaseFirestore.instance
        .collection('service_requests')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barangay Portal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Service Requests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('service_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading requests: ${snapshot.error}'),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];
          final user = FirebaseAuth.instance.currentUser;
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['userId'] == user?.uid;
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.teal.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    'No Service Requests Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the "+" button below to submit a new request.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditRequestDialog(
                                    context,
                                    doc.id,
                                    data['title'] ?? '',
                                    data['description'] ?? '',
                                    data['category'] ?? 'Other',
                                  );
                                } else if (value == 'delete') {
                                  _deleteRequest(doc.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          child: Text(
                            data['category'] ?? 'General',
                            style: TextStyle(fontSize: 10, color: Colors.teal.shade800, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            data['description'] ?? '',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Text(
                                data['status'] ?? 'Pending',
                                style: TextStyle(fontSize: 9, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              data['userEmail']?.split('@').first ?? 'User',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Text(
                                data['status'] ?? 'Pending',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditRequestDialog(
                                    context,
                                    doc.id,
                                    data['title'] ?? '',
                                    data['description'] ?? '',
                                    data['category'] ?? 'Other',
                                  );
                                } else if (value == 'delete') {
                                  _deleteRequest(doc.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.category, size: 14, color: Colors.teal.shade700),
                            const SizedBox(width: 4),
                            Text(
                              data['category'] ?? 'General',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['description'] ?? '',
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Requested by: ${data['userEmail'] ?? 'User'}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              data['createdAt'] != null
                                  ? (data['createdAt'] as Timestamp).toDate().toString().split('.').first
                                  : '',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRequestDialog(context),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }
}
