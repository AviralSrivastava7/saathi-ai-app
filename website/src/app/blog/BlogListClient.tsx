"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { blogPosts } from "@/utils/blogData";

const categoryColors: Record<string, string> = {
    Awareness: "#6366F1",
    Meditation: "#06B6D4",
    Wellness: "#10B981",
    Technology: "#EC4899",
    "Self-Care": "#F59E0B",
};

export default function BlogListClient() {
    return (
        <div
            style={{
                minHeight: "100vh",
                paddingTop: 100,
                paddingBottom: 80,
                background: "linear-gradient(180deg, #0F172A 0%, #1E1B4B 50%, #0F172A 100%)",
            }}
        >
            <div className="section-container" style={{ maxWidth: 900, margin: "0 auto" }}>
                {/* Header */}
                <motion.div
                    initial={{ opacity: 0, y: 30 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.7 }}
                    style={{ textAlign: "center", marginBottom: 60 }}
                >
                    <h1
                        className="gradient-text"
                        style={{
                            fontSize: "clamp(2rem, 5vw, 3rem)",
                            fontWeight: 800,
                            letterSpacing: "-0.03em",
                            marginBottom: 16,
                        }}
                    >
                        Saathi Blog
                    </h1>
                    <p style={{ color: "rgba(241,245,249,0.5)", fontSize: "1.1rem", maxWidth: 500, margin: "0 auto" }}>
                        Mental health, meditation aur self-care ke baare mein helpful articles — Hinglish mein 💜
                    </p>
                </motion.div>

                {/* Blog Grid */}
                <div
                    style={{
                        display: "grid",
                        gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
                        gap: 24,
                    }}
                >
                    {blogPosts.map((post, i) => (
                        <motion.div
                            key={post.slug}
                            initial={{ opacity: 0, y: 40 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.5, delay: i * 0.1 }}
                        >
                            <Link href={`/blog/${post.slug}`} style={{ textDecoration: "none" }}>
                                <div
                                    className="glass-card feature-card"
                                    style={{
                                        padding: 28,
                                        height: "100%",
                                        cursor: "pointer",
                                        display: "flex",
                                        flexDirection: "column",
                                    }}
                                >
                                    {/* Emoji Cover */}
                                    <div
                                        style={{
                                            fontSize: "3rem",
                                            marginBottom: 16,
                                            width: 72,
                                            height: 72,
                                            borderRadius: 18,
                                            background: "rgba(99, 102, 241, 0.1)",
                                            display: "flex",
                                            alignItems: "center",
                                            justifyContent: "center",
                                        }}
                                    >
                                        {post.coverEmoji}
                                    </div>

                                    {/* Category Badge */}
                                    <div
                                        style={{
                                            display: "inline-flex",
                                            alignItems: "center",
                                            gap: 6,
                                            marginBottom: 12,
                                        }}
                                    >
                                        <span
                                            style={{
                                                fontSize: "0.7rem",
                                                fontWeight: 600,
                                                textTransform: "uppercase",
                                                letterSpacing: "0.05em",
                                                color: categoryColors[post.category] || "#8B5CF6",
                                                background: `${categoryColors[post.category] || "#8B5CF6"}15`,
                                                padding: "4px 10px",
                                                borderRadius: 6,
                                            }}
                                        >
                                            {post.category}
                                        </span>
                                        <span style={{ fontSize: "0.75rem", color: "rgba(241,245,249,0.3)" }}>
                                            · {post.readTime}
                                        </span>
                                    </div>

                                    {/* Title */}
                                    <h2
                                        style={{
                                            fontSize: "1.15rem",
                                            fontWeight: 700,
                                            color: "#F1F5F9",
                                            lineHeight: 1.4,
                                            marginBottom: 10,
                                        }}
                                    >
                                        {post.title}
                                    </h2>

                                    {/* Excerpt */}
                                    <p
                                        style={{
                                            fontSize: "0.85rem",
                                            color: "rgba(241,245,249,0.45)",
                                            lineHeight: 1.6,
                                            flex: 1,
                                        }}
                                    >
                                        {post.excerpt}
                                    </p>

                                    {/* Footer */}
                                    <div
                                        style={{
                                            display: "flex",
                                            alignItems: "center",
                                            justifyContent: "space-between",
                                            marginTop: 16,
                                            paddingTop: 12,
                                            borderTop: "1px solid rgba(255,255,255,0.06)",
                                        }}
                                    >
                                        <span style={{ fontSize: "0.75rem", color: "rgba(241,245,249,0.3)" }}>
                                            {new Date(post.date).toLocaleDateString("en-IN", {
                                                day: "numeric",
                                                month: "short",
                                                year: "numeric",
                                            })}
                                        </span>
                                        <span
                                            style={{
                                                fontSize: "0.8rem",
                                                color: "#8B5CF6",
                                                fontWeight: 500,
                                            }}
                                        >
                                            Padhein →
                                        </span>
                                    </div>
                                </div>
                            </Link>
                        </motion.div>
                    ))}
                </div>
            </div>
        </div>
    );
}
