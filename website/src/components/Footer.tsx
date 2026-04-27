"use client";

import { useRef, useState, useEffect } from "react";
import { motion, useInView } from "framer-motion";

const socialLinks = [
  {
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.064 2.064 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
      </svg>
    ),
    label: "LinkedIn",
    url: "https://www.linkedin.com/in/aviral-srivastava-58720b312",
  },
  {
    icon: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0 1 12 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z" />
      </svg>
    ),
    label: "GitHub",
    url: "https://github.com/AviralSrivastava7",
  },
];

const footerLinks = [
  { label: "Blog", url: "/blog" },
  { label: "Privacy Policy", url: "/privacy" },
  { label: "Terms of Service", url: "/terms" },
];

export default function Footer() {
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { once: false, margin: "-50px" });
  const [isMounted, setIsMounted] = useState(false);

  useEffect(() => {
    setIsMounted(true);
  }, []);

  return (
    <footer
      ref={ref}
      style={{
        position: "relative",
        padding: "80px 40px",
        width: "100%",
        boxSizing: "border-box",
        background:
          "linear-gradient(180deg, transparent 0%, rgba(15,23,42,0.8) 30%, #0a0a1a 100%)",
      }}
    >
      {/* Twinkling stars */}
      {isMounted && (
        <div
          style={{
            position: "absolute",
            inset: 0,
            overflow: "hidden",
            pointerEvents: "none",
          }}
        >
          {Array.from({ length: 30 }).map((_, i) => (
            <motion.div
              key={i}
              animate={{ opacity: [0.2, 0.8, 0.2] }}
              transition={{
                duration: 2 + Math.random() * 3,
                repeat: Infinity,
                delay: Math.random() * 3,
              }}
              style={{
                position: "absolute",
                width: 2,
                height: 2,
                borderRadius: "50%",
                background: "white",
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`,
              }}
            />
          ))}
        </div>
      )}

      <div
        style={{
          maxWidth: 700,
          margin: "0 auto",
          width: "100%",
          textAlign: "center",
          position: "relative",
          zIndex: 1,
        }}
      >
        {/* Logo */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          style={{
            marginBottom: 32,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
          }}
        >
          <span style={{ fontSize: "2.5rem", marginBottom: 12 }}>🤝</span>
          <h3
            className="gradient-text"
            style={{
              fontSize: "1.25rem",
              fontWeight: 700,
              letterSpacing: "-0.02em",
            }}
          >
            Saathi AI
          </h3>
          <p
            style={{
              fontSize: "0.85rem",
              marginTop: 8,
              color: "rgba(241,245,249,0.4)",
            }}
          >
            Your Private, Offline Mental Health Companion
          </p>
          <p
            style={{
              fontSize: "0.75rem",
              marginTop: 4,
              color: "rgba(241,245,249,0.3)",
            }}
          >
            by Aviral Srivastava
          </p>
        </motion.div>

        {/* Social links */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: 16,
            marginBottom: 36,
          }}
        >
          {socialLinks.map((social) => (
            <motion.a
              key={social.label}
              href={social.url}
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.1, rotate: 5 }}
              whileTap={{ scale: 0.95 }}
              className="glass-card"
              style={{
                height: 44,
                borderRadius: 14,
                fontSize: "0.85rem",
                color: "rgba(255,255,255,0.7)",
                display: "flex",
                alignItems: "center",
                gap: 8,
                padding: "0 16px",
                textDecoration: "none",
                cursor: "pointer",
              }}
            >
              {social.icon}
              <span>{social.label}</span>
            </motion.a>
          ))}
        </motion.div>

        {/* Footer links */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 0.4 }}
          style={{
            display: "flex",
            flexWrap: "wrap",
            alignItems: "center",
            justifyContent: "center",
            gap: 24,
            marginBottom: 36,
          }}
        >
          {footerLinks.map((link) => (
            <a
              key={link.label}
              href={link.url}
              target={link.url.startsWith("http") ? "_blank" : undefined}
              rel={
                link.url.startsWith("http")
                  ? "noopener noreferrer"
                  : undefined
              }
              style={{
                color: "rgba(241,245,249,0.4)",
                fontSize: "0.85rem",
                textDecoration: "none",
                transition: "color 0.2s",
              }}
              onMouseEnter={(e) =>
                (e.currentTarget.style.color = "#8B5CF6")
              }
              onMouseLeave={(e) =>
                (e.currentTarget.style.color = "rgba(241,245,249,0.4)")
              }
            >
              {link.label}
            </a>
          ))}
        </motion.div>

        {/* Divider */}
        <div
          style={{
            width: 60,
            height: 1,
            background:
              "linear-gradient(90deg, transparent, rgba(99,102,241,0.4), transparent)",
            margin: "0 auto 20px",
          }}
        />

        {/* Copyright */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={inView ? { opacity: 1 } : {}}
          transition={{ duration: 0.6, delay: 0.6 }}
          style={{ fontSize: "0.75rem", color: "rgba(241,245,249,0.3)" }}
        >
          © {new Date().getFullYear()} Saathi AI. All rights reserved. Made
          with 💜 by Aviral Srivastava
        </motion.p>
      </div>
    </footer>
  );
}
