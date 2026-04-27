"use client";

import { useRef } from "react";
import { motion, useInView } from "framer-motion";
import FeedbackForm from "./FeedbackForm";

export default function FeedbackSection() {
    const containerRef = useRef<HTMLDivElement>(null);
    const inView = useInView(containerRef, { once: false, margin: "-50px" });

    return (
        <section
            ref={containerRef}
            id="feedback"
            style={{ padding: "96px 20px", width: "100%", boxSizing: "border-box", background: "rgba(10, 10, 26, 0.5)" }}
        >
            <div style={{ maxWidth: 900, margin: "0 auto", width: "100%", padding: "0 10px" }}>
                <motion.div
                    initial={{ opacity: 0, y: 40 }}
                    animate={inView ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.8 }}
                    style={{ textAlign: "center", marginBottom: 32 }}
                >
                    <span style={{ color: "#EC4899", fontSize: "0.75rem", fontWeight: 600, letterSpacing: "0.15em", textTransform: "uppercase" as const }}>
                        Feedback
                    </span>
                    <h2 style={{ fontSize: "clamp(1.8rem, 5vw, 3rem)", fontWeight: 800, letterSpacing: "-0.03em", marginTop: 12, marginBottom: 16 }}>
                        Help Us <span className="gradient-text">Improve</span>
                    </h2>
                    <p style={{ color: "rgba(241,245,249,0.5)", maxWidth: 500, margin: "0 auto", fontSize: "0.9rem", lineHeight: 1.5 }}>
                        Your feedback is invaluable to us. Let us know how we can make Saathi AI even better for you.
                    </p>
                </motion.div>

                <motion.div
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={inView ? { opacity: 1, scale: 1 } : {}}
                    transition={{ duration: 0.8, delay: 0.2 }}
                    className="glass-card"
                    style={{
                        padding: "32px 24px",
                        borderRadius: "24px",
                        overflow: "hidden",
                        position: "relative",
                        background: "rgba(255, 255, 255, 0.03)",
                        border: "1px solid rgba(255, 255, 255, 0.05)"
                    }}
                >
                    <FeedbackForm />
                </motion.div>
            </div>
        </section>
    );
}
