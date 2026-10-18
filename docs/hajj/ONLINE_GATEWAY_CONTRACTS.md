# Online gateway contracts

Typed, mockable interfaces live in `lib/domain/hajj_online_contracts.dart`.  
Hajj Home still talks to `HajjOnlineAssistGateway` so a future live implementation can be injected in `lib/application/providers.dart` without rewriting the dashboard.

## Interfaces

| Contract | Demo / local implementation |
| --- | --- |
| `HajjSourceRegistry` | `BundledHajjSourceRegistry` |
| `HajjOfficialSourceGateway` | `DemoHajjOfficialSourceGateway` |
| `HajjSourceVerificationService` | `LocalHajjSourceVerificationService` |
| `HajjPathwayResolver` | `LocalHajjPathwayResolver` |
| `HajjProviderDirectoryGateway` | `EmptyHajjProviderDirectoryGateway` |
| `HajjAIInterpretationGateway` | `DemoHajjAIInterpretationGateway` |
| `HajjConsentManager` | local, no I/O |
| `HajjProposedPlanChangeReviewer` | accept / reject on the store |

`DemoHajjOnlineAssistGateway` remains the testing and default runtime implementation of `HajjOnlineAssistGateway`. `FailingHajjOnlineAssistGateway` covers unavailability.

## Dependency injection

```dart
hajjOnlineAssistGatewayProvider → DemoHajjOnlineAssistGateway(registry)
hajjOfficialSourceGatewayProvider → DemoHajjOfficialSourceGateway
hajjAiInterpretationGatewayProvider → DemoHajjAIInterpretationGateway
hajjProviderDirectoryGatewayProvider → EmptyHajjProviderDirectoryGateway
hajjPathwayResolverProvider → LocalHajjPathwayResolver
```

A live 3B-2B Worker client would replace only the official-source and AI providers. Offline planning does not use them.

## AI response shape (stored as `HajjPlanProposal`, additive JSON)

- Original source ids
- Extracted requirement (null if none)
- Jurisdiction / season / retrievedAt
- Uncertainty note (mandatory when sources are missing, stale, or conflicting)
- Suggested action = optional reminder milestone title
- `requiresUserApproval: true` always

AI must not set `officialDeadline`, standing, or traveller readiness. **Reject** dismisses the proposal. **Accept** may add a pending reminder only.

## Sample AI demo payload (on-device)

```json
{
  "id": "prop.demo.2026-10-18",
  "title": "Ask your mission about the registration window",
  "origin": "aiInterpretation",
  "extractedRequirement": null,
  "uncertaintyNote": "Official sources are missing, outdated, or unverified. The app will not invent a deadline or eligibility ruling.",
  "requiresUserApproval": true
}
```
