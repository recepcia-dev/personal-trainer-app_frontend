import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Messages tab - Client communications for trainers
class MessagesTab extends ConsumerStatefulWidget {
  const MessagesTab({super.key});

  @override
  ConsumerState<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<MessagesTab> {
  String _searchQuery = '';
  String _sortBy = 'recent'; // recent, unread, name

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'Broadcast Message',
            onPressed: () => _showBroadcastDialog(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _sortBy == 'recent' ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Recent'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_email_unread,
                      color: _sortBy == 'unread' ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Unread'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: _sortBy == 'name' ? theme.colorScheme.primary : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Client Name'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Conversations list
          Expanded(
            child: _buildConversationsList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageDialog(context),
        child: const Icon(Icons.edit),
        tooltip: 'New Message',
      ),
    );
  }

  Widget _buildConversationsList(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock conversations data
    final conversations = [
      _MockConversation(
        clientId: '1',
        clientName: 'John Smith',
        lastMessage: 'Thanks for the workout plan!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
      ),
      _MockConversation(
        clientId: '2',
        clientName: 'Sarah Johnson',
        lastMessage: 'When is our next session?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
      ),
      _MockConversation(
        clientId: '3',
        clientName: 'Mike Wilson',
        lastMessage: 'I completed today\'s workout!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
        isOnline: true,
      ),
      _MockConversation(
        clientId: '4',
        clientName: 'Emily Brown',
        lastMessage: 'Can we reschedule?',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
      ),
    ];

    // Filter by search
    var filtered = conversations.where((c) =>
        c.clientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Sort
    switch (_sortBy) {
      case 'unread':
        filtered.sort((a, b) => b.unreadCount.compareTo(a.unreadCount));
        break;
      case 'name':
        filtered.sort((a, b) => a.clientName.compareTo(b.clientName));
        break;
      case 'recent':
      default:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No conversations yet' : 'No results found',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with a client',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final conversation = filtered[index];
        return _ConversationTile(
          conversation: conversation,
          onTap: () => _openConversation(context, conversation),
        );
      },
    );
  }

  void _openConversation(BuildContext context, _MockConversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatScreen(
          clientId: conversation.clientId,
          clientName: conversation.clientName,
        ),
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: const Text('Select a client to start a conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to client selection
            },
            child: const Text('Select Client'),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send a message to all your clients:'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Broadcast sent to all clients')),
              );
            },
            child: const Text('Send to All'),
          ),
        ],
      ),
    );
  }
}

class _MockConversation {
  final String clientId;
  final String clientName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  _MockConversation({
    required this.clientId,
    required this.clientName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
  });
}

class _ConversationTile extends StatelessWidget {
  final _MockConversation conversation;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              conversation.clientName[0].toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (conversation.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        conversation.clientName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: hasUnread
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(conversation.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: hasUnread
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

/// Chat screen for individual conversations
class _ChatScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  const _ChatScreen({
    required this.clientId,
    required this.clientName,
  });

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_MockMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Load mock messages
    _messages.addAll([
      _MockMessage(
        id: '1',
        text: 'Hi! How are you doing with the new workout plan?',
        isFromTrainer: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _MockMessage(
        id: '2',
        text: 'It\'s challenging but I\'m enjoying it!',
        isFromTrainer: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 23)),
      ),
      _MockMessage(
        id: '3',
        text: 'Great to hear! Let me know if you need any modifications.',
        isFromTrainer: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 22)),
      ),
      _MockMessage(
        id: '4',
        text: 'Thanks for the workout plan!',
        isFromTrainer: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_MockMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isFromTrainer: true,
        timestamp: DateTime.now(),
        isSynced: false,
      ));
    });

    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate sync after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.last.isSynced = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                widget.clientName[0].toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Online',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'View Profile',
            onPressed: () {
              // TODO: Navigate to client profile
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // TODO: Attach file
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMessage {
  final String id;
  final String text;
  final bool isFromTrainer;
  final DateTime timestamp;
  bool isSynced;

  _MockMessage({
    required this.id,
    required this.text,
    required this.isFromTrainer,
    required this.timestamp,
    this.isSynced = true,
  });
}

class _MessageBubble extends StatelessWidget {
  final _MockMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFromTrainer = message.isFromTrainer;

    return Align(
      alignment: isFromTrainer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isFromTrainer
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isFromTrainer ? const Radius.circular(4) : null,
            bottomLeft: !isFromTrainer ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isFromTrainer
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isFromTrainer
                        ? theme.colorScheme.onPrimary.withOpacity(0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isFromTrainer) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isSynced ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isSynced
                        ? Colors.lightBlueAccent
                        : theme.colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
