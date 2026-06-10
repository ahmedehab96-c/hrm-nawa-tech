import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/repositories/recruitment_repository.dart';
import 'package:hrm_saas/core/api/api_result.dart';

void main() {
  group('JobItem.fromJson', () {
    test('parses full JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Flutter Developer',
        'department': 'Tech',
        'location': 'Riyadh',
        'description': 'Build apps',
        'status': 'open',
        'candidates_count': 5,
        'created_at': '2025-01-01',
      };
      final job = JobItem.fromJson(json);
      expect(job.id, '1');
      expect(job.title, 'Flutter Developer');
      expect(job.department, 'Tech');
      expect(job.status, 'open');
      expect(job.candidatesCount, 5);
      expect(job.candidates, isEmpty);
    });

    test('handles missing optional fields gracefully', () {
      final job = JobItem.fromJson({'id': 2, 'title': 'Dev', 'status': 'draft', 'candidates_count': 0});
      expect(job.department, isNull);
      expect(job.location, isNull);
      expect(job.description, isNull);
    });

    test('parses nested candidates', () {
      final json = {
        'id': 1,
        'title': 'Dev',
        'status': 'open',
        'candidates_count': 1,
        'candidates': [
          {'id': 10, 'name': 'Ahmed', 'email': 'a@test.com', 'stage': 'new'},
        ],
      };
      final job = JobItem.fromJson(json);
      expect(job.candidates, hasLength(1));
      expect(job.candidates.first.name, 'Ahmed');
      expect(job.candidates.first.stage, 'new');
    });
  });

  group('CandidateItem.fromJson', () {
    test('parses all fields', () {
      final json = {'id': 5, 'name': 'Sara', 'email': 'sara@test.com', 'phone': '0501111111', 'stage': 'interview', 'notes': 'Good candidate'};
      final c = CandidateItem.fromJson(json);
      expect(c.id, '5');
      expect(c.name, 'Sara');
      expect(c.stage, 'interview');
      expect(c.notes, 'Good candidate');
    });

    test('handles null optional fields', () {
      final c = CandidateItem.fromJson({'id': 1, 'name': 'X', 'stage': 'new'});
      expect(c.email, isNull);
      expect(c.phone, isNull);
      expect(c.notes, isNull);
    });
  });

  group('RecruitmentRepository demo data', () {
    test('getJobs returns demo data when API disabled', () async {
      // API is disabled by default in tests (no SharedPreferences)
      final result = await RecruitmentRepository.instance.getJobs();
      expect(result, isA<ApiSuccess<List<JobItem>>>());
      final jobs = (result as ApiSuccess<List<JobItem>>).data;
      expect(jobs, isNotEmpty);
      expect(jobs.first.title, isNotEmpty);
    });

    test('demo jobs have candidates', () async {
      final result = await RecruitmentRepository.instance.getJobs();
      final jobs = (result as ApiSuccess<List<JobItem>>).data;
      final withCandidates = jobs.where((j) => j.candidates.isNotEmpty);
      expect(withCandidates, isNotEmpty);
    });
  });
}
