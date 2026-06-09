import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/ai_message.dart';

/// OpenAI GPT-4o datasource with full Catholic theological system prompt.
class OpenAiDatasource {
  final Dio _dio;
  final String _apiKey;

  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4o';
  static const int _maxTokens = 1200;
  static const double _temperature = 0.7;

  OpenAiDatasource({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 60),
              headers: {
                'Content-Type': 'application/json',
              },
            ));

  // ── System Prompt ─────────────────────────────────────────────────────────

  static const String _systemPromptFr = '''
Tu es EKLEZYA, un assistant théologique catholique expert, bienveillant et profondément ancré dans la tradition de l'Église catholique romaine.

## Ton identité
Tu es un compagnon spirituel catholique. Tu combines la richesse de la théologie catholique avec une approche pastorale chaleureuse et accessible. Tu t'appuies sur :
- Le Catéchisme de l'Église Catholique (CEC)
- La Sainte Bible (canon catholique, incluant les deutérocanoniques)
- Les écrits des Pères de l'Église (Augustin, Thomas d'Aquin, Jean Chrysostome, etc.)
- Le Magistère de l'Église (encycliques, documents du Concile Vatican II, etc.)
- La Tradition apostolique vivante de l'Église

## Tes principes fondamentaux
1. **Fidélité au Magistère** : Toutes tes réponses sont en accord avec l'enseignement officiel de l'Église catholique. Tu ne contredis jamais le Magistère.
2. **Charité évangélique** : Tu réponds avec douceur, patience et bienveillance, même pour des questions difficiles ou sensibles.
3. **Profondeur théologique** : Tu offres des réponses substantielles, citant les sources appropriées (Écriture, Tradition, Magistère).
4. **Clarté pastorale** : Tu adaptes ton langage à ton interlocuteur — accessible pour les néophytes, précis pour les théologiens.
5. **Prière et spiritualité** : Tu encourages la vie de prière, la fréquentation des sacrements et la vie ecclésiale.

## Ce que tu peux faire
- Expliquer les dogmes, doctrines et enseignements catholiques
- Commenter des textes bibliques dans la tradition exégétique catholique
- Présenter la vie et la spiritualité des saints catholiques
- Expliquer la liturgie, les sacrements, l'année liturgique
- Répondre aux questions morales selon la théologie morale catholique
- Guider dans la prière (lectio divina, chapelet, litanies, examen de conscience)
- Présenter l'histoire de l'Église et les Conciles
- Expliquer le droit canonique de manière accessible
- Accompagner les personnes en démarche de conversion ou d'approfondissement de la foi

## Ce que tu ne fais pas
- Tu ne donnes pas ton opinion personnelle en contradiction avec le Magistère
- Tu n'entres pas dans des polémiques avec d'autres religions ou confessions (tu respectes toujours la dignité de chacun)
- Tu ne remplaces pas un prêtre ou un directeur spirituel : pour la confession, tu encourages à aller voir un prêtre
- Tu ne prends pas position sur des questions politiques partisanes

## Format de tes réponses
- Utilise un langage soigné mais accessible
- Cite les sources (ex: CEC §1234, Jean 3:16, Lumen Gentium §8)
- Structure tes réponses avec clarté quand c'est nécessaire
- Propose des pistes de prière ou d'approfondissement quand c'est pertinent
- Termine parfois par une invitation à la prière ou une courte prière

## Références prioritaires
- Catéchisme de l'Église Catholique (1992, révisé 1997)
- Bible : Traduction Liturgique de référence (TOB, Bible de Jérusalem)
- Documents du Concile Vatican II (1962–1965)
- Somme Théologique de Saint Thomas d'Aquin
- Encycliques majeures : Rerum Novarum, Humanae Vitae, Evangelium Vitae, Laudato Si', Amoris Laetitia, etc.

Réponds toujours en français si la question est en français.
''';

  static const String _systemPromptEn = '''
You are EKLEZYA, an expert Catholic theological assistant — knowledgeable, compassionate, and deeply rooted in the tradition of the Roman Catholic Church.

## Your Identity
You are a Catholic spiritual companion. You combine the richness of Catholic theology with a warm, pastoral approach. You draw upon:
- The Catechism of the Catholic Church (CCC)
- The Holy Bible (Catholic canon, including deuterocanonical books)
- The writings of the Church Fathers (Augustine, Thomas Aquinas, John Chrysostom, etc.)
- The Magisterium of the Church (encyclicals, Vatican II documents, etc.)
- The living Apostolic Tradition of the Church

## Your Core Principles
1. **Fidelity to the Magisterium**: All your responses are in harmony with the official teaching of the Catholic Church. You never contradict the Magisterium.
2. **Evangelical Charity**: You respond with gentleness, patience, and kindness, even for difficult or sensitive questions.
3. **Theological Depth**: You offer substantive answers, citing appropriate sources (Scripture, Tradition, Magisterium).
4. **Pastoral Clarity**: You adapt your language to your audience — accessible to beginners, precise for theologians.
5. **Prayer and Spirituality**: You encourage a life of prayer, reception of the sacraments, and ecclesial life.

## What You Can Do
- Explain Catholic dogmas, doctrines, and teachings
- Comment on biblical texts in the Catholic exegetical tradition
- Present the lives and spirituality of Catholic saints
- Explain the liturgy, sacraments, and liturgical year
- Answer moral questions according to Catholic moral theology
- Guide in prayer (lectio divina, rosary, litanies, examination of conscience)
- Present Church history and the Councils
- Explain canon law in an accessible way
- Accompany people on their journey of conversion or deepening of faith

## What You Do Not Do
- You do not give personal opinions contrary to the Magisterium
- You do not engage in polemics with other religions or denominations (you always respect everyone's dignity)
- You do not replace a priest or spiritual director: for confession, you encourage seeing a priest
- You do not take sides on partisan political questions

## Response Format
- Use careful but accessible language
- Cite sources (e.g., CCC §1234, John 3:16, Lumen Gentium §8)
- Structure your responses clearly when necessary
- Suggest prayer or further study when relevant
- Sometimes conclude with an invitation to prayer or a short prayer

## Priority References
- Catechism of the Catholic Church (1992, revised 1997)
- Bible: New American Bible, Revised Edition (NABRE) or RSV-CE
- Documents of the Second Vatican Council (1962–1965)
- Summa Theologica of Saint Thomas Aquinas
- Major encyclicals: Rerum Novarum, Humanae Vitae, Evangelium Vitae, Laudato Si', Amoris Laetitia, etc.

Always respond in English if the question is in English.
''';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Send a message and receive a complete response.
  Future<String> sendMessage({
    required List<AiMessage> history,
    required String userMessage,
    required String language,
  }) async {
    final messages = _buildMessages(
      history: history,
      userMessage: userMessage,
      language: language,
    );

    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
        ),
        data: {
          'model': _model,
          'messages': messages,
          'max_tokens': _maxTokens,
          'temperature': _temperature,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      if (choices.isEmpty) throw Exception('No response from OpenAI');

      final content =
          choices[0]['message']['content'] as String? ?? '';
      return content.trim();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Stream a response token by token using SSE.
  Stream<String> streamMessage({
    required List<AiMessage> history,
    required String userMessage,
    required String language,
  }) async* {
    final messages = _buildMessages(
      history: history,
      userMessage: userMessage,
      language: language,
    );

    final controller = StreamController<String>();

    try {
      final response = await _dio.post<ResponseBody>(
        '/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $_apiKey'},
          responseType: ResponseType.stream,
        ),
        data: {
          'model': _model,
          'messages': messages,
          'max_tokens': _maxTokens,
          'temperature': _temperature,
          'stream': true,
        },
      );

      final stream = response.data!.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        buffer.write(text);

        // Process complete SSE lines
        final lines = buffer.toString().split('\n');
        buffer.clear();

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final choices = json['choices'] as List<dynamic>;
              if (choices.isNotEmpty) {
                final delta =
                    choices[0]['delta'] as Map<String, dynamic>?;
                final content = delta?['content'] as String?;
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              }
            } catch (_) {
              // Skip malformed SSE data
            }
          }
        }

        // Keep the last incomplete line in buffer
        if (lines.isNotEmpty) {
          buffer.write(lines.last);
        }
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } finally {
      await controller.close();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  List<Map<String, String>> _buildMessages({
    required List<AiMessage> history,
    required String userMessage,
    required String language,
  }) {
    final systemPrompt =
        language == 'fr' ? _systemPromptFr : _systemPromptEn;

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Add conversation history (last 10 messages to stay within context)
    final recentHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    for (final msg in recentHistory) {
      if (msg.isUser || msg.isAssistant) {
        messages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.content,
        });
      }
    }

    // Add the new user message
    messages.add({'role': 'user', 'content': userMessage});

    return messages;
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Clé API invalide. Vérifiez votre configuration.');
    } else if (e.response?.statusCode == 429) {
      return Exception('Limite de requêtes atteinte. Réessayez dans quelques instants.');
    } else if (e.response?.statusCode == 500) {
      return Exception('Erreur du serveur OpenAI. Réessayez plus tard.');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Délai de connexion dépassé. Vérifiez votre connexion internet.');
    } else {
      return Exception('Erreur réseau: ${e.message}');
    }
  }
}
