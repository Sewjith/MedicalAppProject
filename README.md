# Medical App

A cross-platform **telemedicine application** built with Flutter, connecting **patients** and **doctors** in a single app. It covers the full care journey — finding a doctor, booking and paying for appointments, video consultations, digital prescriptions, health records, and medication reminders.

> Built as a full-featured learning/portfolio project. Runs on Android, iOS, Web, Windows, macOS, and Linux from a single codebase.

---

## Overview

The app has two distinct experiences behind a role-based login:

- **Patients** can search for doctors, book and manage appointments, join video consultations, pay in-app, view their prescriptions and health records, set medication reminders, track symptoms, and read health articles.
- **Doctors** get their own dashboard to manage availability, appointments, consultation history, patients, prescriptions, and analytics.

## Features

### For Patients
- 🔍 **Doctor search** — find and browse doctors
- 📅 **Appointment scheduling & history** — book, reschedule, and review past visits
- 🎥 **Teleconsultation** — live video calls with doctors (Agora)
- 💳 **In-app payments** — pay for consultations (Stripe)
- 💊 **Medication reminders** — never miss a dose
- 📈 **Symptom history tracker** — log and monitor symptoms over time
- 🗂️ **Digital health records** — store and access medical documents
- 🏥 **Hospitals & pharmacies** directory
- 📰 **Health articles** and an in-app **chatbot** for guidance
- 🆘 **Emergency assistance**
- 👤 **Profile & settings**, help center, notifications

### For Doctors
- 🩺 **Doctor dashboard** with an overview of daily activity
- ⏰ **Availability management** — set consultation hours
- 📋 **Appointment schedule** & **consultation history**
- 👥 **Patient management**
- 📝 **Prescription tool** — create and export prescriptions (PDF)
- 📊 **Analytics** — practice insights and charts
- 👤 **Doctor profile**

### Shared
- 💬 **In-app chat** between patients and doctors
- 🔔 **Notifications**
- 🔐 **Role-based authentication** (patient / doctor)

## Tech Stack

| Area | Technology |
|------|-----------|
| Framework | Flutter (Dart) |
| Backend & Auth | Supabase |
| Payments | Stripe (`flutter_stripe`) |
| Video calls | Agora RTC Engine |
| State management | flutter_bloc (BLoC / Cubit) |
| Routing | go_router |
| Dependency injection | get_it |
| Local storage | sqflite |
| Charts | fl_chart |
| PDF / printing | pdf, printing |

The codebase follows a **feature-first structure** with a clean-architecture split (`data` / `domain` / `presentation`) under `lib/features`, and shared code under `lib/core`.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.5.4`)
- A Supabase project, plus Stripe and Agora credentials

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/Sewjith/MedicalAppProject.git
cd MedicalAppProject

# 2. Install dependencies
flutter pub get

# 3. Configure your credentials (see "Configuration" below)

# 4. Run the app
flutter run
```

### Configuration

The app reads its credentials from two places:

**Supabase** — set your project URL and anon key in
`lib/core/secrets/supabase_secrets.dart`:

```dart
class SupabaseSecrets {
  static const supabaseUrl = "https://<your-project>.supabase.co";
  static const supabaseAnonKey = "<your-anon-key>";
}
```

**Stripe** — create a `.env` file in the project root:

```env
STRIPE_PUBLISH_KEY="pk_test_..."
STRIPE_SECRET_KEY="sk_test_..."
```

> Agora credentials for video calls are configured similarly — check the
> teleconsultation feature for the expected keys.

## Project Structure

```
lib/
├── core/            # Shared: routing, themes, DI, widgets, config
└── features/
    ├── auth/            # Login & role-based authentication
    ├── Patient/         # Patient dashboard, search, appointments, profile...
    ├── Doctor/          # Doctor dashboard, availability, prescriptions, analytics...
    └── main_features/   # Chat, teleconsultation, payments, health records,
                         # reminders, notifications, chatbot, and more
```

## Status

This is an earlier project and is shared as a portfolio / reference example.

## License

No license specified. All rights reserved by the author.
