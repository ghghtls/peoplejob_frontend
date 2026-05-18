# Repository Guidelines

## Project Structure & Module Organization
- `lib/`: Flutter front-end source (features under `ui/`, state in `viewmodel/`, shared services in `services/`).
- `test/`: Flutter widget/unit tests mirroring `lib/` structure.
- `peoplejob-backend/`: Spring Boot backend (controllers in `src/main/java/com/people/job/**`, configs in `src/main/resources/`); Maven wrapper included.
- `assets/` and `web/`: static resources for the Flutter app.
- Environment secrets stay in `.env` (never commit); build artifacts live in `build/` and `peoplejob-backend/target/`.

## Build, Test, and Development Commands
```bash
flutter pub get          # resolve Dart dependencies
flutter analyze          # static analysis per analysis_options.yaml
flutter test             # execute unit/widget tests
flutter run -d chrome    # launch web preview (adjust device as needed)

cd peoplejob-backend
./mvnw spring-boot:run   # run API locally (uses application-dev.properties)
./mvnw test              # backend unit/integration tests
./mvnw clean package     # produce executable JAR in target/
```

## Coding Style & Naming Conventions
- Dart: 2-space indentation, `lowerCamelCase` for members, `UpperCamelCase` for types; keep `dart format .` clean.
- Java: follow Spring conventions with 4-space indentation, `lowerCamelCase` fields and methods, `UpperCamelCase` classes; apply Spotless via `./mvnw spotless:apply` if configured.
- Align DTO/model names across tiers (`JobopeningDTO`, `Job`); shared helpers belong in `lib/core/` or `lib/services/config/`.

## Testing Guidelines
- Flutter tests sit in `test/feature_name/...` with descriptive `group()`/`test()` names.
- Backend specs mirror packages under `src/test/java`; use `@SpringBootTest` for integration flows.
- Provide representative payloads and cover new logic paths before shipping.
- Run both `flutter test` and `./mvnw test` prior to opening a PR.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat:`, `fix:`, `refactor:`) in present tense, e.g., `feat: add resume detail view`.
- PRs should summarize changes, link issues ("Closes #123"), include test evidence, and add UI screenshots/GIFs when relevant.
- Ensure analyzers/tests pass and rebase onto the latest `main` to keep history linear.
- Mention configuration needs (e.g., `.env` keys) so reviewers can reproduce environments quickly.

## Security & Configuration Tips
- Never commit real secrets; share sanitized `.env.example` values instead.
- Use sandbox credentials for email/payment integrations and document manual steps in PR descriptions.
