# Architectural Decision Records (ADR)

## Overview
This document tracks all significant architectural decisions for the Personal Trainer App using the ADR format.

---

## ADR-001: Clean Architecture + Riverpod

**Date**: 2025-12-09
**Status**: Accepted

### Context
Need to choose an architecture pattern and state management solution for a complex mobile app with offline-first requirements, dual authentication, and payment integration.

### Decision
Adopt Clean Architecture with Riverpod for state management and dependency injection.

**Architecture Layers**:
- Presentation: UI, Widgets, Riverpod State Providers
- Domain: Entities, Repository Interfaces, Use Cases (pure Dart)
- Data: Models, Repository Implementations, Data Sources

**State Management**: Riverpod with code generation (@riverpod annotation)

### Consequences

**Positive**:
- Clear separation of concerns
- Domain layer independent of Flutter/frameworks
- Testable business logic in isolation
- Riverpod provides compile-time safety and better performance than Provider
- Dependency injection handled elegantly with Riverpod providers
- Code generation reduces boilerplate

**Negative**:
- Steeper learning curve for developers unfamiliar with Clean Architecture
- More initial boilerplate (3 layers per feature)
- Code generation adds build step (build_runner required)

**Mitigation**:
- Comprehensive plan.md documentation
- CLAUDE.md with clear guidelines
- Start with simpler features to establish patterns

---

## ADR-002: Offline-First Architecture with Drift

**Date**: 2025-12-09
**Status**: Accepted

### Context
App must work seamlessly offline for trainers and clients who may have unreliable internet connectivity. Need to choose local database and sync strategy.

### Decision
Implement full offline-first architecture using Drift (SQLite) with background sync.

**Pattern**:
1. Read: Try remote → cache locally → fallback to cache on error
2. Write: Save locally first → mark for sync → attempt remote sync
3. Background sync every 5 minutes when online

**Database**: Drift (formerly Moor) for type-safe SQL operations and reactive queries.

### Consequences

**Positive**:
- App works completely offline
- Better user experience (no waiting for network)
- Data persistence survives app crashes
- Drift provides type safety and compile-time SQL validation
- Reactive queries update UI automatically

**Negative**:
- Increased complexity in repository layer
- Must handle sync conflicts (implementing last-write-wins initially)
- Larger local storage requirements
- Background sync consumes battery/data

**Mitigation**:
- Clear repository pattern examples in plan.md
- Exponential backoff for API rate limits
- User controls for sync frequency
- Conflict resolution strategy documented

---

## ADR-003: Dual Authentication System

**Date**: 2025-12-09
**Status**: Accepted

### Context
Two distinct user types with different security requirements:
- Trainers: Power users who manage clients and content
- Clients: Casual users who need frictionless login

### Decision
Implement two-tier authentication:
- **Trainers**: Email + password (traditional) + optional biometric
- **Clients**: Magic link + OTP/PIN + optional biometric

**Token Storage**: flutter_secure_storage for all tokens (never shared_preferences)

### Consequences

**Positive**:
- Trainers have secure, traditional login flow
- Clients get passwordless, frictionless experience
- Biometric auth available for both
- Reduced client support (no password resets)
- Magic links are more secure than SMS OTP

**Negative**:
- Two authentication flows to maintain
- Email delivery dependency for clients
- Magic links expire (15 minutes) - requires re-send mechanism

**Mitigation**:
- Shared authentication infrastructure where possible
- Clear error messages for expired magic links
- Email template testing in development
- Fallback to OTP if magic link fails

---

## ADR-004: Stripe for Payment Processing

**Date**: 2025-12-09
**Status**: Accepted

### Context
Need payment processing for:
- One-time payments (digital goods: workout plans, training sessions)
- Recurring subscriptions (monthly/annual memberships)
- Support for Visa, Mastercard, PayPal

### Decision
Use Stripe as primary payment processor with flutter_stripe SDK.

**Features**:
- Payment Intents API for one-time payments
- Subscriptions API for recurring billing
- PayPal integration through Stripe
- Stripe webhooks for payment confirmations

### Consequences

**Positive**:
- Industry-leading security (PCI compliant)
- Excellent Flutter SDK support
- Built-in fraud detection
- Comprehensive dashboard for reconciliation
- Supports subscriptions natively
- PayPal integration available

**Negative**:
- 2.9% + $0.30 per transaction fee
- Stripe account required for trainers
- Complex webhook verification logic
- Test mode limitations

**Mitigation**:
- Pass fees to clients as part of pricing
- Clear documentation for trainer onboarding
- Webhook signature verification enforced
- Comprehensive test mode coverage

---

## ADR-005: Material Design 3 with Dynamic Color

**Date**: 2025-12-09
**Status**: Accepted

### Context
Need modern, accessible UI that feels native on both iOS and Android. Must support light/dark modes.

### Decision
Adopt Material Design 3 with dynamic color support.

**Features**:
- Material 3 components (Flutter 3.19+)
- Dynamic color from wallpaper (Android 12+)
- Light + Dark theme support
- System-based theme detection
- Manual theme toggle

### Consequences

**Positive**:
- Modern, polished UI out of the box
- Accessibility built-in (contrast ratios, touch targets)
- Dynamic color personalizes experience on Android
- Consistent design system
- Less custom theming required

**Negative**:
- May feel less "iOS-native" to iPhone users
- Dynamic color not available on iOS
- Requires Flutter 3.19+ and Material 3 migration

**Mitigation**:
- Focus on Material 3 design tokens for consistency
- Provide custom seed color for iOS (blue)
- Follow Material 3 guidelines closely
- Test on both platforms regularly

---

## ADR Template

Use this template for future architectural decisions:

### ADR-XXX: [Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded

#### Context
What is the issue we're facing? What factors are influencing this decision?

#### Decision
What are we doing to address this issue? Be specific and concrete.

#### Consequences

**Positive**:
- What benefits does this decision bring?

**Negative**:
- What drawbacks or trade-offs exist?

**Mitigation**:
- How do we address the negative consequences?

---

## Decision Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-001 | Clean Architecture + Riverpod | Accepted | 2025-12-09 |
| ADR-002 | Offline-First with Drift | Accepted | 2025-12-09 |
| ADR-003 | Dual Authentication System | Accepted | 2025-12-09 |
| ADR-004 | Stripe for Payments | Accepted | 2025-12-09 |
| ADR-005 | Material Design 3 | Accepted | 2025-12-09 |
