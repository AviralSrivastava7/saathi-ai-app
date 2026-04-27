"use client";

import { motion } from "framer-motion";

export default function HeroSection() {
  return (
    <section
      id="hero"
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "120px 24px 80px",
        textAlign: "center",
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* Ambient glow blobs */}
      <div
        style={{
          position: "absolute",
          width: 500,
          height: 500,
          borderRadius: "50%",
          background: "rgba(99,102,241,0.08)",
          filter: "blur(120px)",
          top: -100,
          right: -150,
          pointerEvents: "none",
        }}
      />
      <div
        style={{
          position: "absolute",
          width: 400,
          height: 400,
          borderRadius: "50%",
          background: "rgba(236,72,153,0.06)",
          filter: "blur(120px)",
          bottom: -100,
          left: -100,
          pointerEvents: "none",
        }}
      />

      <motion.div
        initial={{ opacity: 0, y: 40 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        style={{ position: "relative", zIndex: 1 }}
      >
        <span style={{ fontSize: "4rem" }}>🤝</span>
      </motion.div>

      <motion.h1
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.15 }}
        className="gradient-text"
        style={{
          fontSize: "clamp(2.5rem, 6vw, 4.5rem)",
          fontWeight: 900,
          letterSpacing: "-0.04em",
          lineHeight: 1.1,
          marginTop: 16,
          marginBottom: 20,
          position: "relative",
          zIndex: 1,
        }}
      >
        SAATHI
      </motion.h1>

      <motion.p
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8, delay: 0.3 }}
        style={{
          fontSize: "clamp(1rem, 2.5vw, 1.4rem)",
          color: "rgba(241,245,249,0.6)",
          fontWeight: 300,
          maxWidth: 600,
          marginBottom: 24,
          lineHeight: 1.6,
          position: "relative",
          zIndex: 1,
        }}
      >
        Your Mental Wellness Companion — Powered by On-Device AI
      </motion.p>

      {/* Privacy Hero Banner */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.6, delay: 0.45 }}
        style={{
          background:
            "linear-gradient(135deg, rgba(108,99,255,0.12), rgba(0,212,170,0.12))",
          border: "2px solid rgba(0,212,170,0.3)",
          borderRadius: 16,
          padding: "16px 36px",
          marginBottom: 24,
          position: "relative",
          zIndex: 1,
        }}
      >
        <p
          style={{
            fontSize: "clamp(0.85rem, 2vw, 1.1rem)",
            fontWeight: 700,
            color: "#00D4AA",
            letterSpacing: "0.5px",
          }}
        >
          🔒 Your Data Never Leaves Your Device — Zero Sharing, Absolute
          Privacy
        </p>
      </motion.div>

      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.6, delay: 0.55 }}
        style={{
          color: "rgba(241,245,249,0.45)",
          maxWidth: 550,
          fontSize: "0.95rem",
          lineHeight: 1.7,
          marginBottom: 32,
          position: "relative",
          zIndex: 1,
        }}
      >
        A comprehensive, privacy-first mental health app built with Flutter &
        Gemma AI.{" "}
        <strong style={{ color: "#FF6B6B" }}>
          No servers. No cloud. No data collection. Everything stays on YOUR
          phone.
        </strong>
      </motion.p>

      {/* Badges */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.65 }}
        style={{
          display: "flex",
          gap: 8,
          flexWrap: "wrap",
          justifyContent: "center",
          marginBottom: 40,
          position: "relative",
          zIndex: 1,
        }}
      >
        {[
          "🔒 100% Private",
          "🧠 AI-Powered",
          "📴 Fully Offline",
          "🌍 Trilingual",
          "📱 Multi-Platform",
          "💰 Free Forever",
        ].map((badge) => (
          <span
            key={badge}
            style={{
              display: "inline-block",
              background: "rgba(99,102,241,0.15)",
              color: "#8B5CF6",
              padding: "6px 16px",
              borderRadius: 20,
              fontSize: "0.8rem",
              fontWeight: 600,
            }}
          >
            {badge}
          </span>
        ))}
      </motion.div>

      {/* CTA */}
      <motion.a
        href="https://saathiai.tech"
        target="_blank"
        rel="noopener noreferrer"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.75 }}
        className="cta-button"
        style={{
          textDecoration: "none",
          color: "white",
          display: "inline-block",
          position: "relative",
          zIndex: 1,
        }}
      >
        Download Saathi AI →
      </motion.a>

      {/* Scroll hint */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1, delay: 1.2 }}
        style={{
          position: "absolute",
          bottom: 30,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 8,
        }}
      >
        <span
          style={{
            fontSize: "0.7rem",
            color: "rgba(241,245,249,0.3)",
            letterSpacing: "0.1em",
            textTransform: "uppercase",
          }}
        >
          Scroll Down
        </span>
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 1.5, repeat: Infinity }}
          style={{
            width: 20,
            height: 30,
            borderRadius: 10,
            border: "2px solid rgba(241,245,249,0.2)",
            display: "flex",
            justifyContent: "center",
            paddingTop: 6,
          }}
        >
          <div
            style={{
              width: 3,
              height: 8,
              borderRadius: 3,
              background: "rgba(241,245,249,0.4)",
            }}
          />
        </motion.div>
      </motion.div>
    </section>
  );
}
