import 'package:flutter/material.dart';

class SocialLink {
  String type;
  String url;

  SocialLink({required this.type, required this.url});
}

class SocialLinksPage extends StatefulWidget {
  final List<SocialLink> existingLinks;
  final Function(List<SocialLink>) onSave;

  const SocialLinksPage({
    super.key,
    required this.existingLinks,
    required this.onSave,
  });

  @override
  State<SocialLinksPage> createState() => _SocialLinksPageState();
}

class _SocialLinksPageState extends State<SocialLinksPage> {
  late List<SocialLink> _socialLinks;
  final Map<String, TextEditingController> _controllers = {};

  final List<Map<String, dynamic>> _availablePlatforms = [
    {'name': 'Email', 'icon': Icons.email, 'color': Colors.red, 'type': 'email'},
    {'name': 'Instagram', 'icon': Icons.photo_camera, 'color': Colors.purple, 'type': 'instagram'},
    {'name': 'Facebook', 'icon': Icons.facebook, 'color': Colors.blue, 'type': 'facebook'},
    {'name': 'YouTube', 'icon': Icons.play_circle_filled, 'color': Colors.red, 'type': 'youtube'},
    {'name': 'Twitter/X', 'icon': Icons.chat_bubble_outline, 'color': Colors.blue, 'type': 'twitter'},
    {'name': 'WhatsApp', 'icon': Icons.chat, 'color': Colors.green, 'type': 'whatsapp'},
    {'name': 'LinkedIn', 'icon': Icons.work, 'color': Colors.blue, 'type': 'linkedin'},
    {'name': 'Website', 'icon': Icons.language, 'color': Colors.blueGrey, 'type': 'website'},
  ];

  @override
  void initState() {
    super.initState();
    _socialLinks = List.from(widget.existingLinks);
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var link in _socialLinks) {
      _controllers[link.type] = TextEditingController(text: link.url);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSocialLink(String type, String platformName) {
    if (_socialLinks.any((link) => link.type == type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$platformName already added')),
      );
      return;
    }

    setState(() {
      _socialLinks.add(SocialLink(type: type, url: ''));
      _controllers[type] = TextEditingController();
    });
  }

  void _removeSocialLink(int index) {
    final removedType = _socialLinks[index].type;
    setState(() {
      _controllers[removedType]?.dispose();
      _controllers.remove(removedType);
      _socialLinks.removeAt(index);
    });
  }

  void _updateSocialLink(int index, String value) {
    _socialLinks[index].url = value;
  }

  void _save() {
    // Validate URLs
    for (var link in _socialLinks) {
      if (link.url.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all social links or remove empty ones')),
        );
        return;
      }
    }
    widget.onSave(_socialLinks);
    Navigator.pop(context);
  }

  String _getPlaceholder(String type) {
    switch (type) {
      case 'email':
        return 'e.g., store@example.com';
      case 'instagram':
        return 'e.g., https://instagram.com/username';
      case 'facebook':
        return 'e.g., https://facebook.com/username';
      case 'youtube':
        return 'e.g., https://youtube.com/@channel';
      case 'twitter':
        return 'e.g., https://twitter.com/username';
      case 'whatsapp':
        return 'e.g., https://wa.me/1234567890';
      case 'linkedin':
        return 'e.g., https://linkedin.com/in/username';
      case 'website':
        return 'e.g., https://yourstore.com';
      default:
        return 'Enter URL or contact info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social & Contact Links'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Add your social media and contact links. Customers can use these to connect with your store.',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Existing Links
                if (_socialLinks.isNotEmpty) ...[
                  const Text(
                    'Your Links',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_socialLinks.length, (index) {
                    final link = _socialLinks[index];
                    final platform = _availablePlatforms.firstWhere(
                          (p) => p['type'] == link.type,
                      orElse: () => {'name': link.type, 'icon': Icons.link, 'color': Colors.grey},
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(platform['icon'], color: platform['color'], size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    platform['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeSocialLink(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _controllers[link.type],
                              decoration: InputDecoration(
                                hintText: _getPlaceholder(link.type),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) => _updateSocialLink(index, value),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // Add New Link Section
                const Text(
                  'Add New Link',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availablePlatforms.map((platform) {
                    final bool isAdded = _socialLinks.any((l) => l.type == platform['type']);
                    return FilterChip(
                      label: Text(platform['name']),
                      avatar: Icon(platform['icon'], size: 18),
                      selected: isAdded,
                      onSelected: isAdded
                          ? null
                          : (selected) => _addSocialLink(platform['type'], platform['name']),
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.green.shade100,
                      checkmarkColor: Colors.green,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}