# Saathi \u2014 Your Mental Wellness Companion

> **Privacy-First, AI-Powered, 100% Offline Mental Health Support**

Saathi is an AI-powered mental wellness companion app built with **Flutter** and **Google's Gemma 2B** on-device language model. It runs **100% offline** \u2014 your conversations, mood data, and journal entries **never leave your device**.

## Key Features

- **On-Device AI Chat** \u2014 Empathetic Hinglish conversations powered by Gemma 2B via `flutter_gemma`
- **Voice Chat** \u2014 Talk to your AI companion using on-device speech recognition
- **Mood Tracker** \u2014 Daily mood logging with analytics, trends, and insights
- **Journal** \u2014 Personal diary with emotion tagging and AI-powered mood insights
- **Meditation** \u2014 Guided sessions (Morning Calm, Deep Focus, Stress Relief, Wind-down)
- **Breathing Exercises** \u2014 4-7-8, Box Breathing, Deep Breathing with animations
- **CBT Exercises** \u2014 Body Scan, Grounding, Muscle Relaxation, Visualization
- **8+ Mindful Games** \u2014 Tap the Calm, Color Therapy, Pattern Flow, Breathing Bubbles & more
- **SOS / Crisis** \u2014 Emergency helplines, 5-4-3-2-1 grounding, instant calming tools
- **Virtual Pet (Buddy)** \u2014 Interactive emotional support companion
- **Achievements & Gamification** \u2014 Wellness milestones and streaks
- **Trilingual** \u2014 Full English, Hindi, Punjabi UI + Hinglish AI chat
- **Dark/Light Mode** \u2014 Premium UI with smooth transitions
- **Biometric App Lock** \u2014 Privacy protection via fingerprint/face authentication

## Tech Stack

| Category | Technologies |
|----------|-------------|
| **Frontend** | Flutter 3.x, Dart, Material Design 3 |
| **AI/ML** | Google Gemma 2B, flutter_gemma, Custom EmotionDetector, SaathiBrain |
| **Storage** | SharedPreferences, Local JSON (100% on-device) |
| **Voice** | speech_to_text, flutter_tts |
| **State Management** | Provider |
| **Localization** | English, Hindi, Punjabi (450+ keys) |

## Architecture

Feature-first modular architecture with 30+ independent feature modules:

```
lib/
\u251c\u2500\u2500 core/           \u2014 AI engines, emotion detection, storage, theme, localization
\u251c\u2500\u2500 features/       \u2014 30 independent modules (chat, mood, journal, games, etc.)
\u251c\u2500\u2500 models/         \u2014 Data models
\u251c\u2500\u2500 services/       \u2014 Platform services
\u2514\u2500\u2500 main.dart       \u2014 Entry point
```

## Privacy

Saathi's #1 USP is **absolute privacy**:
- \u2705 All AI processing happens on-device
- \u2705 Zero data collection \u2014 no servers, no cloud, no analytics
- \u2705 No internet required after initial AI model download
- \u2705 No sign-up, no accounts, no tracking

## Links

- **Website**: [saathiai.tech](https://saathiai.tech)
- **Demo Video**: [saathiaivdo.netlify.app](https://saathiaivdo.netlify.app)
- **APK Download**: [Releases](https://github.com/AviralSrivastava7/saathi-ai-app/releases/tag/v1.0.1)

## Getting Started

```bash
# Clone the repository
git clone https://github.com/AviralSrivastava7/saathi-ai-app.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## License

This project is developed as part of the **Google Solution Challenge 2026**.

---

*Built with \u2764\uFE0F by Aviral Srivastava*
