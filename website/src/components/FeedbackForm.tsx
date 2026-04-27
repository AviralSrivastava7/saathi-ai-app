"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const FEEDBACK_TYPES = [
    { id: "feature", label: "Feature Suggestion", icon: "💡" },
    { id: "bug", label: "Report a Bug", icon: "🐛" },
    { id: "general", label: "General Feedback", icon: "💬" },
];

export default function FeedbackForm() {
    const [rating, setRating] = useState(0);
    const [hoverRating, setHoverRating] = useState(0);
    const [type, setType] = useState("general");
    const [comment, setComment] = useState("");
    const [email, setEmail] = useState("");
    const [status, setStatus] = useState<"idle" | "submitting" | "success" | "error">("idle");
    const [errorMessage, setErrorMessage] = useState("");

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (rating === 0) {
            setErrorMessage("Please select a rating!");
            setStatus("error");
            return;
        }

        setStatus("submitting");
        try {
            const res = await fetch("https://api.web3forms.com/submit", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                body: JSON.stringify({
                    access_key: "320187ab-082b-4659-817b-c1ab124da579",
                    subject: `New Feedback: ${type}`,
                    from_name: "Saathi AI Feedback",
                    category: type,
                    rating: rating,
                    message: comment,
                    email: email
                }),
            });

            const data = await res.json();
            if (data.success) {
                setStatus("success");
            } else {
                setErrorMessage(data.message || "Something went wrong.");
                setStatus("error");
            }
        } catch {
            setErrorMessage("Connection issue. Please try again.");
            setStatus("error");
        }
    };

    if (status === "success") {
        return (
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                style={{ textAlign: "center", padding: "40px 20px" }}
            >
                <div style={{ fontSize: "4rem", marginBottom: 20 }}>🎉</div>
                <h3 style={{ fontSize: "1.5rem", fontWeight: 700, marginBottom: 12 }}>Thank You!</h3>
                <p style={{ color: "rgba(241,245,249,0.5)", marginBottom: 24 }}>
                    We&apos;ve received your feedback. Our team will review it shortly.
                </p>
                <button
                    onClick={() => { setStatus("idle"); setRating(0); setComment(""); }}
                    className="cta-button"
                    style={{ padding: "12px 24px", fontSize: "0.9rem" }}
                >
                    Send another feedback?
                </button>
            </motion.div>
        );
    }

    return (
        <form onSubmit={handleSubmit} style={{ width: "100%", maxWidth: 500, margin: "0 auto" }}>
            {/* Rating Stars */}
            <div style={{ marginBottom: 32, textAlign: "center" }}>
                <p style={{ fontSize: "0.9rem", color: "rgba(241,245,249,0.5)", marginBottom: 12 }}>How was your experience with Saathi AI?</p>
                <div style={{ display: "flex", justifyContent: "center", gap: 12 }}>
                    {[1, 2, 3, 4, 5].map((star) => (
                        <motion.span
                            key={star}
                            whileHover={{ scale: 1.2 }}
                            whileTap={{ scale: 0.9 }}
                            onMouseEnter={() => setHoverRating(star)}
                            onMouseLeave={() => setHoverRating(0)}
                            onClick={() => setRating(star)}
                            style={{
                                fontSize: "2rem",
                                cursor: "pointer",
                                filter: (hoverRating || rating) >= star ? "grayscale(0)" : "grayscale(1) opacity(0.3)",
                                transition: "filter 0.2s"
                            }}
                        >
                            ⭐
                        </motion.span>
                    ))}
                </div>
            </div>

            {/* Feedback Type Tabs */}
            <div style={{ marginBottom: 24 }}>
                <div style={{ display: "flex", gap: 8, flexWrap: "wrap", justifyContent: "center" }}>
                    {FEEDBACK_TYPES.map((t) => (
                        <button
                            key={t.id}
                            type="button"
                            onClick={() => setType(t.id)}
                            style={{
                                padding: "8px 16px",
                                borderRadius: "12px",
                                border: "1px solid",
                                borderColor: type === t.id ? "#8B5CF6" : "rgba(255,255,255,0.1)",
                                background: type === t.id ? "rgba(139, 92, 246, 0.2)" : "transparent",
                                color: type === t.id ? "white" : "rgba(255,255,255,0.5)",
                                fontSize: "0.85rem",
                                cursor: "pointer",
                                transition: "all 0.2s",
                                display: "flex",
                                alignItems: "center",
                                gap: 6
                            }}
                        >
                            <span>{t.icon}</span>
                            <span>{t.label}</span>
                        </button>
                    ))}
                </div>
            </div>

            {/* Comment Area */}
            <div style={{ marginBottom: 20 }}>
                <textarea
                    placeholder="Tell us how we can improve..."
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                    style={{
                        width: "100%",
                        minHeight: "120px",
                        padding: "16px",
                        borderRadius: "16px",
                        background: "rgba(255,255,255,0.05)",
                        border: "1px solid rgba(255,255,255,0.1)",
                        color: "white",
                        fontSize: "0.95rem",
                        resize: "vertical",
                        outline: "none",
                        fontFamily: "inherit",
                        boxSizing: "border-box"
                    }}
                />
            </div>

            {/* Email Input */}
            <div style={{ marginBottom: 24 }}>
                <input
                    type="email"
                    placeholder="Your Email (Optional)"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    style={{
                        width: "100%",
                        padding: "12px 16px",
                        borderRadius: "12px",
                        background: "rgba(255,255,255,0.05)",
                        border: "1px solid rgba(255,255,255,0.1)",
                        color: "white",
                        fontSize: "0.9rem",
                        outline: "none",
                        boxSizing: "border-box"
                    }}
                />
            </div>

            {/* Error Message */}
            <AnimatePresence>
                {status === "error" && (
                    <motion.p
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: "auto" }}
                        exit={{ opacity: 0, height: 0 }}
                        style={{ color: "#EF4444", fontSize: "0.85rem", marginBottom: 16, textAlign: "center" }}
                    >
                        {errorMessage}
                    </motion.p>
                )}
            </AnimatePresence>

            {/* Submit Button */}
            <button
                type="submit"
                disabled={status === "submitting"}
                className="cta-button"
                style={{ width: "100%", opacity: status === "submitting" ? 0.7 : 1 }}
            >
                {status === "submitting" ? "Sending..." : "Send Feedback →"}
            </button>
        </form>
    );
}
