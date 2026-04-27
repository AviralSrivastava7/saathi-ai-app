"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";

const features = [
  {
    icon: "🤖",
    title: "AI Chat",
    desc: "Gemma AI powered Hinglish conversations — like talking to a friend who truly understands.",
    color: "#6366F1",
  },
  {
    icon: "🔒",
    title: "Privacy-First AI",
    desc: "Runs entirely on-device. No server calls, no data collection, no sharing whatsoever.",
    color: "#FF6B6B",
  },
  {
    icon: "📴",
    title: "Fully Offline",
    desc: "Works in rural areas and no-network zones. Internet only needed once to download the AI model.",
    color: "#F59E0B",
  },
  {
    icon: "📊",
    title: "Mood Tracker",
    desc: "Daily mood logging with statistics, history, and pattern recognition.",
    color: "#06B6D4",
  },
  {
    icon: "📝",
    title: "Journal",
    desc: "Personal diary with emotion tagging — your private space to express and reflect.",
    color: "#10B981",
  },
  {
    icon: "🧘",
    title: "Meditation",
    desc: "Guided meditation sessions for stress relief, focus, and better sleep.",
    color: "#8B5CF6",
  },
  {
    icon: "🌬️",
    title: "Breathing Exercises",
    desc: "4-7-8, Box breathing and more scientifically proven calming techniques.",
    color: "#EC4899",
  },
  {
    icon: "🏋️",
    title: "CBT Exercises",
    desc: "Cognitive Behavioral Therapy tools — evidence-based techniques for mental wellness.",
    color: "#06B6D4",
  },
  {
    icon: "🎮",
    title: "8 Mindful Games",
    desc: "Calm Maze, Focus Dots, Zen Shapes, Memory Match, and more.",
    color: "#F59E0B",
  },
  {
    icon: "🆘",
    title: "SOS / Crisis",
    desc: "Emergency helplines, grounding exercises, and instant calming tools.",
    color: "#FF6B6B",
  },
  {
    icon: "🏆",
    title: "Achievements",
    desc: "Gamified wellness milestones to keep you motivated on your journey.",
    color: "#10B981",
  },
  {
    icon: "📈",
    title: "Analytics",
    desc: "Weekly and monthly insights with beautiful charts to track your progress.",
    color: "#6366F1",
  },
];

export default function FeaturesSection() {
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section
      id="features"
      ref={ref}
      style={{
        padding: "100px 24px",
        width: "100%",
        boxSizing: "border-box",
      }}
    >
      <div
        className="section-container"
        style={{ maxWidth: 1100, margin: "0 auto" }}
      >
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7 }}
          style={{ textAlign: "center", marginBottom: 60 }}
        >
          <span
            style={{
              color: "#EC4899",
              fontSize: "0.75rem",
              fontWeight: 600,
              letterSpacing: "0.15em",
              textTransform: "uppercase" as const,
            }}
          >
            28 Feature Modules
          </span>
          <h2
            style={{
              fontSize: "clamp(1.8rem, 5vw, 3rem)",
              fontWeight: 800,
              letterSpacing: "-0.03em",
              marginTop: 12,
              marginBottom: 16,
            }}
          >
            Everything You Need for{" "}
            <span className="gradient-text">Mental Wellness</span>
          </h2>
          <p
            style={{
              color: "rgba(241,245,249,0.5)",
              maxWidth: 550,
              margin: "0 auto",
              fontSize: "0.95rem",
              lineHeight: 1.6,
            }}
          >
            From AI-powered conversations to mindful games, Saathi covers every
            aspect of your mental health journey — all 100% offline and free.
          </p>
        </motion.div>

        {/* Feature Grid */}
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(250px, 1fr))",
            gap: 20,
          }}
        >
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              initial={{ opacity: 0, y: 30 }}
              animate={inView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: i * 0.06 }}
              className="glass-card feature-card"
              style={{
                padding: 28,
                cursor: "default",
              }}
            >
              <div
                style={{
                  fontSize: "2rem",
                  marginBottom: 14,
                  width: 56,
                  height: 56,
                  borderRadius: 14,
                  background: `${f.color}15`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                {f.icon}
              </div>
              <h3
                style={{
                  fontSize: "1.05rem",
                  fontWeight: 700,
                  color: "#F1F5F9",
                  marginBottom: 8,
                }}
              >
                {f.title}
              </h3>
              <p
                style={{
                  fontSize: "0.85rem",
                  color: "rgba(241,245,249,0.5)",
                  lineHeight: 1.6,
                }}
              >
                {f.desc}
              </p>
            </motion.div>
          ))}
        </div>

        {/* USP Highlight */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, delay: 0.8 }}
          className="glass-card-strong"
          style={{
            marginTop: 48,
            padding: "28px 36px",
            textAlign: "center",
            borderLeft: "4px solid #6366F1",
          }}
        >
          <p
            style={{
              fontSize: "clamp(0.95rem, 2vw, 1.15rem)",
              fontWeight: 600,
              color: "#F1F5F9",
            }}
          >
            🏆{" "}
            <span className="gradient-text">
              Saathi = (Wysa + Headspace + Therapist) × Privacy × Free ×
              Hinglish
            </span>
          </p>
        </motion.div>
      </div>
    </section>
  );
}
