import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class CandidateItem {
  CandidateItem({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.stage,
    this.notes,
    this.cvSummary,
    this.skills = const [],
    this.yearsExperience,
    this.aiFitScore,
    this.aiMatchReason,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String stage;
  final String? notes;
  final String? cvSummary;
  final List<String> skills;
  final double? yearsExperience;
  final int? aiFitScore;
  final String? aiMatchReason;

  factory CandidateItem.fromJson(Map<String, dynamic> json) => CandidateItem(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        stage: json['stage']?.toString() ?? 'new',
        notes: json['notes']?.toString(),
        cvSummary: json['cv_summary']?.toString(),
        skills: (json['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList() ??
            const [],
        yearsExperience: (json['years_experience'] as num?)?.toDouble(),
        aiFitScore: (json['ai_fit_score'] as num?)?.toInt(),
        aiMatchReason: json['ai_match_reason']?.toString(),
      );
}

class JobItem {
  JobItem({
    required this.id,
    required this.title,
    this.department,
    this.location,
    this.description,
    required this.status,
    required this.candidatesCount,
    this.candidates = const [],
    this.createdAt,
  });

  final String id;
  final String title;
  final String? department;
  final String? location;
  final String? description;
  final String status;
  final int candidatesCount;
  final List<CandidateItem> candidates;
  final String? createdAt;

  factory JobItem.fromJson(Map<String, dynamic> json) => JobItem(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        department: json['department']?.toString(),
        location: json['location']?.toString(),
        description: json['description']?.toString(),
        status: json['status']?.toString() ?? 'open',
        candidatesCount: (json['candidates_count'] as num?)?.toInt() ?? 0,
        candidates: (json['candidates'] as List<dynamic>?)
                ?.map((c) => CandidateItem.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['created_at']?.toString(),
      );
}

// ─── Demo data ────────────────────────────────────────────────────────────────

List<JobItem> _demoJobs() => [
      JobItem(
        id: '1',
        title: 'Flutter Developer',
        department: 'Technology',
        location: 'Riyadh',
        description: 'We are looking for a passionate Flutter developer.',
        status: 'open',
        candidatesCount: 3,
        candidates: [
          CandidateItem(id: '1', name: 'Ahmed Ali', email: 'ahmed@demo.com', stage: 'interview'),
          CandidateItem(id: '2', name: 'Sara Hassan', email: 'sara@demo.com', stage: 'new', aiFitScore: 83),
          CandidateItem(id: '3', name: 'Omar Khaled', email: 'omar@demo.com', stage: 'offer', aiFitScore: 74),
        ],
      ),
      JobItem(
        id: '2',
        title: 'Accountant',
        department: 'Finance',
        location: 'Jeddah',
        description: 'Experienced accountant needed for finance team.',
        status: 'open',
        candidatesCount: 2,
        candidates: [
          CandidateItem(id: '4', name: 'Layla Saeed', email: 'layla@demo.com', stage: 'new'),
          CandidateItem(id: '5', name: 'Khalid Nasser', email: 'khalid@demo.com', stage: 'hired'),
        ],
      ),
    ];

// ─── Repository ───────────────────────────────────────────────────────────────

class RecruitmentRepository {
  RecruitmentRepository._();
  static final instance = RecruitmentRepository._();

  Future<ApiResult<List<JobItem>>> getJobs() async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(_demoJobs());
    }
    final result = await ApiClient.get('jobs');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final list = jsonDecode(data.body) as List<dynamic>;
            return ApiSuccess(
              list.map((e) => JobItem.fromJson(e as Map<String, dynamic>)).toList(),
            );
          } catch (e) {
            return ApiFailure<List<JobItem>>('Could not parse jobs: $e');
          }
        }(),
    };
  }

  Future<ApiResult<JobItem>> getJob(String id) async {
    if (!ApiConfig.useApi) {
      final job = _demoJobs().where((j) => j.id == id).firstOrNull;
      if (job == null) return const ApiFailure('Job not found');
      return ApiSuccess(job);
    }
    final result = await ApiClient.get('jobs/$id');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            final raw = map['data'] as Map<String, dynamic>? ?? map;
            return ApiSuccess(JobItem.fromJson(raw));
          } catch (e) {
            return ApiFailure<JobItem>('Could not parse job: $e');
          }
        }(),
    };
  }

  Future<ApiResult<String>> createJob({
    required String title,
    String? department,
    String? location,
    String? description,
    String status = 'open',
  }) async {
    if (!ApiConfig.useApi) return const ApiSuccess('demo-id');
    final result = await ApiClient.post('jobs', body: {
      'title': title,
      'status': status,
      'department': ?department,
      'location': ?location,
      'description': ?description,
    });
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            return ApiSuccess(map['id']?.toString() ?? '');
          } catch (e) {
            return const ApiSuccess('');
          }
        }(),
    };
  }

  Future<ApiResult<void>> updateJob(
    String id, {
    String? title,
    String? department,
    String? location,
    String? description,
    String? status,
  }) async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final result = await ApiClient.put('jobs/$id', body: {
      'title': ?title,
      'department': ?department,
      'location': ?location,
      'description': ?description,
      'status': ?status,
    });
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  Future<ApiResult<void>> deleteJob(String id) async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final result = await ApiClient.delete('jobs/$id');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  Future<ApiResult<String>> addCandidate(
    String jobId, {
    required String name,
    String? email,
    String? phone,
    String? notes,
    String? resumeText,
  }) async {
    if (!ApiConfig.useApi) return const ApiSuccess('demo-candidate-id');
    final result = await ApiClient.post('jobs/$jobId/candidates', body: {
      'name': name,
      'email': ?email,
      'phone': ?phone,
      'notes': ?notes,
      'resume_text': ?resumeText,
    });
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            return ApiSuccess(map['id']?.toString() ?? '');
          } catch (_) {
            return const ApiSuccess('');
          }
        }(),
    };
  }

  Future<ApiResult<void>> updateCandidateStage(
    String jobId,
    String candidateId,
    String stage,
  ) async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final result = await ApiClient.put(
      'jobs/$jobId/candidates/$candidateId',
      body: {'stage': stage},
    );
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  Future<ApiResult<void>> deleteCandidate(String jobId, String candidateId) async {
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final result = await ApiClient.delete('jobs/$jobId/candidates/$candidateId');
    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  Future<ApiResult<CandidateItem>> parseCandidateCv(
    String jobId,
    String candidateId, {
    required String cvText,
    required String languageCode,
  }) async {
    if (!ApiConfig.useApi) {
      return ApiSuccess(CandidateItem(
        id: candidateId,
        name: 'Demo Candidate',
        stage: 'new',
        cvSummary: 'Demo parsed CV summary',
        skills: const ['Flutter', 'Dart'],
        yearsExperience: 3,
      ));
    }

    final result = await ApiClient.post(
      'jobs/$jobId/candidates/$candidateId/parse-cv',
      body: {
        'cv_text': cvText,
        'language_code': languageCode,
      },
    );

    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            final raw = map['data'] as Map<String, dynamic>? ?? map;
            return ApiSuccess(CandidateItem.fromJson(raw));
          } catch (e) {
            return ApiFailure<CandidateItem>('Could not parse CV response: $e');
          }
        }(),
    };
  }

  Future<ApiResult<List<CandidateItem>>> matchCandidates(
    String jobId, {
    required String languageCode,
  }) async {
    if (!ApiConfig.useApi) {
      final job = _demoJobs().where((j) => j.id == jobId).firstOrNull;
      return ApiSuccess(job?.candidates ?? const []);
    }

    final result = await ApiClient.post(
      'jobs/$jobId/match-candidates',
      body: {'language_code': languageCode},
    );

    return switch (result) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            final list = (map['data'] as List<dynamic>? ?? const []);
            return ApiSuccess(
              list.map((e) => CandidateItem.fromJson(e as Map<String, dynamic>)).toList(),
            );
          } catch (e) {
            return ApiFailure<List<CandidateItem>>('Could not parse match response: $e');
          }
        }(),
    };
  }
}
