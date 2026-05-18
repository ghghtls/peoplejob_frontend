# Integration Status Notes

## Completed Recon
- Spring Boot backend runs on port 5000 with primary APIs under /api/*.
- Flutter services mostly hardcode http://localhost:9000 or outdated endpoints.
- Auth flows rely on AuthService; JWT stored under jwt, user identifiers retrieved from secure storage.

## High-Priority Gaps
- **Job API**: Frontend hits /api/jobopening without pagination; backend exposes /api/jobs (paged). Need query parameter support and DTO field alignment before UI renders proper data.
- **Scrap API**: Frontend uses /api/scrap/my, /api/scrap/job/{id}, /api/scrap/check/{id}; backend only provides /api/scrap/{userNo} and /api/scrap delete with userNo + jobopeningNo. Requires service refactor plus auth-aware calls (inject userNo).
- **Apply API**: UI expects /api/apply/my, /api/apply/check, /api/apply/check-job, /api/apply/stats; backend provides only basic CRUD (/api/apply, /api/apply/resume/{id}, /api/apply/job/{id}). Need new controller methods or frontend simplification.
- **File Upload**: FileUploadService points at http://localhost:8080/api/files, while backend serves /api/files on port 5000. Must unify base URL and update auth token header name (jwt).
- **Auth metadata**: ApplyDialog parses userInfo['userid'] to derive userNo, but backend expects numeric userNo. Need consistent storage after login response mapping.

## Next Steps
1. Finish refactoring JobService to rely on ApiConfig.apiUrl, add pagination, and map backend JobopeningDTO fields to UI expectations.
2. Redesign scrap flows: acquire userNo via AuthService, call backend endpoints accordingly, and adjust list DTO usage.
3. Define minimal /api/apply/my and /api/apply/check* behavior (either implement backend endpoints or change frontend logic).
4. Normalize file upload base URL/headers once port is confirmed.
5. Audit all service constructors to remove hardcoded ports and ensure they use shared config.

## Reminders
- Keep server port value as configured by the owner (do not change defaults in code).
- Avoid introducing non-ASCII comments to prevent encoding issues.
